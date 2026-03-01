package glslang

import "core:c"


// yes these are empty structs. 
// Apparently in the c++ code of glslang 
// they are just classes with methods but have no actual data. 
// Why? I dont know? Maybe i just dont understand it.
shader_t   :: struct {};
program_t  :: struct {};
mapper_t   :: struct {};
resolver_t :: struct {};

// /* Version counterpart */
version_t :: struct {
    major  : c.int,
    minor  : c.int,
    patch  : c.int,
    flavor : cstring,
}


// /* TLimits counterpart */
limits_t :: struct {
	non_inductive_for_loops 					: c.bool,
	while_loops 								: c.bool,
	do_while_loops 								: c.bool,
	general_uniform_indexing 					: c.bool,
	general_attribute_matrix_vector_indexing 	: c.bool,
	general_varying_indexing 					: c.bool,
	general_sampler_indexing 					: c.bool,
	general_variable_indexing					: c.bool,
	general_constant_matrix_vector_indexing 	: c.bool,
}

/* TBuiltInResource counterpart */
resource_t :: struct{
    max_lights										: c.int,
    max_clip_planes									: c.int,
    max_texture_units 								: c.int,
    max_texture_coords 								: c.int,
    max_vertex_attribs 								: c.int,
    max_vertex_uniform_components 					: c.int,
    max_varying_floats								: c.int,
    max_vertex_texture_image_units					: c.int,
    max_combined_texture_image_units				: c.int,
    max_texture_image_units 						: c.int,
    max_fragment_uniform_components					: c.int,
    max_draw_buffers 								: c.int,
    max_vertex_uniform_vectors 						: c.int,
    max_varying_vectors 							: c.int,
    max_fragment_uniform_vectors 					: c.int,
    max_vertex_output_vectors 						: c.int,
    max_fragment_input_vectors 						: c.int,
    min_program_texel_offset 						: c.int,
    max_program_texel_offset 						: c.int,
    max_clip_distances 								: c.int,
    max_compute_work_group_count_x 					: c.int,
    max_compute_work_group_count_y					: c.int,
    max_compute_work_group_count_z					: c.int,
    max_compute_work_group_size_x					: c.int,
    max_compute_work_group_size_y					: c.int,
    max_compute_work_group_size_z					: c.int,
    max_compute_uniform_components 					: c.int,
    max_compute_texture_image_units					: c.int,
    max_compute_image_uniforms 						: c.int,
    max_compute_atomic_counters						: c.int,
    max_compute_atomic_counter_buffers 				: c.int,
    max_varying_components 							: c.int,
    max_vertex_output_components 					: c.int,
    max_geometry_input_components 					: c.int,
    max_geometry_output_components 					: c.int,
    max_fragment_input_components					: c.int,
    max_image_units 								: c.int,
    max_combined_image_units_and_fragment_outputs 	: c.int,
    max_combined_shader_output_resources			: c.int,
    max_image_samples 								: c.int,
    max_vertex_image_uniforms 						: c.int,
    max_tess_control_image_uniforms 				: c.int,
    max_tess_evaluation_image_uniforms 				: c.int,
    max_geometry_image_uniforms						: c.int,
    max_fragment_image_uniforms						: c.int,
    max_combined_image_uniforms						: c.int,
    max_geometry_texture_image_units 				: c.int,
    max_geometry_output_vertices 					: c.int,
    max_geometry_total_output_components			: c.int,
    max_geometry_uniform_components					: c.int,
    max_geometry_varying_components					: c.int,
    max_tess_control_input_components 				: c.int,
    max_tess_control_output_components 				: c.int,
    max_tess_control_texture_image_units			: c.int,
    max_tess_control_uniform_components 			: c.int,
    max_tess_control_total_output_components		: c.int,
    max_tess_evaluation_input_components 			: c.int,
    max_tess_evaluation_output_components			: c.int,
    max_tess_evaluation_texture_image_units			: c.int,
    max_tess_evaluation_uniform_components 			: c.int,
    max_tess_patch_components 						: c.int,
    max_patch_vertices 								: c.int,
    max_tess_gen_level 								: c.int,
    max_viewports 									: c.int,
    max_vertex_atomic_counters 						: c.int,
    max_tess_control_atomic_counters				: c.int,
    max_tess_evaluation_atomic_counters 			: c.int,
    max_geometry_atomic_counters					: c.int,
    max_fragment_atomic_counters					: c.int,
    max_combined_atomic_counters					: c.int,
    max_atomic_counter_bindings 					: c.int,
    max_vertex_atomic_counter_buffers 				: c.int,
    max_tess_control_atomic_counter_buffers 		: c.int,
    max_tess_evaluation_atomic_counter_buffers		: c.int,
    max_geometry_atomic_counter_buffers				: c.int,
    max_fragment_atomic_counter_buffers				: c.int,
    max_combined_atomic_counter_buffers				: c.int,
    max_atomic_counter_buffer_size					: c.int,
    max_transform_feedback_buffers					: c.int,
    max_transform_feedback_interleaved_components 	: c.int,
    max_cull_distances 								: c.int,
    max_combined_clip_and_cull_distances			: c.int,
    max_samples 									: c.int,
    max_mesh_output_vertices_nv 					: c.int,
    max_mesh_output_primitives_nv 					: c.int,
    max_mesh_work_group_size_x_nv 					: c.int,
    max_mesh_work_group_size_y_nv 					: c.int,
    max_mesh_work_group_size_z_nv 					: c.int,
    max_task_work_group_size_x_nv 					: c.int,
    max_task_work_group_size_y_nv 					: c.int,
    max_task_work_group_size_z_nv 					: c.int,
    max_mesh_view_count_nv 							: c.int,
    max_mesh_output_vertices_ext 					: c.int,
    max_mesh_output_primitives_ext 					: c.int,
    max_mesh_work_group_size_x_ext 					: c.int,
    max_mesh_work_group_size_y_ext 					: c.int,
    max_mesh_work_group_size_z_ext 					: c.int,
    max_task_work_group_size_x_ext 					: c.int,
    max_task_work_group_size_y_ext 					: c.int,
    max_task_work_group_size_z_ext 					: c.int,
    max_mesh_view_count_ext 						: c.int,
    max_dual_source_draw_buffers_ext 				: c.int,

    // NOTE: not sure how to translate the below c code to odin but it seems its only used for backwards compatability anyway...
    // union {
    //     max_dual_source_draw_buffers_ext : i32,
    //     /* Incorrectly capitalized name retained for backward compatibility */
    //     maxDualSourceDrawBuffersEXT : i32,
    // },

    limits : limits_t,
}

/* Inclusion result structure allocated by C include_local/include_system callbacks */
include_result_t :: struct {
    /* Header file name or NULL if inclusion failed */
    header_name : cstring,

    /* Header contents or NULL */
    header_data : cstring,
    
    header_length : c.size_t,
}

/* Callback for local file inclusion */
//typedef glsl_include_result_t* (*glsl_include_local_func)(void* ctx, const char* header_name, const char* includer_name, size_t include_depth);
include_local_func :: #type proc "c" (ctx : rawptr, header_name : cstring, includer_name : cstring, include_depth : c.size_t) -> ^include_result_t

/* Callback for system file inclusion */
//typedef glsl_include_result_t* (*glsl_include_system_func)(void* ctx, const char* header_name, const char* includer_name, size_t include_depth);
include_system_func :: #type proc "c" (ctx : rawptr, header_name : cstring, includer_name : cstring, include_depth : c.size_t) -> ^include_result_t

/* Callback for include result destruction */
//typedef int (*glsl_free_include_result_func)(void* ctx, glsl_include_result_t* result);
free_include_result_func :: #type proc "c" (ctx : rawptr, result : ^include_result_t ) -> c.int


/* Collection of callbacks for GLSL preprocessor */
include_callbacks_t :: struct {
    include_system : include_system_func,
    include_local : include_local_func,
    free_include_result : free_include_result_func,
}

input_t :: struct {
    language 	: source_t,
    stage 		: stage_t,
    client 		: client_t,
    client_version  : target_client_version_t,
    target_language : target_language_t,
    target_language_version : target_language_version_t,
    
    /** Shader source code */
    code : cstring,
    default_version : c.int,
    default_profile : profile_t,
    
    force_default_version_and_profile: c.int,
    forward_compatible : c.int,
    messages : messages_t,
    
    resource : ^resource_t,
    
    callbacks : include_callbacks_t,
    
    callbacks_ctx : rawptr,
}

/* SpvOptions counterpart */
spv_options_t :: struct {
    generate_debug_info 					: c.bool,
    strip_debug_info						: c.bool,
    disable_optimizer						: c.bool,
    optimize_size							: c.bool,
    disassemble								: c.bool,
    validate								: c.bool,
    emit_nonsemantic_shader_debug_info		: c.bool,
    emit_nonsemantic_shader_debug_source	: c.bool,
    compile_only							: c.bool,
    optimize_allow_expanded_id_bound		: c.bool,
}