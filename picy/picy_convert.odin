package picy

import "core:mem"

FormatType :: enum {
	INVLAID = 0,
	UNORM_8 ,
	UNORM_16,
	F_16,
	F_32,
}

get_FormatType_from_PicFormat :: proc(format : PicFormat) -> FormatType {
	switch format {
		case .NONE			: return .INVLAID;
		
		case .R8_UNORM		: return .UNORM_8;
		case .RG8_UNORM		: return .UNORM_8;
		case .RGB8_UNORM	: return .UNORM_8;
		case .RGBA8_UNORM	: return .UNORM_8;

		case .R16_UNORM		: return .UNORM_16;		  	
		case .RG16_UNORM	: return .UNORM_16;	  	
		case .RGB16_UNORM	: return .UNORM_16; 			 
		case .RGBA16_UNORM	: return .UNORM_16;

		case .R16_F			: return .F_16;
		case .RG16_F		: return .F_16;
		case .RGB16_F		: return .F_16;
		case .RGBA16_F		: return .F_16;
		
		case .R32_F			: return .F_32;
		case .RG32_F		: return .F_32;
		case .RGB32_F		: return .F_32;
		case .RGBA32_F		: return .F_32;
	}

	panic("invalid codepath");
}


// TODO: Unfinished
convert_format :: proc(pixels : []byte, src_format : PicFormat, width : u32, height : u32, dst_format : PicFormat, allocator := context.allocator) -> []byte {

	assert(pixels != nil);
	assert(src_format != .NONE);
	assert(dst_format != .NONE);
	assert(width > 0);
	assert(height > 0);

	dst_byte_size  := calc_bytes_for_img(width, height, dst_format);
	out_pixels := make_slice([]byte, cast(int)dst_byte_size, allocator);
	
	if src_format == dst_format {
		mem.copy(&out_pixels, raw_data(pixels), cast(int)dst_byte_size);
		return out_pixels;
	}

	num_src_channels := get_num_channels_from_format(src_format);
	num_dst_channels := get_num_channels_from_format(dst_format);

	src_format_type := get_FormatType_from_PicFormat(src_format);
	dst_format_type := get_FormatType_from_PicFormat(dst_format);

	assert(src_format_type != .INVLAID);
	assert(dst_format_type != .INVLAID);

	src_pixels_bytes : [^]byte = cast([^]byte)raw_data(pixels);

	if num_src_channels == num_dst_channels {

		assert(src_format_type != dst_format_type); // Already handled the case where src_format == dst_format.

		num_values : u32 = width * height * num_src_channels;

		src_pixels_u8  : [^]u8  = cast([^]u8) src_pixels_bytes;
		src_pixels_u16 : [^]u16 = cast([^]u16)src_pixels_bytes;
		src_pixels_f16 : [^]f16 = cast([^]f16)src_pixels_bytes;
		src_pixels_f32 : [^]f32 = cast([^]f32)src_pixels_bytes;

		dst_buffer_u8  : [^]u8  = cast([^]u8) raw_data(out_pixels);
		dst_buffer_u16 : [^]u16 = cast([^]u16)raw_data(out_pixels);
		dst_buffer_f16 : [^]f16 = cast([^]f16)raw_data(out_pixels);
		dst_buffer_f32 : [^]f32 = cast([^]f32)raw_data(out_pixels);

		switch src_format_type {
			case .INVLAID:	panic("Invalid Codepath");
			case .UNORM_8:				
				for i in 0..<num_values {
					switch dst_format_type {
						case .INVLAID:	// invalid codepath
						case .UNORM_8:  // invalid codepath
						case .UNORM_16: dst_buffer_u16[i] = #force_inline convert_u8_to_u16(src_pixels_u8[i]);
						case .F_16:		dst_buffer_f16[i] = #force_inline convert_u8_to_f16(src_pixels_u8[i]);
						case .F_32:		dst_buffer_f32[i] = #force_inline convert_u8_to_f32(src_pixels_u8[i]);
					}
				}
			case .UNORM_16:
				for i in 0..<num_values {
					switch dst_format_type {
						case .INVLAID:	// invalid codepath
						case .UNORM_8:	dst_buffer_u8[i]  = #force_inline convert_u16_to_u8(src_pixels_u16[i]);
						case .UNORM_16: // invalid codepath
						case .F_16:		dst_buffer_f16[i] = #force_inline convert_u16_to_f16(src_pixels_u16[i]);
						case .F_32:		dst_buffer_f32[i] = #force_inline convert_u16_to_f32(src_pixels_u16[i]);
					}
				}
			case .F_16:
				for i in 0..<num_values {
					switch dst_format_type {
						case .INVLAID:	// invalid codepath
						case .UNORM_8: 	dst_buffer_u8[i]  = #force_inline convert_f16_to_u8(src_pixels_f16[i]);
						case .UNORM_16:	dst_buffer_u16[i] = #force_inline convert_f16_to_u16(src_pixels_f16[i]);
						case .F_16: 	// invalid codepath
						case .F_32:		dst_buffer_f32[i] = #force_inline convert_f16_to_f32(src_pixels_f16[i]);
					}
				}
			case .F_32:
				for i in 0..<num_values {
					switch dst_format_type {
						case .INVLAID:	// invalid codepath
						case .UNORM_8:  dst_buffer_u8[i]  = #force_inline convert_f32_to_u8(src_pixels_f32[i]);
						case .UNORM_16:	dst_buffer_u16[i] = #force_inline convert_f32_to_u16(src_pixels_f32[i]);
						case .F_16:		dst_buffer_f16[i] = #force_inline convert_f32_to_f16(src_pixels_f32[i]);
						case .F_32: 	// invalid codepath
					}
				}
		}

		return out_pixels;
	}

	if src_format_type == dst_format_type {
		assert(num_src_channels != num_dst_channels);


	}

	return nil;
}

//  @Note: We can perhaps do simd versions for some of these or at least
// make versions using odins array types so that the compiler may do some simd tricks where it can.

convert_u8_to_u16 :: proc "contextless" (v : u8) -> u16 {
	return cast(u16)(f32(v) / 255.0 * 65535.0);
}
convert_u8_to_f16 :: proc "contextless" (v : u8) -> f16 {
	return f16(v) / 255.0;
}
convert_u8_to_f32 :: proc "contextless" (v : u8) -> f32 {
	return f32(v) / 255.0;
}

convert_u16_to_u8 :: proc "contextless" (v : u16) -> u8 {
	return cast(u8)(f32(v) / 65535.0 * 255.0);
}
convert_u16_to_f16 :: proc "contextless" (v : u16) -> f16 {
	return cast(f16)(f32(v) / 65535.0);
}
convert_u16_to_f32 :: proc "contextless" (v : u16) -> f32 {
	return f32(v) / 65535.0;
}

// @Note: we currently assume floating point values to be in 0..1 range. otherwise we would have to tonemap them.
convert_f16_to_f32 :: proc "contextless" (v : f16) -> f32 {
	return cast(f32)v;
}
convert_f16_to_u16 :: proc "contextless" (v : f16) -> u16 {
	return cast(u16)clamp( f32(v) * 65535.0, 0.0, 65535.0);
}
convert_f16_to_u8 :: proc "contextless" (v : f16) -> u8 {
	return cast(u8)clamp( f32(v) * 255.0, 0.0, 255.0);
}

convert_f32_to_f16 :: proc "contextless" (v : f32) -> f16 {
	return cast(f16)v;
}
convert_f32_to_u16 :: proc "contextless" (v : f32) -> u16 {
	return cast(u16)clamp(v * 65535.0, 0.0, 65535.0);
}
convert_f32_to_u8 :: proc "contextless" (v : f32) -> u8 {
	return cast(u8)clamp(v * 255.0, 0.0, 255.0);
}