package simdy


import s "core:simd"
import intrin "base:intrinsics"

ZERO_f32x4 :: #simd[4]f32{0.0,0.0,0.0,0.0}
ONE_f32x4  :: #simd[4]f32{1.0,1.0,1.0,1.0}


cast_to_array_f32x4 :: #force_inline proc "contextless" (a: #simd[4]f32) -> (vec: [4]f32) {
	return transmute([4]f32)a;
}

unaligned_load_f32x4 :: #force_inline proc "contextless" (ptr : ^[4]f32) -> #simd[4]f32 {
	return intrin.unaligned_load(cast(^#simd[4]f32)ptr);
}

from_scalar :: proc {
	from_scalar_f32x4,
	from_scalar_i32x4,
	from_scalar_u32x4,
}

from_scalar_f32x4 :: #force_inline proc "contextless" (v : f32) -> #simd[4]f32 {
	return #simd[4]f32{v,v,v,v};
}

from_scalar_i32x4 :: #force_inline proc "contextless" (v : i32) -> #simd[4]i32 {
	return #simd[4]i32{v,v,v,v};
}

from_scalar_u32x4 :: #force_inline proc "contextless" (v : u32) -> #simd[4]u32 {
	return #simd[4]u32{v,v,v,v};
}

from_vec3_f32 :: #force_inline proc "contextless" (v : [3]f32, last : f32 = 0.0) -> #simd[4]f32 {
	return #simd[4]f32{v.x,v.y,v.z,last};
}


// Simd Cross product of two f32 vectors which are expected to be in the registers 0,1,2. 
// Last Register is ignored and may return as garbage.
cross_f32x4 :: proc "contextless" (a : #simd[4]f32, b : #simd[4]f32) -> #simd[4]f32 {
    
    // Note: 
    //from: https://geometrian.com/resources/cross_product/
    
    // C version
    //     [[nodiscard]] inline static __m128 cross_product(
    //     __m128 const& vec0, __m128 const& vec1
    // ) noexcept {
    //     __m128 tmp0 = _mm_shuffle_ps( vec0,vec0, _MM_SHUFFLE(3,0,2,1) );
    //     __m128 tmp1 = _mm_shuffle_ps( vec1,vec1, _MM_SHUFFLE(3,1,0,2) );
    //     __m128 tmp2 = _mm_mul_ps( tmp0, vec1 );
    //     __m128 tmp3 = _mm_mul_ps( tmp0, tmp1 );
    //     __m128 tmp4 = _mm_shuffle_ps( tmp2,tmp2, _MM_SHUFFLE(3,0,2,1) );
    //     return _mm_sub_ps( tmp3, tmp4 );
    //}
        
    // NOTE: We have to invert order of shuffle indecies compared to 
    // the refrence in C above because ODIN simd probably does more sensible not reversed order.

    tmp0 := s.shuffle(a,a,1,2,0,3);
    tmp1 := s.shuffle(b,b,2,0,1,3);
    tmp2 := s.mul(tmp0,b);
    tmp3 := s.mul(tmp0,tmp1);
    tmp0 = s.shuffle(tmp2,tmp2,1,2,0,3); // reuse of tmp0 allocation

    return s.sub(tmp3,tmp0);
}


dot_last_is_0_f32x4 :: dot_unsafe // TODO remove this and keep dot_unsafe

// Unsage because assumes that last lane of one of the vectors is 0. If in doubt use masked_dot() instead.
dot_unsafe :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32) -> f32 {
	return intrin.simd_reduce_add_ordered(s.mul(a,b));
}

// Dot product of two 3D (xyz) vectors. Last lane is ignored.
dot_f32x4 :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32) -> f32 {
	
	// Ensure that at least for one of the two inputs, last value is 0. because we asume that its should represent a 3D vector.
	_b: #simd[4]f32 = s.select(#simd[4]int{ 1, 1, 1, 0}, b, ZERO_f32x4);
	return intrin.simd_reduce_add_ordered(s.mul(a,_b));
}

// Dot product of two vectors but mask out lanes
masked_dot :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32, mask : #simd[4]int = #simd[4]int{ 1, 1, 1, 0}) -> f32 {
	_b: #simd[4]f32 = s.select(mask, b, ZERO_f32x4);
	return intrin.simd_reduce_add_ordered(s.mul(a,_b));
}

saturate_f32x4 :: #force_inline proc "contextless" (a : #simd[4]f32) -> #simd[4]f32 {
	return s.max(s.min(a, ONE_f32x4), ZERO_f32x4);
}

lerp_f32x4 :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32, t : f32) ->  #simd[4]f32 {

	// standard lerp -> (1.0 - t) * a + b * t

	_t : #simd[4]f32 = #simd[4]f32{t,t,t,t};

	tmp0 := s.sub( ONE_f32x4, _t);
	tmp1 := s.mul(tmp0,a);	
	tmp2 := s.mul(b,_t);

	return s.add(tmp1,tmp2);
}

lerp_per_lane_f32x4 :: #force_inline proc "contextless" (a : #simd[4]f32, b : #simd[4]f32, t : #simd[4]f32) -> #simd[4]f32 {
	// standard lerp -> (1.0 - t) * a + b * t

	tmp0 := s.sub( ONE_f32x4, t);
	tmp1 := s.mul(tmp0,a);	
	tmp2 := s.mul(b,t);
	return s.add(tmp1,tmp2);
}