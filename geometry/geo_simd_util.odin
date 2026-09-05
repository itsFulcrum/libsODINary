package geometry

import s "core:simd"
import intrin "base:intrinsics"

SIMD_ZERO_f32x4 :: #simd[4]f32{0.0,0.0,0.0,0.0}
SIMD_ONE_f32x4  :: #simd[4]f32{1.0,1.0,1.0,1.0}


// simd_cast_to_array_f32x4 :: #force_inline proc "contextless" (a: #simd[4]f32) -> (vec: [4]f32) {
// 	return transmute([4]f32)a;
// }

// simd_unaligned_load_f32x4 :: #force_inline proc "contextless" (ptr : ^[4]f32) -> #simd[4]f32 {
// 	return intrin.unaligned_load(cast(^#simd[4]f32)ptr);
// }

simd_from_scalar :: proc {
	simd_from_scalar_f32x4,
	simd_from_scalar_i32x4,
	simd_from_scalar_u32x4,
}

simd_from_scalar_f32x4 :: #force_inline proc "contextless" (v : f32) -> #simd[4]f32 {
	return #simd[4]f32{v,v,v,v}
}

simd_from_scalar_i32x4 :: #force_inline proc "contextless" (v : i32) -> #simd[4]i32 {
	return #simd[4]i32{v,v,v,v}
}

simd_from_scalar_u32x4 :: #force_inline proc "contextless" (v : u32) -> #simd[4]u32 {
	return #simd[4]u32{v,v,v,v}
}

simd_from_vec3_f32 :: #force_inline proc "contextless" (v : [3]f32, last : f32 = 0.0) -> #simd[4]f32 {
	return #simd[4]f32{v.x,v.y,v.z,last}
}


// Simd Cross product of two f32 vectors which are expected to be in the registers 0,1,2. 
// Last lane is ignored and may return as garbage.
simd_cross :: proc "contextless" (a : #simd[4]f32, b : #simd[4]f32) -> #simd[4]f32 {
    //from: https://geometrian.com/resources/cross_product/
    tmp0 := s.shuffle(a,a,1,2,0,3)
    tmp1 := s.shuffle(b,b,2,0,1,3)
    tmp2 := s.mul(tmp0,b)
    tmp3 := s.mul(tmp0,tmp1)
    tmp0 = s.shuffle(tmp2,tmp2,1,2,0,3) // reuse of tmp0 allocation

    return s.sub(tmp3,tmp0)
}

// Unsafe because assumes that last lane of one of the vectors is 0. If in doubt use masked_dot() instead.
simd_dot_unsafe :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32) -> f32 {
	return intrin.simd_reduce_add_ordered(s.mul(a,b))
}

// // Dot product of two 3D (xyz) vectors. Last lane is ignored.
// simd_dot_f32x4 :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32) -> f32 {
	
// 	// Ensure that at least for one of the two inputs, last value is 0. because we asume that its should represent a 3D vector.
// 	_b: #simd[4]f32 = s.select(#simd[4]int{ 1, 1, 1, 0}, b, ZERO_f32x4);
// 	return intrin.simd_reduce_add_ordered(s.mul(a,_b));
// }

// Dot product of two vectors but mask out last lanes
simd_masked_dot :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32, mask : #simd[4]int = #simd[4]int{ 1, 1, 1, 0}) -> f32 {
	_b: #simd[4]f32 = s.select(mask, b, SIMD_ZERO_f32x4)
	return intrin.simd_reduce_add_ordered(s.mul(a,_b))
}