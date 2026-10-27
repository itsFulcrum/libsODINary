package picy

import sdl "vendor:sdl3"

format_to_sdl_GPUTextureFormat :: proc(picy_format : Format) -> sdl.GPUTextureFormat {

	switch picy_format {
	case .NONE			: return sdl.GPUTextureFormat.INVALID // undefined
	
	case .R8_UNORM		: return sdl.GPUTextureFormat.R8_UNORM       		// 1 component 8 bit: unsigned normalized
	case .RG8_UNORM		: return sdl.GPUTextureFormat.R8G8_UNORM     		// 2 component 8 bit: unsigned normalized
	case .RGB8_UNORM	: return sdl.GPUTextureFormat.INVALID        		// invalid
	case .RGBA8_UNORM	: return sdl.GPUTextureFormat.R8G8B8A8_UNORM 		// 4 component 8 bit: unsigned normalized

	case .R16_UNORM		: return sdl.GPUTextureFormat.R16_UNORM 		  	// 1 component 16 bit: unsigned normalized
	case .RG16_UNORM	: return sdl.GPUTextureFormat.R16G16_UNORM 	  		// 2 component 16 bit: unsigned normalized
	case .RGB16_UNORM	: return sdl.GPUTextureFormat.INVALID 			  	// invalid
	case .RGBA16_UNORM	: return sdl.GPUTextureFormat.R16G16B16A16_UNORM 	// 4 component 16 bit: unsigned normalized

	case .R16_F			: return sdl.GPUTextureFormat.R16_FLOAT  			// 1 component 16 bit: singed half float (16bit)
	case .RG16_F		: return sdl.GPUTextureFormat.R16G16_FLOAT 			// 2 component 16 bit: singed half float (16bit)
	case .RGB16_F		: return sdl.GPUTextureFormat.INVALID 				// invalid
	case .RGBA16_F		: return sdl.GPUTextureFormat.R16G16B16A16_FLOAT 	// 4 component 16 bit: singed half float (16bit)
	
	case .R32_F			: return sdl.GPUTextureFormat.R32_FLOAT 			// 1 component 32 bit: signed float (32bit)
	case .RG32_F		: return sdl.GPUTextureFormat.R32G32_FLOAT 			// 2 component 32 bit: signed float (32bit)
	case .RGB32_F		: return sdl.GPUTextureFormat.INVALID 				// invalid
	case .RGBA32_F		: return sdl.GPUTextureFormat.R32G32B32A32_FLOAT 	// 4 component 32 bit: signed float (32bit)
	}

	return sdl.GPUTextureFormat.INVALID // undefined
}