package geometry

import "core:math"
import "core:math/linalg"

import "core:simd"
import "base:intrinsics"

AABB :: struct {
	using umin : struct #raw_union {
	  min : [4]f32,
	 _min : #simd[4]f32,
	},
	using umax : struct #raw_union {
	  max : [4]f32,
	 _max : #simd[4]f32,
	},
}

aabb_create_inverse_infinite :: #force_inline proc "contextless" () -> AABB {
	return {
		min = [4]f32{math.INF_F32,math.INF_F32,math.INF_F32, 1.0},
		max = [4]f32{math.NEG_INF_F32,math.NEG_INF_F32,math.NEG_INF_F32, 1.0},
	}
}

aabb_from_min_max_vec3 :: proc "contextless" (aabb_min, aabb_max : [3]f32) -> AABB {
	return AABB{
		min = [4]f32{aabb_min.x, aabb_min.y, aabb_min.z, 1.0},
		max = [4]f32{aabb_max.x, aabb_max.y, aabb_max.z, 1.0},
	}
}

aabb_from_sphere :: proc "contextless" (center : [3]f32, radius : f32) -> AABB {

	aabb : AABB
	aabb.min.xyz = center - [3]f32{radius, radius, radius}
	aabb.max.xyz = center + [3]f32{radius, radius, radius}
	aabb.min.w = 1.0
	aabb.max.w = 1.0

	return aabb
}


aabb_to_transform_matrix :: proc "contextless" (aabb : AABB) -> matrix[4,4]f32 {
	// get a 'model' matrix from an aabb that we can use to render a unit cube as the aabb to visualize it.

	extent := (aabb.max - aabb.min) * [4]f32{0.5,0.5,0.5,0.0}
	center := aabb.min + extent

	return {
		extent.x, 0  , 0  , center.x,
		0  , extent.y, 0  , center.y,
		0  , 0  , extent.z, center.z,
		0  , 0  , 0  , 1,
	}
}

aabb_get_center_extent :: proc "contextless" (aabb : AABB) -> (center : [3]f32, extent : [3]f32){

	extent4 := (aabb.max - aabb.min) * [4]f32{0.5,0.5,0.5,0.0}
	center4 := aabb.min + extent4
	return center4.xyz, extent4.xyz
}

aabb_overlaps_aabb :: proc "contextless" (a, b : AABB) -> bool {
	
	// @Note: can prob do simd with per lane compare and reduce bit AND's.

	if b.min.x < a.max.x && b.min.y < a.max.y && b.min.z < a.max.z {
		if b.min.x > a.min.x && b.min.y > a.min.y && b.min.z > a.min.z {
			return true
		}
	}

	if b.max.x > a.min.x && b.max.y > a.min.y && b.max.z > a.min.z {
		if b.max.x < a.max.x && b.max.y < a.max.y && b.max.z < a.max.z {
			return true
		}
	}

	return false
}

aabb_combine :: #force_inline proc "contextless" (a , b : AABB) -> AABB {
	return AABB {
		_min = simd.min(a._min,b._min),
		_max = simd.max(a._max,b._max),
	}
}

aabb_grow_by_point :: #force_inline proc "contextless" (aabb : ^AABB, point : [3]f32) {
	_p := #simd[4]f32{point.x, point.y, point.z, 1.0}
	aabb._min = simd.min(aabb._min, _p)
	aabb._max = simd.max(aabb._max, _p)
}

aabb_calculate_surface_area :: #force_inline proc "contextless" (aabb : AABB) -> f32 {
	//e : [4]f32 = aabb.max - aabb.min; // extent
	// surf_area := 2 * (e.x * e.y + e.y * e.z + e.z * e.x);
	// extent_xyzw : #simd[4]f32 = simd.sub(aabb._max, aabb._min);
	// extent_yzxw : #simd[4]f32 = simd.shuffle(extent_xyzw,extent_xyzw,1,2,0,3);
	// half_area : f32 = simd_masked_dot(extent_xyzw, extent_yzxw); // e.x * e.y + e.y * e.z + e.z * e.x
	// return half_area * 2;
	e : [4]f32 = aabb.max - aabb.min // extent
	return 2 * (e.x * e.y + e.y * e.z + e.z * e.x)
}

aabb_transform_by_mat4 :: proc "contextless"  (aabb : AABB,  m : matrix[4,4]f32) -> AABB {
	// Transform an AABB by a matrix e.g from local to world space and maintain its Axis alignedness.
	// Note that, unless there is no rotation in the matrix, the resulting AABB doesn't thigtly enclose the mesh anymore.
	// This is correct because we efectivly create a new AABB from the transformed AABB corners in e.g. world space
	// Otherwise we would have to transform every vertex in the mesh and compute a new min,max pair out of all vertecies in the transformed space.

	extent := (aabb.max - aabb.min) * [4]f32{0.5,0.5,0.5,1.0}
	center := aabb.min + extent

	// transform center	
	t_center : [4]f32 = m * [4]f32{center.x, center.y, center.z, 1.0}

	abs_mat : matrix[4,4]f32 = ---
	abs_mat[0] = linalg.abs(m[0])
	abs_mat[1] = linalg.abs(m[1])
	abs_mat[2] = linalg.abs(m[2])
	abs_mat[3] = linalg.abs(m[3])

	t_extent : [4]f32 = abs_mat * extent

	// transform back to min/max box representation
	tmin : [4]f32 = t_center - t_extent
	tmax : [4]f32 = t_center + t_extent

	return AABB{
		min = [4]f32{tmin.x,tmin.y,tmin.z, 1.0},
		max = [4]f32{tmax.x,tmax.y,tmax.z, 1.0},
	}
}



aabb_transform_by_mat4_and_get_tranform_mat :: proc "contextless"  (aabb : AABB,  m : matrix[4,4]f32) ->  matrix[4,4]f32 {
	extent := (aabb.max - aabb.min) * [4]f32{0.5,0.5,0.5,1.0}
	center := aabb.min + extent

	// transform center	
	t_center : [4]f32 = m * [4]f32{center.x, center.y, center.z, 1.0}

	abs_mat : matrix[4,4]f32 = ---
	abs_mat[0] = linalg.abs(m[0])
	abs_mat[1] = linalg.abs(m[1])
	abs_mat[2] = linalg.abs(m[2])
	abs_mat[3] = linalg.abs(m[3])

	t_extent : [4]f32 = abs_mat * extent

	return {
		t_extent.x, 0  , 0  , t_center.x,
		0  , t_extent.y, 0  , t_center.y,
		0  , 0  , t_extent.z, t_center.z,
		0  , 0  , 0  , 1,
	}
}


aabb_get_corners :: proc "contextless" (aabb : AABB) -> [8][4]f32 {
	
	corners : [8][4]f32 = ---

	corners[0] = {aabb.min.x, aabb.min.y, aabb.min.z, 1.0}
	corners[1] = {aabb.max.x, aabb.min.y, aabb.min.z, 1.0}
	corners[2] = {aabb.max.x, aabb.min.y, aabb.max.z, 1.0}
	corners[3] = {aabb.min.x, aabb.min.y, aabb.max.z, 1.0}
	corners[4] = {aabb.min.x, aabb.max.y, aabb.min.z, 1.0}
	corners[5] = {aabb.max.x, aabb.max.y, aabb.min.z, 1.0}
	corners[6] = {aabb.min.x, aabb.max.y, aabb.max.z, 1.0}
	corners[7] = {aabb.max.x, aabb.max.y, aabb.max.z, 1.0}

	return corners
}


// @Note - DONT JUST USE THIS. TLDR: reports false-negatives
@(private="file")
aabb_test_frustum_intersection :: proc "contextless" (aabb : AABB, model_view_proj_mat : matrix[4,4]f32) -> bool {

	// This is super simple 
	// just transform all 8 corners of the box to clip space
	// which is between -w..w so we just need to check if any corner is within -w..w to know if its
	// inside the camera frustum

	// However  there are cases where a mesh may be visible inside the frustum even though non of the 
	// corner are inside it. Either if mesh is a very big plane e.g ground plane, or if we get very close to an object.

	within :: proc "contextless" (val, min, max : f32) -> bool {
		return val >= min && val <= max
	}

	corners : [8][4]f32 = #force_inline aabb_get_corners(aabb)

	inside : bool = false

	for i in 0..<8 {
		corner := model_view_proj_mat * corners[i]

		inside = inside || within(corner.x, -corner.w, corner.w) && within(corner.y, -corner.w, corner.w) && within(corner.z, 0.0, corner.w)
	}

	return inside
}