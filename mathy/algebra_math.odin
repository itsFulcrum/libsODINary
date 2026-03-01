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


// produce a perpective matrix where clip values are in z range 0..1 instead of -1..1 as the procedure in odins math/linalg package does.
matrix4_perspective_01_f32 :: proc "contextless" (fovy, aspect, near, far: f32, flip_z_axis: bool = true) -> (m: matrix[4,4]f32) #no_bounds_check {
    tan_half_fovy := math.tan(0.5 * fovy);
    m[0, 0] = 1 / (aspect*tan_half_fovy);
    m[1, 1] = 1 / (tan_half_fovy);
    m[2, 2] = far / (far - near);
    m[3, 2] = 1;
    m[2, 3] = - ( far * near / (far - near) );

    if flip_z_axis {
        m[2] = -m[2];
    }

    return;
}
