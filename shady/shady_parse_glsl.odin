package shady

import "core:log"

import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:fmt"

// Parse and preprocess a glsl source file with options to do '#include' unfolding, '#define' insertions and tracking of included filepaths.
// Returned is a string buffer containing the combined file contents with correct '#line' directives added during unfolding of include files.
// Optionally a pointer to a dynamic string array can be provided inside the parse info to record all files included during the procedure.
// Note that the file index for the '#line' directive can only be set correctly if this array is provided, otherwise it will stil track line numbers but file index will always be 0.
// This array can be useful for tracking error messages inside include files during compilation (to spirv for instance) and also for hot reloading shaders at runtime.
// Upon errors, return 'ok' bool will be false but contents may still contain data as not all errors will result in compilation failure neccesarily. (though likely.)
// So contents has to potentially be freed even on errors.
// Inside ParseInfo struct the 'out_error_string' will be set with all error mesagges that occured.
parse_glsl_file :: proc(filename: string, parse_info: ^ParseInfo, allocator := context.allocator) -> (contents : []u8, ok : bool) {

	src_filename_clean := filepath.clean(filename, context.temp_allocator);

	delete_string(parse_info.error_string);
	parse_info.error_string = "";

	if !os.exists(src_filename_clean) || !os.is_file(src_filename_clean) {
		err_str := fmt.aprintf("SHADY: Parse Error: File does not exist: {}\n", src_filename_clean, allocator = context.temp_allocator);
		append_error_string_to_parse_info(parse_info, err_str);
		return nil, false;
	}

	if parse_info.read_file_proc == nil {
		parse_info.read_file_proc = read_file_contents;
	}

	builder : [dynamic]u8 = make_dynamic_array([dynamic]u8, allocator);

	parse_ok := parse_glsl_file_recursive(&builder, filename, parse_info, is_top_level_file = true, allocator = allocator);

	return builder[:], parse_ok;
}

@(private="file")
parse_glsl_file_recursive :: proc(builder : ^[dynamic]u8, filename: string, parse_info: ^ParseInfo, is_top_level_file : bool, allocator := context.allocator) -> (ok : bool) {


	parse_ok : bool = true;

	src_filename_clean := filepath.clean(filename, context.temp_allocator);

	file_contents, read_ok := parse_info.read_file_proc(src_filename_clean, allocator);
	defer if file_contents != nil {
		delete(file_contents);
	}

	if !read_ok || file_contents == nil {
		err_str := fmt.aprintf("SHADY: Parse Error: Faild to read file {} \n", src_filename_clean, allocator = context.temp_allocator);
		append_error_string_to_parse_info(parse_info, err_str);
		return false;
	}

	parse_flags := parse_info.parse_flags;


	_file_index : int = 0;


	unfold : bool = .UnfoldIncludes in parse_flags && parse_info.out_include_files != nil;

	if unfold {
		
		already_included := false;

		for &path, index in parse_info.out_include_files {

			if(0 == strings.compare(path, src_filename_clean)){
				already_included = true;
				_file_index = index;
				break;
			}
		}

		if !already_included {		
			append(parse_info.out_include_files, strings.clone(src_filename_clean, allocator));
			_file_index = len(parse_info.out_include_files) -1;
		
		} else if .StripAlreadyIncluded in parse_flags {
			return true; // We already included this file and can omit it. This is not an error.
		}
	}

	generate_headerguards : bool = .GenerateHeaderguards in parse_flags;
	if is_top_level_file {
		generate_headerguards = false; // never for top level file..
	}

	if !is_top_level_file {

		if generate_headerguards{

			// get the base filename: "folder/subfulder/filename.vert.glsl" -> "filename.vert.glsl"
			src_filename_base : string = filepath.base(src_filename_clean); 
			// get the stem of a filename: "filename.vert.glsl" -> "filename"
			src_filename_stem : string = filepath.short_stem(src_filename_base); 

			// -> "filename_AUTOGUARD"
			headerguard_str : string = strings.join({src_filename_stem, "AUTOGUARD"}, "_", context.temp_allocator); 

			ifndef_str := strings.join({"#ifndef", headerguard_str, "\n"}, " ", context.temp_allocator);
			def_str := strings.join({"#define", headerguard_str, "\n"}, " ", context.temp_allocator);
			
			append(builder, ifndef_str);
			append(builder, def_str);
		}

		_file_line_str : string = make_file_line_insertion_string(file_index = _file_index, line_nbr = 0);
		append(builder, _file_line_str);
	}

	file_contents_str := cast(string)file_contents;


	_line_nbr : int = 0;

	currently_in_multi_line_comment : bool =  false;

	for line in strings.split_lines_iterator(&file_contents_str){

		_line_nbr += 1;

		line_str : string = line;

		if currently_in_multi_line_comment {

			end_multicomment := strings.index(line, "*/")
			if end_multicomment == -1 {
				// @Note: dont skip comments atm to maintain line_numbers.
				append(builder, line);
				append(builder, '\n');
				continue;
			} else {
				line_str = line[end_multicomment+2:];
				currently_in_multi_line_comment = false;
			}
		}

		comment_offset := strings.index(line_str, "//")
		if comment_offset != -1 {
			line_str = line_str[:comment_offset];
			// @Note: dont skip comments atm to maintain line_numbers.
			// if len(line_str) == 0 {
			// 	continue;
			// }
		}

		muli_comment_offset := strings.index(line_str, "/*");
		if muli_comment_offset != -1 {

			currently_in_multi_line_comment = true;

			remaining := line_str[muli_comment_offset:];
			muli_comment_end := strings.index(remaining, "*/");
			if muli_comment_end != -1 {
				// Unhadled case where multi line is closed on the same line....
				log.warnf("SHADY: parse_glsl_file_recursive: detected multi line comment that is closed on the same line. This is currently not properly. Remaining line after closing of comment will be ignored.")
				currently_in_multi_line_comment = false;
			}

			line_str = line_str[:muli_comment_offset];
		}


		if is_top_level_file && strings.contains(line_str, "#version") {
			
			if .ReplaceVersionString in parse_flags {

				if len(parse_info.version_str) > 0 {
					version_line := strings.join({"#version", parse_info.version_str, "\n"}, " ", context.temp_allocator);						
					append(builder, version_line);

				} else {
					err_str := fmt.aprintf("SHADY: Parse Error: 'ReplaceVersionString' bit is set in parse_flags but version_string was not set.\n");
					append_error_string_to_parse_info(parse_info, err_str);
					return false;
				}
			} else {
				append(builder,line_str); // append the user version line
			}

			inserted_some_defines : bool = false;
			// Include user defines directly after we found ther version line.
			if parse_info.insert_defines != nil {

				for &def_str in parse_info.insert_defines {

					define_line := strings.join({"#define", def_str, "\n"}, " ", context.temp_allocator);
					append(builder, define_line);
					inserted_some_defines = true;
				}
			}

			// update line number if neccesary
			if inserted_some_defines {
				_file_line : string = make_file_line_insertion_string(file_index = _file_index, line_nbr = _line_nbr + 1);
				append(builder, _file_line);
			}

			continue;
		}

		if .UnfoldIncludes in parse_flags && strings.contains(line_str, "#include") {

			// Extract include path by getting the byte offset for the quotes in e.g. "filename.glsl"
			first_quote  := strings.index(line_str, "\"");
			second_quote := strings.last_index(line_str, "\"");

			if first_quote == -1 || second_quote == -1 || first_quote == second_quote {
				
				append(builder, '\n'); // replace with blank line

				err_str := fmt.aprintf("SHADY: Parse Error: #include statement was found but filepath is not wrapped inside qoutation marks. Line is Ignored.\n File: {} - Line {}\n", src_filename_clean, _line_nbr + 1);
				append_error_string_to_parse_info(parse_info, err_str);
				parse_ok = false;
				continue;
			}

			include_path_relative := string(line_str[first_quote+1:second_quote]);

			// get the filepath to the include file.
			src_fileanme_parent_dir := filepath.dir(src_filename_clean, context.temp_allocator);
			full_include_filepath   := filepath.join({src_fileanme_parent_dir, include_path_relative}, context.temp_allocator);

			recursive_parse_ok := parse_glsl_file_recursive(builder, full_include_filepath, parse_info, is_top_level_file = false, allocator = allocator);

			if !recursive_parse_ok {
				append(builder, '\n'); // replace '#include' statement with blank line instead

				err_str := fmt.aprintf("SHADY: Parse Error: Found #include statement in source file: {}, but faild to include specified file: {} \n", src_filename_clean, include_path_relative);
				append_error_string_to_parse_info(parse_info, err_str);
				parse_ok = false;

			} else {
				_file_line : string = make_file_line_insertion_string(file_index = _file_index, line_nbr = _line_nbr +1);
				append(builder, _file_line);
			}				
		
			continue;			
		}

		append(builder, line);
		append(builder, '\n');
	}

	if generate_headerguards {
		append(builder, "#endif \n");
	}



	return parse_ok;
}


@(private="file")
append_error_string_to_parse_info :: proc( parse_info: ^ParseInfo, err_str : string) {
	parse_info.error_string = strings.join({parse_info.error_string, err_str},"", context.temp_allocator);
}

@(private="file")
make_file_line_insertion_string :: proc(file_index : int, line_nbr : int) -> string {
	return fmt.aprintf("#line {} {} \n", line_nbr, file_index, allocator = context.temp_allocator);
}
