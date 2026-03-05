package shady

import "core:log"
import "core:os"

// An example of using shady to load and preprocess glsl files and compile them to SPIRV.
load_spirv_from_glsl_file :: proc(src_filename : string, shader_stage : ShaderStage, spirv_version : SpirvVersion, client_version : ClientVersion, log_errors: bool = true) -> []byte {

	included_files : [dynamic]string;
	defer {
		for &str in included_files{
			delete(str);
		}
		delete(included_files);
	}

	parse_info : ParseInfo = {
		// Options used for parsing.
    	parse_flags = ParseFlags{.UnfoldIncludes, .GenerateHeaderguards, .StripAlreadyIncluded},
    	// We will record included filepaths into this array, 0 will be the src file.
    	out_include_files = &included_files,
    	
    	// Optional: A set of macro keywords to be defined at the top. e.g. {"USE_ALPHA", "SAMPLE_COUNT 16"} will insert '#define USE_ALPHA' and '#define SAMPLE_COUNT 16' at the top of the file.
    	//insert_defines = {"USE_ALPHA", "SAMPLE_COUNT 16"},
    	
    	// Optional: A version string to replace the current version with. e.g. "450 core". '#version' directive must still be present in the source file. Ignored if 'ReplaceVersionString' flag is not set.
    	//version_str = "450 core",
    	
    	// Optional: A procedure callback to read files from disk. If nill, default procedure in odins 'core:os' package will be used.
    	//read_file_proc = nil,
    
    	// ReadOnly: Filled with an error message upon errors, duh. Allocated using context.temp_allocator.
    	//error_string = "", 
    }

	glsl_src_code, parse_ok := parse_glsl_file(src_filename, &parse_info, context.allocator);
	// @Note: if 'parse_ok == false', glsl_src_code may still contain data as not all erros result in compilation failure.
	defer if glsl_src_code != nil {
		delete(glsl_src_code);
	}
	if !parse_ok {
		if log_errors {
			// Upon errors we can get error massage from the 'error_string' in parse_info.
			log.errorf("SHADY: Parsing Error: {}", parse_info.error_string);
		}
		return nil;
	}


	data_or_error_str, transpile_ok := transpile_glsl_to_SPIRV(glsl_src_code, shader_stage, spirv_version, client_version, included_files[:], context.allocator);

	if !transpile_ok {
		// Upon errors the compile error message will be in the returned data as a string,
		// NOTE that we do NOT free the 'data_or_error_str' in this case because if it's an error string, it was allocated using context.temp_allocator.
		if log_errors {
			log.errorf("SHADY: Compilation Error: {}", transmute(string)data_or_error_str);
		}
		return nil;
	}

	return data_or_error_str;
}


read_file_contents :: proc(filename: string, allocator := context.allocator) -> (data : []byte, ok : bool) {

	if !os.exists(filename) || !os.is_file(filename) {
		return nil, false;
	}

	file_contents, err := os.read_entire_file_from_path(filename, allocator);
	if err != nil || file_contents == nil {
		return nil, false;
	}

	return file_contents, true;
}


write_file_contents :: proc(filenme: string, data: []byte) -> bool {
	
	if data == nil {
		return false;
	}

	err :=  os.write_entire_file_from_bytes(filenme, data);

	return err == nil;
}