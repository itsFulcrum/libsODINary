package shady

ParseFlags :: distinct bit_set[ParseFlag]
ParseFlag :: enum u32 {
    UnfoldIncludes = 0,    // Wheather to search for and unfold '#include "filename.glsl"' preprocessor statements.
    StripAlreadyIncluded,  // Wheather to omit already included files in the output. There is no reason not to do this unless for debugging maybe.
    GenerateHeaderguards,  // Wheather to generate headerguards based on filenames of include files automatically.
    ReplaceVersionString,  // Wheather to replace the glsl version string at the top of the file with someting else. 'version_str' in 'ParseInfo' must be set.
}

PARSE_FLAGS_DEFAULT :: ParseFlags{.UnfoldIncludes, .GenerateHeaderguards, .StripAlreadyIncluded}


ReadFile_CallbackSignature :: #type proc(filename: string, allocator := context.allocator) -> (data : []byte, ok : bool)

ParseInfo :: struct {
    parse_flags    : ParseFlags,                    // Required: Options for parsing.
    insert_defines : []string,                      // Optional: A set of macro keywords to be defined at the top. e.g. {"USE_ALPHA", "SAMPLE_COUNT 16"} will insert '#define USE_ALPHA' and '#define SAMPLE_COUNT 16' at the top of the file.
    version_str    : string,                        // Optional: A version string to replace the current version with. e.g. "450 core". '#version' directive must still be present in the source file. Ignored if 'ReplaceVersionString' flag is not set.
    read_file_proc : ReadFile_CallbackSignature,    // Optional: A procedure callback to read files from disk. If nill, defaults to procedures in the 'core:os' package.
    
    out_include_files: []string,                    // ReadOnly: List of filenames included during unfolding of '#include' directives. nil when '.UnfoldIncludes' flag is not set.
    out_error_string : string,                      // ReadOnly: Filled with an error message upon errors, duh. Allocated using context.temp_allocator.
}

SpirvCompileInfo :: struct {    
    shader_stage   : ShaderStage,
    spirv_version  : SpirvVersion,
    client_version : ClientVersion,

    glsl_src_filenames : []string,  // Optional: provide glsl source files for better error printing. 
    out_error_string : string,      // Readonly: Error string upon compilation failure. This Will Contain the Compile Error. Allocated using context.temp_allocator
}

ReflectInfo :: struct {
    shader_stage : ShaderStage,
    num_samplers : u32,
    num_uniform_buffers : u32,
    
    num_readonly_storage_textures  : u32,
    num_readwrite_storage_textures : u32, // WriteOnly AND ReadWrite

    num_readonly_storage_buffers   : u32,    
    num_readwrite_storage_buffers  : u32, // WriteOnly AND ReadWrite

    compute_threadcount : [3]u32,
}

// @Note: Matches with glsl.stage_t so one can do:  'cast(glsl.stage_t)ShaderStage.VERTEX'
ShaderStage :: enum u32 {
	VERTEX 			= 0,    // cast(u32)glslang.stage_t.STAGE_VERTEX,
    TESSCONTROL 	= 1,    // cast(u32)glslang.stage_t.STAGE_TESSCONTROL,
    TESSEVALUATION 	= 2,    // cast(u32)glslang.stage_t.STAGE_TESSEVALUATION,
    GEOMETRY 		= 3,    // cast(u32)glslang.stage_t.STAGE_GEOMETRY,
    FRAGMENT 		= 4,    // cast(u32)glslang.stage_t.STAGE_FRAGMENT,
    COMPUTE 		= 5,    // cast(u32)glslang.stage_t.STAGE_COMPUTE,
    RAYGEN 			= 6,    // cast(u32)glslang.stage_t.STAGE_RAYGEN,
    INTERSECT 		= 7,    // cast(u32)glslang.stage_t.STAGE_INTERSECT,
    ANYHIT     		= 8,    // cast(u32)glslang.stage_t.STAGE_ANYHIT,
    CLOSESTHIT 		= 9,    // cast(u32)glslang.stage_t.STAGE_CLOSESTHIT,
    MISS 			= 10,   // cast(u32)glslang.stage_t.STAGE_MISS,
    CALLABLE 		= 11,   // cast(u32)glslang.stage_t.STAGE_CALLABLE,
    TASK 			= 12,   // cast(u32)glslang.stage_t.STAGE_TASK,
    MESH 			= 13,   // cast(u32)glslang.stage_t.STAGE_MESH,
    COUNT			,       // cast(u32)glslang.stage_t.STAGE_COUNT,
}

// @Note: Matches with glslang.target_language_version_t so one can do:  'cast( glslang.target_language_version_t)SpirvVersion.SPV_1_3'
SpirvVersion :: enum u32 {
    SPV_1_0 = (1 << 16),            // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_0,
    SPV_1_1 = (1 << 16) | (1 << 8), // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_1,
    SPV_1_2 = (1 << 16) | (2 << 8), // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_2,
    SPV_1_3 = (1 << 16) | (3 << 8), // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_3,
    SPV_1_4 = (1 << 16) | (4 << 8), // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_4,
    SPV_1_5 = (1 << 16) | (5 << 8), // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_5,
    SPV_1_6 = (1 << 16) | (6 << 8), // cast(u32)glslang.target_language_version_t.TARGET_SPV_1_6,
   	COUNT   = 7,                    // cast(u32)glslang.target_language_version_t.TARGET_LANGUAGE_VERSION_COUNT,
}

// @Note: Matches with glslang.target_client_version_t so one can do:  'cast(glslang.target_client_version_t)ClientVersion.VULKAN_1_2'
ClientVersion :: enum u32 {
    VULKAN_1_0 	= (1 << 22),                // cast(u32)glslang.target_client_version_t.TARGET_VULKAN_1_0,
    VULKAN_1_1 	= (1 << 22) | (1 << 12),    // cast(u32)glslang.target_client_version_t.TARGET_VULKAN_1_1,
    VULKAN_1_2 	= (1 << 22) | (2 << 12),    // cast(u32)glslang.target_client_version_t.TARGET_VULKAN_1_2,
    VULKAN_1_3 	= (1 << 22) | (3 << 12),    // cast(u32)glslang.target_client_version_t.TARGET_VULKAN_1_3,
    VULKAN_1_4 	= (1 << 22) | (4 << 12),    // cast(u32)glslang.target_client_version_t.TARGET_VULKAN_1_4,
    OPENGL_450 	= 450,                      // cast(u32)glslang.target_client_version_t.TARGET_OPENGL_450,
    COUNT 		= 6,                        // cast(u32)glslang.target_client_version_t.TARGET_CLIENT_VERSION_COUNT,
}