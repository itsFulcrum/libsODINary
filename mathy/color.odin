package mathy

import "core:math"


hsv_to_rgb :: proc(h, s, v: f32) -> [3]f32 {
    c : f32 = v * s
    x : f32 = c * (1.0 - math.abs(math.mod(h * 6.0, 2.0) - 1.0))
    m : f32 = v - c

    r, g, b: f32

    switch {
	    case h < 1.0/6.0:
	        r, g, b = c, x, 0
	    case h < 2.0/6.0:
	        r, g, b = x, c, 0
	    case h < 3.0/6.0:
	        r, g, b = 0, c, x
	    case h < 4.0/6.0:
	        r, g, b = 0, x, c
	    case h < 5.0/6.0:
	        r, g, b = x, 0, c
	    case true:
	        r, g, b = c, 0, x
    }

    return [3]f32{r + m, g + m, b + m}
}
