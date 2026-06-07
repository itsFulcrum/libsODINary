package geometry

import "core:math"
import "core:math/linalg"
import "core:simd"
import "base:intrinsics"

Ray :: struct {
	origin: [3]f32,
	dir: [3]f32,
	inv_dir: [3]f32,
}

SimdRay :: struct {
    origin: #simd[4]f32,
    dir: #simd[4]f32,
    inv_dir: #simd[4]f32,
}


// Reference implementation
// @Note: if instead we have aabb and ray use 4 component vectors this may more easily be optimized with simd instructions at compilation time.
ray_intersects_aabb :: proc "contextless" (ray : Ray, aabb_min : [3]f32, aabb_max : [3]f32, max_ray_dist : f32 = math.INF_F32) -> bool {

    t_min : [3]f32 = (aabb_min - ray.origin) * ray.inv_dir;
    t_max : [3]f32 = (aabb_max - ray.origin) * ray.inv_dir;

    mi : [3]f32 = linalg.min(t_min, t_max)
    ma : [3]f32 = linalg.max(t_min, t_max)

    dist_near : f32 = max(max(mi.x, mi.y), mi.z);
    dist_far  : f32 = min(min(ma.x, ma.y), ma.z);

    // if dist_near > dist_far, ray doesn't intersect AABB
    // if dist_far < 0, ray (line) is intersecting AABB, but the whole AABB is behind us
    did_hit : bool = dist_far >= dist_near && dist_far > 0 && dist_near < max_ray_dist;
    return did_hit;
}

ray_intersects_aabb_dist :: proc "contextless" (ray : Ray, aabb_min : [3]f32, aabb_max : [3]f32, max_ray_dist : f32 = math.INF_F32) -> f32 {

    t_min : [3]f32 = (aabb_min - ray.origin) * ray.inv_dir;
    t_max : [3]f32 = (aabb_max - ray.origin) * ray.inv_dir;

    mi : [3]f32 = linalg.min(t_min, t_max)
    ma : [3]f32 = linalg.max(t_min, t_max)

    dist_near : f32 = max(max(mi.x, mi.y), mi.z);
    dist_far  : f32 = min(min(ma.x, ma.y), ma.z);

    // if dist_near > dist_far, ray doesn't intersect AABB
    // if dist_far < 0, ray (line) is intersecting AABB, but the AABB is behind ray direction
    did_hit : bool = dist_far >= dist_near && dist_near < max_ray_dist && dist_far > 0;
    return did_hit ? dist_near : math.INF_F32;
}




simd_ray_intersects_aabb :: proc "contextless" (ray : SimdRay, aabb_min : #simd[4]f32, aabb_max : #simd[4]f32, max_ray_dist : f32 = math.INF_F32) -> bool {

   
    _t_min : #simd[4]f32 = simd.mul(simd.sub(aabb_min, ray.origin), ray.inv_dir);
    _t_max : #simd[4]f32 = simd.mul(simd.sub(aabb_max, ray.origin), ray.inv_dir);

    _t_min1 := simd.min(_t_min,_t_max);
    _t_max1 := simd.max(_t_min,_t_max);
    
    // Since we do reduce max/min next we ensure last lane is ignored.
    _t_min1 = simd.replace(_t_min1, 3, math.NEG_INF_F32);
    _t_max1 = simd.replace(_t_max1, 3, math.INF_F32);
    
    dist_near : f32 = simd.reduce_max(_t_min1);
    dist_far  : f32 = simd.reduce_min(_t_max1);

    // if dist_near > dist_far, ray doesn't intersect AABB
    // if dist_far < 0, ray (line) is intersecting AABB, but the whole AABB is behind us
    did_hit : bool = dist_far >= dist_near && dist_far > 0 && dist_near < max_ray_dist;
    return did_hit;
}

// Reference implementation
ray_intersects_triangle :: proc "contextless" (ray : Ray, tri_vert_a, tri_vert_b, tri_vert_c : [3]f32, max_ray_dist : f32 = math.INF_F32) -> (did_hit : bool, dist : f32) {

	// could actually pre precompute per triangle..
    edge_ab : [3]f32 = tri_vert_b-tri_vert_a;
    edge_ac : [3]f32 = tri_vert_c-tri_vert_a;

    normal : [3]f32 = linalg.cross(edge_ab, edge_ac);

    ao :  [3]f32 = ray.origin.xyz - tri_vert_a;
    dao : [3]f32 = linalg.cross(ao, ray.dir);


    determinant : f32 = -linalg.dot(ray.dir, normal.xyz);
    inv_det : f32 = 1.0 / determinant;

    distance : f32 = linalg.dot(ao.xyz,normal.xyz) * inv_det;
    u : f32 = linalg.dot(edge_ac.xyz,dao.xyz) * inv_det;
    v : f32 = -linalg.dot(edge_ab.xyz,dao.xyz) * inv_det;

    w : f32 = 1.0 - u -v;
    did_miss :=  distance >= max_ray_dist || distance < 0.0001 || u < 0 || v < 0 || w < 0;
    // @Note: use additional determinant check if we want to backface cull
    //did_miss := determinant < 0.00001 || distance < 0 || u < 0 || v < 0 || w < 0; // use deteiminant check if we want to backface cull

    return !did_miss, distance;
}


simd_ray_intersects_triangle :: proc "contextless" (ray : SimdRay, tri_vert_a, tri_vert_b, tri_vert_c : #simd[4]f32, max_ray_dist : f32 = math.INF_F32) -> bool {

    // @Note: Normally my convention is that simd postions have a value of 1
    // as the w component and direcitons have 0. But in this case we need to enforce postions to have 0 in the last lane

    _pos_a    : #simd[4]f32 = simd.select(#simd[4]u32{1,1,1,0}, tri_vert_a, #simd[4]f32{0,0,0,0});
    _pos_b    : #simd[4]f32 = simd.select(#simd[4]u32{1,1,1,0}, tri_vert_b, #simd[4]f32{0,0,0,0});
    _pos_c    : #simd[4]f32 = simd.select(#simd[4]u32{1,1,1,0}, tri_vert_c, #simd[4]f32{0,0,0,0});

    _edge_ab := simd.sub(_pos_b,_pos_a);
    _edge_ac := simd.sub(_pos_c,_pos_a);        

    _ao := simd.sub(ray.origin, _pos_a);

    _dao := #force_inline simd_cross(_ao, ray.dir);
    _normal :=  #force_inline simd_cross(_edge_ab,_edge_ac);        
    
    // dot product can be done with simd using mul and reduce_add.   dot -> a.x * b.x  +  a.y * b.y  +  a.z * b.z
    _det := simd.mul(ray.dir,_normal);
    _dist := simd.mul(_ao,_normal);
    _u := simd.mul(_edge_ac,_dao);
    _v := simd.mul(_edge_ab,_dao);
    
    determinant : f32 = -intrinsics.simd_reduce_add_ordered(_det);

    inv_det : f32 = 1.0 / determinant;
    distance : f32 = simd.reduce_add_ordered(_dist) * inv_det;
    u : f32 = simd.reduce_add_ordered(_u) * inv_det;
    v : f32 = -simd.reduce_add_ordered(_v) * inv_det;


    w : f32 = 1.0 - u -v;
    did_miss := distance > max_ray_dist || distance < 0 || u < 0 || v < 0 || w < 0;
    
    // @Note: use additional determinant check if we want to backface cull
    //did_miss := determinant < 0.00001 || distance < 0 || u < 0 || v < 0 || w < 0; // use deteiminant check if we want to backface cull

    return !did_miss;
}