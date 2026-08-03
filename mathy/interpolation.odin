package mathy

import "core:math"
import "core:math/linalg"

inv_lerp :: proc {
    inv_lerp_f32,
}

lerp :: proc {
    lerp_f32,
}

lerp_f32 :: proc "contextless" (a,b,t :f32) -> f32 {
    return (1.0 - t) * a + b * t;
}

inv_lerp_f32 :: proc "contextless" (a,b, v :f32) -> f32 {
    return (v-a) / (b - a);
}

lerp_smooth :: proc {
    lerp_smooth_f32,
    lerp_smooth_2f32,
    lerp_smooth_3f32,
    lerp_smooth_4f32,
}


lerp_smooth_f32 :: proc "contextless" (a : f32, b: f32, t : f32, delta_seconds : f32) -> f32{
    // @Note: decay usefull range 1 - 25: Watch Freya Holmer Talk on Lerp Smoothing.

    decay : f32 =  (1.0 - t) + (25.0 * t);

    return b + (a-b) * math.exp_f32(-decay * delta_seconds);
}

lerp_smooth_2f32 :: proc "contextless" (a : [2]f32, b: [2]f32, t : f32, delta_seconds : f32) -> [2]f32 {
    // @Note: decay usefull range 1 - 25: Watch Freya Holmer Talk on Lerp Smoothing.
    decay : f32 =  (1.0 - t) + (25.0 * t);
    return b + (a-b) * math.exp_f32(-decay * delta_seconds);
}

lerp_smooth_3f32 :: proc "contextless" (a : [3]f32, b: [3]f32, t : f32, delta_seconds : f32) -> [3]f32 {
    // @Note: decay usefull range 1 - 25: Watch Freya Holmer Talk on Lerp Smoothing.
    decay : f32 =  lerp_f32(1.0, 25.0, t);
    return b + (a-b) * math.exp_f32(-decay * delta_seconds);
}

lerp_smooth_4f32 :: proc "contextless" (a : [4]f32, b: [4]f32, t : f32, delta_seconds : f32) -> [4]f32 {
    // @Note: decay usefull range 1 - 25: Watch Freya Holmer Talk on Lerp Smoothing.
    decay : f32 =  lerp_f32(1.0, 25.0, t);
    return b + (a-b) * math.exp_f32(-decay * delta_seconds);
}

quaternion_slerp_smooth :: proc {
    quaternion_slerp_smooth_f32,
}

quaternion_slerp_smooth_f32 :: proc "contextless" (a, b: quaternion128, t : f32, delta_seconds : f32) -> (q: quaternion128) {
    // @Note: decay usefull range 1 - 25: Watch Freya Holmer Talk on Lerp Smoothing.
    decay : f32 =  lerp_f32(1.0, 25.0, t);
    slerp_t : f32 = 1.0 - math.exp_f32(-decay * delta_seconds)
    return linalg.quaternion_slerp(a, b, t);
}