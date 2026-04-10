package poly
import "core:math/linalg"

LOAD_FLAGS_DEFAULT :: LoadFlags{.LoadMaterials, .LoadLights, .LogErrors}
LoadFlags :: distinct bit_set[LoadFlag]
LoadFlag :: enum {
	LoadMaterials = 0,
	LoadLights,
	LogErrors,
}

SceneData :: struct {
	meshes    : [dynamic]MeshData,
	lights    : [dynamic]LightData,
	materials : [dynamic]MaterialData,

	filename : string,
}

MeshData :: struct {

	name : string,

	num_vertecies : u32,
	positions	: [^][3]f32,
	normals  	: [^][3]f32,
	tangents 	: [^][4]f32, // .w is a sign (-1 or +1) for bitangent reconsturction. (Bitan = cross(Norm,Tan) * Tan.w)
	colors_0 	: [^][4]f32,
	colors_1 	: [^][4]f32,
	texcoords_0 : [^][2]f32,
	texcoords_1 : [^][2]f32,

	num_indecies: u32,
	indecies: 	[^]u32,

	material_index : i32, // index into SceneData.materials or -1 if not present.

	aabb_min : [3]f32,
	aabb_max : [3]f32,

	// transform data
	transform : TransformData,
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

material_data_create_default :: proc () -> MaterialData {

	mat : MaterialData;

	material_data_init_default(&mat);

	return mat;
}

material_data_init_default :: proc(mat : ^MaterialData) {
	if mat == nil {
		return;
	}
	//mat.name;

	mat.albedo_color 	= {0.8,0.8,0.8};
	mat.emissive_color 	=  {0.0,0.0,0.0};
	mat.emissive_strength = 0.0;
	mat.roughness 		= 0.2;
	mat.metallic 		= 0.0;
	mat.normal_scale 	= 1.0;
	mat.alpha_mode 		= AlphaBlendModes.Opaque;
	mat.alpha_value 	= 1.0;

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

	return;
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
	intensity : f32,

	spot_inner_cone_angle_radians : f32,
	spot_outer_cone_angle_radians : f32,
	
	// transform data
	position : [3]f32,
	orientation : quaternion128,
}

TransformData :: struct{
	position    : [3]f32,
	scale       : [3]f32,
	orientation : quaternion128,
}

transform_data_get_identity :: proc() -> TransformData {
	return TransformData{
		position = {0,0,0},
		scale    = {1,1,1},
		orientation = quaternion(x = 0, y = 0, z = 0, w = 1),
	}
}

transform_data_transform_child_by_parent :: proc "contextless" (child, parent: TransformData) -> TransformData {

    return TransformData{
    	//@Note - child positon must first be scaled by parent scale and rotated by parent orientation before adding to parent position
        position    = parent.position + linalg.quaternion128_mul_vector3(parent.orientation, child.position * parent.scale),
        scale       = parent.scale * child.scale,
        orientation = parent.orientation * child.orientation,
    };
}