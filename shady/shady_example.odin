package shady

import "core:log"

// An example of using shady to load and preprocess glsl files and compile them to SPIRV.
load_spirv_from_glsl_file :: proc(src_filename : string, shader_stage : ShaderStage, spirv_version : SpirvVersion, client_version : ClientVersion) -> (spirv_code : []byte, reflect_info : ReflectInfo, ok : bool) {

	parse_info := ParseInfo{
		
    	parse_flags = ParseFlags{.UnfoldIncludes, .GenerateHeaderguards, .StripAlreadyIncluded},
    	
    	// insert_defines = {"USE_ALPHA", "SAMPLE_COUNT 16"}, // Optional: A list of define keywords to be defined at the top. e.g. {"USE_ALPHA", "SAMPLE_COUNT 16"} will insert '#define USE_ALPHA' and '#define SAMPLE_COUNT 16' at the top of the file.
    	
    	// version_str = "450 core", // Optional: A version string to replace the current version with. e.g. "450 core". '#version' directive must still be present in the source file. Ignored if 'ReplaceVersionString' flag is not set.
    	// read_file_proc = nil,   // Optional: A procedure callback to read files from disk. If nill, default procedure in odins 'core:os' package will be used.
    
    	// out_include_files, 	  // ReadOnly:  List of filenames included during unfolding of '#include' directives. nil when '.UnfoldIncludes' flag is not set.
    	// out_error_string = "", // ReadOnly: Filled with an error message upon errors, duh. Allocated using context.temp_allocator.
    }

	glsl_src_code, parse_ok := parse_glsl_file(src_filename, &parse_info, context.allocator)
	if !parse_ok {
		log.errorf("SHADY: Parsing Error: {}", parse_info.out_error_string)
		return nil, ReflectInfo{}, false
	}

	defer {
		delete(glsl_src_code)
    
    	// Cleanup Memory for Recorded include filenames at the end.
    	for &str in parse_info.out_include_files {
    		delete_string(str)
    	}
    	delete_slice(parse_info.out_include_files)
	}

	compile_info := SpirvCompileInfo{
		shader_stage   = shader_stage,
	    spirv_version  = spirv_version,
	    client_version = client_version,

	    glsl_src_filenames = parse_info.out_include_files, // Optional can be nill. But provide include files from parse info to get better error printing for include files.
	    // out_error_string : string,     // Readonly: Error string upon compilation failure. This Contains the Compilation Error! Allocated using context.temp_allocator
	}

	spirv, compile_ok := compile_glsl_to_spirv(glsl_src_code, &compile_info, context.allocator)
	if !compile_ok {
		log.errorf("SHADY: Compilation Error: {}", compile_info.out_error_string)
		return nil, ReflectInfo{}, false
	}

	refl_info, refl_error_str, refl_ok := reflect_spirv(spirv)
	if !refl_ok {
		log.warnf("SHADY: Reflection Error: {}", refl_error_str)	
	}
	 
	return spirv, refl_info, true
}