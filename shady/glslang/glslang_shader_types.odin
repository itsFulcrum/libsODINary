package glslang

/* EShLanguage counterpart */
stage_t :: enum u32 {
    STAGE_VERTEX 			= 0,
    STAGE_TESSCONTROL 		= 1,
    STAGE_TESSEVALUATION 	= 2,
    STAGE_GEOMETRY 			= 3,
    STAGE_FRAGMENT 			= 4,
    STAGE_COMPUTE 			= 5,
    STAGE_RAYGEN 			= 6,
    STAGE_RAYGEN_NV 		= 6,
    STAGE_INTERSECT 		= 7,
    STAGE_INTERSECT_NV 		= 7,
    STAGE_ANYHIT     		= 8,
    STAGE_ANYHIT_NV  		= 8,
    STAGE_CLOSESTHIT 		= 9,
    STAGE_CLOSESTHIT_NV 	= 9,
    STAGE_MISS 				= 10,
    STAGE_MISS_NV 			= 10,
    STAGE_CALLABLE 			= 11,
    STAGE_CALLABLE_NV  		= 11,
    STAGE_TASK 				= 12,
    STAGE_TASK_NV 			= 12,
    STAGE_MESH 				= 13,
    STAGE_MESH_NV 			= 13,
    STAGE_COUNT,
}

/* EShLanguageMask counterpart */
stage_mask_t :: enum u32 {
    STAGE_VERTEX_MASK 			= 1 , 	//(1 << glslang_stage_t.GLSLANG_STAGE_VERTEX),
    STAGE_TESSCONTROL_MASK 		= 2 , 	//(1 << glslang_stage_t.GLSLANG_STAGE_TESSCONTROL),
    STAGE_TESSEVALUATION_MASK 	= 4 , 	//(1 << glslang_stage_t.GLSLANG_STAGE_TESSEVALUATION),
    STAGE_GEOMETRY_MASK 		= 8 , 	//(1 << glslang_stage_t.GLSLANG_STAGE_GEOMETRY),
    STAGE_FRAGMENT_MASK 		= 16, 	//(1 << glslang_stage_t.GLSLANG_STAGE_FRAGMENT),
    STAGE_COMPUTE_MASK 			= 32, 	//(1 << glslang_stage_t.GLSLANG_STAGE_COMPUTE),
    STAGE_RAYGEN_MASK 			= 64, 	//(1 << glslang_stage_t.GLSLANG_STAGE_RAYGEN),
    STAGE_RAYGEN_NV_MASK 		= 64, 	//glslang_stage_t.GLSLANG_STAGE_RAYGEN_MASK,
    STAGE_INTERSECT_MASK 		= 128, 	//(1 << glslang_stage_t.GLSLANG_STAGE_INTERSECT),
    STAGE_INTERSECT_NV_MASK 	= 128, 	//glslang_stage_t.GLSLANG_STAGE_INTERSECT_MASK,
    STAGE_ANYHIT_MASK 			= 256, 	//(1 << glslang_stage_t.GLSLANG_STAGE_ANYHIT),
    STAGE_ANYHIT_NV_MASK 		= 256, 	//glslang_stage_t.GLSLANG_STAGE_ANYHIT_MASK,
    STAGE_CLOSESTHIT_MASK 		= 512, 	//(1 << glslang_stage_t.GLSLANG_STAGE_CLOSESTHIT),
    STAGE_CLOSESTHIT_NV_MASK 	= 512, 	//glslang_stage_t.GLSLANG_STAGE_CLOSESTHIT_MASK,
    STAGE_MISS_MASK 			= 1024, //(1 << glslang_stage_t.GLSLANG_STAGE_MISS),
    STAGE_MISS_NV_MASK 			= 1024, //glslang_stage_t.GLSLANG_STAGE_MISS_MASK,
    STAGE_CALLABLE_MASK 		= 2048, //(1 << glslang_stage_t.GLSLANG_STAGE_CALLABLE),
    STAGE_CALLABLE_NV_MASK 		= 2048, //glslang_stage_t.GLSLANG_STAGE_CALLABLE_MASK,
    STAGE_TASK_MASK 			= 4096, //(1 << glslang_stage_t.GLSLANG_STAGE_TASK),
    STAGE_TASK_NV_MASK 			= 4096, //glslang_stage_t.GLSLANG_STAGE_TASK_MASK,
    STAGE_MESH_MASK 			= 8192, //(1 << glslang_stage_t.GLSLANG_STAGE_MESH),
    STAGE_MESH_NV_MASK 			= 8192, //glslang_stage_t.GLSLANG_STAGE_MESH_MASK,
    STAGE_MASK_COUNT = 8193,
}

/* EShSource counterpart */
source_t :: enum u32 {
    SOURCE_NONE,
    SOURCE_GLSL,
    SOURCE_HLSL,
    SOURCE_COUNT,
}

/* EShClient counterpart */
client_t :: enum u32 {
    CLIENT_NONE,
    CLIENT_VULKAN,
    CLIENT_OPENGL,
    CLIENT_COUNT,
}

/* EShTargetLanguage counterpart */
target_language_t :: enum u32 {
    TARGET_NONE,
    TARGET_SPV,
    TARGET_COUNT,
}

/* SH_TARGET_ClientVersion counterpart */
target_client_version_t :: enum u32 {
    TARGET_VULKAN_1_0 = (1 << 22),
    TARGET_VULKAN_1_1 = (1 << 22) | (1 << 12),
    TARGET_VULKAN_1_2 = (1 << 22) | (2 << 12),
    TARGET_VULKAN_1_3 = (1 << 22) | (3 << 12),
    TARGET_VULKAN_1_4 = (1 << 22) | (4 << 12),
    TARGET_OPENGL_450 = 450,
    TARGET_CLIENT_VERSION_COUNT = 6,
}

/* SH_TARGET_LanguageVersion counterpart */
target_language_version_t :: enum u32 {
    TARGET_SPV_1_0 = (1 << 16),
    TARGET_SPV_1_1 = (1 << 16) | (1 << 8),
    TARGET_SPV_1_2 = (1 << 16) | (2 << 8),
    TARGET_SPV_1_3 = (1 << 16) | (3 << 8),
    TARGET_SPV_1_4 = (1 << 16) | (4 << 8),
    TARGET_SPV_1_5 = (1 << 16) | (5 << 8),
    TARGET_SPV_1_6 = (1 << 16) | (6 << 8),
   	TARGET_LANGUAGE_VERSION_COUNT = 7,
}

/* EShExecutable counterpart */
executable_t :: enum u32 { 
	EX_VERTEX_FRAGMENT, 
	EX_FRAGMENT 
}

// EShOptimizationLevel counterpart
// This enum is not used in the current C interface, but could be added at a later date.
// GLSLANG_OPT_NONE is the current default.
optimization_level_t :: enum u32 {
    OPT_NO_GENERATION,
    OPT_NONE,
    OPT_SIMPLE,
    OPT_FULL,
    OPT_LEVEL_COUNT,
}

/* EShTextureSamplerTransformMode counterpart */
texture_sampler_transform_mode_t :: enum u32 {
    TEX_SAMP_TRANS_KEEP,
    TEX_SAMP_TRANS_UPGRADE_TEXTURE_REMOVE_SAMPLER,
    TEX_SAMP_TRANS_COUNT,
}

/* EShMessages counterpart */
messages_t :: enum u32 {
    MSG_DEFAULT_BIT                 = 0,
    MSG_RELAXED_ERRORS_BIT          = (1 << 0),
    MSG_SUPPRESS_WARNINGS_BIT       = (1 << 1),
    MSG_AST_BIT                     = (1 << 2),
    MSG_SPV_RULES_BIT               = (1 << 3),
    MSG_VULKAN_RULES_BIT            = (1 << 4),
    MSG_ONLY_PREPROCESSOR_BIT       = (1 << 5),
    MSG_READ_HLSL_BIT               = (1 << 6),
    MSG_CASCADING_ERRORS_BIT        = (1 << 7),
    MSG_KEEP_UNCALLED_BIT           = (1 << 8),
    MSG_HLSL_OFFSETS_BIT            = (1 << 9),
    MSG_DEBUG_INFO_BIT              = (1 << 10),
    MSG_HLSL_ENABLE_16BIT_TYPES_BIT = (1 << 11),
    MSG_HLSL_LEGALIZATION_BIT       = (1 << 12),
    MSG_HLSL_DX9_COMPATIBLE_BIT     = (1 << 13),
    MSG_BUILTIN_SYMBOL_TABLE_BIT    = (1 << 14),
    MSG_ENHANCED                    = (1 << 15),
    MSG_ABSOLUTE_PATH               = (1 << 16),
    MSG_DISPLAY_ERROR_COLUMN        = (1 << 17),
    MSG_LINK_TIME_OPTIMIZATION_BIT  = (1 << 18),
    MSG_VALIDATE_CROSS_STAGE_IO_BIT = (1 << 19),
    MSG_COUNT,
}

/* EShReflectionOptions counterpart */
reflection_options_t :: enum u32 {
    REFLECTION_DEFAULT_BIT 				= 0,
    REFLECTION_STRICT_ARRAY_SUFFIX_BIT 	= (1 << 0),
    REFLECTION_BASIC_ARRAY_SUFFIX_BIT 	= (1 << 1),
    REFLECTION_INTERMEDIATE_IOO_BIT 	= (1 << 2),
    REFLECTION_SEPARATE_BUFFERS_BIT 	= (1 << 3),
    REFLECTION_ALL_BLOCK_VARIABLES_BIT 	= (1 << 4),
    REFLECTION_UNWRAP_IO_BLOCKS_BIT 	= (1 << 5),
    REFLECTION_ALL_IO_VARIABLES_BIT 	= (1 << 6),
    REFLECTION_SHARED_STD140_SSBO_BIT 	= (1 << 7),
    REFLECTION_SHARED_STD140_UBO_BIT 	= (1 << 8),
    REFLECTION_COUNT,
}

/* EProfile counterpart (from Versions.h) */
profile_t :: enum u32 {
    BAD_PROFILE 			= 0,
    NO_PROFILE 				= (1 << 0),
    CORE_PROFILE 			= (1 << 1),
    COMPATIBILITY_PROFILE 	= (1 << 2),
    ES_PROFILE 				= (1 << 3),
    PROFILE_COUNT,
}

/* Shader options */
shader_options_t :: enum u32 {
    SHADER_DEFAULT_BIT 			= 0,
    SHADER_AUTO_MAP_BINDINGS 	= (1 << 0),
    SHADER_AUTO_MAP_LOCATIONS 	= (1 << 1),
    SHADER_VULKAN_RULES_RELAXED = (1 << 2),
    SHADER_COUNT,
}

/* TResourceType counterpart */
resource_type_t :: enum u32 {
    RESOURCE_TYPE_SAMPLER,
    RESOURCE_TYPE_TEXTURE,
    RESOURCE_TYPE_IMAGE,
    RESOURCE_TYPE_UBO,
    RESOURCE_TYPE_SSBO,
    RESOURCE_TYPE_UAV,
 	RESOURCE_TYPE_COUNT,
}