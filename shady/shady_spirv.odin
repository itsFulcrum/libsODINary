package shady

import "glslang"

import "core:c"
import "core:mem"

import "core:log"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:path/filepath"


// @Note:
// This is an example / default way to transpile glsl source code to spirv using glslang bindings.
// I do not claim to be an expert on glslang and how to use it. For more advanced features such as shader reflection and such, refer to the original non existent documentation for glslang.
// Upon compilation or other erros, the output spirv data will instead be a readable error string.

// @ A note on the 'src_files' parameter.
// Parameter 'src_files' is optional and can be left nill but should be an array of filepaths that made up the glsl_src_code string. 
// This is helpfull for returning compile errors with correct file names and line numbers in cases where we constructed the src code from multiple files/strings instead of just one.
// Note that 'src_files' must be ordered such that the file_index from the compile error can be used to index into the array to retrieve the correct filename.
// As a quick explanation. When compiling glsl we can usually provide multiple strings and link them together into a shader programm so that we can reuse bits of code between programms.
// Often though we do this kind preprocessing ourselves with a custom #include directive to ease development. Shady's preprocessor does this e.g.
// Therefore in glsl src code, we can insert '#line <lineNbr> <file_index>' preprocessor directives which may look like this '#line 0 2'. 
// This tells the compiler that the current file has an index of 2 and the line number is from now on 0. (Line After that is considerd as 1).
// One can think of this as overwriting the complier macros '__FILE__' and '__LINE__' in c/c++ compilers
// Glsl compilers then use this when printing compile errors. 
// If we manually unfold includes and combine strings into a single source string we rely on this '#line' directive to keep line numbers and files in sync between our source code representation and the preprocessed representaiton.
// When using the shady preprocessor for loading glsl files, the filenames that can be recorded will be correctly orderd such that they can be passed to this function or more specifically
// the 'format_glslang_error_info_log()' procedure below.
transpile_glsl_to_SPIRV :: proc(glsl_src_code : []u8, shader_stage : ShaderStage, spirv_version : SpirvVersion, target_client_version : ClientVersion, src_files : []string = nil, allocator := context.allocator) -> (data_or_error_str: []byte, ok : bool) {
	
	assert(glsl_src_code != nil);
	assert(shader_stage != ShaderStage.COUNT);
	assert(spirv_version != SpirvVersion.COUNT);
	assert(target_client_version != ClientVersion.COUNT);

	client 							: glslang.client_t 					= target_client_version == ClientVersion.OPENGL_450 ? glslang.client_t.CLIENT_OPENGL : glslang.client_t.CLIENT_VULKAN;
	shader_stage_glslang 			: glslang.stage_t 					= cast(glslang.stage_t)shader_stage;
	client_version_glslang 			: glslang.target_client_version_t   = cast(glslang.target_client_version_t)target_client_version;
	target_language_version_glslang : glslang.target_language_version_t = cast(glslang.target_language_version_t)spirv_version;

	shader_code_cstr : cstring = cast(cstring)raw_data(glsl_src_code); 

	input : glslang.input_t = {
		language = glslang.source_t.SOURCE_GLSL,
		stage  = shader_stage_glslang,
		client = client,		
		client_version = client_version_glslang,
		target_language = glslang.target_language_t.TARGET_SPV,
		target_language_version = target_language_version_glslang,
		code = shader_code_cstr,
		default_version = 100,		
		default_profile = glslang.profile_t.NO_PROFILE,
		force_default_version_and_profile = 0, // false
		forward_compatible = 0,	// false
		messages = glslang.messages_t.MSG_DEFAULT_BIT,
		resource = glslang.default_resource(),
	}


	shader : ^glslang.shader_t = glslang.shader_create(&input);
	defer glslang.shader_delete(shader);
	
	successful : c.int;
	successful = glslang.shader_preprocess(shader, &input)

	src_filename : string = "unknown";
	if src_files != nil && len(src_files) > 0 {
		src_filename = strings.clone(src_files[0], context.temp_allocator);
	}

	if successful == 0 {
		info_log : string = strings.clone_from_cstring(glslang.shader_get_info_log(shader), context.temp_allocator);
		error_str : string = format_glslang_error_info_log(&info_log, "Preprocessing", src_files);		
		err := transmute([]u8)error_str;
		return err, false;
	}

	// assert(shader != nil);
	// log.warnf("Compile to spirv, successful {}", successful);
	successful = glslang.shader_parse(shader, &input)
	if successful == 0 {

		info_log : string = strings.clone_from_cstring(glslang.shader_get_info_log(shader), context.temp_allocator);
		error_str : string = format_glslang_error_info_log(&info_log, "Parsing", src_files);		
		err := transmute([]u8)error_str;
		return err, false;
	}


	program : ^glslang.program_t = glslang.program_create();
	defer glslang.program_delete(program);

	glslang.program_add_shader(program, shader);
	
	successful = glslang.program_link(program, cast(c.int)(glslang.messages_t.MSG_SPV_RULES_BIT | glslang.messages_t.MSG_VULKAN_RULES_BIT) );
	if successful == 0 {		
		info_log : string = strings.clone_from_cstring(glslang.shader_get_info_log(shader), context.temp_allocator);
		error_str : string = format_glslang_error_info_log(&info_log, "Linking", src_files);
		err := transmute([]u8)error_str;
		return err, false;
	}

	glslang.program_SPIRV_generate(program, shader_stage_glslang);

	size : int = cast(int)glslang.program_SPIRV_get_size(program);
	words : [^]c.uint = make_multi_pointer([^]c.uint, cast(int)size, allocator);

	glslang.program_SPIRV_get(program, words);
	
	spirv_data : []byte = mem.ptr_to_bytes(words, size);

	return spirv_data, true;
}


format_glslang_error_info_log :: proc(info_log : ^string, stage: string, src_files : []string = nil) -> string {
	
	// @Note: info_log by glsl function 'glslang.shader_get_info_log(shader)' is generally in this format:
	/*
		ERROR: 0:38: '=' :  cannot convert from ' const float' to ' temp highp 3-component vector of float'
		ERROR: 0:38: '' : compilation terminated
		ERROR: 2 compilation errors.  No code generated.
	*/

	// We want to transform it into a different format with potentially more clear information.
	// If we encounter a substring like this '0:38:', the first number represents a file index integer, and the second number is the line number of the error.
	// If src_files is provided it is supposed to be indexable by this file number to lookup the src filenames so we replace the index by filename.
	// when src_files is not provided, or incomplete we fallback to the numbers in the info log.

	/*
		SHADY: GLSLang Parsing Error: Source Filename: ../shaders/post_process.frag
		FILE:post_process.frag | LINE:38 - '=' :  cannot convert from ' const float' to ' temp highp 3-component vector of float'
		FILE:post_process.frag | LINE:38 - '' : compilation terminated
		2 compilation errors.  No code generated.
	*/

	src_filename : string = "unknown";
	if src_files != nil && len(src_files) > 0 {
		src_filename = src_files[0];
	}

	error_str : string = fmt.aprintf("SHADY: GLSLang {} Error: Source Filepath: {}",stage, src_filename, allocator = context.temp_allocator);

	for line_str in strings.split_lines_iterator(info_log){

		ERROR_substr_offset : int = strings.index(line_str, "ERROR:")
		if ERROR_substr_offset == -1 {
			// There might be empty lines that  we will skip
			continue;
		}

		// Trim off 'ERROR: ' substring
		error_trim : string = line_str[ERROR_substr_offset+7:]; // 'ERROR: ' = 7 bytes
		
		first_colon_offset : int = strings.index(error_trim, ":");
		if first_colon_offset == -1 {
			// If we dont find a ':' we just append this line
			error_str = strings.join({error_str, error_trim}, "\n", context.temp_allocator);
			continue;
		}

		file_index_str : string = error_trim[:first_colon_offset];
		// Trim off until first colon
		first_number_trimmed : string = error_trim[first_colon_offset+1:];

		// Find second colon
		second_colon : int = strings.index(first_number_trimmed, ":");
		if second_colon == -1 {
			// If we now dont find a second ':' this line does not contain file/line numbers so we also just append it.
			error_str = strings.join({error_str, error_trim}, "\n", context.temp_allocator);
			continue;
		}

		// From here we can be pretty sure that 'file_index_str' is a number reffereing to a file;
		// and that 'line_number' is the actual line number.

		line_number : string = first_number_trimmed[:second_colon];
		remaining_msg : string = first_number_trimmed[second_colon+1:];


		file_str : string = file_index_str; // we fallback to the number given.

		if src_files != nil {
			file_index_uint , parse_uint_ok := strconv.parse_uint(file_index_str);
		 	
		 	if parse_uint_ok && file_index_uint < cast(uint)len(src_files) {
		 		file_str = filepath.base(src_files[file_index_uint]);
		 	} 
		}


		out_line := fmt.aprintf("FILE:{} | LINE:{} -{}",file_str, line_number,remaining_msg, allocator =  context.temp_allocator);
		error_str = strings.join({error_str, out_line}, "\n", context.temp_allocator);
	}

	return error_str;
}