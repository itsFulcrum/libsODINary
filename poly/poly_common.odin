package poly

import "core:mem"
import "core:math"
import "core:math/linalg"
import "core:strings"
import "core:os"


free_mesh :: proc(mesh : ^MeshData, free_mesh_data_itself : bool = true) {
	
	if mesh == nil {
		return;
	}

	delete_string(mesh.name);

	if mesh.indecies != nil do free(mesh.indecies);

	if mesh.positions   != nil do free(mesh.positions  );
	if mesh.normals     != nil do free(mesh.normals    );
	if mesh.tangents    != nil do free(mesh.tangents   );
	if mesh.colors_0    != nil do free(mesh.colors_0   );
	if mesh.colors_1    != nil do free(mesh.colors_1   );
	if mesh.texcoords_0 != nil do free(mesh.texcoords_0);
	if mesh.texcoords_1 != nil do free(mesh.texcoords_1);

	if free_mesh_data_itself {
		free(mesh);
	}
}
free_material ::  proc(mat : ^MaterialData) {
	delete(mat.name);

	delete(mat.albedo_alpha_tex_filename);
	delete(mat.normal_tex_filename);
	delete(mat.orm_tex_filename);
	delete(mat.emissive_tex_filename);
}


free_scene :: proc(scene : ^SceneData){

	if scene == nil {
		return;
	}

	delete_string(scene.filename);
	
	// delete lights
	for &light in scene.lights {

		delete_string(light.name);
	}
	delete(scene.lights);

	// delete materials
	for &mat in scene.materials {
		free_material(&mat);
	}

	delete(scene.materials);

	// delete meshes
	for &mesh in scene.meshes{

		free_mesh(&mesh, false);
	}
	delete(scene.meshes);

	free(scene);
}

// Combine all meshes contained in a scene into one. This operation looses all information about material data
join_scene_meshes :: proc(scene : ^SceneData, apply_transforms: bool = true) -> (^MeshData, bool) {

	if scene == nil {
		return nil, false;
	}

	if len(scene.meshes) == 0 {
		return nil, false;
	}

	mesh_data : ^MeshData = new(MeshData, context.allocator);
	
	if len(scene.filename) > 0 {

		_ , file_name := os.split_path(scene.filename);

		name_only := os.short_stem(file_name);

		mesh_data.name = strings.clone(name_only, context.allocator);

	} else {
		mesh_data.name = strings.clone(string("Unnamed Mesh"), context.allocator);
	}

	mesh_data.transform = transform_data_get_identity();
	mesh_data.material_index = -1;

	// It makes our lives quite a bit easier to 
	// just count the buffer size we need in advance.
	total_num_vertecies : u32 = 0;
	total_num_indecies  : u32 = 0;

	for &mesh in scene.meshes {
		total_num_vertecies += mesh.num_vertecies;
		total_num_indecies  += mesh.num_indecies;
	}

	mesh_data.num_vertecies = total_num_vertecies;
	mesh_data.num_indecies  = total_num_indecies;

	// Allocate buffers

	mesh_data.indecies = make_multi_pointer([^]u32, cast(int)total_num_indecies);

	mesh_data.positions 	= make_multi_pointer([^][3]f32, cast(int)total_num_vertecies);
	mesh_data.normals 		= make_multi_pointer([^][3]f32, cast(int)total_num_vertecies);
	mesh_data.tangents 		= make_multi_pointer([^][4]f32, cast(int)total_num_vertecies);
	mesh_data.colors_0 		= make_multi_pointer([^][4]f32, cast(int)total_num_vertecies);
	mesh_data.colors_1 		= make_multi_pointer([^][4]f32, cast(int)total_num_vertecies);
	mesh_data.texcoords_0 	= make_multi_pointer([^][2]f32, cast(int)total_num_vertecies);
	mesh_data.texcoords_1 	= make_multi_pointer([^][2]f32, cast(int)total_num_vertecies);

	// initialize aabbs to aabb of first mesh
	mesh_data.aabb_min = scene.meshes[0].aabb_min;
	mesh_data.aabb_max = scene.meshes[0].aabb_max;

	// @Note - fulcrum
	// first pass we just merge into one big buffer without worring about applying transfromations
	mesh_offset : u32 = 0;
	indecie_offset : u32 = 0;
	for m in 0..<len(scene.meshes) {

		if scene.meshes[m].positions   != nil do mem.copy(&mesh_data.positions[mesh_offset]  , &scene.meshes[m].positions[0]  , cast(int)scene.meshes[m].num_vertecies * size_of([3]f32));
		if scene.meshes[m].normals     != nil do mem.copy(&mesh_data.normals[mesh_offset]    , &scene.meshes[m].normals[0]    , cast(int)scene.meshes[m].num_vertecies * size_of([3]f32));
		if scene.meshes[m].tangents    != nil do mem.copy(&mesh_data.tangents[mesh_offset]   , &scene.meshes[m].tangents[0]   , cast(int)scene.meshes[m].num_vertecies * size_of([4]f32));
		if scene.meshes[m].colors_0    != nil do mem.copy(&mesh_data.colors_0[mesh_offset]   , &scene.meshes[m].colors_0[0]   , cast(int)scene.meshes[m].num_vertecies * size_of([4]f32));
		if scene.meshes[m].colors_1    != nil do mem.copy(&mesh_data.colors_1[mesh_offset]   , &scene.meshes[m].colors_1[0]   , cast(int)scene.meshes[m].num_vertecies * size_of([4]f32));
		if scene.meshes[m].texcoords_0 != nil do mem.copy(&mesh_data.texcoords_0[mesh_offset], &scene.meshes[m].texcoords_0[0], cast(int)scene.meshes[m].num_vertecies * size_of([2]f32));
		if scene.meshes[m].texcoords_1 != nil do mem.copy(&mesh_data.texcoords_1[mesh_offset], &scene.meshes[m].texcoords_1[0], cast(int)scene.meshes[m].num_vertecies * size_of([2]f32));

		// @Note - fulcrum
		// we cannot just copy indecies, since they of course point into the individual buffers to form triangles
		// we have to offset each indecie by the amount of previously added vertecies.
		for i in 0..<scene.meshes[m].num_indecies {
			indecie: u32 = scene.meshes[m].indecies[i] + mesh_offset;
			mesh_data.indecies[indecie_offset + i] = indecie;
		}

		mesh_data.aabb_min = linalg.min(mesh_data.aabb_min,scene.meshes[m].aabb_min);
		mesh_data.aabb_max = linalg.max(mesh_data.aabb_max,scene.meshes[m].aabb_max);

		mesh_offset += scene.meshes[m].num_vertecies;
		indecie_offset += scene.meshes[m].num_indecies;
	}

	// if we dont want to apply transformations we are already done here.
	// otherwise wee need to multiply each position with the tranform matrix of the mesh
	// ass well as multiply normals and tagents with normal matrix.
	// aabb min/max also need to be recalculated.

	if apply_transforms {

		mesh_offset = 0;

		// reset aabb
		mesh_data.aabb_min = [3]f32{math.F32_MAX,math.F32_MAX, math.F32_MAX};
		mesh_data.aabb_max = [3]f32{math.F32_MIN,math.F32_MIN, math.F32_MIN};

		for &scene_mesh in scene.meshes{

			transform_mat : matrix[4,4]f32 = linalg.matrix4_translate_f32(scene_mesh.transform.position) * linalg.matrix4_from_quaternion_f32(scene_mesh.transform.orientation) * linalg.matrix4_scale_f32(scene_mesh.transform.scale);
			normal_mat : matrix[4,4]f32 = linalg.matrix4_inverse_transpose_f32(transform_mat);

			for i in 0..<scene_mesh.num_vertecies {

				vert_offset : u32 = mesh_offset + i;

				pos : [3]f32 = mesh_data.positions[vert_offset];
				nor : [3]f32 = mesh_data.normals[vert_offset];

				// @Note for tangent we keep the .w the same
				tan : [3]f32 = mesh_data.tangents[vert_offset].xyz;

				mesh_data.positions[vert_offset] = (transform_mat * [4]f32{pos.x, pos.y, pos.z, 1.0}).xyz;
				mesh_data.normals[vert_offset]   = (normal_mat    * [4]f32{nor.x, nor.y, nor.z, 1.0}).xyz;
				mesh_data.tangents[vert_offset].xyz  = (normal_mat    * [4]f32{tan.x, tan.y, tan.z, 1.0}).xyz;				
			}


			aabb_min : [4]f32 = transform_mat * [4]f32{scene_mesh.aabb_min.x, scene_mesh.aabb_min.y, scene_mesh.aabb_min.z, 1.0};
			aabb_max : [4]f32 = transform_mat * [4]f32{scene_mesh.aabb_max.x, scene_mesh.aabb_max.y, scene_mesh.aabb_max.z, 1.0};

			mesh_data.aabb_min = linalg.min(mesh_data.aabb_min, aabb_min.xyz);
			mesh_data.aabb_max = linalg.max(mesh_data.aabb_max, aabb_max.xyz);

			mesh_offset += scene_mesh.num_vertecies;
		}
	}

	return mesh_data, true;
}

mesh_data_compute_aabb :: proc(mesh_data : ^MeshData) -> (aabb_min, aabb_max : [3]f32){
	// compute aabb
	
	assert(mesh_data != nil)

	if mesh_data.positions == nil && mesh_data.num_vertecies == 0 {
		return aabb_min, aabb_max;
	}

	first_pos := mesh_data.positions[0];

	aabb_min = first_pos;
	aabb_max = first_pos;

	for i in 0..<mesh_data.num_vertecies {
		pos := mesh_data.positions[i];
		aabb_min = linalg.min(aabb_min, pos);
		aabb_max = linalg.max(aabb_max, pos);
	}

	return aabb_min, aabb_max;
}


// TODO calculate properly
// @Note: there is an odin implementation of MTkks tangent space algorithim.
mesh_data_recalculate_tangents :: proc(mesh_data : ^MeshData) {

	assert(mesh_data != nil)

	assert(mesh_data.num_vertecies > 0)

	// We need at least normals..
	if mesh_data.normals == nil {
		mesh_data_recalculate_normals(mesh_data)
	}


	if mesh_data.tangents == nil {
		mesh_data.tangents = make_multi_pointer([^][4]f32, cast(int)mesh_data.num_vertecies, context.allocator);
	}

	any_perpendicular :: proc "contextless" (vec : [3]f32) -> [3]f32 {
    
	    if abs(vec.z) < 0.999 {
	        return linalg.normalize(linalg.cross(vec, [3]f32{0,0,1}));
	    } 

	    return linalg.normalize(linalg.cross(vec, [3]f32{0,1,0}));
	}

	for i in 0..<mesh_data.num_vertecies {
		mesh_data.tangents[i].xyz = any_perpendicular(mesh_data.normals[i].xyz);
		mesh_data.tangents[i].w   = 1;
	}
}


// Recalculate Normals for a mesh. TODO: Implement proper smooth/hardedge normals.
// Currently only a fallback implementation that produces some valid normals but not actually 
mesh_data_recalculate_normals :: proc(mesh_data : ^MeshData){

	assert(mesh_data != nil)
	assert(mesh_data.num_vertecies > 0)
	assert(mesh_data.positions != nil)


	if mesh_data.normals == nil {
		mesh_data.normals = make_multi_pointer([^][3]f32, mesh_data.num_vertecies, context.allocator);
	} 


	for index in 0..<mesh_data.num_vertecies {

		// as fallback we can maybe use normalized position as normal.
		// better than nothing.
		N : [3]f32 = mesh_data.positions[index];

		if abs(linalg.dot(N, N)) < 0.00001 {
			// Fallback to up vector if length is very small	
			mesh_data.normals[index] = [3]f32{0.0, 1.0, 0.0}; 
		} else {
			mesh_data.normals[index] = linalg.normalize(N);
		}
	}
}