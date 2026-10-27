package picy

import "core:log"
import "core:os"
import "core:fmt"


test_writer :: proc(src_img_path : string, file_format : FileFormat , output_dir : string) {
		

	assert(file_format != FileFormat.NONE)

	src_pic, read_err := read_from_file(src_img_path, ReadInfo{read_flags = {.FLIP_VERTICALLY, .GRAY_TO_RGB, .APPEND_ALPHA_TO_RGB}})

	if read_err != nil {
		log.errorf("Test Writer {}: Failed to run test. Could not read source image. ReadErr: {}", file_format, read_err)
		return
	}
	defer free_pixels(&src_pic)

	_, filename_ext := os.split_path(src_img_path)

	src_filename_only, _ := os.split_filename(filename_ext)


	write_flags := WriteFlags{.FLIP_VERTICALLY}

	for target_format in Format {
		if target_format == Format.NONE {
			continue
		}

		converted_pic, convert_err := convert_format_picture(src_pic, target_format, context.allocator)
		if convert_err != nil {
			log.errorf("Test Writer {}: FAILED:    Format {} {}x{} - Conversion Failed from {} to {}. Error: {}", file_format, target_format, src_pic.width, src_pic.height, src_pic.format, target_format, convert_err)
		}
		defer free_pixels(&converted_pic)

		file_ext := get_file_ext_from_file_format(file_format)

		// Target format may not match what is actually outputted..
		out_filename := fmt.aprintf("{}_{}x{}_{}{}", src_filename_only, converted_pic.width, converted_pic.height, converted_pic.format, file_ext,  allocator = context.temp_allocator)

		out_filepath, _ := os.join_path({output_dir, out_filename}, context.temp_allocator)

		write_err := Error.NONE

		switch file_format {
		case .NONE: panic("Invalid_Codepath")
		case .PNG : unimplemented("png Write not yet unimplemented")
		case .JPG : write_err = write_jpg_to_file(out_filepath, converted_pic, write_flags)
		case .TIF : write_err = write_tif_to_file(out_filepath, converted_pic, write_flags)
		case .HDR : write_err = write_hdr_to_file(out_filepath, converted_pic, write_flags)
		case .EXR : unimplemented("exr Writer not yet unimplemented")
		}

		if write_err != nil {
			log.errorf("Test Writer {}: FAILED:    Format {} {}x{} - Error: {}", file_format, target_format, src_pic.width, src_pic.height, write_err)
		} else {
			log.infof( "Test Writer {}: SUCCEEDED: Format {} {}x{}", file_format, target_format, src_pic.width, src_pic.height)
		}
	}
}


test_tif_reader :: proc(folder_with_images : string) {


	if !os.is_directory(folder_with_images) {
		log.errorf("Test Tif Reader: Failed to run Test folder does not exist {}", folder_with_images)
	}

	read_info := ReadInfo{
		read_flags = ReadFlags{},
	}


	dir_f, open_err := os.open(folder_with_images)
	if open_err != os.ERROR_NONE {
		return
	}
	defer os.close(dir_f)


	file_infos , os_err := os.read_directory(dir_f, 0, context.temp_allocator)
	if os_err != os.ERROR_NONE {
		return
	}	

	file_loop: for &file_info, _ in file_infos {

		#partial switch file_info.type {
		case .Directory:
		case .Regular: {

			file_format := get_file_format_from_filename(file_info.fullpath)
			
			if file_format != .TIF {
				continue file_loop
			}

			pic, read_err := read_tif_from_file(file_info.fullpath,read_info,context.allocator)
			defer free_pixels(&pic)

			_, filename := os.split_path(file_info.fullpath)

			if read_err != nil {
				log.errorf("Test Tif Reader: FAILED:    Error: {} - {}", read_err, filename)
			} else {
				log.infof( "Test Tif Reader: SUCCEEDED: Format {} {}x{} - {}", pic.format, pic.width, pic.height, filename)
			}
		}
		case: continue
		}
	}
}