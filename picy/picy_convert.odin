package picy

import "core:mem"
import "core:c"

calc_bytes :: proc {
	calc_bytes_from_picture,
	calc_bytes_from_width_height_format,
}

calc_bytes_from_picture :: proc "contextless" (#by_ptr pic : Picture) -> u32 {
	return pic.width * pic.height * calc_bytes_per_pixel(pic.format)
}

calc_bytes_from_width_height_format :: proc "contextless" (width: u32, height: u32, format : Format) -> u32 {
	return width * height * calc_bytes_per_pixel(format)
}

calc_bytes_per_pixel :: proc "contextless" (format : Format) -> u32 {
	
	switch format {
	case .NONE			: return 0
	
	case .R8_UNORM		: return size_of(u8) * 1
	case .RG8_UNORM		: return size_of(u8) * 2
	case .RGB8_UNORM	: return size_of(u8) * 3
	case .RGBA8_UNORM	: return size_of(u8) * 4

	case .R16_UNORM		: return size_of(u16) * 1
	case .RG16_UNORM	: return size_of(u16) * 2
	case .RGB16_UNORM	: return size_of(u16) * 3
	case .RGBA16_UNORM	: return size_of(u16) * 4

	case .R16_F			: return size_of(f16) * 1
	case .RG16_F		: return size_of(f16) * 2
	case .RGB16_F		: return size_of(f16) * 3
	case .RGBA16_F		: return size_of(f16) * 4
	
	case .R32_F			: return size_of(f32) * 1
	case .RG32_F		: return size_of(f32) * 2
	case .RGB32_F		: return size_of(f32) * 3
	case .RGBA32_F		: return size_of(f32) * 4
	}

	return 0
}

get_format_info :: proc "contextless" (format : Format) -> (num_channels : u32, bits_per_channel : u32, bytes_per_pixel : u32, format_type : FormatType){
	
	switch format {
	case .NONE			: return 0, 0, 0, FormatType.INVLAID
	
	case .R8_UNORM		: return 1,  8, size_of(u8) * 1, FormatType.UNORM_8
	case .RG8_UNORM		: return 2,  8, size_of(u8) * 2, FormatType.UNORM_8
	case .RGB8_UNORM	: return 3,  8, size_of(u8) * 3, FormatType.UNORM_8
	case .RGBA8_UNORM	: return 4,  8, size_of(u8) * 4, FormatType.UNORM_8

	case .R16_UNORM		: return 1, 16, size_of(u16) * 1, FormatType.UNORM_16
	case .RG16_UNORM	: return 2, 16, size_of(u16) * 2, FormatType.UNORM_16
	case .RGB16_UNORM	: return 3, 16, size_of(u16) * 3, FormatType.UNORM_16
	case .RGBA16_UNORM	: return 4, 16, size_of(u16) * 4, FormatType.UNORM_16

	case .R16_F			: return 1, 16, size_of(f16) * 1, FormatType.F_16
	case .RG16_F		: return 2, 16, size_of(f16) * 2, FormatType.F_16
	case .RGB16_F		: return 3, 16, size_of(f16) * 3, FormatType.F_16
	case .RGBA16_F		: return 4, 16, size_of(f16) * 4, FormatType.F_16
	
	case .R32_F			: return 1, 32, size_of(f32) * 1, FormatType.F_32
	case .RG32_F		: return 2, 32, size_of(f32) * 2, FormatType.F_32
	case .RGB32_F		: return 3, 32, size_of(f32) * 3, FormatType.F_32
	case .RGBA32_F		: return 4, 32, size_of(f32) * 4, FormatType.F_32
	}

	return num_channels, bits_per_channel, bytes_per_pixel, FormatType.INVLAID
}

get_num_channels_from_format :: proc "contextless" (format : Format) -> u32 {
	
	switch format {
	case .NONE			: return 0
	
	case .R8_UNORM		: return 1
	case .RG8_UNORM		: return 2
	case .RGB8_UNORM	: return 3
	case .RGBA8_UNORM	: return 4

	case .R16_UNORM		: return 1
	case .RG16_UNORM	: return 2
	case .RGB16_UNORM	: return 3
	case .RGBA16_UNORM	: return 4

	case .R16_F			: return 1
	case .RG16_F		: return 2
	case .RGB16_F		: return 3
	case .RGBA16_F		: return 4
	
	case .R32_F			: return 1
	case .RG32_F		: return 2
	case .RGB32_F		: return 3
	case .RGBA32_F		: return 4
	}

	return 0
}

get_format_type_from_pic_format :: proc "contextless" (format : Format) -> FormatType {
	
	switch format {
	case .NONE			: return .INVLAID
	
	case .R8_UNORM		: return .UNORM_8
	case .RG8_UNORM		: return .UNORM_8
	case .RGB8_UNORM	: return .UNORM_8
	case .RGBA8_UNORM	: return .UNORM_8

	case .R16_UNORM		: return .UNORM_16
	case .RG16_UNORM	: return .UNORM_16
	case .RGB16_UNORM	: return .UNORM_16
	case .RGBA16_UNORM	: return .UNORM_16

	case .R16_F			: return .F_16
	case .RG16_F		: return .F_16
	case .RGB16_F		: return .F_16
	case .RGBA16_F		: return .F_16
	
	case .R32_F			: return .F_32
	case .RG32_F		: return .F_32
	case .RGB32_F		: return .F_32
	case .RGBA32_F		: return .F_32
	}

	return .INVLAID
}

// channels 1..=4 bits_per_channel either 8,16 or 32
get_format_from_channels_and_bits_per_channel :: proc(num_channels : u32, bits_per_channel : u32, is_16_bit_floating_point : bool) -> Format {

	assert(num_channels >= 0 && num_channels <=4)
	assert(bits_per_channel == 8 || bits_per_channel == 16 || bits_per_channel == 32)

	if bits_per_channel == 8 {
		switch num_channels {
		case 1: return .R8_UNORM
		case 2: return .RG8_UNORM
		case 3: return .RGB8_UNORM
		case 4: return .RGBA8_UNORM
		}
	} else if bits_per_channel == 16 {
		switch num_channels {
		case 1: return is_16_bit_floating_point ? .R16_F    : .R16_UNORM
		case 2: return is_16_bit_floating_point ? .RG16_F   : .RG16_UNORM
		case 3: return is_16_bit_floating_point ? .RGB16_F  : .RGB16_UNORM
		case 4: return is_16_bit_floating_point ? .RGBA16_F : .RGBA16_UNORM
		}
	} else if bits_per_channel == 32 {
		switch num_channels {
		case 1: return .R32_F
		case 2: return .RG32_F
		case 3: return .RGB32_F
		case 4: return .RGBA32_F
		}
	}

	return .NONE
}

get_read_info_target_format :: proc(src_format : Format, read_info : ReadInfo) -> Format {
	num_channels := get_num_channels_from_format(src_format)

	target_format: Format = src_format
	if num_channels == 1 && .GRAY_TO_RGB in read_info.read_flags {

		target_format = cast(Format)(cast(u32)src_format + 2)
		num_channels = 3
	}

	if num_channels == 3 && .APPEND_ALPHA_TO_RGB in read_info.read_flags {
		target_format = cast(Format)(cast(u32)src_format + 1)
		num_channels = 3
	}

	return target_format
}

flip_vertically :: proc(pixels : []byte, width : u32, height : u32, format : Format, allocator := context.allocator){

	bytes_per_pixel : u32 = calc_bytes_per_pixel(format)
	bytes_per_row   : u32 = width * bytes_per_pixel

	temp_row_buf : [^]byte = make_multi_pointer([^]byte, bytes_per_row, allocator)

	half_height: u32 = height / 2
	height_minus_one: u32 = height -1

	for h : u32 = 0; h < half_height; h+= 1 {

		top_row : rawptr = &pixels[h * bytes_per_row]
		bot_row : rawptr = &pixels[(height_minus_one - h) * bytes_per_row]

		mem.copy(temp_row_buf, top_row     , int(bytes_per_row))
		mem.copy(top_row     , bot_row     , int(bytes_per_row))
		mem.copy(bot_row     , temp_row_buf, int(bytes_per_row))
	}

	free(temp_row_buf)
}


convert_format :: proc {
	convert_format_explicit,
	convert_format_picture,
}

convert_format_picture :: proc(pic : Picture, target_format : Format, allocator := context.allocator) -> (Picture, Error) {

	// return error instead
	if !is_valid_picture(pic) {
		return Picture{}, Error.INVALID_PICTURE
	}

	converted_pixels := convert_format_explicit(pic.pixels, pic.format, pic.width, pic.height, target_format, allocator)

	out_pic := Picture {
		width  = pic.width,
		height = pic.height,
		format = target_format,
		pixels = converted_pixels,
	}

	return out_pic, Error.NONE
}

// TODO: TEST
convert_format_explicit :: proc(src_pixels : []byte, src_format : Format, width: u32, height: u32, dst_format: Format, allocator := context.allocator) -> []byte {

	assert(src_pixels != nil)
	assert(src_format != .NONE)
	assert(dst_format != .NONE)
	assert(width > 0)
	assert(height > 0)

	dst_byte_size  := calc_bytes(width, height, dst_format)
	out_pixels := make_slice([]byte, cast(int)dst_byte_size, allocator)
	
	if src_format == dst_format {
		mem.copy(&out_pixels[0], &src_pixels[0], cast(int)dst_byte_size)
		return out_pixels
	}

	num_src_channels := cast(int)get_num_channels_from_format(src_format)
	num_dst_channels := cast(int)get_num_channels_from_format(dst_format)

	src_format_type := get_format_type_from_pic_format(src_format)
	dst_format_type := get_format_type_from_pic_format(dst_format)

	// src_bytes_per_pixel : int = cast(int)calc_bytes_per_pixel(src_format)
	dst_bytes_per_pixel : int = cast(int)calc_bytes_per_pixel(dst_format)

	// src_num_values : u32 = width * height * cast(u32)num_src_channels
	// dst_num_values : u32 = width * height * cast(u32)num_dst_channels

	assert(src_format_type != .INVLAID)
	assert(dst_format_type != .INVLAID)

	src_pixels_as_bytes : [^]byte = raw_data(src_pixels)
	
	src_pixels_as_u8  : [^]u8  = src_pixels_as_bytes
	src_pixels_as_u16 : [^]u16 = cast([^]u16)src_pixels_as_bytes
	src_pixels_as_f16 : [^]f16 = cast([^]f16)src_pixels_as_bytes
	src_pixels_as_f32 : [^]f32 = cast([^]f32)src_pixels_as_bytes

	dst_pixels_as_bytes  : [^]byte  = raw_data(out_pixels)
	
	dst_pixels_as_u8  : [^]u8  = raw_data(out_pixels)
	dst_pixels_as_u16 : [^]u16 = cast([^]u16)raw_data(out_pixels)
	dst_pixels_as_f16 : [^]f16 = cast([^]f16)raw_data(out_pixels)
	dst_pixels_as_f32 : [^]f32 = cast([^]f32)raw_data(out_pixels)


	// if num_src_channels == num_dst_channels {

	// 	assert(src_format_type != dst_format_type) // Already handled the case where src_format == dst_format.

	// 	num_values : u32 = width * height * num_src_channels


	// 	switch src_format_type {
	// 	case .INVLAID:	panic("Invalid Codepath")
	// 	case .UNORM_8:				
	// 		for i in 0..<num_values {
	// 			switch dst_format_type {
	// 			case .INVLAID:	// invalid codepath
	// 			case .UNORM_8:  // invalid codepath
	// 			case .UNORM_16: dst_pixels_as_u16[i] = #force_inline convert_u8_to_u16(src_pixels_as_u8[i])
	// 			case .F_16:		dst_pixels_as_f16[i] = #force_inline convert_u8_to_f16(src_pixels_as_u8[i])
	// 			case .F_32:		dst_pixels_as_f32[i] = #force_inline convert_u8_to_f32(src_pixels_as_u8[i])
	// 			}
	// 		}
	// 	case .UNORM_16:
	// 		for i in 0..<num_values {
	// 			switch dst_format_type {
	// 			case .INVLAID:	// invalid codepath
	// 			case .UNORM_8:	dst_pixels_as_u8[i]  = #force_inline convert_u16_to_u8(src_pixels_as_u16[i])
	// 			case .UNORM_16: // invalid codepath
	// 			case .F_16:		dst_pixels_as_f16[i] = #force_inline convert_u16_to_f16(src_pixels_as_u16[i])
	// 			case .F_32:		dst_pixels_as_f32[i] = #force_inline convert_u16_to_f32(src_pixels_as_u16[i])
	// 			}
	// 		}
	// 	case .F_16:
	// 		for i in 0..<num_values {
	// 			switch dst_format_type {
	// 			case .INVLAID:	// invalid codepath
	// 			case .UNORM_8: 	dst_pixels_as_u8[i]  = #force_inline convert_f16_to_u8(src_pixels_as_f16[i])
	// 			case .UNORM_16:	dst_pixels_as_u16[i] = #force_inline convert_f16_to_u16(src_pixels_as_f16[i])
	// 			case .F_16: 	// invalid codepath
	// 			case .F_32:		dst_pixels_as_f32[i] = #force_inline convert_f16_to_f32(src_pixels_as_f16[i])
	// 			}
	// 		}
	// 	case .F_32:
	// 		for i in 0..<num_values {
	// 			switch dst_format_type {
	// 			case .INVLAID:	// invalid codepath
	// 			case .UNORM_8:  dst_pixels_as_u8[i]  = #force_inline convert_f32_to_u8(src_pixels_as_f32[i])
	// 			case .UNORM_16:	dst_pixels_as_u16[i] = #force_inline convert_f32_to_u16(src_pixels_as_f32[i])
	// 			case .F_16:		dst_pixels_as_f16[i] = #force_inline convert_f32_to_f16(src_pixels_as_f32[i])
	// 			case .F_32: 	// invalid codepath
	// 			}
	// 		}
	// 	}

	// 	return out_pixels
	// }

	// if src_format_type == dst_format_type {
	// 	assert(num_src_channels != num_dst_channels)

	// 	num_pixels : int = int(width * height)

	// 	value_byte_size : int 
	// 	switch src_format_type { // same as dst_format type here!
	// 	case .INVLAID:	// invalid codepath
	// 	case .UNORM_8:  value_byte_size = size_of(u8)
	// 	case .UNORM_16: value_byte_size = size_of(u16)
	// 	case .F_16:		value_byte_size = size_of(f16)
	// 	case .F_32:		value_byte_size = size_of(f32)
	// 	}

	// 	// In this case we just truncate them.
	// 	if num_dst_channels < num_src_channels {

	// 		// TODO: special case if we go from RGB or RGBA to just R convert it to grayscale img ?!
	// 		// TODO: speed
	// 		for pix in 0..<num_pixels{
	// 			src_r_channel_offset : int = (pix * src_bytes_per_pixel) + value_byte_size * 0
	// 			mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 0], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size * cast(int)num_dst_channels)
	// 		}

	// 	} else { // num_dest_channels > num_src_channels

	// 		assert(num_dst_channels > 1)
			
	// 		if num_dst_channels == 2 {
	// 			for pix in 0..<num_pixels{ 

	// 				src_r_channel_offset : int = (pix * src_bytes_per_pixel) + value_byte_size * 0

	// 				mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 0], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size) // src R to dst R channel
	// 				mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 1], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size) // src R to dst G channel
	// 			}				
	// 		}
	// 		if num_dst_channels == 3 {
	// 			if num_src_channels == 1 { // Copy R to RGB
	// 				for pix in 0..<num_pixels{ 
	// 					src_r_channel_offset : int = (pix * src_bytes_per_pixel) + value_byte_size * 0
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 0], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size) // src R to dst R channel
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 1], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size) // src R to dst G channel
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 2], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size) // src R to dst B channel
	// 				}
	// 			} else {
	// 				// Src has RG and we Just Fill B channel with 0 aka do nothing
	// 				for pix in 0..<num_pixels{ 
	// 					src_r_channel_offset : int = (pix * src_bytes_per_pixel) + value_byte_size * 0
	// 					src_g_channel_offset : int = (pix * src_bytes_per_pixel) + value_byte_size * 1
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 0], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size)
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 1], &src_pixels_as_bytes[src_g_channel_offset], value_byte_size)
	// 				}
	// 			}
	// 		}
	// 		if num_dst_channels == 4 {

	// 			if num_src_channels == 1 {
	// 				for pix in 0..<num_pixels{
	// 					src_r_channel_offset : int = (pix * src_bytes_per_pixel) + value_byte_size * 0
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 0], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size)
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 1], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size)
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 2], &src_pixels_as_bytes[src_r_channel_offset], value_byte_size)
	// 				}
	// 			} else if num_src_channels == 2 || num_src_channels == 3 {
	// 				// Copy RGB over
	// 				for pix in 0..<num_pixels{
	// 					mem.copy(&dst_pixels_as_bytes[(pix * dst_bytes_per_pixel) + value_byte_size * 0], &src_pixels_as_bytes[pix * src_bytes_per_pixel], value_byte_size * cast(int)num_src_channels)
	// 				}
	// 			} else {
	// 				panic("Invalid Codepath. num_src_channels cant be 4 or higher!")
	// 			}

	// 			// Fill Alpha channel with fully opaque
	// 			for pix in 0..<num_pixels {
	// 				switch src_format_type { // same as dst_format type here!
	// 				case .INVLAID:	// invalid codepath
	// 				case .UNORM_8:  dst_pixels_as_u8[pix + 3]  = u8(c.UINT8_MAX)
	// 				case .UNORM_16: dst_pixels_as_u16[pix + 3] = u16(c.UINT16_MAX)
	// 				case .F_16:		dst_pixels_as_f16[pix + 3] = f16(1.0)
	// 				case .F_32:		dst_pixels_as_f32[pix + 3] = f32(1.0)
	// 				}
	// 			}
	// 		}
	// 	}
	// }

	//if src_format_type != dst_format_type && num_src_channels != num_dst_channels {
	

	num_pixels : int = int(width * height)

	// 
	// FIRST PASS: write converted format values to correct postion in dest buffer
	//

	// TODO: optimize for case when src and dest format are equal!!!

	{
		num_channels_to_copy : int = num_src_channels
		if num_dst_channels < num_src_channels {
			num_channels_to_copy = num_dst_channels
		}

		if src_format_type == .UNORM_8 {
			for pix in 0..<num_pixels {
				for chan in 0..<num_channels_to_copy {
					switch dst_format_type {
					case .INVLAID:	// invalid codepath
					case .UNORM_8:  dst_pixels_as_u8 [(pix * num_dst_channels) + chan] =                                 src_pixels_as_u8[(pix * num_src_channels) + chan]
					case .UNORM_16: dst_pixels_as_u16[(pix * num_dst_channels) + chan] = #force_inline convert_u8_to_u16(src_pixels_as_u8[(pix * num_src_channels) + chan])
					case .F_16:		dst_pixels_as_f16[(pix * num_dst_channels) + chan] = #force_inline convert_u8_to_f16(src_pixels_as_u8[(pix * num_src_channels) + chan])
					case .F_32:		dst_pixels_as_f32[(pix * num_dst_channels) + chan] = #force_inline convert_u8_to_f32(src_pixels_as_u8[(pix * num_src_channels) + chan])
					}
				}
			}
		} else if src_format_type == .UNORM_16 {
			for pix in 0..<num_pixels {
				for chan in 0..<num_channels_to_copy {
					switch dst_format_type {
					case .INVLAID:	// invalid codepath
					case .UNORM_8:  dst_pixels_as_u8[ (pix * num_dst_channels) + chan] = #force_inline convert_u16_to_u8 (src_pixels_as_u16[(pix * num_src_channels) + chan])
					case .UNORM_16: dst_pixels_as_u16[(pix * num_dst_channels) + chan] =                                  src_pixels_as_u16[(pix * num_src_channels) + chan]
					case .F_16:		dst_pixels_as_f16[(pix * num_dst_channels) + chan] = #force_inline convert_u16_to_f16(src_pixels_as_u16[(pix * num_src_channels) + chan])
					case .F_32:		dst_pixels_as_f32[(pix * num_dst_channels) + chan] = #force_inline convert_u16_to_f32(src_pixels_as_u16[(pix * num_src_channels) + chan])
					}
				}
			}
		} else if src_format_type == .F_16 {
			for pix in 0..<num_pixels {
				for chan in 0..<num_channels_to_copy {
					switch dst_format_type {
					case .INVLAID:	// invalid codepath
					case .UNORM_8:  dst_pixels_as_u8 [(pix * num_dst_channels) + chan] = #force_inline convert_f16_to_u8 (src_pixels_as_f16[(pix * num_src_channels) + chan])
					case .UNORM_16: dst_pixels_as_u16[(pix * num_dst_channels) + chan] = #force_inline convert_f16_to_u16(src_pixels_as_f16[(pix * num_src_channels) + chan])
					case .F_16:		dst_pixels_as_f16[(pix * num_dst_channels) + chan] =                                  src_pixels_as_f16[(pix * num_src_channels) + chan]
					case .F_32:		dst_pixels_as_f32[(pix * num_dst_channels) + chan] = #force_inline convert_f16_to_f32(src_pixels_as_f16[(pix * num_src_channels) + chan])
					}
				}
			}
		} else if src_format_type == .F_32 {
			for pix in 0..<num_pixels { 
				for chan in 0..<num_channels_to_copy { 
					switch dst_format_type {
					case .INVLAID:	// invalid codepath
					case .UNORM_8:  dst_pixels_as_u8 [(pix * num_dst_channels) + chan] = #force_inline convert_f32_to_u8 (src_pixels_as_f32[(pix * num_src_channels) + chan])
					case .UNORM_16: dst_pixels_as_u16[(pix * num_dst_channels) + chan] = #force_inline convert_f32_to_u16(src_pixels_as_f32[(pix * num_src_channels) + chan])
					case .F_16:		dst_pixels_as_f16[(pix * num_dst_channels) + chan] = #force_inline convert_f32_to_f16(src_pixels_as_f32[(pix * num_src_channels) + chan])
					case .F_32:		dst_pixels_as_f32[(pix * num_dst_channels) + chan] =                                  src_pixels_as_f32[(pix * num_src_channels) + chan]
					}
				}
			}
		}
	}
	
	// 
	// SECOND PASS: Operate on dst buffer and copy channels (R TO RGB) if neccesary and fill alpha with opaque if needed.
	// 				if dst_channels is lower than src_channels we are already done.
	// 

	if num_dst_channels > num_src_channels {

		value_byte_size : int 
		switch dst_format_type {
		case .INVLAID:	// invalid codepath
		case .UNORM_8:  value_byte_size = size_of(u8)
		case .UNORM_16: value_byte_size = size_of(u16)
		case .F_16:		value_byte_size = size_of(f16)
		case .F_32:		value_byte_size = size_of(f32)
		}

		// Copy R to G channel
		if num_dst_channels == 2 {
			for pix in 0..<num_pixels{ 

				r_channel_offset : int = (pix * dst_bytes_per_pixel) + value_byte_size * 0
				g_channel_offset : int = (pix * dst_bytes_per_pixel) + value_byte_size * 1

				mem.copy(&dst_pixels_as_bytes[g_channel_offset], &dst_pixels_as_bytes[r_channel_offset], value_byte_size) // dst R to dst G channel
			}
		}

		if num_dst_channels == 3 || num_dst_channels == 4{
			// Copy R to GB
			if num_src_channels == 1 { 
				for pix in 0..<num_pixels{ 
					
					r_channel_offset : int = (pix * dst_bytes_per_pixel) + value_byte_size * 0
					g_channel_offset : int = (pix * dst_bytes_per_pixel) + value_byte_size * 1
					b_channel_offset : int = (pix * dst_bytes_per_pixel) + value_byte_size * 2
					mem.copy(&dst_pixels_as_bytes[g_channel_offset], &dst_pixels_as_bytes[r_channel_offset], value_byte_size) // dst R to dst G channel
					mem.copy(&dst_pixels_as_bytes[b_channel_offset], &dst_pixels_as_bytes[r_channel_offset], value_byte_size) // dst R to dst B channel
				}
			}
			// in case that num_src_channels == 2 or 3 we dont have to copy anything.
		}

		// Fill alpha channel with opaque value
		if num_dst_channels == 4 && num_src_channels < 4{
			switch dst_format_type {
			case .INVLAID:	// invalid codepath
			case .UNORM_8:
				for pix in 0..<num_pixels {
					dst_pixels_as_u8[(pix * num_dst_channels) + 3] = u8(c.UINT8_MAX)
				}
			case .UNORM_16: 
				for pix in 0..<num_pixels {
					dst_pixels_as_u16[(pix * num_dst_channels) + 3] = u16(c.UINT16_MAX)
				}
			case .F_16:	
				for pix in 0..<num_pixels {
					dst_pixels_as_f16[(pix * num_dst_channels) + 3] = f16(1.0)
				}
			case .F_32:
				for pix in 0..<num_pixels {
					dst_pixels_as_f32[(pix * num_dst_channels) + 3] = f32(1.0)
				}
			}
		}
	}

	return out_pixels
}

//  @Note: We can perhaps do simd versions for some of these or at least
// make versions using odins array types so that the compiler may do some simd tricks where it can.


convert_u8_to_u16 :: proc "contextless" (v : u8) -> u16 {
	return cast(u16)(f32(v) / 255.0 * 65535.0)
}
convert_u8_to_f16 :: proc "contextless" (v : u8) -> f16 {
	return f16(v) / 255.0
}
convert_u8_to_f32 :: proc "contextless" (v : u8) -> f32 {
	return f32(v) / 255.0
}

convert_u16_to_u8 :: proc "contextless" (v : u16) -> u8 {
	return cast(u8)(f32(v) / 65535.0 * 255.0)
}
convert_u16_to_f16 :: proc "contextless" (v : u16) -> f16 {
	return cast(f16)(f32(v) / 65535.0)
}
convert_u16_to_f32 :: proc "contextless" (v : u16) -> f32 {
	return f32(v) / 65535.0
}

// @Note: we currently assume floating point values to be in 0..1 range. otherwise we would have to tonemap them.
convert_f16_to_f32 :: proc "contextless" (v : f16) -> f32 {
	return cast(f32)v
}
convert_f16_to_u16 :: proc "contextless" (v : f16) -> u16 {
	return cast(u16)clamp( f32(v) * 65535.0, 0.0, 65535.0)
}
convert_f16_to_u8 :: proc "contextless" (v : f16) -> u8 {
	return cast(u8)clamp( f32(v) * 255.0, 0.0, 255.0)
}

convert_f32_to_f16 :: proc "contextless" (v : f32) -> f16 {
	return cast(f16)v
}
convert_f32_to_u16 :: proc "contextless" (v : f32) -> u16 {
	return cast(u16)clamp(v * 65535.0, 0.0, 65535.0)
}
convert_f32_to_u8 :: proc "contextless" (v : f32) -> u8 {
	return cast(u8)clamp(v * 255.0, 0.0, 255.0)
}