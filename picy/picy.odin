package picy

import "base:runtime"
import "core:os"
import "core:mem"
import "core:strings"
import "core:path/filepath"
import "core:fmt"
import "core:thread"
import "core:simd"

import stbi "vendor:stb/image"


// PicReadInfo :: struct {
// 	// TODO should make these into flags
// 	flip_vertically:     bool,
// 	convert_grey_to_rgb: bool,
// 	convert_hdr_to_ldr:  bool,
// 	RGB_to_RGBA: bool,
// }



PicLoadFlags :: distinct bit_set[PicLoadFlag]
PicLoadFlag :: enum u32 {
	FLIP_VERTICALLY, 	// flip images vertically
	GRAY_TO_RGB,		// copy gray (single channel) to RGB channels
	// HDR_TO_LDR, TODO:			
	RGB_TO_RGBA,	// Add alpha channel with value of 1.0 to rgb images, works with GRAY_TO_RGB
}

PicFormat :: enum u8 {
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
	RGBA32_F		= 16  // 4 component 32 bit: signed float (32bit)
};

PicFileFormat :: enum u8 {
	NONE = 0,
	PNG = 1,
	JPG = 2,
	TIF = 3,
	HDR = 4,
	EXR = 5,
}

PicInfo :: struct {
	format: PicFormat,	
	width : u32,
	height: u32,
	num_bytes : u32,
	pixels: [^]byte,
}

// TODO: redesign thread interface
// PicThreadData :: struct {
// 	// thread input
// 	filename : string,
// 	flip_vertically 	:bool,
// 	convert_grey_to_rgb :bool,
// 	convert_hdr_to_ldr  :bool,

// 	// thread outpu
// 	out_pic_info : PicInfo,
// }

read_from_file :: proc(filename: string, load_flags : PicLoadFlags) -> (PicInfo, bool) {

	out_info: PicInfo;

	// TODO, determine file format
	file_format := get_file_format_from_filename(filename);

	switch file_format {
		case PicFileFormat.NONE: return out_info, false;
		case PicFileFormat.PNG:  return read_png(filename,load_flags);
		case PicFileFormat.JPG:  return read_jpg(filename,load_flags);
		case PicFileFormat.TIF:  return out_info, false; // not supported yet
		case PicFileFormat.HDR:  return read_hdr(filename,load_flags);
		case PicFileFormat.EXR:  return out_info, false; // not supported yet
	}


	return out_info, false;
}

// read_from_file_threadproc :: proc(t: ^thread.Thread) {

// 	data : ^PicThreadData = cast(^PicThreadData)t.data;

// 	out_info: PicInfo;
// 	success: bool;


// 	file_format := get_file_format_from_filename(data.filename);

// 	read_info := PicReadInfo{
// 		flip_vertically = data.flip_vertically,
// 		convert_grey_to_rgb = data.convert_grey_to_rgb,
// 		convert_hdr_to_ldr = data.convert_hdr_to_ldr,
// 	}
// 	switch file_format {
// 		case PicFileFormat.NONE: //out_pic_info = out_info;
// 		case PicFileFormat.PNG:  out_info,success = read_png(data.filename,read_info);
// 		case PicFileFormat.JPG:  out_info,success = read_jpg(data.filename,read_info);
// 		case PicFileFormat.TIF:  //out_pic_info = out_info; // not supported yet
// 		case PicFileFormat.HDR:  out_info,success = read_hdr(data.filename,read_info);
// 		case PicFileFormat.EXR:  //out_pic_info = out_info; // not supported yet
// 	}

// 	//fmt.println("Pic: Loaded Tex {}", data.filename);

// 	if(!success){
// 		fmt.println("FAILED TO LOAD TEXTURE {}", data.filename);
// 		if(out_info.pixels != nil){
// 			free(out_info.pixels);
// 			out_info.pixels = nil;
// 		}
// 		out_info.format = PicFormat.NONE;
// 		out_info.width = 0;
// 		out_info.height = 0;			
// 	}

// 	data.out_pic_info.format = out_info.format;
// 	data.out_pic_info.width  = out_info.width;
// 	data.out_pic_info.height = out_info.height;
// 	data.out_pic_info.pixels = out_info.pixels;
// 	return;
// }


read_png :: proc(filename: string, load_flags : PicLoadFlags) -> (PicInfo, bool) {
	return read_stbi(filename,load_flags);
}

read_jpg :: proc(filename: string, load_flags : PicLoadFlags) -> (PicInfo, bool) {
	return read_stbi(filename,load_flags);
}

read_hdr :: proc(filename: string, load_flags : PicLoadFlags) -> (PicInfo, bool) {
	
	out_info: PicInfo;

	filename_cstr := strings.clone_to_cstring(filename);
	defer delete(filename_cstr);

	flip: i32 = .FLIP_VERTICALLY in load_flags ? 1 : 0;
	stbi.set_flip_vertically_on_load(flip);

	width, height, channels: i32;

	stb_buffer_f32 : [^]f32 = stbi.loadf(filename_cstr, &width,&height,&channels,3);

	defer {
		if(stb_buffer_f32 != nil){
			stbi.image_free(stb_buffer_f32);
		}
	}

	if(width == 0 || height == 0 || channels == 0) {		
		return out_info, false;
	}

	// Hdr file format always has 3 channels of float 32
	assert(channels == 3);

	input_format: PicFormat = PicFormat.RGB32_F;
	input_num_bytes: int = cast(int)width * cast(int)height * 3 * size_of(f32);//cast(int)calc_bytes_for_img(cast(u32)width, cast(u32)height, .RGB32_F);

	output_format : PicFormat = .NONE;
	output_num_bytes : int    = 0;
	output_pixels : [^]byte   = nil;

	if .RGB_TO_RGBA in load_flags {

		output_format = PicFormat.RGBA32_F;
		output_num_bytes = cast(int)width * cast(int)height * 4 * size_of(f32);// cast(int)calc_bytes_for_img(cast(u32)width, cast(u32)height, .RGBA32_F);

		output_pixels = make_multi_pointer([^]byte, output_num_bytes);

		num_pixels : u32 = cast(u32)width * cast(u32)height;

		_load_mask  : #simd[4]bool = {true,true,true,false};
		_store_mask : #simd[4]bool = {true,true,true,true};
		_fill : #simd[4]f32 = {1.0,1.0,1.0,1.0};
		
		// cast to byte buffer to make things simpler to reason about
		src_buf : [^]byte = cast([^]byte)stb_buffer_f32; 

		for pixel in 0..<num_pixels{

			src_offset : u32 = pixel * size_of([3]f32); // because src has 3 channels per pixel
			dst_offset : u32 = pixel * size_of([4]f32); // dst has 4 channels

			_pixel_values : #simd[4]f32 = simd.masked_load(&src_buf[src_offset], _fill, _load_mask);

			simd.masked_store(&output_pixels[dst_offset], _pixel_values, _store_mask);
		}

	} else {

		output_format 	 = input_format;
		output_num_bytes = input_num_bytes;

		output_pixels = make_multi_pointer([^]byte, output_num_bytes);
		mem.copy_non_overlapping(output_pixels, stb_buffer_f32, output_num_bytes);
	}

	assert(output_format != .NONE);
	assert(output_num_bytes > 0);
	assert(output_pixels != nil);


	out_info.width  = cast(u32)width;
	out_info.height = cast(u32)height;
	out_info.format = output_format;
	out_info.pixels = output_pixels;
	out_info.num_bytes = cast(u32)output_num_bytes;

	return out_info, true;
}


read_stbi :: proc(filename: string, load_flags : PicLoadFlags) -> (PicInfo, bool) {

	out_info: PicInfo;

	filename_cstr := strings.clone_to_cstring(filename);
	defer delete(filename_cstr);

	flip: i32 = .FLIP_VERTICALLY in load_flags ? 1 : 0;
	stbi.set_flip_vertically_on_load(flip);

	is_16: b32 = stbi.is_16_bit(filename_cstr);

	// I have not yet tested if stb does the right thing with desired channels..
	desired_channels : i32 = 0;
	if .GRAY_TO_RGB in load_flags {

		if .RGB_TO_RGBA in load_flags {
			desired_channels = 4
		} else {
			desired_channels = 3;
		}
	}

	width, height, channels: i32;

	//16 bit images
	if(is_16) {

		stb_buffer_16 : [^]u16 = stbi.load_16(filename_cstr, &width,&height,&channels, desired_channels);

		defer {
			if stb_buffer_16 != nil {
				stbi.image_free(stb_buffer_16);
			}
		}
		
		if(stb_buffer_16 == nil || width == 0 || height == 0 || channels == 0) {
			return out_info, false;
		}

		assert(channels <= 4);

		if(desired_channels != 0){
			
			assert(desired_channels == channels);
		}

		input_format: PicFormat = PicFormat.NONE;
		switch channels {
			case 1: input_format = .R16_UNORM;
			case 2: input_format = .RG16_UNORM;
			case 3: input_format = .RGB16_UNORM;
			case 4:	input_format = .RGBA16_UNORM;
		}

		input_num_bytes: int = cast(int)calc_bytes_for_img(cast(u32)width,cast(u32)height, input_format);

		output_pixels : [^]byte = make_multi_pointer([^]byte, input_num_bytes);

		mem.copy_non_overlapping(output_pixels, stb_buffer_16, input_num_bytes);

		out_info.width  = cast(u32)width;
		out_info.height = cast(u32)height;
		out_info.format = input_format;
		out_info.pixels = output_pixels;
		out_info.num_bytes = cast(u32)input_num_bytes;

		return out_info, true;
	}

	// this interface always return 8bit image data
	stb_buffer : [^]u8 = stbi.load(filename_cstr, &width,&height,&channels,0);

	defer if stb_buffer != nil {
		stbi.image_free(stb_buffer);
	}
	
	if(stb_buffer == nil || width == 0 || height == 0 || channels == 0) {
		return out_info, false;
	}

	input_format: PicFormat = PicFormat.NONE;

	switch channels {
		case 1: input_format = PicFormat.R8_UNORM
		case 2: input_format = PicFormat.RG8_UNORM;
		case 3: input_format = PicFormat.RGB8_UNORM;
		case 4:	input_format = PicFormat.RGBA8_UNORM;
	}


	
	input_num_bytes : int = cast(int)calc_bytes_for_img(cast(u32)width,cast(u32)height, input_format);
	
	output_pixels : [^]byte = make_multi_pointer([^]byte, input_num_bytes);
	mem.copy_non_overlapping(output_pixels, stb_buffer, input_num_bytes);
	

	out_info.width  = cast(u32)width;
	out_info.height = cast(u32)height;
	out_info.format = input_format;
	out_info.pixels = output_pixels;
	out_info.num_bytes = cast(u32)input_num_bytes;
	return out_info, true;
}

free_pixels_if_allocated :: proc(pic_info: ^PicInfo) {	
	if(pic_info.pixels != nil){
		//fmt.println("Freeing pixel memory");
		free(pic_info.pixels);
		pic_info.pixels = nil;
	}
}

is_valid_picinfo :: proc(pic_info: ^PicInfo) -> bool{
	
	if pic_info == nil {
		return false;	
	}

	if pic_info.pixels == nil {
		return false;	
	}

	if pic_info.format == PicFormat.NONE {
		return false;
	}

	if pic_info.width == 0 || pic_info.height == 0 {
		return false;
	}

	if pic_info.num_bytes == 0 {
		return false;
	}

	return true;
}

get_file_format_from_filename :: proc(filename: string) -> PicFileFormat {

	if(!os.is_file(filename)){
		return PicFileFormat.NONE;
	}

	file_extention := filepath.ext(filename);

	if(file_extention == ".png"){
		return PicFileFormat.PNG;
	}
	else if(file_extention == ".jpg" || file_extention == ".jpeg"){
		return PicFileFormat.JPG;
	}
	else if(file_extention == ".tif" || file_extention == ".tiff"){
		return PicFileFormat.TIF;
	}
	else if(file_extention == ".hdr"){
		return PicFileFormat.HDR;
	}
	else if(file_extention == ".exr"){
		return PicFileFormat.EXR;
	}

	return PicFileFormat.NONE;

}

calc_bytes_for_img :: proc(width: u32, height: u32, format : PicFormat) -> u32 {

	bytes_per_pixel := calc_bytes_per_pixel(format);

	return width * height * bytes_per_pixel;
}

calc_bytes_per_pixel :: proc(format : PicFormat) -> u32 {
	
	switch format {
		case .NONE			: return 0;
		
		case .R8_UNORM		: return size_of(u8) * 1;
		case .RG8_UNORM		: return size_of(u8) * 2;
		case .RGB8_UNORM	: return size_of(u8) * 3;
		case .RGBA8_UNORM	: return size_of(u8) * 4;

		case .R16_UNORM		: return size_of(u16) * 1;		  	
		case .RG16_UNORM	: return size_of(u16) * 2;	  	
		case .RGB16_UNORM	: return size_of(u16) * 3; 			 
		case .RGBA16_UNORM	: return size_of(u16) * 4;

		case .R16_F			: return size_of(f16) * 1;
		case .RG16_F		: return size_of(f16) * 2;
		case .RGB16_F		: return size_of(f16) * 3;
		case .RGBA16_F		: return size_of(f16) * 4;
		
		case .R32_F			: return size_of(f32) * 1;
		case .RG32_F		: return size_of(f32) * 2;
		case .RGB32_F		: return size_of(f32) * 3;
		case .RGBA32_F		: return size_of(f32) * 4;
	}

	panic("invalid codepath");
}

get_num_channels_from_format :: proc(format : PicFormat) -> u32 {
	
	switch format {
		case .NONE			: return 0;
		
		case .R8_UNORM		: return 1;
		case .RG8_UNORM		: return 2;
		case .RGB8_UNORM	: return 3;
		case .RGBA8_UNORM	: return 4;

		case .R16_UNORM		: return 1;		  	
		case .RG16_UNORM	: return 2;	  	
		case .RGB16_UNORM	: return 3; 			 
		case .RGBA16_UNORM	: return 4;

		case .R16_F			: return 1;
		case .RG16_F		: return 2;
		case .RGB16_F		: return 3;
		case .RGBA16_F		: return 4;
		
		case .R32_F			: return 1;
		case .RG32_F		: return 2;
		case .RGB32_F		: return 3;
		case .RGBA32_F		: return 4;
	}

	panic("invalid codepath");
}