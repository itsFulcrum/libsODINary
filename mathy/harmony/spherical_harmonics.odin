package harmony

import "core:math"
import "core:math/linalg"

sh_cartesian_to_spherical :: proc (dir : [3]f32) -> (theta : f32, phi : f32) {
	
	length_xy : f32 = linalg.length( dir.xy );
    theta = linalg.atan2( length_xy, dir.z );
    phi   = linalg.atan2( dir.y , dir.x );

    return theta, phi;
}

// Evaluate an Associated Legendre Polynomial P(l,m,x) at x
eval_legendere_polynomial :: proc(l, m : i32, x : f64) -> f64 {

	pmm: f64  = 1.0;

	if(m > 0) {
		 somx2: f64 = linalg.sqrt((1.0-x)*(1.0+x));
		 fact : f64 = 1.0;
		 
		 for i : i32 = 1; i <= m; i+=1 {
		 	pmm *= (-fact) * somx2;
		 	fact += 2.0;
		 }
	}
	if(l==m){
		return pmm;
	} 

	pmmp1 : f64 = x * (2.0*cast(f64)m+1.0) * pmm;

	if (l==m+1) {
		return pmmp1;
	}	
	
	pll: f64 = 0.0;

	for ll: i32 = m+2; ll<=l; ll+=1 {

		pll = ( (2.0*cast(f64)ll-1.0) * x *pmmp1-( cast(f64)ll+ cast(f64)m-1.0)*pmm ) / cast(f64)(ll-m);
		pmm = pmmp1;
		pmmp1 = pll;
	}
	return pll;
}

// fast type version of 'eval_legendere_polynomial'
sh_p :: proc(l,m : i32, x : f64) -> f64 {
 	return #force_inline eval_legendere_polynomial(l,m, x);
}

// renormalisation constant for SH function
sh_k :: proc( l, m: i32) -> f64 {
	tmp : f64 = ((2.0* cast(f64)l + 1.0) * cast(f64)math.factorial( cast(int)(l-m) )) / (4.0 * math.PI * cast(f64)math.factorial( cast(int)(l+m) ));
	return linalg.sqrt(tmp);
}



// get sh basis function for given l,m and spherical coordinates by doing slow polynomial evaluation.
estimate_sh :: proc(l,m: i32, theta, phi : f64) -> f64 {
 	
 	if(m==0) {
 		return sh_k( l , 0) * sh_p( l, m, linalg.cos(theta) );
 	}
 	else if (m>0) {

 		return math.SQRT_TWO * sh_k(l,m) * linalg.cos( cast(f64)m *phi) * sh_p(l,m,linalg.cos(theta));
 	}

	return math.SQRT_TWO * sh_k(l,-m) * linalg.sin( cast(f64)(-m) * phi) * sh_p(l,-m,linalg.cos(theta));
}


// Get sh basis function for given l,m and cartesian direcition vector (normalized)
// Uses faster precalculated (and slightly less accurate) math
estimate_sh_fast :: proc ( l,m: i32, dir : [3]f32 ) -> f32{

	x  : f32 = dir.x;
    y  : f32 = dir.y;
    z  : f32 = dir.z;
    xx : f32 = x*x;
    yy : f32 = y*y;
    zz : f32 = z*z;

    if(l == 0){
        // l0 = 1 coef
        return  0.282095;
    }
    else if( l == 1){
    	// l1 = 4 coef
        switch (m) {
			case -1: return -0.488603 * y;
			case  0: return  0.488603 * z;
			case  1: return -0.488603 * x;
		}
    }
    else if( l == 2) {
    	// l2 = 9 coef
        switch (m) {
	        case -2: return  1.092548 * x * y;
			case -1: return -1.092548 * y * z;
			case  0: return  0.315392 * (-x * x - yy + 2.0*zz);
			case  1: return -1.092548 * x * z;
			case  2: return  0.546274 * (xx - yy);
		}
    }
    else if(l == 3) {
    	// l3 = 16 coef
        switch (m) {
	        case -3: return -0.590044 * y * (3.0 * xx - yy);
	        case -2: return  2.890611 * x * y * z;
			case -1: return -0.457046 * y * (4.0 * zz - xx - yy) ;
			case  0: return  0.373176 * z * (2.0 * zz - 3.0 * xx - 3.0 * yy);
			case  1: return -0.457046 * x * (4.0 * zz - xx - yy) ;
			case  2: return  1.445306 * z * ( xx - yy );
			case  3: return -0.590044 * x * (xx - 3.0*yy);
		}
    }
    else if(l == 4) {
    	// l4 = 25 coef

        switch (m) {
	        case -4: return  2.50334294179670453835 * x * y * (xx-yy);
	        case -3: return -1.77013100000000000000 * y * z * ( 3.0 * xx - yy);
	        case -2: return  0.94617469575756001809 * x * y * (7.0*zz - 1.0);
			case -1: return -0.66904654355728916795 * y * z * (7.0 * zz - 3.0);
			case  0: return  0.10578554691520430380 * (35.0 * zz*zz  - 30.0 * zz + 3.0);
			case  1: return -0.66904654355728916795 * x * z * (7.0 * zz - 3.0);
			case  2: return  0.47308734787878000905 * (xx - yy) * (7.0*zz -1.0);
			case  3: return -1.77013076977993053104 * x * z * (xx - 3.0 * yy);
			case  4: return  0.62583573544917613459 * ( xx * (xx - 3.0 * yy) - yy * (3.0 * xx - yy) );
		}
    }
    else if(l == 5){
    	//l5 = 36
    	x4 : f32 = xx*xx;
    	y4 : f32 = yy*yy;
    	z4 : f32 = zz*zz;

		switch (m) {
	        case -5: return -0.1093970094733616838 * y * (30.0*x4 - 60.0*xx*yy + 6.0*y4);
	        case -4: return  8.3026492595241651159 * x * y * z * (xx - yy);
	        case -3: return -0.2446191497176251938 * y * (-6.0*xx + 2.0*yy + 54.0*xx*zz - 18.0*yy*zz);
	        case -2: return  1.1983841962433309387 * x * y * z * (8.0 - 12.0*xx - 12.0*yy);
			case -1: return -0.4529466511956969213 * y * (8 - 28*xx - 28*yy + 21*x4 + 42*xx*yy + 21*y4);
			case  0: return  0.1169503224534235964 * z * (8 - 56*xx - 56*yy + 63*x4 + 126 * xx*yy + 63*y4);
			case  1: return -0.4529466511956969213 * x * (8 - 28*xx - 28*yy + 21*x4 + 42*xx*yy + 21*y4);
			case  2: return -2.3967683924866618775 * z * (x - y) * (x + y) * ( -2 + 3*xx + 3*yy);
			case  3: return  0.4892382994352503877 * x * (1 - 3*z) * (1 + 3*z)*(xx - 3*yy);
			case  4: return  2.0756623148810412790 * z * (x4 - 6*xx* yy + y4);
			case  5: return -0.6563820568401701028 * x * (x4 - 10*xx*yy + 5*y4);
		}
    
    }
    else if(l == 6){
    	//l6 = 49
    	x4 : f32 = xx*xx;
    	y4 : f32 = yy*yy;
    	z4 : f32 = zz*zz;
    	xxyy : f32 = xx*yy;
    	xy : f32 = x*y;
    	xz : f32 = x*z;
    	yz : f32 = y*z;
    	xxmyy : f32 = xx-yy;
    	x4py4 : f32 = x4+y4;

		switch (m) {
			case -6: return  0.34159205259595716099 * xy * (12.0*(x4py4) - 40.0*xxyy);
		    case -5: return -0.39443652703862533866 * yz * (30.0*x4 - 60.0*xxyy + 6.0*y4);
			case -4: return  0.08409415012145402654 * xy *(240.0*(xxmyy) - 264.0*x4 + 264.0*y4);
			case -3: return -0.46060262975746174957 * yz * (48.0 * xx - 16.0*yy - 66.0*x4 - 44.0*xxyy + 22.0*y4);
			case -2: return  0.23030131487873087479 * xy *(64.0 - 192.0*xx - 192.0*yy + 132.0*(x4py4) + 264.0*xxyy);
			case -1: return -0.58262136251873138884 * yz * (8 - 36*xx - 36*yy + 33*(x4py4) + 66*xxyy);
			case  0: return  0.06356920226762842593 * (16 - 168*xx - 168*yy + 378*x4 + 378*y4 + 756*xxyy - 231*x4*xx - 231*y4*yy - 693*x4*yy - 693*xx*y4);		
			case  1: return -0.58262136251873138884 * xz * (8 - 36*xx - 36*yy + 33*(x4py4) + 66*xxyy );
			case  2: return  0.46060262975746174957 * (x - y) * (x + y) * (16 - 48*xx - 48*yy + 33*(x4py4) + 66*xxyy );
			case  3: return  0.92120525951492349914 * xz *(xx - 3*yy) *(-8 + 11*(xx+yy) );
			case  4: return  0.50456490072872415925 * (-10 + 11*(xx+yy) ) * ( -xx + 2 * xy + yy) * (xxmyy + 2*xy);
			case  5: return -2.36661916223175203199 * xz * (x4 - 10*xxyy + 5*y4);
			case  6: return  0.68318410519191432197 * (x4*xx - 15*x4*yy + 15*xx*y4 - y4*yy);
		}
    }
    else if(l == 7) {
    	
    	x4 : f32 = xx*xx;
    	y4 : f32 = yy*yy;
    	z4 : f32 = zz*zz;

    	x6 : f32 = x4*xx;
    	y6 : f32 = y4*yy;
    	z6 : f32 = z4*zz;

    	xxyy : f32 = xx*yy;
    	xy : f32 = x*y;
    	xyz : f32 = x*y*z;
    	x4py4 : f32 = x4+y4;
    	x4yy : f32 = x4*yy;
    	xxy4 : f32 = xx*y4;

		switch (m) {
			case -7: return -0.11786045542076602970 * y * (42.0*x6 - 210.0*x4yy + 126.0*xxy4 - 6.0*y6);
			case -6: return  0.44099344363365003700 * xyz * (36.0*(x4py4) - 120.0*xxyy);
			case -5: return -0.08648592978671005329 * y * (360.0*x4 - 720.0*xxyy + 72.0*y4 - 390.0*x6 + 390.0*x4yy + 702.0*xxy4 - 78.0*y6);
			case -4: return  0.17297185957342010658 * xyz * (240.0*(xx-yy) - 312.0*x4 + 312.0*y4);
			case -3: return -0.02607648897704900561 * y * (1440.0*xx - 480.0*yy - 3960.0*x4 - 2640.0*xxyy + 1320.0*y4 + 2574.0*x6 + 4290.0*x4yy + 858.0*(xxy4 - y6));
			case -2: return  0.03687772437041521940 * xyz * (576.0 - 2112.0*xx - 2112.0*yy + 1716.0*(x4py4) + 3432.0*xxyy);
			case -1: return -5.78122288528110811078 * y * (1.0 - 6.75*xx - 6.75*yy + 12.375*(x4py4) + 24.75*xxyy - 6.703125*x6 - 20.109375*x4yy - 20.109375*xxy4 - 6.703125*y6);
			case  0: return  0.06828427691200494191 * z * (16 - 216*xx - 216*yy + 594*(x4py4) + 1188*xxyy - 429*x6 - 1287*x4yy - 1287*xxy4 - 429*y6);
			case  1: return -0.09033160758251731423 * x * (64 - 432*xx - 432*yy + 792*(x4py4) + 1584*xxyy - 429*x6 - 1287*x4yy - 1287*xxy4 - 429*y6);
			case  2: return  0.22126634622249131638 * z * (x - y)*(x + y)*(48 - 176*xx - 176*yy + 143*(x4py4) + 286*xxyy);
			case  3: return -0.15645893386229403365 * x * (xx - 3*yy)*(80 - 220*xx - 220*yy + 143*(x4py4) + 286*xxyy);
			case  4: return  1.03783115744052063950 * z * (-10 + 13*(xx+yy)) * (-xx + 2*xy + yy)* (xx + 2*xy - yy);
		    case  5: return  0.51891557872026031975 * x * (-12 + 13*(xx+yy) ) * (x4 - 10*xxyy + 5*y4);
			case  6: return  2.64596066180190022197 * z * (x6 - 15*x4yy + 15*xxy4 - y6);
			case  7: return -0.70716273252459617823 * x * (x6 - 21*x4yy + 35*xxy4 - 7*y6);
		}
    }

    // do it the slow way
    theta , phi := #force_inline sh_cartesian_to_spherical(dir);

    return cast(f32)estimate_sh(l, m,cast(f64)theta, cast(f64)phi);
}