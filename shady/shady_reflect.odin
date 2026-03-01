package shady

import "core:log"
import "core:strings"
import "core:strconv"

// @Note: THIS IS NOT COMPLETE AND DOES NOT WORK FOR EVERYTHING!
// This is a fairly naive (and slow) implementation to get some limited reflection information from glsl src code.
// That said it'll probably work just fine unless you do werid things or dont use a vulkan style glsl.

// Here is a list of things that definitly wont work correctly.
// First: All resources must have a 'layout' specifiyer at the beginning. Aka. Vulkan style.

// Second: Macros and defines are compleatly ignored! Should be unfolded beforehand.
// Doing the following won't work even tough its valid glsl.
// "#define TexSampler sampler2D
// layout(set=2, binding=0) uniform TexSampler _tex;"

// Third: Different resources must be defined on different lines. 
// The follwoing wont count the second Resource
// "layout(binding=0) uniform sampler2D _tex0; layout(binding=0) uniform sampler2D _tex1;"
// It must be on differnt lines:
// "layout(binding=0) uniform sampler2D _tex0; 
//  layout(binding=0) uniform sampler2D _tex1;"

// Forth: standard and multiline comments are mostly supported. However Multiline comments must be opened and closed on different lines!
// This means Doing Weird stuff like "layout(binding=0) /* comment */ uniform _ubo;" will NOT work!
// if your single line mutli line comment is at the end it should be fine.
// "layout(binding=0) uniform _ubo; /* comment */" -> this is fine
// "/* comment */ layout(binding=0) uniform _ubo;" -> this is not fine
// "layout(binding=0) /* comment */ uniform _ubo;" -> this is not fine



reflect_parse_glsl_src_code :: proc (src_code : []u8) -> ReflectInfo {

	info : ReflectInfo;

	src_code_str : string = cast(string)src_code;

	currently_in_multi_line_comment : bool =  false;

	for line in strings.split_lines_iterator(&src_code_str) {

		line_str : string = line;

		if currently_in_multi_line_comment {

			end_multicomment := strings.index(line, "*/")
			if end_multicomment == -1 {
				continue;
			} else {
				line_str = line[end_multicomment+2:];
				currently_in_multi_line_comment = false;
			}
		}

		comment_offset := strings.index(line_str, "//")
		if comment_offset != -1 {
			line_str = line_str[:comment_offset];
			if len(line_str) == 0 {
				continue;
			}
		}

		muli_comment_offset := strings.index(line_str, "/*");
		if muli_comment_offset != -1 {

			currently_in_multi_line_comment = true;

			remaining := line_str[muli_comment_offset:];
			muli_comment_end := strings.index(remaining, "*/");
			if muli_comment_end != -1 {
				// Unhadled case where multi line is closed on the same line....
				log.warnf("SHADY: reflect_parse_glsl_src_code: detected multi line comment that is closed on the same line. This is currently not supported for reflection parsing. Remaining line after closing of comment will be ignored.")
				currently_in_multi_line_comment = false;
			}

			line_str = line_str[:muli_comment_offset];
		}



		if !strings.contains(line_str, "layout") {
			continue;
		}

		if strings.contains(line_str, " buffer "){

			if strings.contains(line_str, " readonly "){
				info.num_readonly_storage_buffers += 1;
			} else if strings.contains(line_str, " writeonly "){
				info.num_writeonly_storage_buffers += 1;
			} else {
				info.num_readwrite_storage_buffers += 1;
			}
			continue;
		}

		if strings.contains(line_str, "local_size_x"){

			get_threadcount_for :: proc(src_string : string, axis_str : string) -> u32 {
				
				// Src string must be like this: 'layout(local_size_x=16,local_size_y=16,local_size_z=1)in;'
				// All empty spaces removed!
				// axis_str must be either 'local_size_x' or 'local_size_y' or 'local_size_z'

				offset := strings.index(src_string, axis_str);
				if offset == -1 {
					return 1;
				}

				// axis_str will be 'local_size_x' or 'local_size_y' or 'local_size_z'
				// which is always 12 bytes we skip.
				// after that will be an '=' which is 1 byte that we also skip.
				start := src_string[offset+12+1:];

				end : int = -1;

				comma_offset := strings.index(start, ",");
				if comma_offset == -1 {
					paren_offset := strings.index(start, ")");
					if paren_offset != -1 {
						end = paren_offset;
					} else {
						// This should not be possilbe it think since if we already found the axis_str it must be closed by either a ',' or ')'
					}

				} else {
					end = comma_offset;
				}

				if end == -1 {
					return 1; // not found
				}

				nbr_str := start[:end];

				nbr, ok := strconv.parse_uint(nbr_str);

				if !ok {
					return 1;
				}

				return cast(u32)nbr;
			}


			no_tabs   , was_alloc0 := strings.remove_all(line_str, "\t", context.temp_allocator);
			no_spaces , was_alloc1 := strings.remove_all(no_tabs, " ", context.temp_allocator);
			
			info.compute_threadcount.x = get_threadcount_for(no_spaces, "local_size_x");
			info.compute_threadcount.y = get_threadcount_for(no_spaces, "local_size_y");
			info.compute_threadcount.z = get_threadcount_for(no_spaces, "local_size_z");
		}

		uniform_offset := strings.index(line_str, "uniform"); 
		if uniform_offset == -1 {
			continue;
		}

		// get remaining line after 'uniform' keyword
		sub_line_with_space : string = line_str[uniform_offset+7:]; // 'uniform' = 7 bytes
		sub_line := strings.trim_left_space(sub_line_with_space);


		if  is_next_substring(sub_line,"sampler") {
			info.num_samplers +=1;
			continue;
		}

		if strings.contains(sub_line, "image"){

			offset := strings.index(sub_line, "image"); 
			trimmed:= sub_line[offset:offset+5+7]

			is_really_image_resource : bool = false;

			if strings.contains(trimmed, "image2D"){
				is_really_image_resource = true;
			} else if strings.contains(trimmed, "image3D"){
				is_really_image_resource = true;
			} else if strings.contains(trimmed, "imageCube"){
				is_really_image_resource = true;				
			} // @Note: there is also "image2DArray" but it includes substr "image2D"

			if is_really_image_resource {
				if is_next_substring(sub_line, "readonly"){
					info.num_readonly_storage_textures += 1;
				} else if is_next_substring(sub_line, "writeonly") {
					info.num_writeonly_storage_textures += 1;
				} else {
					info.num_readwrite_storage_textures += 1;
				}

				continue;
			}
		}

		// if non of the above we assume its a uniform buffer. I dont think it can be anything else unless we are in OpenGl land which we dont support right now.
		info.num_uniform_buffers += 1;
	}

	info.num_storage_buffers = info.num_readonly_storage_buffers + info.num_writeonly_storage_buffers + info.num_readwrite_storage_buffers;
	info.num_writeable_storage_buffers = info.num_writeonly_storage_buffers + info.num_readwrite_storage_buffers;

	info.num_storage_textures = info.num_readonly_storage_textures + info.num_writeonly_storage_textures + info.num_readwrite_storage_textures;
	info.num_writeable_storage_textures = info.num_writeonly_storage_textures + info.num_readwrite_storage_textures;


	return info;
}

@(private="file")
is_next_substring :: proc(src : string, sub_str : string) -> bool {
	if len(src) >= len(sub_str){

		if src[:len(sub_str)] == sub_str {
			return true;
		}
	}

	return false;
}