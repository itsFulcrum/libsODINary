package mathy

import "core:math"
import "core:math/linalg"

cartesian_to_spherical :: proc "contextless" (dir : [3]f32) -> (theta : f32, phi : f32) #no_bounds_check {
    
    length_xy : f32 = linalg.length( dir.xy );
    theta = linalg.atan2( length_xy, dir.z );
    phi   = linalg.atan2( dir.y , dir.x );

    return theta, phi;
}

spherical_to_cartesian :: proc "contextless" (theta: f32, phi: f32) -> [3]f32 #no_bounds_check {

    return [3]f32{
        linalg.sin(theta)*linalg.cos(phi), // x
        linalg.sin(theta)*linalg.sin(phi), // y
        linalg.cos(theta) ,                 // z
    };
}


rotate_around_axis_radians :: proc "contextless" (In : [3]f32, Axis : [3]f32,  Rotation : f32) -> [3]f32 #no_bounds_check {
    s : f32 = linalg.sin(Rotation);
    c : f32 = linalg.cos(Rotation);
    one_minus_c := 1.0 - c;
    axis_times_c := Axis * one_minus_c;
    axis_times_s := Axis * s;

    rot_mat : matrix[3,3]f32;
    rot_mat[0][0] = axis_times_c.x * Axis.x + c;
    rot_mat[1][0] = axis_times_c.x * Axis.y - axis_times_s.z;
    rot_mat[2][0] = axis_times_c.z * Axis.x + axis_times_s.y;
    rot_mat[0][1] = axis_times_c.x * Axis.y + axis_times_s.z;
    rot_mat[1][1] = axis_times_c.y * Axis.y + c;
    rot_mat[2][1] = axis_times_c.y * Axis.z - axis_times_s.x;
    rot_mat[0][2] = axis_times_c.z * Axis.x - axis_times_s.y;
    rot_mat[1][2] = axis_times_c.y * Axis.z + axis_times_s.x;
    rot_mat[2][2] = axis_times_c.z * Axis.z + c;
    return rot_mat * In;
}

any_perpendicular :: proc "contextless" (vec : [3]f32) -> [3]f32 {
    
    if abs(vec.z) < 0.999 {
        return linalg.normalize(linalg.cross(vec, [3]f32{0,0,1}));
    } 

    return linalg.normalize(linalg.cross(vec, [3]f32{0,1,0}));
}

vec2_rotate_angle :: proc "contextless" (vec : [2]f32, angle_radians : f32) -> [2]f32 {
    c : f32 = linalg.cos(angle_radians);
    s : f32 = linalg.sin(angle_radians);
    return [2]f32{
        vec.x * c - vec.y * s,
        vec.x * s + vec.y * c
    }
}


// Vulkan style perspective projection matrix that maps z into range 0..1 instead of OpenGl style -1..1
@(require_results)
matrix4_perspective_z0to1_f32 :: proc "contextless" (fovy, aspect, near, far: f32, flip_z_axis : bool = true, reversed_z_buffer : bool = false) -> (m: matrix[4,4]f32) #no_bounds_check {
   
    tan_half_fovy := math.tan(0.5 * fovy)
    m[0, 0] = 1 / (aspect*tan_half_fovy)
    m[1, 1] = 1 / (tan_half_fovy)


    n, f := near, far;

    if reversed_z_buffer {
        n, f = far, near;
    }

    m[2, 2] = f / (f - n)
    m[3, 2] = +1
    m[2, 3] = -1 * f * n / (f - n)
    

    if flip_z_axis {
        m[2] = -m[2]
    }

    return
}

// Vulkan style orthographic projection matrix that maps z into range 0..1 instead of OpenGl style -1..1
@(require_results)
matrix_orthographic_z0to1_f32 :: proc "contextless" (left, right, bottom, top, near_plane, far_plane: f32, flip_z_axis := true, reversed_z_buffer : bool = false) -> (m: matrix[4,4]f32) #no_bounds_check {
    

    near, far := near_plane, far_plane;

    if reversed_z_buffer {
        near, far = far_plane, near_plane;
    }

    m[0, 0] = +2 / (right - left)
    m[1, 1] = +2 / (top - bottom)
    m[2, 2] = +1 / (far - near)
    
    m[0, 3] = -(right + left)   / (right - left)
    m[1, 3] = -(top   + bottom) / (top - bottom)
    m[2, 3] = -(near) / (far- near)
    m[3, 3] = 1

    if flip_z_axis {
        m[2] = -m[2]
    }

    return
}
