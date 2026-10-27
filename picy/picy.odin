package picy

// import "core:log"

// import "base:runtime"
import "core:os"
import "core:mem"
import "core:strings"
// import "core:fmt"
// import "core:thread"
import "core:simd"

import tiff "libtiff"

import stbi "vendor:stb/image"
// import exr "vendor:OpenEXRCore"

// TODO:

// - png writer - preferebly with LodePng bc stb image does not support writing 16 bit png images as far as i remember.
// - exr reader & writer
// - optimize performance for convert function
// - srgb to linear helpers ?


ReadFlags :: distinct bit_set[ReadFlag; u32]
ReadFlag :: enum u32 {
	FLIP_VERTICALLY, 	// flip images vertically
	GRAY_TO_RGB,		// copy gray (single channel) to RGB channels
	// HDR_TO_LDR, TODO:			
	APPEND_ALPHA_TO_RGB,	// Add alpha channel with value of 1.0 to rgb images, works with GRAY_TO_RGB
}

READ_FLAGS_DEFAULT :: ReadFlags{.FLIP_VERTICALLY, .GRAY_TO_RGB, .APPEND_ALPHA_TO_RGB}

ReadInfo :: struct {
	read_flags : ReadFlags,		
}

READ_INFO_DEFAULT :: ReadInfo{read_flags = READ_FLAGS_DEFAULT}

WriteFlags :: distinct bit_set[WriteFlag; u32]
WriteFlag :: enum u32 {
	FLIP_VERTICALLY,
	
	// For compression formats (jpg)
	QUALITY_HIGH,
	QUALITY_MEDIUM,
	QUALITY_LOW,
}

Format :: enum u8 {
	NONE			= 0, // undefined
	
	R8_UNORM		= 1, // 1 component 8 bit: unsigned normalized
	RG8_UNORM		= 2, // 2 component 8 bit: unsigned normalized
	RGB8_UNORM		= 3, // 3 component 8 bit: unsigned normalized
	RGBA8_UNORM		= 4, // 4 component 8 bit: unsigned normalized

	R16_UNORM		= 5, // 1 component 16 bit: unsigned normalized
	RG16_UNORM		= 6, // 2 component 16 bit: unsigned normalized
	RGB16_UNORM		= 7, // 3 component 16 bit: unsigned normalized
	RGBA16_UNORM	= 8, // 4 component 16 bit: unsigned normalized

	R16_F			= 9,  // 1 component 16 bit: singed half float (16bit)
	RG16_F			= 10, // 2 component 16 bit: singed half float (16bit)
	RGB16_F			= 11, // 3 component 16 bit: singed half float (16bit)
	RGBA16_F		= 12, // 4 component 16 bit: singed half float (16bit)
	
	R32_F			= 13, // 1 component 32 bit: signed float (32bit)
	RG32_F			= 14, // 2 component 32 bit: signed float (32bit)
	RGB32_F			= 15, // 3 component 32 bit: signed float (32bit)
	RGBA32_F		= 16, // 4 component 32 bit: signed float (32bit)
}

FormatType :: enum {
	INVLAID = 0,
	UNORM_8 ,
	UNORM_16,
	F_16,
	F_32,
}

FileFormat :: enum u8 {
	NONE = 0,
	PNG = 1,
	JPG = 2,
	TIF = 3,
	HDR = 4,
	EXR = 5,
}

Picture :: struct {
	format: Format,	
	width : u32,
	height: u32,
	pixels: []byte,
}

Error :: enum u32 {
	NONE = 0,
	UNKNOWN_FILE_FORMAT,
	FILE_NOT_FOUND,
	FAILD_TO_OPEN_FILE,
	INVALID_IMAGE_DIMENSIONS,
	MEMORY_ALLOCATION_ERROR,
	NIL_BUFFER,
	INVALID_FORMAT,
	INVALID_FILE_FORMAT,
	INVALID_PICTURE,
	FILE_FORMAT_DOES_NOT_SUPPORT_WRITING_THIS_IMAGE_FORMAT,
	UNSUPPORTED_NUMBER_OF_CHANNELS,
	UNSUPPORTED_BIT_DEPTH,
	PIXEL_BUFFER_SIZE_DOES_NOT_MATCH_EXPECTED_NUM_BYTES,
	FAILED_TO_WRITE_TO_FILE,
}

read_from_file :: proc(filepath: string, read_info : ReadInfo, allocator := context.allocator) -> (Picture, Error) {

	file_format := get_file_format_from_filename(filepath)

	switch file_format {
	case FileFormat.NONE: return Picture{}, Error.UNKNOWN_FILE_FORMAT
	case FileFormat.PNG:  return read_png_from_file(filepath, read_info, allocator)
	case FileFormat.JPG:  return read_jpg_from_file(filepath, read_info, allocator)
	case FileFormat.TIF:  return read_tif_from_file(filepath, read_info, allocator)
	case FileFormat.HDR:  return read_hdr_from_file(filepath, read_info, allocator)
	case FileFormat.EXR:  unimplemented("EXR not yet Unsupported")
	}

	return Picture{}, Error.UNKNOWN_FILE_FORMAT
}


read_tif_from_file :: proc(filepath : string, read_info : ReadInfo, allocator := context.allocator) -> (pic : Picture, error : Error) {

	ext := os.ext(filepath)

	if ext != ".tiff" && ext != ".tif" {
		return Picture{}, Error.INVALID_FILE_FORMAT
	}

	if !os.is_file(filepath){
		return Picture{}, Error.FILE_NOT_FOUND
	}

	filepath_cstr : cstring = strings.clone_to_cstring(filepath, context.temp_allocator)

	when true {
		// shut up tiff from logging!
		tiff.SetErrorHandler(nil)
		tiff.SetWarningHandler(nil)
	}

	open_opts := tiff.OpenOptionsAlloc()

	// make sure we can read big enough images
	limit : i64 = (size_of(u32) * 4 * 16384 * 16384)

	tiff.OpenOptionsSetMaxSingleMemAlloc(open_opts, limit)
	
	tiff_handle: ^tiff.TIFF = tiff.OpenExt(filepath_cstr, "r", open_opts)
	
	tiff.OpenOptionsFree(open_opts)

	if tiff_handle == nil {
		return Picture{}, Error.FAILD_TO_OPEN_FILE
	}
	
	defer tiff.Close(tiff_handle)

	width            : u32 = 0
	height           : u32 = 0
	num_channels     : u32 = 0
	bits_per_channel : u32 = 0

	tiff.GetField(tiff_handle, tiff.TIFFTAG_IMAGEWIDTH, &width)
	tiff.GetField(tiff_handle, tiff.TIFFTAG_IMAGELENGTH, &height)
	tiff.GetField(tiff_handle, tiff.TIFFTAG_SAMPLESPERPIXEL, &num_channels)		// channels per pixel (1,2,3,4)
	tiff.GetField(tiff_handle, tiff.TIFFTAG_BITSPERSAMPLE, &bits_per_channel)	// bits per channel (8 , 16 or 32)

	if width == 0 || height == 0 {
		return Picture{}, Error.INVALID_IMAGE_DIMENSIONS
	}

	if num_channels <= 0 || num_channels > 4 {
		return Picture{}, Error.UNSUPPORTED_NUMBER_OF_CHANNELS,
	}

	if bits_per_channel != 8 && bits_per_channel != 16 && bits_per_channel != 32 {
		return Picture{}, Error.UNSUPPORTED_BIT_DEPTH,
	}


	src_format : Format = get_format_from_channels_and_bits_per_channel(num_channels, bits_per_channel, is_16_bit_floating_point = false)
	
	assert(src_format != .NONE)

	num_strips : u32 = tiff.NumberOfStrips(tiff_handle)
	strip_size : i64 = tiff.StripSize(tiff_handle)

	bytes_per_pixel : u32 = num_channels * (bits_per_channel / 8)
	buffer_size     : u32 = width * height * bytes_per_pixel

	pixel_buf, alloc_err : = make_multi_pointer([^]byte,cast(int)buffer_size, allocator)
	if alloc_err != nil {
		return Picture{}, Error.MEMORY_ALLOCATION_ERROR
	}
	
	defer if error != .NONE {
		free(pixel_buf)
	}

	tiff_err : i64

	for strip : i64 = 0; strip < i64(num_strips); strip +=1 {
		tiff_err = tiff.ReadEncodedStrip(tiff_handle, cast(u32)strip, &pixel_buf[strip * strip_size], -1)
	}

	if .FLIP_VERTICALLY in read_info.read_flags {
		flip_vertically(pixel_buf[0:buffer_size], width, height, src_format)
	}

	target_format := get_read_info_target_format(src_format, read_info)

	if src_format != target_format {

		target_pixel_buf : []byte = convert_format(pixel_buf[0: buffer_size], src_format, width, height, target_format, allocator)
		free(pixel_buf)
		pixel_buf   = &target_pixel_buf[0]
		buffer_size = cast(u32)len(target_pixel_buf)
	}

	out_pic := Picture{
		width  = width,
		height = height,
		format = target_format,
		pixels = pixel_buf[0:buffer_size],
	}

	return out_pic, Error.NONE
}

// Dual channel (RG) will convert to RGB. Format type F16 will convert to UNORM_16. Convertion uses provided allocator.
// small temp allocations (strings) use context.temp_allocator.
write_tif_to_file :: proc(filepath : string, #by_ptr pic : Picture, write_flags : WriteFlags, allocator := context.allocator) -> Error {

	is_valid_picture_with_error(pic) or_return

	when true {
		// shut up tiff from logging!
		tiff.SetErrorHandler(nil)
		tiff.SetWarningHandler(nil)
	}

	src_num_channels, _, _, src_format_type := get_format_info(pic.format)
	format := pic.format
	num_bytes : int = len(pic.pixels)
	pixel_buf : [^]byte = &pic.pixels[0]


	should_free_pixel_buffer : bool = false

	if src_num_channels == 2 || src_format_type == .F_16 {

		target_format := pic.format

		if src_format_type == .F_16 {
			switch src_num_channels {
			case 1: target_format = .R16_UNORM  
			case 2: target_format = .RGB16_UNORM
			case 3: target_format = .RGB16_UNORM
			case 4: target_format = .RGBA16_UNORM
			}
		} else if src_num_channels == 2 {
			switch src_format_type {
			case .INVLAID : panic("Invalid Codepath")
			case .UNORM_8 : target_format = .RGB8_UNORM
			case .UNORM_16: target_format = .RGB16_UNORM
			case .F_16:     target_format = .RGB16_UNORM
			case .F_32:     target_format = .RGB32_F
			}
		}

		format = target_format
		converted_pixels := convert_format(pic.pixels, pic.format, pic.width, pic.height, target_format, allocator)
		should_free_pixel_buffer = true

		num_bytes = len(converted_pixels)
		pixel_buf = &converted_pixels[0]
	}

	defer if should_free_pixel_buffer {
		free(pixel_buf)
	}

	num_channels, bits_per_channel, bytes_per_pixel, format_type := get_format_info(format)

	{

		calc_num_bytes := calc_bytes_from_width_height_format(pic.width, pic.height, format)
		assert(num_bytes == cast(int)calc_num_bytes)
	}


	filepath_cstr : cstring = strings.clone_to_cstring(filepath, context.temp_allocator)


	// this should make sure we are allowed to allocate large amounts of data
	alloc_limit : i64 = cast(i64)num_bytes  + 1024 // some extra buffer
	open_opts : ^tiff.OpenOptions = tiff.OpenOptionsAlloc()
	tiff.OpenOptionsSetMaxSingleMemAlloc(open_opts, alloc_limit)

	tiff_handle : ^tiff.TIFF = tiff.OpenExt(filepath_cstr, "w", open_opts)
	tiff.OpenOptionsFree(open_opts)

	if tiff_handle == nil {
		return Error.FAILD_TO_OPEN_FILE
	}

	defer tiff.Close(tiff_handle)

	// Set neccessary tiff tag fields
	tiff.SetField(tiff_handle, tiff.TIFFTAG_IMAGEWIDTH,  pic.width)
	tiff.SetField(tiff_handle, tiff.TIFFTAG_IMAGELENGTH, pic.height)
	tiff.SetField(tiff_handle, tiff.TIFFTAG_SAMPLESPERPIXEL, num_channels)   // channels per pixel (1,2,3,4)
	tiff.SetField(tiff_handle, tiff.TIFFTAG_BITSPERSAMPLE, bits_per_channel) // bits per channel (8 , 16 or 32)
	tiff.SetField(tiff_handle, tiff.TIFFTAG_ROWSPERSTRIP, 1)
	tiff.SetField(tiff_handle, tiff.TIFFTAG_ORIENTATION,  tiff.ORIENTATION_TOPLEFT)
	tiff.SetField(tiff_handle, tiff.TIFFTAG_PLANARCONFIG, tiff.PLANARCONFIG_CONTIG)

	// for grayscale images set different tag
	if num_channels == 1 {
		tiff.SetField(tiff_handle, tiff.TIFFTAG_PHOTOMETRIC, tiff.PHOTOMETRIC_MINISBLACK)
	} else {
		tiff.SetField(tiff_handle, tiff.TIFFTAG_PHOTOMETRIC, tiff.PHOTOMETRIC_RGB)
	}

	if num_channels == 4 {
		// https://stackoverflow.com/questions/3451806/getting-error-when-trying-to-apply-extrasamples-tag-to-a-tiff-file-to-be-writt
		extras : [2]u16
		extras[0] = tiff.EXTRASAMPLE_ASSOCALPHA
		tiff.SetField(tiff_handle, tiff.TIFFTAG_EXTRASAMPLES, 1, &extras[0])
	}

	if format_type == .F_32 {
		tiff.SetField(tiff_handle, tiff.TIFFTAG_SAMPLEFORMAT, tiff.SAMPLEFORMAT_IEEEFP)
	} else {
		tiff.SetField(tiff_handle, tiff.TIFFTAG_SAMPLEFORMAT, tiff.SAMPLEFORMAT_UINT)
	}
	
	tiff.SetField(tiff_handle, tiff.TIFFTAG_COMPRESSION, tiff.COMPRESSION_NONE)


	row_byte_size : u32 = pic.width * bytes_per_pixel

	

	if .FLIP_VERTICALLY in write_flags {

		row_byte_offset : u32 = (pic.height - 1) * row_byte_size
		//for h : int = cast(int)pic.height -1; h >= 0; h-=1 {
		for h in 0..<pic.height {
			tiff.WriteScanline(tiff_handle, &pixel_buf[row_byte_offset], u32(h), sample = 0)
			row_byte_offset -= row_byte_size
		}
	} else {
		row_byte_offset : u32 = 0		
		for h in 0..<pic.height{
			tiff.WriteScanline(tiff_handle, &pixel_buf[row_byte_offset], h, sample = 0)
			row_byte_offset += row_byte_size
		}
	}


	return Error.NONE
}

// UNIMPLEMENTED!! UNFINISHED!!!
// @(private="file")
// read_exr_from_path :: proc(filepath : string, load_flags : PicLoadFlags) -> (pic_info : PicInfo, error_string : string, ok : bool) {

// 	if !os.is_file(filepath) {
// 		return PicInfo{}, fmt.aprintf("Not a valid filepath: {}", filepath, context.temp_allocator), false
// 	}

// 	ctxt : exr.context_t

// 	path_cstr := strings.clone_to_cstring(filepath, context.temp_allocator)

// 	res := exr.start_read(&ctxt, path_cstr, nil)

// 	if res != .SUCCESS {
// 		return PicInfo{}, fmt.aprintf("{}", res, context.temp_allocator), false
// 	}
// 	defer exr.finish(&ctxt)


// 	data_window : exr.attr_box2i_t
// 	res = exr.get_data_window(ctxt, part_index = 0 , out = &data_window)
// 	if res != .SUCCESS {
// 		return PicInfo{}, fmt.aprintf("{}", res, context.temp_allocator), false
// 	}

// 	width  : i32 = data_window.max.x - data_window.min.x + 1
// 	height : i32 = data_window.max.y - data_window.min.y + 1

// 	if width <= 0 || height <= 0 {
// 		return PicInfo{}, fmt.aprintf("img Widht or Height are <= 0", context.temp_allocator), false	
// 	}


// 	channel_list : ^exr.attr_chlist_t

// 	res = exr.get_channels(ctxt, part_index = 0, chlist = &channel_list)
// 	if res != .SUCCESS {
// 		return PicInfo{}, fmt.aprintf("{}", res, context.temp_allocator), false
// 	}
// 	if channel_list.num_channels >= 0 {
// 		return PicInfo{}, fmt.aprintf("exr contains 0 channels", context.temp_allocator), false
// 	}


// 	channels : [4]^exr.attr_chlist_entry_t 
// 	channel_formats : [4]PicFormat

// 	for i in 0..<channel_list.num_channels {
// 		channel_entry := &channel_list.entries[i]

// 		name_cstr : cstring = channel_entry.name.str

// 		channel_index : int = -1

// 		if name_cstr == "R" {
// 			channel_index = 0
// 		} else if name_cstr == "G" {
// 			channel_index = 1
// 		} else if name_cstr == "B" {
// 			channel_index = 2

// 		} else if name_cstr == "A" {
// 			channel_index = 3
// 		} else if name_cstr == "Gray" {
// 			channel_index = 0
// 			// gray channel
// 		} else if name_cstr == "Y" {
// 			channel_index = 0 // technically supposed to mean luminance
// 			// gray channel
// 		} else if name_cstr == "Z" {
// 			channel_index = 0 // might be z/depth buffer data..
// 			// gray channel
// 		}

// 		if channel_index != -1 {
// 			channels[channel_index] = channel_entry
// 			if channel_entry.pixel_type == .HALF {
// 				channel_formats[channel_index] = PicFormat.R16_F
// 			} else if channel_entry.pixel_type == .FLOAT {
// 				channel_formats[channel_index] = PicFormat.R32_F
// 			} else if channel_entry.pixel_type == .UINT {
// 				// Unsupported
// 				channels[channel_index] = nil
// 				channel_formats[channel_index] = PicFormat.NONE
// 			}
// 		}
// 	}

// 	//
// 	// Validate channels and find picture format
// 	//

// 	// R/Gray channel must exist
// 	if channels.r == nil {
// 		return PicInfo{}, fmt.aprintf("Exr No R or Gray channel found", context.temp_allocator), false
// 	}

// 	assert(channel_formats.r != .NONE)

// 	// R channel defines which format the other channels need to be!
// 	num_channels : int = 0
// 	all_channel_format : PicFormat = channel_formats.r

// 	for i in 0..<4 {
// 		if channel_formats[i] != all_channel_format {
// 			break
// 		}
// 		num_channels += 1
// 	}

// 	part_index : i32 = 0

// 	num_scanlines_per_chunk : i32
// 	res = exr.get_scanlines_per_chunk(ctxt, part_index, &num_scanlines_per_chunk)
// 	assert(res == .SUCCESS)

// 	chunk_info : exr.chunk_info_t
// 	res = exr.read_scanline_chunk_info(ctxt, part_index, num_scanlines_per_chunk, &chunk_info)
// 	assert(res == .SUCCESS)


// 	chunk_buffer : [^]byte = make_multi_pointer([^]byte, chunk_info.packed_size, context.allocator)
// 	res = exr.read_chunk(ctxt, part_index, &chunk_info, chunk_buffer)


// 	return PicInfo{}, fmt.aprintf("Unfinished implementation", context.temp_allocator), false
// }

read_png_from_file :: proc(filepath: string, read_info : ReadInfo, allocator := context.allocator) -> (Picture, Error) {
	return read_stbi_from_file(filepath,read_info)
}

// jpg only supports RGB8_UNORM, anything else will be converted to it using provided allocator.
// small temp allocations are done using context.temp_allocator.
read_jpg_from_file :: proc(filepath: string, read_info : ReadInfo, allocator := context.allocator) -> (Picture, Error) {
	return read_stbi_from_file(filepath, read_info)
}

write_jpg_to_file :: proc(filepath : string, #by_ptr pic : Picture, write_flags : WriteFlags, allocator := context.allocator) -> Error {

	is_valid_picture_with_error(pic) or_return

	stbi.flip_vertically_on_write(.FLIP_VERTICALLY in write_flags)

	src_format := pic.format
	src_buffer : [^]byte = &pic.pixels[0]
	should_free_src_buffer : bool = false

	if pic.format != Format.RGB8_UNORM {

		target_format := Format.RGB8_UNORM
		converted_buffer : []byte = convert_format(pic.pixels, pic.format, pic.width, pic.height, target_format, allocator)
		
		src_format = target_format
		src_buffer = &converted_buffer[0]
		should_free_src_buffer = true
	}

	defer if should_free_src_buffer {
		free(src_buffer)
	}

	num_channels : i32 = 3 // Always RGB8_UNORM

	filepath_cstr := strings.clone_to_cstring(filepath, context.temp_allocator)

	quality : i32 = 100

	if .QUALITY_HIGH in write_flags {
		quality = 90
	} else if .QUALITY_MEDIUM in write_flags {
		quality = 70
	} else if .QUALITY_LOW in write_flags {
		quality = 50
	}

	stbi_error : i32 = stbi.write_jpg(filepath_cstr, cast(i32)pic.width, cast(i32)pic.height, num_channels, src_buffer, quality)

	if stbi_error == 0 {		
		return Error.FAILED_TO_WRITE_TO_FILE
	}

	return Error.NONE
}

read_hdr_from_file :: proc(filepath: string, read_info : ReadInfo, allocator := context.allocator) -> (Picture, Error) {
	
	if !os.is_file(filepath){
		return Picture{}, Error.FILE_NOT_FOUND
	}

	filepath_cstr := strings.clone_to_cstring(filepath, context.temp_allocator)

	flip: i32 = .FLIP_VERTICALLY in read_info.read_flags ? 1 : 0
	stbi.set_flip_vertically_on_load(flip)

	width, height, channels: i32
	stb_buffer_f32 : [^]f32 = stbi.loadf(filepath_cstr, &width,&height,&channels,3)

	defer if stb_buffer_f32 != nil {
		stbi.image_free(stb_buffer_f32)
	}

	if width == 0 || height == 0 || channels == 0 {		
		return Picture{}, Error.INVALID_IMAGE_DIMENSIONS
	}

	// Hdr file format always has 3 channels of float 32
	assert(channels == 3)

	src_format: Format = Format.RGB32_F
	src_num_bytes: int = cast(int)width * cast(int)height * 3 * size_of(f32) //cast(int)calc_bytes_for_img(cast(u32)width, cast(u32)height, .RGB32_F);

	output_format : Format = src_format
	output_num_bytes : int    = 0
	output_pixels : [^]byte   = nil

	if .APPEND_ALPHA_TO_RGB in read_info.read_flags {

		output_format = Format.RGBA32_F
		output_num_bytes = cast(int)width * cast(int)height * 4 * size_of(f32) // cast(int)calc_bytes_for_img(cast(u32)width, cast(u32)height, .RGBA32_F);

		output_pixels = make_multi_pointer([^]byte, output_num_bytes)

		num_pixels : u32 = cast(u32)width * cast(u32)height

		_load_mask  : #simd[4]bool = {true,true,true,false}
		_store_mask : #simd[4]bool = {true,true,true,true}
		_fill       : #simd[4]f32 = {1.0,1.0,1.0,1.0}
		
		src_buf : [^]byte = cast([^]byte)stb_buffer_f32

		for pixel in 0..<num_pixels{

			src_offset : u32 = pixel * size_of([3]f32) // because src has 3 channels per pixel
			dst_offset : u32 = pixel * size_of([4]f32) // dst has 4 channels

			_pixel_values : #simd[4]f32 = simd.masked_load(&src_buf[src_offset], _fill, _load_mask)
			simd.masked_store(&output_pixels[dst_offset], _pixel_values, _store_mask)
		}

	} else {

		output_format 	 = src_format
		output_num_bytes = src_num_bytes

		output_pixels = make_multi_pointer([^]byte, output_num_bytes)
		mem.copy_non_overlapping(output_pixels, stb_buffer_f32, output_num_bytes)
	}

	assert(output_format != .NONE)
	assert(output_num_bytes > 0)
	assert(output_pixels != nil)

	out_pic := Picture {
		width  = cast(u32)width,
		height = cast(u32)height,
		format = output_format,
		pixels = output_pixels[0:output_num_bytes],
	}

	return out_pic, Error.NONE
}


write_hdr_to_file :: proc(filepath : string, #by_ptr pic : Picture, write_flags : WriteFlags, allocator := context.allocator) -> Error {

	is_valid_picture_with_error(pic) or_return

	stbi.flip_vertically_on_write(.FLIP_VERTICALLY in write_flags)

	src_format := pic.format
	src_buffer : [^]byte = &pic.pixels[0]
	should_free_src_buffer : bool = false

	defer if should_free_src_buffer {
		free(src_buffer)
	}

	if pic.format != Format.RGB32_F {

		target_format := Format.RGB32_F
		converted_buffer : []byte = convert_format(pic.pixels, pic.format, pic.width, pic.height, target_format, allocator)
		
		src_format = target_format
		src_buffer = &converted_buffer[0]
		should_free_src_buffer = true
	}

	num_channels : i32 = 3 // Always RGB32_F

	filepath_cstr := strings.clone_to_cstring(filepath, context.temp_allocator)

	stbi_error : i32 = stbi.write_hdr(filepath_cstr, cast(i32)pic.width, cast(i32)pic.height, num_channels, cast([^]f32)src_buffer)

	if stbi_error == 0 {		
		return Error.FAILED_TO_WRITE_TO_FILE
	}

	return Error.NONE
}


read_stbi_from_file :: proc(filepath: string, read_info : ReadInfo, allocator := context.allocator) -> (Picture, Error) {

	if !os.is_file(filepath){
		return Picture{}, Error.FILE_NOT_FOUND
	}

	filepath_cstr := strings.clone_to_cstring(filepath, context.temp_allocator)
	
	flip: i32 = .FLIP_VERTICALLY in read_info.read_flags ? 1 : 0
	stbi.set_flip_vertically_on_load(flip)

	is_16_bit: b32 = stbi.is_16_bit(filepath_cstr)

	width, height, channels: i32

	src_format : Format = .NONE
	stb_buffer : [^]byte = nil

	//16 bit images
	if is_16_bit {

		stb_buffer_16 : [^]u16 = stbi.load_16(filepath_cstr, &width,&height, &channels, 0)
		
		if stb_buffer_16 == nil || width == 0 || height == 0 || channels == 0 {
			return Picture{}, Error.FAILD_TO_OPEN_FILE
		}

		stb_buffer = cast([^]byte)&stb_buffer_16[0]

		assert(channels <= 4)

		switch channels {
		case 1: src_format = .R16_UNORM
		case 2: src_format = .RG16_UNORM
		case 3: src_format = .RGB16_UNORM
		case 4:	src_format = .RGBA16_UNORM
		}

	} else {

		// this interface always return 8bit image data
		stb_buffer = stbi.load(filepath_cstr, &width, &height, &channels,0)

		assert(channels <= 4)

		switch channels {
		case 1: src_format = .R8_UNORM
		case 2: src_format = .RG8_UNORM
		case 3: src_format = .RGB8_UNORM
		case 4:	src_format = .RGBA8_UNORM
		}
	}

	defer if stb_buffer != nil{
		stbi.image_free(stb_buffer)
	}

	src_num_bytes: int = cast(int)calc_bytes(cast(u32)width,cast(u32)height, src_format)
		
	target_format := get_read_info_target_format(src_format, read_info)

	out_pic := Picture{}

	if src_format != target_format {
		out_pic.pixels = convert_format(stb_buffer[0:src_num_bytes], src_format, cast(u32)width, cast(u32)height, target_format, allocator)
	} else {
		out_pic.pixels = make_slice([]byte, src_num_bytes, allocator)
		mem.copy_non_overlapping(&out_pic.pixels[0], stb_buffer, src_num_bytes)
	}

	out_pic.width  = cast(u32)width
	out_pic.height = cast(u32)height
	out_pic.format = target_format

	return out_pic, Error.NONE
}

free_pixels :: proc(pic : ^Picture) {
	
	if pic.pixels != nil {
		delete_slice(pic.pixels)
		pic.pixels = nil
	}
	pic.height = 0
	pic.width  = 0
	pic.format = .NONE
}

is_valid_picture :: proc(#by_ptr pic: Picture) -> bool {

	if pic.pixels == nil {
		return false
	}

	if pic.format == Format.NONE {
		return false
	}

	if pic.width == 0 || pic.height == 0 {
		return false
	}

	calculated_bytes := cast(int)calc_bytes(pic)
	len_buffer := len(pic.pixels)

	if calculated_bytes != len_buffer {
		return false
	}

	return true
}

is_valid_picture_with_error :: proc(#by_ptr pic: Picture) -> Error {
	if pic.pixels == nil {
		return Error.NIL_BUFFER
	}

	if pic.format == Format.NONE {
		return Error.INVALID_FORMAT
	}

	if pic.width == 0 || pic.height == 0 {
		return Error.INVALID_IMAGE_DIMENSIONS
	}

	calculated_bytes := cast(int)calc_bytes(pic)
	len_buffer := len(pic.pixels)

	if calculated_bytes != len_buffer {
		return Error.PIXEL_BUFFER_SIZE_DOES_NOT_MATCH_EXPECTED_NUM_BYTES
	}

	return Error.NONE
}

get_file_format_from_filename :: proc(filename: string) -> FileFormat {

	file_ext := os.ext(filename)

	switch file_ext {
	case ".png":  return .PNG
	case ".PNG":  return .PNG
	case ".tiff": return .TIF
	case ".tif":  return .TIF
	case ".TIFF": return .TIF
	case ".jpg":  return .JPG
	case ".JPG":  return .JPG
	case ".jpeg": return .JPG
	case ".JPEG": return .JPG
	case ".hdr":  return .HDR
	case ".exr":  return .EXR
	}

	return FileFormat.NONE
}

get_file_ext_from_file_format :: proc(file_format : FileFormat) -> string {

	switch file_format {
	case .NONE: return ""
	case .PNG : return ".png"
	case .JPG : return ".jpg"
	case .TIF : return ".tif"
	case .HDR : return ".hdr"
	case .EXR : return ".exr"
	}

	return ""
}