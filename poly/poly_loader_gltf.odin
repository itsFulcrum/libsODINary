package poly

import "core:log"
import "core:strings"
import "core:fmt"
import "core:path/filepath"
import "core:os"
import "core:mem"
import "base:runtime"
import "core:math"
import "core:math/linalg"

import "vendor:cgltf"


// TODOS:
// - calculate missing normals
// - calculate tangents properly.. / @Note there is an odin package that can to MikkT calculation..
// - when loading meshes which were split by material, we need to generate unique mesh names... meh

load_gltf_from_path :: proc(path: string, load_flags : LoadFlags = LOAD_FLAGS_DEFAULT) -> (scene : ^SceneData, ok : bool) {
		
	log_errors : bool = .LogErrors in load_flags;	

	path_clean, alloc_error := filepath.clean(path, context.temp_allocator);
	path_clean_cstr := strings.clone_to_cstring(path_clean, context.temp_allocator);

	if alloc_error != runtime.Allocator_Error.None {
		if log_errors do log.errorf("Poly: Failed to load model: {}, runetime allocation error", path_clean);
		return nil, false;
	}

	if !os.exists(path_clean) || !os.is_file(path_clean) {
		if log_errors do log.errorf("Poly: Failed to load model, path does not point to a valid file: {}", path_clean);
		return nil, false;
	}

	parse_options := cgltf.options {
		type = cgltf.file_type.invalid, // Auto detect
	}

	gltf_data , result := cgltf.parse_file(parse_options, path_clean_cstr);

	defer if gltf_data != nil {
		cgltf.free(gltf_data);
	}

	if result != cgltf.result.success {
		if log_errors do log.errorf("Poly: Failed parse gltf file: {}, error code: {}", result);
		return nil, false;
	}

	result = cgltf.load_buffers(parse_options, gltf_data, path_clean_cstr);

	if result != cgltf.result.success {
		if log_errors do log.errorf("Poly: Cgltf failed to load buffers: {}, error code: {}", result);
		return nil, false;
	}

	result = cgltf.validate(gltf_data);

	if result != cgltf.result.success {
		if log_errors do log.errorf("Poly: Cgltf validation failed: {}, error code: {}", result);
		return nil, false;
	}

    scene_data : ^SceneData = new(SceneData);
    scene_data.filename = strings.clone(path_clean, context.allocator);

    load_cgltf_data_into_poly_scene(gltf_data, scene_data, load_flags);

    return scene_data, true;
}

@(private="file")
load_cgltf_data_into_poly_scene :: proc(data : ^cgltf.data, scene : ^SceneData, load_flags : LoadFlags){

	assert(data != nil);
	assert(scene != nil);

	// TODO: stack allocating materials is prob NOT good idea!
	if .LoadMaterials in load_flags {

		if data.materials != nil {

			scene.materials = make_dynamic_array_len([dynamic]MaterialData, len(data.materials), context.allocator);
			for &mat, mat_index in data.materials {

				material_data_init_default(&scene.materials[mat_index]);
				load_cgltf_material_to_material_data(&mat, &scene.materials[mat_index]);
			}
		}
	}

	if data.nodes != nil {
		for &node in data.nodes {
			load_cgltf_node_into_poly_scene(data, scene, load_flags, &node);
		}
	}
}

@(private="file")
load_cgltf_node_into_poly_scene :: proc(data : ^cgltf.data, scene : ^SceneData, load_flags : LoadFlags, node : ^cgltf.node){

	log_errors : bool = .LogErrors in load_flags;
	flatten_transforms : bool = true;

	node_transform := get_cgltf_node_transforms(node, flatten_transforms);

	if node.light != nil && .LoadLights in load_flags {
		
		light_data , light_ok := load_cgltf_light(node.light, node_transform);

		if light_ok {
			append(&scene.lights, light_data);
		}
	}

	if node.mesh != nil {

		if node.mesh.primitives != nil {

			for &primitve, index in node.mesh.primitives {

				// @Note:
				// We want to make sure as best as possible to output unique names.
				// if we need to split up meshes by material we will give each a index suffix. 
				// this is not a uniqueness gurantee per se but blender for example takes care that 
				// mesh names are unique already so adding suffixes to those should normally not cause 
				// clashes unless u provoke it.

				mesh_name : string = strings.clone_from_cstring(node.mesh.name, context.temp_allocator);

				if index > 0 {
					mesh_name = fmt.aprintf("{}_{}", mesh_name, index, allocator = context.temp_allocator);
				}

				mesh_data , mesh_data_ok := load_cgltf_primitve(data, &primitve, node_transform, mesh_name, load_flags);
				if mesh_data_ok {
					append(&scene.meshes, mesh_data);
				}
			}
		}
	}

}

@(private="file")
get_cgltf_node_transforms :: proc(node : ^cgltf.node, flatten_parent_hierarchy : bool) -> TransformData{
	assert(node != nil);

	transform : TransformData = transform_data_get_identity();

	if node.has_translation {
		transform.position = node.translation;
	}

	if node.has_scale {
		transform.scale = node.scale;
	}

	if node.has_rotation {
		transform.orientation = quaternion(x = node.rotation.x, y = node.rotation.y, z = node.rotation.z, w = node.rotation.w);
	}
	
	if flatten_parent_hierarchy && node.parent != nil {
		parent_transform := get_cgltf_node_transforms(node.parent, flatten_parent_hierarchy);
		transform = transform_data_transform_child_by_parent(transform, parent_transform);
	}

	return transform;
}


@(private="file")
load_cgltf_light :: proc(gltf_light : ^cgltf.light, node_transform : TransformData) -> (light : LightData, ok : bool) {

	assert(gltf_light != nil);

	if gltf_light.type == cgltf.light_type.invalid {
		return light, false;
	}

	light.name 		= strings.clone_from_cstring(gltf_light.name, context.allocator);
	light.color 	= gltf_light.color;
	light.intensity = gltf_light.intensity;
	
	switch gltf_light.type {
		case .invalid: panic("Invalid Codepath");
		case .directional: 	light.type = .DIRECTIONAL;
		case .point: 		light.type = .POINT;
		case .spot: 		light.type = .SPOT;
	}

	if light.type == .SPOT {
		light.spot_inner_cone_angle_radians = gltf_light.spot_inner_cone_angle;
		light.spot_outer_cone_angle_radians = gltf_light.spot_outer_cone_angle;
	}

	light.position    = node_transform.position;
	light.orientation = node_transform.orientation;

	return light, true;
}


// TODO: calc missing normals
// TODO: calc propper tangents.
// @Note: mesh_data.name is not set by this function because its not part of the primitve.
@(private="file")
load_cgltf_primitve :: proc(data : ^cgltf.data, primitive : ^cgltf.primitive, node_transform : TransformData, mesh_name : string, load_flags : LoadFlags) -> (mesh_data : MeshData, ok : bool) {

	assert(primitive != nil)

	ok = false;

	log_errors : bool = .LogErrors in load_flags;

	if primitive.type != cgltf.primitive_type.triangles {
		// For now we only support triangles meshes.
		return;
	}
	
	mesh_data.material_index = -1;

	if .LoadMaterials in load_flags {

		if primitive.material != nil {
			// This should work as long as all material in the data.materials array are loaded.
			index := cgltf.material_index(data, primitive.material);
			mesh_data.material_index = cast(i32)index;
		}
	}

	// Load Indecies 
	{
		accessor := primitive.indices;

		if accessor == nil {
			return; // cannot load without indecies
		}

		assert(!accessor.is_sparse); // TODO: we should prob handle sparse accessors if they actually exits practically ??
		
		component_byte_size : uint = cgltf.component_size(accessor.component_type);
		num_indecies   : uint = accessor.count;
		
		if num_indecies == 0 do return;
							
		comp_type := accessor.component_type;

		// For indecies we only support u16 and u32 for now.
		if comp_type != .r_16u && comp_type != .r_32u {
			if log_errors do log.warnf("Poly: found indecies of component_type {}, which we currently dont support,we skip this mesh", comp_type);
			return;
		}
		
		indecies_raw : [^]byte = make_multi_pointer([^]byte, cast(int)num_indecies * cast(int)component_byte_size, context.allocator);

		num_loaded_indecies : uint = cgltf.accessor_unpack_indices(accessor, indecies_raw, out_component_size = component_byte_size, index_count = num_indecies)

		if num_loaded_indecies == 0 {
			free(indecies_raw);
			if log_errors do log.warnf("Poly: cgltf failed to unpack indecies.");
			return;
		}

		assert(num_loaded_indecies == num_indecies);

		indecies_u32 : [^]u32 = nil;

		if comp_type == .r_16u {
			// Convert u16 indecies to u32 indecies.

			indecies_u32 = make_multi_pointer([^]u32, cast(int)num_indecies, context.allocator);

			indecies_u16 : [^]u16 = cast([^]u16)indecies_raw;

			for a in 0..<num_indecies {
				indecies_u32[a] = cast(u32)indecies_u16[a];
			}

			free(indecies_raw);
			indecies_raw = nil;

		} else if comp_type == cgltf.component_type.r_32u {
			// if they are already u32 we can just cast and keep the original raw buffer
			indecies_u32 = cast([^]u32)indecies_raw;
		}

		mesh_data.indecies     = indecies_u32;
		mesh_data.num_indecies = cast(u32)num_indecies;
	}

	// At this point we should have valid indecies.
	assert(mesh_data.indecies != nil)
	assert(mesh_data.num_indecies > 0)

	// Load Attributes.
	{
		num_positions 	: int = -1;
		num_normals 	: int = -1;
		num_tangents 	: int = -1;
		num_texcoords_0 : int = -1;
		num_texcoords_1 : int = -1;
		num_colors_0 	: int = -1;
		num_colors_1 	: int = -1;

		attrib_loop: for &attrib in primitive.attributes {

			accessor : ^cgltf.accessor = attrib.data;
			if accessor == nil do continue attrib_loop;

			// here we make sure we skip everything that we dont need or already have, 
			// we only load 2 texcoords and 2 color attrubutes max at the moment.
			switch attrib.type {
				case .invalid : continue attrib_loop;
				case .position:	if mesh_data.positions   != nil do continue attrib_loop; // already have positions.
				case .normal  :	if mesh_data.normals     != nil do continue attrib_loop; // already have normals
				case .tangent :	if mesh_data.tangents    != nil do continue attrib_loop; // already have tangents
				case .texcoord:	if mesh_data.texcoords_0 != nil && mesh_data.texcoords_1 != nil do continue attrib_loop; // already have 2 texcoords.
				case .color   : if mesh_data.colors_0    != nil && mesh_data.colors_1 != nil do continue attrib_loop;    // already have 2 colors.
				case .joints  : continue attrib_loop;
				case .weights : continue attrib_loop;
				case .custom  : continue attrib_loop;
			}

			assert(!accessor.is_sparse) // TODO: handle sparce accessor if we ever encounter it.

			count : uint = cgltf.accessor_unpack_floats(accessor, nil, 0); // passing nil resturns the count
			if count == 0 {
				if log_errors do log.warnf("Poly: cgltf accessor has a count of 0 for attribute of type {}, skipping attribute", attrib.type);
				continue attrib_loop;
			}

			buf : [^]f32 = make_multi_pointer([^]f32, cast(int)count, context.allocator);
			
			num_loaded_floats : uint = cgltf.accessor_unpack_floats(accessor, buf, float_count = count);

			if num_loaded_floats == 0 {
				free(buf);
				if log_errors do log.warnf("Poly: cgltf failed to unpack floats while loading attributes, skipping attribute of type {}", attrib.type);
				continue attrib_loop;
			}

			assert(num_loaded_floats == count);

			//log.warnf("res: {} attrib: {}, comp type {}, float count {}",0, attrib.type, accessor.type, count);

			accessor_type := accessor.type;

			#partial switch attrib.type {
				case .position:{
					assert(mesh_data.positions == nil);
					assert(accessor_type == .vec3) // Handle if we ever encounter someting else.

					mesh_data.positions = cast([^][3]f32)buf;
					num_positions = cast(int)count / 3;
				}
				case .normal  : {
					assert(mesh_data.normals == nil);
					assert(accessor_type == .vec3) // Handle if we ever encounter someting else.
				
					mesh_data.normals = cast(^[3]f32)buf;
					num_normals = cast(int)count / 3;
				}
				case .tangent : {
					assert(mesh_data.tangents == nil);
					assert(accessor_type == .vec4) // Handle if we ever encounter someting else.
					mesh_data.tangents = cast(^[4]f32)buf;
					num_tangents = cast(int)count / 4;
				}
				case .texcoord: {

					assert(accessor_type == .vec2) // Handle if we ever encounter someting else.
					
					if mesh_data.texcoords_0 == nil {
						mesh_data.texcoords_0 = cast(^[2]f32)buf;
						num_texcoords_0 = cast(int)count / 2;
					} else {
						assert(mesh_data.texcoords_1 == nil)
						mesh_data.texcoords_1 = cast(^[2]f32)buf;
						num_texcoords_1 = cast(int)count / 2;
					}
				}
				case .color   : {
					// TODO: test this.. we could be converting different accesor types to a vec4 
					assert(accessor_type == .vec4) // Handle if we ever encounter someting else.
					
					// @Note we may not be getting colors as rgba but only rgb ??
					if mesh_data.colors_0 == nil {
						//log.warnf("colors_0 type {}", accessor.type);
						mesh_data.colors_0 = cast(^[4]f32)buf;
						num_colors_0 = cast(int)count / 4;
					} else {
						assert(mesh_data.colors_1 == nil)
						//log.warnf("colors_1 type {}", accessor.type);
						mesh_data.colors_1 = cast(^[4]f32)buf;
						num_colors_1 = cast(int)count / 4;
					}
				}
			}

		} // attrib loop end


		// At the minimum we need position data otherwise nothing makes sense..
		if num_positions == -1 {
			if log_errors do log.warnf("Poly: cgltf did not load any position attibute, skipping mesh");
			free_mesh(&mesh_data);
			return;
		}

		mesh_data.num_vertecies = cast(u32)num_positions;
		
		// TODO: calculate proper normals
		if num_normals == -1 && .CalcMissingNormals in load_flags {
			mesh_data_recalculate_normals(&mesh_data); // only fallback atm. Implement Properly..
			num_normals = cast(int)mesh_data.num_vertecies;
		}

		// TODO: calculate proper tangents.
		if num_tangents == -1 && .CalcMissingTangents in load_flags {
			mesh_data_recalculate_tangents(&mesh_data); // only fallback atm. Implement Properly..
			num_tangents = cast(int)mesh_data.num_vertecies;
		}

		// Validate that all attibutes have the same number of vertecies..

		if num_normals     != -1 do assert(num_normals     == num_positions);
		if num_tangents    != -1 do assert(num_tangents    == num_positions);
		if num_texcoords_0 != -1 do assert(num_texcoords_0 == num_positions);
		if num_texcoords_1 != -1 do	assert(num_texcoords_1 == num_positions);
		if num_colors_0    != -1 do assert(num_colors_0    == num_positions);
		if num_colors_1    != -1 do assert(num_colors_1    == num_positions);		

	} // end load attributes

	mesh_data.name = strings.clone(mesh_name, context.allocator);
	mesh_data.transform = node_transform;

	mesh_data.aabb_min, mesh_data.aabb_max = mesh_data_compute_aabb(&mesh_data);

	ok = true;
	return mesh_data, ok;
}


@(private="file")
load_cgltf_material_to_material_data :: proc(gltf_mat : ^cgltf.material, mat : ^MaterialData) {
	
	if gltf_mat == nil {
		return;
	}

	if mat == nil {
		return;
	}

	// MaterialData :: struct {

	// 	name : string,

	// 	albedo_color : [3]f32,
	// 	emissive_color : [3]f32,
	// 	emissive_strength : f32,
	// 	roughness : f32,
	// 	metallic : f32,
	// 	normal_scale : f32,
	// 	alpha_value : f32,
	// 	alpha_mode : AlphaBlendModes,

	// 	albedo_alpha_tex_filename:	string,
	// 	normal_tex_filename: 		string,
	// 	orm_tex_filename: 			string,	// occlusion, roughness, metallic,
	// 	emissive_tex_filename: 		string,

	// 	has_albedo_alpha_tex:	bool,
	// 	has_normal_tex:			bool,
	// 	has_ao_tex: 			bool,
	// 	has_roughness_tex:		bool,
	// 	has_metallic_tex:		bool,
	// 	has_opacity_tex:		bool,
	// 	has_emissive_tex:		bool,

	// 	render_double_sided: 	bool,
	// }

	// TODO: alpha value should change base on alpha mode prob
	mat.alpha_value = gltf_mat.alpha_cutoff;

	switch gltf_mat.alpha_mode {
		case .opaque: 
			mat.alpha_mode = AlphaBlendModes.Opaque;
			mat.alpha_value = 1.0;
		case .mask:   mat.alpha_mode = AlphaBlendModes.Clip;
		case .blend:  mat.alpha_mode = AlphaBlendModes.Blend;
	}

	if gltf_mat.has_pbr_metallic_roughness {

		mat.albedo_color = gltf_mat.pbr_metallic_roughness.base_color_factor.rgb;
		mat.roughness = gltf_mat.pbr_metallic_roughness.roughness_factor;
		mat.metallic  = gltf_mat.pbr_metallic_roughness.metallic_factor;
	}
	mat.normal_scale = 1.0;

	// emissive
	if gltf_mat.has_emissive_strength {
		mat.emissive_strength = gltf_mat.emissive_strength.emissive_strength;
		mat.emissive_color = gltf_mat.emissive_factor;
	}

	mat.render_double_sided = cast(bool)gltf_mat.double_sided;

	// TODO: texture stuff..

	if gltf_mat.normal_texture.texture != nil {
		//mat.has_normal_tex = true;
	}

	mat.name = strings.clone_from_cstring(gltf_mat.name, context.allocator);
}