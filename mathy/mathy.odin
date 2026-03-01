package mathy

import "core:math"
import "core:math/linalg"

pow_i32 :: proc(base: i32, exp: i32) -> i32 {
	result : i32 = 1;
	for i in 0..<exp {
		result *= base;
	}
	return result;
}


noise_hash_1D_01 :: proc(  x :f32 ) -> f32 {
    // setup    
    i := math.floor(x);
    f := linalg.fract(x);
    s := math.sign(linalg.fract(x/2.0)-0.5);
    
    // use some hash to create a random value k in [0..1] from i
  //float k = hash(uint(i));
  //float k = 0.5+0.5*sin(i);
	k := linalg.fract(i*.1731);

    // quartic polynomial
    return s*f*(f-1.0)*((16.0*k-4.0)*f*(f-1.0)-1.0);
}