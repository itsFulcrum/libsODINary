package poly

SceneData :: struct {
	meshes    : [dynamic]MeshData,
	lights    : [dynamic]LightData,
	materials : [dynamic]MaterialData,

	filename : string,
}


MeshData :: struct {

	name : string,

	// @Note - fulcrum 
	// make these multi pointers..
	// which also means we can do simple mem.copy from assimp probably
	num_vertecies : u32,
	positions	: [^][3]f32,
	normals  	: [^][3]f32,
	tangents 	: [^][3]f32,
	colors_0 	: [^][4]f32,
	colors_1 	: [^][4]f32,
	texcoords_0 : [^][2]f32,
	texcoords_1 : [^][2]f32,

	num_indecies: u32,
	indecies: 	[^]u32,

	material_index : i32,

	aabb_min : [3]f32,
	aabb_max : [3]f32,

	// transform data
	transform_position : [3]f32,
	transform_scale : [3]f32,
	transform_orientation : quaternion128,
}


AlphaBlendModes :: enum u8 {
	Opaque = 0,
	Clip = 1,
	Blend = 2,
}


MaterialData :: struct {

	name : string,

	albedo_color : [3]f32,
	emissive_color : [3]f32,
	emissive_strength : f32,
	roughness : f32,
	metallic : f32,
	normal_scale : f32,
	alpha_value : f32,
	alpha_mode : AlphaBlendModes,

	albedo_alpha_tex_filename:	string,
	normal_tex_filename: 		string,
	orm_tex_filename: 			string,	// occlusion, roughness, metallic,
	emissive_tex_filename: 		string,

	has_albedo_alpha_tex:	bool,
	has_normal_tex:			bool,
	has_ao_tex: 			bool,
	has_roughness_tex:		bool,
	has_metallic_tex:		bool,
	has_opacity_tex:		bool,
	has_emissive_tex:		bool,

	render_double_sided: 	bool,
}

create_default_material :: proc () -> MaterialData {

	mat : MaterialData;
	//mat.name;

	mat.albedo_color = {0.8,0.8,0.8};
	mat.emissive_color =  {0.0,0.0,0.0};
	mat.emissive_strength = 0.0;
	mat.roughness = 0.2;
	mat.metallic = 0.0;
	mat.normal_scale = 1.0;
	mat.alpha_mode = AlphaBlendModes.Opaque;
	mat.alpha_value = 1.0;

	//mat.albedo_alpha_tex_filenam;
	//mat.normal_tex_filename;
	//mat.orm_tex_filename;
	//mat.emissive_tex_filename;

	mat.has_albedo_alpha_tex = false;
	mat.has_normal_tex		 = false;
	mat.has_ao_tex			 = false;
	mat.has_roughness_tex	 = false;
	mat.has_metallic_tex	 = false;
	mat.has_opacity_tex		 = false; // unfortunatly there is no definite way to know wheather the opacity was included as part of the albedo_alpha texture
	mat.has_emissive_tex	 = false;

	mat.render_double_sided  = false;

	return mat;
}


LightType :: enum u8 {
	DIRECTIONAL = 0,
	POINT 		= 1,
	SPOT 		= 2,
}

LightData :: struct {

	name : string,

	type : LightType,
	color : [3]f32,
	spot_angle_inner : f32,
	spot_angle_outer : f32,
	// transform data
	position : [3]f32,
	orientation : quaternion128,
}