package glslang

import "core:c"


@(default_calling_convention = "c")
foreign lib_glslang { 

@(link_name = "glslang_get_version")
get_version :: proc(version : ^version_t) ---;

@(link_name = "glslang_initialize_process")
initialize_process :: proc() -> c.int ---;

@(link_name = "glslang_finalize_process")
finalize_process :: proc() ---;


@(link_name = "glslang_shader_create")
shader_create :: proc(input : ^input_t) -> ^shader_t ---;
@(link_name = "glslang_shader_delete")
shader_delete :: proc(shader : ^shader_t) ---;

@(link_name = "glslang_shader_set_preamble")
shader_set_preamble :: proc(shader : ^shader_t, s : cstring) ---;
@(link_name = "glslang_shader_shift_binding")
shader_shift_binding :: proc(shader : ^shader_t, resource_type : resource_type_t, base : c.uint ) ---;
@(link_name = "glslang_shader_shift_binding_for_set")
shader_shift_binding_for_set :: proc(shader : ^shader_t, resource_type : resource_type_t, base : c.uint , set : c.uint) ---;
@(link_name = "glslang_shader_set_options")
shader_set_options :: proc(shader : ^shader_t, options : c.int) ---; // glslang_shader_options_t
@(link_name = "glslang_shader_set_glsl_version")
shader_set_glsl_version :: proc(shader : ^shader_t, version : c.int) ---;
@(link_name = "glslang_shader_set_default_uniform_block_set_and_binding")
shader_set_default_uniform_block_set_and_binding :: proc(shader : ^shader_t, set : c.uint, binding : c.uint) ---;
@(link_name = "glslang_shader_set_default_uniform_block_name")
shader_set_default_uniform_block_name :: proc(shader : ^shader_t, name : cstring) ---;

// NOTE: weird c syntax here not sure if 'bindings : [^]cstring' is correct odin equivalent to 'const char *const *bindings' ??
//GLSLANG_EXPORT void glslang_shader_set_resource_set_binding(glslang_shader_t* shader, const char *const *bindings, unsigned int num_bindings);
@(link_name = "glslang_shader_set_resource_set_binding")
shader_set_resource_set_binding :: proc(shader : ^shader_t, bindings : [^]cstring,  num_bindings : c.uint) ---;

@(link_name = "glslang_shader_preprocess")
shader_preprocess :: proc(shader : ^shader_t, input : ^input_t) -> c.int ---;
@(link_name = "glslang_shader_parse")
shader_parse :: proc(shader : ^shader_t, input : ^input_t) -> c.int ---;
@(link_name = "glslang_shader_get_preprocessed_code")
shader_get_preprocessed_code :: proc(shader : ^shader_t) -> cstring ---;
@(link_name = "glslang_shader_set_preprocessed_code")
shader_set_preprocessed_code :: proc(shader : ^shader_t, src_code : cstring) ---;
@(link_name = "glslang_shader_get_info_log")
shader_get_info_log :: proc(shader : ^shader_t) -> cstring ---;
@(link_name = "glslang_shader_get_info_debug_log")
shader_get_info_debug_log :: proc(shader : ^shader_t) -> cstring ---;


@(link_name = "glslang_program_create")
program_create :: proc() -> ^program_t ---;

@(link_name = "glslang_program_delete")
program_delete :: proc(program : ^program_t) ---;

@(link_name = "glslang_program_add_shader")
program_add_shader :: proc(program : ^program_t, shader : ^shader_t) ---;


@(link_name = "glslang_program_link")
program_link :: proc(program : ^program_t, messages : c.int) -> c.int ---; // glslang_messages_t
@(link_name = "glslang_program_add_source_text")
program_add_source_text :: proc(program : ^program_t, stage : stage_t, text : cstring, len : c.size_t) ---;
@(link_name = "glslang_program_set_source_file")
program_set_source_file :: proc(program : ^program_t, stage : stage_t, file : cstring) ---;
@(link_name = "glslang_program_map_io")
program_map_io :: proc(program : ^program_t) -> c.int ---;
@(link_name = "glslang_program_map_io_with_resolver_and_mapper")
program_map_io_with_resolver_and_mapper :: proc(program : ^program_t, resolver : ^resolver_t, mapper : ^mapper_t) -> c.int ---;
@(link_name = "glslang_program_SPIRV_generate")
program_SPIRV_generate :: proc(program : ^program_t, stage : stage_t) ---;
@(link_name = "glslang_program_SPIRV_generate_with_options")
program_SPIRV_generate_with_options :: proc(program : ^program_t, stage : stage_t, spv_options : ^spv_options_t) ---;
@(link_name = "glslang_program_SPIRV_get_size")
program_SPIRV_get_size :: proc(program : ^program_t) -> c.size_t ---;
@(link_name = "glslang_program_SPIRV_get")
program_SPIRV_get :: proc(program : ^program_t, x : ^c.uint) ---; // no name specified for uint*
@(link_name = "glslang_program_SPIRV_get_ptr")
program_SPIRV_get_ptr :: proc(program : ^program_t) -> ^c.uint ---;
@(link_name = "glslang_program_SPIRV_get_messages")
program_SPIRV_get_messages :: proc(program : ^program_t) -> cstring ---;
@(link_name = "glslang_program_get_info_log")
program_get_info_log :: proc(program : ^program_t) -> cstring ---;
@(link_name = "glslang_program_get_info_debug_log")
program_get_info_debug_log :: proc(program : ^program_t) -> cstring ---;


@(link_name = "glslang_glsl_mapper_create")
glsl_mapper_create :: proc() -> ^mapper_t ---;
@(link_name = "glslang_glsl_mapper_delete")
glsl_mapper_delete :: proc(mapper : ^mapper_t) ---;

@(link_name = "glslang_glsl_resolver_create")
glsl_resolver_create :: proc(program : ^program_t, stage : stage_t) -> ^resolver_t ---;
@(link_name = "glslang_glsl_resolver_delete")
glsl_resolver_delete :: proc(resolver : ^resolver_t) ---;


// ===========================================
// glslang_default_resource_limits

// Returns a struct that can be use to create custom resource values.
@(link_name = "glslang_resource")
resource :: proc() -> ^resource_t ---

// These are the default resources for TBuiltInResources, used for both
//  - parsing this string for the case where the user didn't supply one,
//  - dumping out a template for user construction of a config file.
@(link_name = "glslang_default_resource")
default_resource :: proc() -> ^resource_t ---

// Returns the DefaultTBuiltInResource as a human-readable string.
// NOTE: User is responsible for freeing this string.
@(link_name = "glslang_default_resource_string")
default_resource_string :: proc() -> cstring ---

// Decodes the resource limits from |config| to |resources|.
@(link_name = "glslang_decode_resource_limits")
decode_resource_limits :: proc( resources : ^resource_t, config : cstring) ---
}