package mathy

import "core:math"
import "core:math/linalg"

oct_wrap :: proc( v : [2]f32 ) -> [2]f32 {
	w : [2]f32 = 1.0 - linalg.abs( v.yx );
    
    if (v.x < 0.0) {
     w.x = -w.x;
    }

    if (v.y < 0.0) {
    	w.y = -w.y;
    }
    return w;
}

oct_wrap_texel_coordinates :: proc(texel : [2]i32, texSize: [2]i32) -> [2]i32 {
  
  wrapped := ((texel % texSize) + texSize) % texSize;
  return (((( math.abs(texel.x / texSize.x) + i32(texel.x < 0)) ~ (math.abs(texel.y / texSize.y) + i32(texel.y < 0))) & 1) != 0) ? (texSize - (wrapped + 1)) : wrapped;

// glsl code
// return (((( math.abs( texel.x / texSize.x) +  i32( texel.x < 0) ) ^ (math.abs(texel.y / texSize.y) + i32(texel.y < 0))) & 1) != 0) ? (texSize - (wrapped + ivec2(1))) : wrapped;
}

 
oct_encode :: proc(dir : [3]f32) -> [2]f32 {

	n := dir;

    n /= ( math.abs( n.x ) + math.abs( n.y ) + math.abs( n.z ) );
    n.xy = n.z > 0.0 ? n.xy : oct_wrap( n.xy );
    n.xy = n.xy * 0.5 + 0.5; // map from -1..1 to 0..1 range
    return n.xy;
}

oct_decode :: proc(encoded : [2]f32) -> [3]f32 {
   	f := encoded * 2.0 - 1.0; // map from 0..1 to -1..1 range 
    //f := encoded; // map from 0..1 to -1..1 range 
    // https://twitter.com/Stubbesaurus/status/937994790553227264
    n : [3]f32 = { f.x, f.y, 1.0 - math.abs( f.x ) - math.abs( f.y ) };
    
    t : f32 = max( -n.z, 0.0 );
    
    n.x += n.x >= 0.0 ? -t : t;
    n.y += n.y >= 0.0 ? -t : t;
    
    return linalg.normalize(n);
}