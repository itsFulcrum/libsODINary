package poly

import "core:log"
import "core:strings"
import "core:path/filepath"
import "core:os"
import "core:mem"
import "base:runtime"
import "core:math"
import "core:math/linalg"

import "assimp"
import ai "assimp/import"


base_assimp_post_process_flags :: 
	ai.aiPostProcessSteps.Triangulate | 
	ai.aiPostProcessSteps.CalcTangentSpace  
//	ai.aiPostProcessSteps.RemoveRedundantMaterials |
//	ai.aiPostProcessSteps.SplitLargeMeshes |
//	ai.aiPostProcessSteps.OptimizeMeshes | 			// I suppose merge meshes with same material? not state clearly in docs 
//	ai.aiPostProcessSteps.ImproveCacheLocality | 	// Reorder triangle base on a heuristic to improve cache access
//	ai.aiPostProcessSteps.SortByPType 				// Remove points or line primitve.


// Load a 3D file format into a flat scene representation (no hierarchy supported)
// Tested mostly with .glTF file format
// Supports loading light and material data
// for glTF files, materials also store possible texture filepaths
// For small temp allocations it using context.temp_allocator
// For big or persistent allocations using context.allocator.
// Returned scene must be freed by users. Recomend to use destroy_scene() procedure.
load_assimp_gltf_from_file :: proc(filename: string, load_materials, load_lights, fill_missing_vertex_attributes : bool) -> (^SceneData, bool) {
	
	filename_clean, alloc_error := filepath.clean(filename, context.temp_allocator);

	if(alloc_error != runtime.Allocator_Error.None) {
		log.errorf("Poly: Failed to load model: {}, runetime allocation error", filename_clean);
		return nil, false;
	}

	if(!os.is_file(filename_clean)){
		log.errorf("Poly: Failed to load model, file does not exist: {}", filename_clean);
		return nil, false;
	}


	assimp_scene : ^assimp.Scene = assimp.import_file_from_file(filename_clean, cast(u32)base_assimp_post_process_flags );
    defer { assimp.release_import(assimp_scene); }
    if(assimp_scene == nil) {
    	log.errorf("Poly: Failed to load model: {}", assimp.get_error_string());
    	return nil, false;
    }

    scene_data : ^SceneData = new(SceneData);
    scene_data.filename = strings.clone(filename_clean, context.allocator);


    load_assimp_scene_to_poly_scene(assimp_scene, scene_data, load_materials, load_lights, fill_missing_vertex_attributes);


    when true {


		tmp , tmp_ok := load_gltf_from_path(filename_clean);

		if !tmp_ok || tmp == nil {
			log.errorf("cgltf load Failed")
			return nil , false;
		}

		// log.warnf("loaded {} meshes", len(tmp.meshes))

		// assimp_mesh_data := &scene_data.meshes[0];
		// cgltf_mesh_data := &tmp.meshes[0];

		// log.warnf("assimp: verts {}, indecies {}, min {}, max {}",assimp_mesh_data.num_vertecies, assimp_mesh_data.num_indecies, assimp_mesh_data.aabb_min, assimp_mesh_data.aabb_max)
		// log.warnf("cgltf : verts {}, indecies {}, min {}, max {}",cgltf_mesh_data.num_vertecies, cgltf_mesh_data.num_indecies, cgltf_mesh_data.aabb_min, cgltf_mesh_data.aabb_max)

		// for i in 0..<assimp_mesh_data.num_indecies {
		// 	log.warnf("assimp:{} indecie {}",i, assimp_mesh_data.indecies[i])
		// 	log.warnf("cgltf :{} indecie {}",i, cgltf_mesh_data.indecies[i])
		// }

		// for i in 0..<assimp_mesh_data.num_vertecies {
		// 	log.warnf("assimp:{} pos {}",i, assimp_mesh_data.positions[i])
		// 	log.warnf("cgltf :{} pos {}",i, cgltf_mesh_data.positions[i])
		// }


		destroy_scene(scene_data);
		free(scene_data)

		return tmp, true;
    } else {

    	// for &m in scene_data.meshes {
    	// 	m.normals = nil;
    	// 	m.tangents = nil;
    	// 	m.texcoords_0 = nil;
    	// 	m.texcoords_1 = nil;
    	// 	m.colors_0 = nil;
    	// 	m.colors_1 = nil;
    	// }

    	return scene_data, true;
    }
}


@(private="file")
load_assimp_scene_to_poly_scene :: proc(assimp_scene: ^ai.aiScene, poly_scene: ^SceneData, load_materials : bool, load_lights : bool, fill_missing_vertex_attributes : bool){

	assert(assimp_scene != nil)
	assert(poly_scene != nil)

	if(load_materials){
		num_materials: u32 = assimp_scene.mNumMaterials;
		reserve_dynamic_array(&poly_scene.materials, num_materials);
		load_assimp_materials_to_poly_scene(assimp_scene, poly_scene);
	}


	load_assimp_nodes_to_poly_scene_recursive(assimp_scene, assimp_scene.mRootNode, poly_scene, load_materials,load_lights, fill_missing_vertex_attributes);
}


// Load all materials into the array inside SceneData
// Textures only properly supported for .glTF file format and embedded textures are not supported
@(private="file")
load_assimp_materials_to_poly_scene :: proc(ai_scene: ^ai.aiScene, poly_scene: ^SceneData){

	num_materials := ai_scene.mNumMaterials;

	
	relative_filepath_dir : string = filepath.dir(poly_scene.filename, context.temp_allocator);

	for i: u32 = 0; i < num_materials; i+=1 {

		ai_mat : ^ai.aiMaterial = ai_scene.mMaterials[i];
		

		poly_mat : MaterialData = create_default_material();


		ai_return : ai.aiReturn = ai.aiReturn.SUCCESS;


		mat_name_aiStr : ai.aiString;
		ai_return = ai.get_material_string(ai_mat,"?mat.name", 0, 0,&mat_name_aiStr);
		if(ai_return == ai.aiReturn.SUCCESS) {
			poly_mat.name = assimp.string_clone_from_ai_string(&mat_name_aiStr,context.allocator);
		}
		

		// First load material pbr values if we find them provided by assimp

		// Base Color
		base_col : ai.aiColor4D;
		ai_return = ai.get_material_color(ai_mat, "$clr.base" ,0, 0, &base_col);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			poly_mat.albedo_color = {base_col.x,base_col.y,base_col.z};
			
		}

		// Emissive Color
		emissive_col : ai.aiColor4D;
		ai_return = ai.get_material_color(ai_mat, "$clr.emissive" ,0, 0, &emissive_col);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			poly_mat.emissive_color = {emissive_col.x,emissive_col.y,emissive_col.z};
			//log.infof("Emissive Color: {}", iri_mat.emissive_color);
		}
		
		// Emissive Strength
		// NOTE: Emissive Strength we get is not high enough for candela light units.  so we just multiply by 1000 atm
		emissive_intensity : f32;
		ai_return = ai.get_material_floatArray(ai_mat, "$mat.emissiveIntensity" ,0, 0, &emissive_intensity,nil);
		if(ai_return == ai.aiReturn.SUCCESS) {
			poly_mat.emissive_strength = cast(f32)emissive_intensity;
			//log.infof("Get emissive Intensity success: {}", iri_mat.emissive_strength);
		}

		// ROUGHNESS
		roughness : f32;
		ai_return = ai.get_material_floatArray(ai_mat, "$mat.roughnessFactor" ,0, 0, &roughness,nil);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			poly_mat.roughness = roughness;
			//log.infof("Get roughness success: {}", iri_mat.roughness);
		}

		// METALLIC
		metallic : f32;
		ai_return = ai.get_material_floatArray(ai_mat, "$mat.metallicFactor" ,0, 0, &metallic,nil);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			poly_mat.metallic = metallic;
			//log.infof("Get metallic success: {}", iri_mat.metallic);
		}

		// NORMAL SCALE
		// NOTE: this one was added to assimp myself but normally wouldnt work with vanilla assimp directly. maybe assimp bug? 
		normal_scale : f32;
		ai_return = ai.get_material_floatArray(ai_mat, "$mat.bumpscaling" ,0, 0, &normal_scale,nil);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			poly_mat.normal_scale = normal_scale;
			//log.infof("Get normal_scale success: {}", iri_mat.normal_scale);
		}

		// OPACITY
		opacity : f32;
		ai_return = ai.get_material_floatArray(ai_mat, "$mat.opacity" ,0, 0, &opacity,nil);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			poly_mat.alpha_value = opacity;
		}


		// ALPHA BLEND MODE
		// NOTE: 
		// by default we'll assume blend mode opaque.
		// assimp passes blend modes as string keys. 'MASK' refers to alpha clipping and 'BLEND' for alpha blending
		// In case of alpha Clipping, we check for alpha Cutoff ($mat.gltf.alphaCutoff) and its value will go into mat.alpha_value
		// technically alpha cuttoff is different then our alpha value but doing an alpha clipped material where alpha value is constant is useless 
		// so the assumption is that actualy oppacity value will come from a texture and therefore we will store the cutoff in the alpha value
		// we'll just need to handle that in the shader also
		blend_mode_aiStr : ai.aiString;
		ai_return = ai.get_material_string(ai_mat, "$mat.gltf.alphaMode", 0, 0, &blend_mode_aiStr);
		if(ai_return == ai.aiReturn.SUCCESS) {	
			//iri_mat.alpha_value = opacity;
			blend_str := assimp.string_clone_from_ai_string(&blend_mode_aiStr,context.temp_allocator);
			//defer delete(blend_str);
			
			if(strings.compare(blend_str,"OPAQUE") == 0){
				poly_mat.alpha_mode = AlphaBlendModes.Opaque;
				poly_mat.alpha_value = 1.0; // it should already be 1 but just to be sure
			}
			else if(strings.compare(blend_str,"BLEND") == 0){
				poly_mat.alpha_mode = AlphaBlendModes.Blend;
				
			}
			else if(strings.compare(blend_str,"MASK") == 0){
				poly_mat.alpha_mode = AlphaBlendModes.Clip;

				cutoff : f32;
				ai_return = ai.get_material_floatArray(ai_mat, "$mat.gltf.alphaCutoff", 0, 0, &cutoff,nil);
				if(ai_return == ai.aiReturn.SUCCESS) {	
					poly_mat.alpha_value = cutoff;
				}
				else{
					poly_mat.alpha_value = 0.5;
				}
			}	

			double_sided : int;
			ai_return = ai.get_material_integerArray(ai_mat, "$mat.twosided", 0, 0, &double_sided,nil);
			if(ai_return == ai.aiReturn.SUCCESS) {
				if(double_sided == 1){
					poly_mat.render_double_sided = true;
				}
			}
			
			
			//log.infof("ALPHA: Mat: {}, DoubleSided: {}, Opacity Val: {},  Mode: {} ",mat_name, iri_mat.render_double_sided, iri_mat.alpha_value, iri_mat.alpha_mode);
		}

		// Load textures paths

		// NOTE: On how assimp and glTF texture loading works
		/*
			So assimp does the following with textures.
			one is supposed to use get_material_textureCount() and pass a aiTextureType e.g. like aiTextureType.DIFFUSE and assimp will 
			return the amount of textures available for that specific type.
			Then we use get_material_texture() which takes tons of parameters but we esentially pass in the aiTextureType again, then the index of the stack which is at max the value from 'get_material_textureCount() -1'
			For us this means just passing 0 for index since we, only care about one texture per type. 
			Adittionally we have to provide an aiString that will be filled with the relative path to the texture, 
			however if the textures where instead embedded into the file then it will fill the string with quote: 
			"If the texture is embedded, receives a '*' followed by the id of the texture (for the textures stored in the corresponding scene) which
			can be converted to an int using a function like atoi."
			For now we just dont support empedded textures
			
			Now glTF format specifies that metallic and roughness will be combined into 1 texture with green channel containing roughness and blue channel containing metallic values 
			However if only roughness or only metallic is used then the other channels will just have a value of 1 and not the respective roughness or metallic values otherwise specified
			that means we still need to figure out weather the given texture uses the roughess or metallic channel or not.
			importing from blender we also get optionally ambient occlusion in the r channel of this texture.
			
			we know that blender will create this packed texture correctly based on which textures are used.
			and it includes keywords for the specific channels used in the filename only if they were included.
			that means we can search the filename for substrings of 'ambientOcclusion', 'roughness' and 'mettallic' to
			figure out if a given texture is included in this channel packed texture.

			a similar thing is true for opacity which is combined into the alpha channel of albedo texture.

			tbh this is actually quite convenient if I choose to build everything around the glTF format, then we can by default just use channel packed textures
		*/

		// Check albedo alpha texture
		albedo_alpha_tex_count := ai.get_material_textureCount(ai_mat,ai.aiTextureType.DIFFUSE);
		if (albedo_alpha_tex_count > 0) {

			albedo_alpha_filename_aiStr : ai.aiString;
			ai_return = ai.get_material_texture(ai_mat,ai.aiTextureType.DIFFUSE,0 , &albedo_alpha_filename_aiStr, nil,nil,nil ,nil,nil);

			// NOTE: Apparently there is no solid way to know wheather the albedo texture also includes an opacity part in the alpha channel 
			// unless we actually load it and see if it has 4 channels
			// blender will include the substring 'opacity' if the alpha input came from an alpha texture slot. so we could search the filename for 'opacity'
			// but this is not reliable since we may have the alpha input from something that wasn't stored in the alpha channel
			
			if(ai_return == ai.aiReturn.SUCCESS) {
				
				albedo_alpha_filename := assimp.string_clone_from_ai_string(&albedo_alpha_filename_aiStr,context.temp_allocator);
				albedo_alpha_path := filepath.join({relative_filepath_dir, albedo_alpha_filename},context.temp_allocator);
				
				if(os.is_file(albedo_alpha_path)) {
					poly_mat.has_albedo_alpha_tex = true;
					poly_mat.albedo_alpha_tex_filename = strings.clone(albedo_alpha_path, context.allocator);
				}

				//log.infof("Albedo_Alpha_Tex Path: {}, contains Opacity: {}", albedo_alpha_path, iri_mat.has_opacity_tex);
			}
		}

		// Check Normal texture
		normal_tex_count := ai.get_material_textureCount(ai_mat,ai.aiTextureType.NORMALS);
		if (normal_tex_count > 0) {

			normal_filename_aiStr : ai.aiString;
			ai_return = ai.get_material_texture(ai_mat,ai.aiTextureType.NORMALS, 0 , &normal_filename_aiStr, nil,nil,nil ,nil,nil);

			if(ai_return == ai.aiReturn.SUCCESS) {
				
				normal_filename := assimp.string_clone_from_ai_string(&normal_filename_aiStr,context.temp_allocator);
				normal_path := filepath.join({relative_filepath_dir, normal_filename},context.temp_allocator);
				
				if(os.is_file(normal_path)){
					poly_mat.normal_tex_filename = strings.clone(normal_path, context.allocator);
					poly_mat.has_normal_tex = true;
				}
			}
		}


		// Check ORM texture // occlusion, roughness, metallic
		orm_tex_count := ai.get_material_textureCount(ai_mat,ai.aiTextureType.aiTextureType_GLTF_METALLIC_ROUGHNESS);
		if (orm_tex_count > 0) {

			orm_filename_aiStr : ai.aiString;
			ai_return = ai.get_material_texture(ai_mat, ai.aiTextureType.aiTextureType_GLTF_METALLIC_ROUGHNESS, 0 , &orm_filename_aiStr, nil,nil,nil ,nil,nil)

			if(ai_return == ai.aiReturn.SUCCESS){

				orm_filename := assimp.string_clone_from_ai_string(&orm_filename_aiStr,context.temp_allocator);
				orm_path := filepath.join({relative_filepath_dir, orm_filename},context.temp_allocator);
				
				if(os.is_file(orm_path)) {
					poly_mat.orm_tex_filename = strings.clone(orm_path, context.allocator);
					
					poly_mat.has_ao_tex = strings.contains(orm_filename, "ambientOcclusion");
					poly_mat.has_roughness_tex = strings.contains(orm_filename, "roughness");
					poly_mat.has_metallic_tex = strings.contains(orm_filename, "metallic");
				}
			}
		}

		// Check emissive texture
		emissive_tex_count := ai.get_material_textureCount(ai_mat,ai.aiTextureType.EMISSIVE);
		if (emissive_tex_count > 0) {

			emissive_filename_aiStr : ai.aiString;
			ai_return = ai.get_material_texture(ai_mat, ai.aiTextureType.EMISSIVE, 0 , &emissive_filename_aiStr, nil,nil,nil ,nil,nil)

			if(ai_return == ai.aiReturn.SUCCESS){

				emissive_filename := assimp.string_clone_from_ai_string(&emissive_filename_aiStr,context.temp_allocator);
				emissive_path := filepath.join({relative_filepath_dir, emissive_filename},context.temp_allocator);
				
				if(os.is_file(emissive_path)){
					poly_mat.emissive_tex_filename = strings.clone(emissive_path);
					poly_mat.has_emissive_tex = true;

				}
			}
		}

		append(&poly_scene.materials, poly_mat);
	}
}


@(private="file") 
load_assimp_mesh :: proc(mesh: ^ai.aiMesh, mesh_data : ^MeshData, fill_missing_attributes : bool) -> bool {

	if(mesh == nil){
		return false;
	}

	num_verts := mesh.mNumVertices;

	if(num_verts == 0){
		return false;
	}

	
	mesh_data.name = assimp.string_clone_from_ai_string(&mesh.mName,context.allocator);


	print_missing_data_components :: false;
	if(print_missing_data_components) {

		positions_exist 	: bool = mesh.mVertices != nil;
		normals_exist 		: bool = mesh.mNormals  != nil;
		tangents_exist 		: bool = mesh.mTangents != nil;
		colors_0_exist 		: bool = mesh.mColors[0] != nil;
		colors_1_exist 		: bool = mesh.mColors[1] != nil;
		texcoords_0_exist 	: bool = mesh.mTextureCoords[0] != nil;
		texcoords_1_exist 	: bool = mesh.mTextureCoords[1] != nil;


		// we check only the important ones but then print all info
		if(!positions_exist || !normals_exist || !tangents_exist || !texcoords_0_exist){

			mesh_name := assimp.string_clone_from_ai_string(&mesh.mName,context.temp_allocator);
			log.warnf("Poly: Mesh: {}, misses important data components.\n\tpositions: {}\n\tnormals: {}\n\ttangents: {}\n\tcolors_0: {}\n\tcolors_1: {}\n\ttexcoords_0: {}\n\ttexcoords_1: {}",
				mesh_name,
				positions_exist,
				normals_exist,
				tangents_exist,
				colors_0_exist,
				colors_1_exist,
				texcoords_0_exist,
				texcoords_1_exist);
		}
	}
	
	mesh_data.num_vertecies = num_verts;


	if(fill_missing_attributes) {
		// just allocate all, they'll be zero-initialized by default.
		mesh_data.positions   = make_multi_pointer([^][3]f32, num_verts);
		mesh_data.normals     = make_multi_pointer([^][3]f32, num_verts);
		mesh_data.tangents    = make_multi_pointer([^][4]f32, num_verts);
		mesh_data.colors_0    = make_multi_pointer([^][4]f32, num_verts);
		mesh_data.colors_1    = make_multi_pointer([^][4]f32, num_verts);
		mesh_data.texcoords_0 = make_multi_pointer([^][2]f32, num_verts);
		mesh_data.texcoords_1 = make_multi_pointer([^][2]f32, num_verts);
	}
	else {
		// only allocate if there is data.
		if mesh.mVertices  != nil do mesh_data.positions   = make_multi_pointer([^][3]f32, num_verts);
		if mesh.mNormals   != nil do mesh_data.normals     = make_multi_pointer([^][3]f32, num_verts);
		if mesh.mTangents  != nil do mesh_data.tangents    = make_multi_pointer([^][4]f32, num_verts);
		if mesh.mColors[0] != nil do mesh_data.colors_0    = make_multi_pointer([^][4]f32, num_verts);
		if mesh.mColors[1] != nil do mesh_data.colors_1    = make_multi_pointer([^][4]f32, num_verts);
		if mesh.mTextureCoords[0] != nil do mesh_data.texcoords_0 = make_multi_pointer([^][2]f32, num_verts);
		if mesh.mTextureCoords[1] != nil do mesh_data.texcoords_1 = make_multi_pointer([^][2]f32, num_verts);
	}

	// copy over what there is.
	if mesh.mVertices  != nil do mem.copy(&mesh_data.positions[0], &mesh.mVertices[0] , cast(int)num_verts * size_of([3]f32));
	if mesh.mNormals   != nil do mem.copy(&mesh_data.normals[0]  , &mesh.mNormals[0]  , cast(int)num_verts * size_of([3]f32));
	
	if mesh.mColors[0] != nil do mem.copy(&mesh_data.colors_0[0] , &mesh.mColors[0][0], cast(int)num_verts * size_of([4]f32));
	if mesh.mColors[1] != nil do mem.copy(&mesh_data.colors_1[0] , &mesh.mColors[1][0], cast(int)num_verts * size_of([4]f32));
	

	// @Note assimp has tangents as xyz but we need that .w wich is a sin (-1 or +1) to reconstruct bitangent correctly
	// we force this to 1 here but its technically not correct
	// and assimp assumes we also load and store bitangents..
	if mesh.mTangents  != nil {

		for tan in 0..<num_verts{
			a_tan : = &mesh.mTangents[tan];
			mesh_data.tangents[tan] = [4]f32 {a_tan.x, a_tan.y,a_tan.z,1.0};	
		}
	} 

	
	// @Note
	// Texcoords we unfortunately have to copy one by one because assimp stores them as vec3 not vec2 for some reason.

	if mesh.mTextureCoords[0] != nil {
		for i in 0..<num_verts {
			mesh_data.texcoords_0[i] =  mesh.mTextureCoords[0][i].xy;
		}
	}
	if mesh.mTextureCoords[1] != nil {
		for i in 0..<num_verts {
			mesh_data.texcoords_0[i] =  mesh.mTextureCoords[1][i].xy
		}
	}


	// Load Indecies
	num_faces := mesh.mNumFaces;

	indecies : [dynamic]u32;	
	reserve_dynamic_array(&indecies, num_faces * 3);
	
	for f in 0..< num_faces {		
		face := mesh.mFaces[f];

		for i in 0..< face.mNumIndices{
			append(&indecies, face.mIndices[i]);
		}
	}

	num_indecies : u32 = cast(u32)len(indecies);

	mesh_data.num_indecies = num_indecies;
	mesh_data.indecies = make_multi_pointer([^]u32, cast(int)num_indecies);

	mem.copy(&mesh_data.indecies[0], &indecies[0], cast(int)num_indecies * size_of(u32));


	delete(indecies);


	// Compute aabb

	mesh_data.aabb_min, mesh_data.aabb_max = mesh_data_compute_aabb(mesh_data);

	// TODO: check if aabb min and max on any axis are almost identical and add small offset in that case..

	return true;
}


@(private="file") 
load_assimp_nodes_to_poly_scene_recursive :: proc(ai_scene: ^ai.aiScene, node: ^ai.aiNode, poly_scene: ^SceneData, load_materials : bool, load_lights : bool, fill_missing_vertex_attributes : bool ) {


	// loop through all meshes of this node
	for m: u32 = 0; m < node.mNumMeshes; m += 1 {
		
		// assimp stores meshes in an array of pointers as part of the main scene
		// assimp nodes hold an array of indexes into the main mesh array
		mesh_id: u32 = node.mMeshes[m];
		assimp_mesh: ^ai.aiMesh = ai_scene.mMeshes[mesh_id];


		mesh_data : MeshData;

		mesh_loading_successful : bool = load_assimp_mesh(assimp_mesh, &mesh_data, fill_missing_vertex_attributes);

		if(!mesh_loading_successful) {
			continue;
		}


		if(load_materials){
			mesh_data.material_index = cast(i32)assimp_mesh.mMaterialIndex;
		} else {
			mesh_data.material_index = -1;
		}


		// grap copy of transform matrix
		assimp_transform_matrix: ai.aiMatrix4x4 = node.mTransformation;
		
		ai_orientation : ai.aiQuaternion;
		ai.decompose_matrix(&assimp_transform_matrix, &mesh_data.transform_scale, &ai_orientation, &mesh_data.transform_position);

		mesh_data.transform_orientation = assimp.quaterion_convert(ai_orientation);

		//log.debugf("MeshData: Pos {}", mesh_data.transform_position)
		//log.debugf("MeshData: Scale {}", mesh_data.transform_scale)
		//log.debugf("MeshData: Orient x{},y{},z{},w{}", mesh_data.transform_orientation.x,mesh_data.transform_orientation.y,mesh_data.transform_orientation.z,mesh_data.transform_orientation.w)

		append(&poly_scene.meshes, mesh_data);
	}

	// process child nodes
	for i in 0..< node.mNumChildren {
		load_assimp_nodes_to_poly_scene_recursive(ai_scene, node.mChildren[i], poly_scene, load_materials, load_lights, fill_missing_vertex_attributes);	
	}

	// Load Lights
	// if a node has no children and no meshes we will compare its name to light names stored in the lights array of the scene to see if we find a match!
	// seems to me this is the only way to reliably retirve postion information from lights since pos and dir fields of lights themselves are not set by assimp
	if(load_lights && node.mNumChildren == 0 && node.mNumMeshes == 0){
		
		numLights := ai_scene.mNumLights;

		if(numLights <= 0){
			return;	
		}

		node_name_str := assimp.string_clone_from_ai_string(&node.mName,context.temp_allocator);
		//defer delete(node_name_str);
		//log.infof("NumLights: {}",numLights);

		lights_loop: for i: u32 = 0; i < numLights; i+=1 {

			aiLight : ^ai.aiLight = ai_scene.mLights[i];
			light_name_str := assimp.string_clone_from_ai_string(&aiLight.mName,context.temp_allocator);
			

			if(0 == strings.compare(node_name_str,light_name_str)){
				// FOUND A LIGHT!!

				light_type: LightType;

				switch aiLight.mType {
					case ai.aiLightSourceType.UNDEFINED: 	continue lights_loop;
					case ai.aiLightSourceType.DIRECTIONAL: 	light_type = LightType.DIRECTIONAL;
					case ai.aiLightSourceType.POINT:		light_type = LightType.POINT;
					case ai.aiLightSourceType.SPOT:			light_type = LightType.SPOT;
					case ai.aiLightSourceType.AMBIENT:		continue lights_loop;
					case ai.aiLightSourceType.AREA:			continue lights_loop;
				}

				light_data : LightData;
				light_data.type = light_type;

				light_data.name = strings.clone(light_name_str, context.allocator);

				// grap copy of transform matrix
				assimp_transform_matrix: ai.aiMatrix4x4 = node.mTransformation;
				assimp_orientation : ai.aiQuaternion;
				scale : [3]f32;
				
				ai.decompose_matrix(&assimp_transform_matrix, &scale, &assimp_orientation, &light_data.position);

				// get transform data
				light_data.orientation = assimp.quaterion_convert(assimp_orientation);


				//@Note: Assimp only give us a single color value for lights. Which is light_color * light_intensity.
				// Below we attempt to recover the original values but it only works correctly when light brightness was 
				// fully given by the original light_intensity values. Meaning that the color part had full luminance (not darkend)
				// By taking the max channel we still get a decent approximation of the original values even if color was not full luminance 
				// but I belive in that case its impossible to restore it correctly.
				// Another option would be to use luminance of color as a denominator but in my test it was not better compared to taking the max.
				color : [3]f32 = aiLight.mColorAmbient;
				intensity : f32 = max(max(color.r, color.g), color.b);
				
				if intensity > 0.0 {
					color /= intensity;	
				}

				light_data.color = color;
				light_data.intensity = intensity;


				light_data.spot_inner_cone_angle_radians = aiLight.mAngleInnerCone;
				light_data.spot_outer_cone_angle_radians = aiLight.mAngleOuterCone;

				append(&poly_scene.lights, light_data);
				return;
			}	

		} // end lights loop
	}
}