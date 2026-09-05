package geometry

import "core:mem"
import "core:math"
// import "core:math/linalg"

// implementation mostly follows this article: 
// https://jacco.ompf2.com/2022/04/13/how-to-build-a-bvh-part-1-basics/

BVH_CONFIG_USE_BINNING :: true

BvhNode :: struct { // 32 bytes
	aabb_min    : [3]f32,
	left_first  : u32,    // if leaf node, this is first triangle index. if not a leaf this is the left child index. right child index is left_first + 1
	aabb_max    : [3]f32,
	count       : u32,    // primitive/triangle count. if > 0 node is a leaf.
}

// Output structure containing a list of bvh nodes where nodes[0] is the root node
// and child nodes are pointed to via indexes into this array.
BvhInfo :: struct {
	nodes : []BvhNode,
	indecies : []u32,		
}

// Internal construction info
@(private="file")
BvhBuildInfo :: struct {
	max_tree_depth : u32, // if == 0, infinite tree depth.

	nodes : []BvhNode,
	num_nodes_used : uint,

	// Temp storage for split bin data
	num_split_planes : u32,
	split_bins : []BvhSplitBin,

	split_plane_area_left   : []f32,
	split_plane_area_right  : []f32,
	split_plane_count_left  : []u32,
	split_plane_count_right : []u32,

	// One center pos per triangle which means len(tri_centroids) == len(indecies) / 3
	tri_centroids : [][3]f32,
	// Vertex Indecies into original vertex buffer but with change order.
	indecies      : []u32,

	// Original supplied vertex buffer. 
	// Not Owned by BVH builder!
	vertex_buf : [^]byte, 
	vertex_byte_size : uint,
}

// TODO: could make this tighter and fit it into 32 bytes.
BvhSplitBin :: struct {
	aabb : AABB,
	count : u32,
}

bvh_release_bvh_info :: proc(info : ^BvhInfo){
	
	if info == nil {
		return
	}

	delete(info.indecies)
	info.indecies = nil
	delete(info.nodes)
	info.nodes = nil
}

bvh_reset_all_bins :: proc(bins : []BvhSplitBin) {
	for &bin in bins {
		bin.aabb = aabb_create_inverse_infinite()
		bin.count = 0
	}
}

// assumes vertex postions to be a [3]f32 (float3) in the first 12 bytes for each vertex.
// Max tree depth can be used to limit tree depth. Value of 0 means tree depth is unbounded.
bvh_build_bottom_level :: proc(vertex_buf : [^]byte, vertex_byte_size : uint, indecies : [^]u32, num_indecies : uint, num_split_planes : u32 = 0, max_tree_depth : u32 = 0) -> BvhInfo {
	
	info : BvhBuildInfo
	info.vertex_buf 	  = vertex_buf
	info.vertex_byte_size = vertex_byte_size
	info.max_tree_depth   = max_tree_depth

	info.num_split_planes = num_split_planes
	when BVH_CONFIG_USE_BINNING {
		// Allocate temporary storage for bin data.
		
		// @Note:
		// if num_split_planes <= 1 we instead do a high quality tree where we evaluate every possible split plane gathered from primitve centers.
		use_binning : bool = num_split_planes > 1
		if use_binning {
			num_intervals : u32 = num_split_planes + 1
			info.split_bins 			 = make_slice([]BvhSplitBin, cast(int)(num_intervals), context.temp_allocator)

			info.split_plane_area_left   = make_slice([]f32, cast(int)(num_split_planes), context.temp_allocator)
			info.split_plane_area_right  = make_slice([]f32, cast(int)(num_split_planes), context.temp_allocator)
			info.split_plane_count_left  = make_slice([]u32, cast(int)(num_split_planes), context.temp_allocator)
			info.split_plane_count_right = make_slice([]u32, cast(int)(num_split_planes), context.temp_allocator)
		}
	}

	num_expected_triangles : uint = num_indecies / 3
	
	// Make copy of indecies which we will mutate throughout building the bvh
	info.indecies  = make_slice([]u32, cast(int)num_indecies, context.allocator)
	mem.copy(&info.indecies[0], &indecies[0], cast(int)num_indecies * size_of(u32))	

	// Precompute a center postion for each triangle which we will refer to many times during construction.
	info.tri_centroids = make_slice([][3]f32, cast(int)num_expected_triangles, context.allocator)
	defer delete_slice(info.tri_centroids)

	root_aabb : AABB = aabb_create_inverse_infinite()
	triangle_index : uint = 0 
	for i : uint = 0; i < num_indecies; i += 3 {
		tri : [3][3]f32 = bvh_get_triangle_positions(&info, triangle_index)
		info.tri_centroids[triangle_index] = (tri[0] + tri[1] + tri[2]) * 0.333333
		triangle_index += 1
		
		aabb_grow_by_point(&root_aabb, tri[0])
		aabb_grow_by_point(&root_aabb, tri[1])
		aabb_grow_by_point(&root_aabb, tri[2])
	}

	num_triangles : uint = triangle_index

	// If this does not hold there is likely a problem with the index buffer or it contaions non triangle faces
	assert(num_expected_triangles == num_triangles)

	// @Note: technically this would need a '-1' here but we skip one node after root to align child nodes to 64 cache line boundries
	max_node_count : uint = num_triangles * 2
	info.nodes = make_slice([]BvhNode, cast(int)max_node_count, context.allocator)

	
	// Initialize root with all triangles and no child nodes.	
	root : ^BvhNode = &info.nodes[0]
	root.left_first = 0
	root.count  = cast(u32)num_triangles
	root.aabb_min = root_aabb.min.xyz
	root.aabb_max = root_aabb.max.xyz

	info.num_nodes_used  = 1 // Root node
	info.num_nodes_used += 1 // Skip one node after the root node.
	
	bvh_subdivide_recursiv(&info, root)
	
	// @Note: Would like to free the unused memory after num_nodes_used but not sure thats possible without making a new allocation.
	out_info := BvhInfo {
		nodes = info.nodes[0:info.num_nodes_used],
		indecies = info.indecies,
	}
	
	return out_info
}

bvh_is_leaf_node :: #force_inline proc "contextless" (node : ^BvhNode) -> bool {
	return node.count > 0
}

bvh_calculate_node_cost :: proc(node : ^BvhNode) -> f32 {
	node_aabb := aabb_from_min_max_vec3(node.aabb_min, node.aabb_max)
	return f32(node.count) * aabb_calculate_surface_area(node_aabb)
}

@(private="file")
bvh_recalculate_node_aabb :: proc (info : ^BvhBuildInfo, node : ^BvhNode) {

	aabb := aabb_create_inverse_infinite()
	
	for i : u32 = 0; i < node.count; i += 1 {

		leaf_tri : [3][3]f32 = bvh_get_triangle_positions(info, uint(node.left_first + i))
		aabb_grow_by_point(&aabb, leaf_tri[0])
		aabb_grow_by_point(&aabb, leaf_tri[1])
		aabb_grow_by_point(&aabb, leaf_tri[2])
	}

	node.aabb_min = aabb.min.xyz
	node.aabb_max = aabb.max.xyz
}

@(private="file")
bvh_split_node_midpoint :: proc(node : ^BvhNode) -> (split_axis : u32, split_pos_along_axis : f32) {

	extent : [3]f32 = node.aabb_max - node.aabb_min
	axis : u32 = 0
	if extent.y > extent.x {
		axis = 1
	}
	if extent.z > extent[axis] {
		axis = 2
	}
	// split position along the longest axis of the nodes aabb
	split_pos : f32 = node.aabb_min[axis] + extent[axis] * 0.5

	return axis, split_pos
}

// num_split_planes is a quality metric of how many split planes to evalute.
// values <= 1 mean best quality where we evaluate every possilbe split plane and 
// values > 1 mean how many split planes to evaluate per axis and higher values will result in better quality.
@(private="file")
bvh_find_best_split_plane :: proc(info : ^BvhBuildInfo, node : ^BvhNode) -> (split_axis : u32, split_pos_along_axis : f32, split_cost : f32){

	assert(bvh_is_leaf_node(node))

	best_axis : u32 = 0
	best_pos  : f32 = 0
	best_cost : f32 = math.INF_F32

	if info.num_split_planes <= 1 {

		// Very Good quality tree where we evalute split planes at each primitve centroid for each axis
		// Very Slow to build though
		for axis : u32 = 0; axis < 3; axis += 1 {
			for i : u32 = 0; i < node.count; i+=1{

				tri_index : uint = uint(node.left_first + i)

				candidate_pos : f32 = info.tri_centroids[tri_index][axis]
				cost : f32 = bvh_evaluate_surface_area_heuristic(info, node, axis, candidate_pos)

				if cost < best_cost{
					best_cost = cost
					best_pos = candidate_pos
					best_axis = axis
				}
			}
		}

	} else {
		
		// Intialze axis candidate to xyz order, then sort them by longest axis.
		// We then only evalute the two longest axis and skip the shortest one for faster builds.
		axis_candidates := [3]u32{0,1,2}
		extent : [3]f32 = node.aabb_max - node.aabb_min

		if extent.y > extent.x {
			axis_candidates.xy = axis_candidates.yx
		}
		if extent.z > extent[axis_candidates[1]] {
			axis_candidates.yz = axis_candidates.zy
		}
		// This test is redundant because we will evaluate the first two candidate anyway.
		if extent[axis_candidates[1]] > extent[axis_candidates[0]] {
			axis_candidates.xy = axis_candidates.yx
		}

		assert(extent[axis_candidates[0]] >= extent[axis_candidates[1]])
		assert(extent[axis_candidates[1]] >= extent[axis_candidates[2]])

		num_intervals : u32 = info.num_split_planes + 1

		// evaluate 2 longest axis
		for a in 0..<2 {

			axis : u32 = axis_candidates[a]

			// Find bounds of the centroids which is smaller than the bounds of the whole aabb
			bounds_min : f32 = info.tri_centroids[node.left_first][axis]
			bounds_max : f32 = info.tri_centroids[node.left_first][axis]

			for i : u32 = 1; i < node.count; i+=1 {
				tri_index : u32 = node.left_first + i
				bounds_min = min(bounds_min, info.tri_centroids[tri_index][axis])
				bounds_max = max(bounds_max, info.tri_centroids[tri_index][axis])
			}

			if bounds_min == bounds_max {
				continue
			}


			when BVH_CONFIG_USE_BINNING {

				bvh_reset_all_bins(info.split_bins)
				
				// num_intervals == num_bins
				bin_scale : f32 = f32(num_intervals) / (bounds_max - bounds_min)

				// Figure out which bin a triangle belongs to and update the bin.
				for i : u32 = 0; i < node.count; i+=1 {
					
					tri_index : u32 = node.left_first + i
					tri : [3][3]f32 = bvh_get_triangle_positions(info, cast(uint)tri_index)

					bin_index : u32 = min(num_intervals - 1, cast(u32)((info.tri_centroids[tri_index][axis] - bounds_min) * bin_scale)  )
					info.split_bins[bin_index].count += 1
					aabb_grow_by_point(&info.split_bins[bin_index].aabb, tri[0])
					aabb_grow_by_point(&info.split_bins[bin_index].aabb, tri[1])
					aabb_grow_by_point(&info.split_bins[bin_index].aabb, tri[2])
				}

				assert(info.num_split_planes == num_intervals - 1)

				// For each split plane we calculate the left and right aabb surface area and tri_count
				// Sweep left to right and right to left simulatneously to gather per split plane data.
				left_aabb  : AABB = aabb_create_inverse_infinite()
				right_aabb : AABB = aabb_create_inverse_infinite()
				left_sum, right_sum : u32 = 0, 0
				
				for i : u32 = 0; i < info.num_split_planes; i +=1 {
					
					left_sum += info.split_bins[i].count
					info.split_plane_count_left[i] = left_sum
					left_aabb = aabb_combine(left_aabb, info.split_bins[i].aabb)
					info.split_plane_area_left[i] = aabb_calculate_surface_area(left_aabb)					

					right_sum += info.split_bins[num_intervals - 1 - i].count
					info.split_plane_count_right[num_intervals - 2 - i] = right_sum
					right_aabb = aabb_combine(right_aabb, info.split_bins[num_intervals - 1 - i].aabb)
					info.split_plane_area_right[num_intervals - 2 - i] = aabb_calculate_surface_area(right_aabb)
				}

				// Find best split plane with lowest surface area cost.
				interval_size : f32 = (bounds_max - bounds_min) / f32(num_intervals)

				for i : u32 = 0; i < info.num_split_planes; i+=1 {
					plane_cost : f32 = cast(f32)info.split_plane_count_left[i] * info.split_plane_area_left[i] + cast(f32)info.split_plane_count_right[i] * info.split_plane_area_right[i]
					if plane_cost < best_cost {
						best_cost = plane_cost
						best_axis = axis
						best_pos  = bounds_min + f32(i + 1) * interval_size
					}
				}
			
			} else { // NO BVH_CONFIG_USE_BINNING

				interval_size : f32 = (bounds_max - bounds_min) / f32(num_intervals)

				for i : u32 = 0; i < info.num_split_planes; i += 1 {

					candidate_pos : f32 = bounds_min + f32(i) * interval_size
					plane_cost : f32 = bvh_evaluate_surface_area_heuristic(info, node, axis, candidate_pos)
					
					assert(plane_cost >= 0.0)

					if plane_cost < best_cost{
						best_cost = plane_cost
						best_pos   = candidate_pos
						best_axis = axis
					}
				}
			}
		}
	}

	return best_axis, best_pos, best_cost
}

@(private="file")
bvh_evaluate_surface_area_heuristic :: proc "contextless" (info : ^BvhBuildInfo, node : ^BvhNode, axis : u32, pos : f32) -> (cost : f32){

	left_box  : AABB = aabb_create_inverse_infinite()
	right_box : AABB = aabb_create_inverse_infinite()
	
	left_count  : int = 0
	right_count : int = 0

	for i in 0..<node.count {

		tri_index : uint = uint(node.left_first + i)

		tri : [3][3]f32 = bvh_get_triangle_positions(info, tri_index)

		if info.tri_centroids[tri_index][axis] < pos {
			left_count += 1

			aabb_grow_by_point(&left_box, tri[0])
			aabb_grow_by_point(&left_box, tri[1])
			aabb_grow_by_point(&left_box, tri[2])

		} else {
			right_count += 1
			aabb_grow_by_point(&right_box, tri[0])
			aabb_grow_by_point(&right_box, tri[1])
			aabb_grow_by_point(&right_box, tri[2])
		}
	}

	left_cost  : f32 = f32(left_count)  * aabb_calculate_surface_area(left_box) 
	right_cost : f32 = f32(right_count) * aabb_calculate_surface_area(right_box) 
	_cost : f32 = left_cost + right_cost

	return _cost > 0.0 ? _cost : math.INF_F32
}

@(private="file")
bvh_subdivide_recursiv :: proc(info : ^BvhBuildInfo, node : ^BvhNode, curr_tree_depth : u32 = 1){
		
	assert(bvh_is_leaf_node(node))

	if info.max_tree_depth > 0 && curr_tree_depth >= info.max_tree_depth {
		return
	}

	// For debugging / testing we can fallback to midpoint split
	DO_MIDPOINT_SPLIT :: false

	when DO_MIDPOINT_SPLIT {
		if node.tri_count <= 2 {
			return
		}
		axis, split_pos := bvh_split_node_midpoint(node)
	} else {

		axis, split_pos, split_cost := bvh_find_best_split_plane(info, node)
		node_no_split_cost : f32 = bvh_calculate_node_cost(node)
		if split_cost >= node_no_split_cost  {
			// abort if splitting does not improve the cost of the node
			return 
		}
	}

	// sort triangles left and right to the split axis position
	// @Note: i and j Must be signed intergers!
	i : int = cast(int)node.left_first
	j : int = i + cast(int)node.count - 1

	{
		tri_indecies : [^][3]u32 = cast([^][3]u32)&info.indecies[0]

		for i <= j {
			if info.tri_centroids[i][axis] < split_pos {
				i += 1	
			} else {

				// swap triangles
				tri_indecies[i]      , tri_indecies[j]       = tri_indecies[j]      , tri_indecies[i]
				info.tri_centroids[i], info.tri_centroids[j] = info.tri_centroids[j], info.tri_centroids[i]
				j -= 1
			}
		}
	}

	left_count : u32 = cast(u32)i - node.left_first
	if left_count == 0 || left_count == node.count {
		return // abort if one of the childs would be empty.
	}

	// create child nodes
	left_child_idx : u32 = cast(u32)info.num_nodes_used
	info.num_nodes_used += 1
	
	right_child_idx : u32 = cast(u32)info.num_nodes_used
	info.num_nodes_used += 1

	info.nodes[left_child_idx].left_first = node.left_first
	info.nodes[left_child_idx].count = left_count

	info.nodes[right_child_idx].left_first = cast(u32)i
	info.nodes[right_child_idx].count = node.count - left_count

	// make the current node a parent node
	node.left_first = left_child_idx
	node.count = 0

	left_child_node  := &info.nodes[left_child_idx]
	right_child_node := &info.nodes[right_child_idx]

	bvh_recalculate_node_aabb(info, left_child_node)
	bvh_recalculate_node_aabb(info, right_child_node)

	bvh_subdivide_recursiv(info, left_child_node , curr_tree_depth + 1)
	bvh_subdivide_recursiv(info, right_child_node, curr_tree_depth + 1)

	return
}

// Triangle index means that triangle_index * 3 is the first indecie for a triangle in a normal index buffer.
@(private="file")
bvh_get_triangle_positions :: proc "contextless" (info : ^BvhBuildInfo, triangle_index : uint) -> (tri_positions : [3][3]f32) #no_bounds_check {

	// 3 indecies per triangle
	// we use vertex byte size to lookup the byte offset in the original vertex buffer.
	v_0_byte_offset : uint = cast(uint)info.indecies[triangle_index * 3 + 0] * info.vertex_byte_size
	v_1_byte_offset : uint = cast(uint)info.indecies[triangle_index * 3 + 1] * info.vertex_byte_size
	v_2_byte_offset : uint = cast(uint)info.indecies[triangle_index * 3 + 2] * info.vertex_byte_size
	
	// cast byte ptr to float3 ptr and dereferance. 
	tri_positions[0] = (cast(^[3]f32)&info.vertex_buf[v_0_byte_offset])^
	tri_positions[1] = (cast(^[3]f32)&info.vertex_buf[v_1_byte_offset])^
	tri_positions[2] = (cast(^[3]f32)&info.vertex_buf[v_2_byte_offset])^
	return tri_positions
}


// REF: bottom up build method.. slow for many primitves!

// TLBvhNode :: struct {
// 	aabb_min : [3]f32,
// 	left_right : u32, // 2x16 bits
// 	aabb_max : [3]f32,
// 	bl_drawable_index : u32,
// }

// bvh_tlas_is_leaf_node :: proc(node : ^TLBvhNode) -> bool {
// 	return node.left_right == 0;
// }

// universe_rebuild_top_level_bvh :: proc(gpu_device : ^sdl.GPUDevice, uni : ^Universe, mesh_manager : ^MeshManager){

// 	num_renderables : int = len(uni.frame_renderables);
// 	if num_renderables == 0 {
// 		return;
// 	}

	
// 	tlas_nodes := &uni.tlas_nodes;
// 	drawables  : ^#soa[dynamic]Drawable = &uni.ecs.drawables;

// 	blas_count : int = num_renderables;
// 	num_nodes : int = blas_count * 2; // -1 // skip -1 bc we resever one extra after root node.
	
// 	// FIXME: resize will copy old data when reallocating which is not what we want here!
// 	resize_dynamic_array(tlas_nodes, num_nodes);

// 	node_indecies : []u32 = make_slice([]u32, blas_count, context.temp_allocator);

// 	nodes_used : uint = 1; // root node

// 	// each renderable drawable will have a bvh backing it 
// 	for drawable_index in uni.frame_renderables {

// 		node_indecies[nodes_used -1] = cast(u32)nodes_used;

// 		mesh_id := drawables.draw_instance[drawable_index].mesh_id

// 		mesh_aabb 	  := mesh_manager.meshes[mesh_id].aabb;
// 		//mesh_bvh_data := mesh_manager.meshes[mesh_id].bvh_data;

// 		world_mat := drawables.world_mat[drawable_index];

// 		world_aabb : geo.AABB = geo.aabb_transform_by_mat4(mesh_aabb, world_mat);
// 		tlas_nodes[nodes_used].aabb_min = world_aabb.min.xyz;
// 		tlas_nodes[nodes_used].aabb_max = world_aabb.max.xyz;

// 		tlas_nodes[nodes_used].bl_drawable_index = drawable_index;
// 		tlas_nodes[nodes_used].left_right = 0; // make it a leaf node
// 		nodes_used += 1;
// 	}

// 	// remaining nodes to pair
// 	// We start with all leaf nodes that we just initialized abouve so remain nodes is num_renderables
// 	// We then below keep finding nodes to pair these with and when creating a new node 
// 	num_remain_nodes : int = blas_count;

// 	A : int = 0;
// 	B : int = tlas_find_best_match(tlas_nodes, node_indecies, num_remain_nodes, A);
// 	for num_remain_nodes > 1 {
		
// 		C : int = tlas_find_best_match(tlas_nodes, node_indecies, num_remain_nodes, B);
// 		if A == C {

// 			node_index_a : u32 = node_indecies[A];
// 			node_index_b : u32 = node_indecies[B];
// 			node_a := &tlas_nodes[node_index_a];
// 			node_b := &tlas_nodes[node_index_b];

// 			new_node := &tlas_nodes[nodes_used];
// 			new_node.left_right = node_index_a + (node_index_b << 16); // Store two u16 in one u32.
// 			new_node.aabb_min = linalg.min(node_a.aabb_min, node_b.aabb_min);
// 			new_node.aabb_max = linalg.max(node_a.aabb_max, node_b.aabb_max);
// 			new_node.bl_drawable_index = 0;

// 			node_indecies[A] = cast(u32)nodes_used;
// 			nodes_used +=1;
// 			node_indecies[B] = node_indecies[num_remain_nodes - 1];

// 			num_remain_nodes -= 1;
// 			B = tlas_find_best_match(tlas_nodes, node_indecies,num_remain_nodes, A);
// 		} else {
// 			A = B;
// 			B = C;
// 		}
// 	}

// 	tlas_nodes[0] = tlas_nodes[node_indecies[A]];


// 	// Force upload everything for now but only reallocate the gpu/transfer buffer if we need more space.

// 	required_byte_size : int = num_nodes * size_of(TLBvhNode);
// 	if cast(u32)required_byte_size > uni.tlas_nodes_buf_curr_size {
// 		uni.tlas_nodes_buf, uni.tlas_nodes_transfer_buf = universe_manager_recreate_gpu_buffers(gpu_device, uni.tlas_nodes_buf, uni.tlas_nodes_transfer_buf, cast(u32)required_byte_size)
// 		uni.tlas_nodes_buf_curr_size = cast(u32)required_byte_size;
// 	}


// 	data_ptr : rawptr = sdl.MapGPUTransferBuffer(gpu_device, uni.tlas_nodes_transfer_buf, true);
// 	{			
// 		mem.copy_non_overlapping(data_ptr, &uni.tlas_nodes[0], required_byte_size);
// 	}
// 	sdl.UnmapGPUTransferBuffer(gpu_device, uni.tlas_nodes_transfer_buf);

	
// 	uni.tlas_nodes_upload_info.requires_upload = true;
// 	uni.tlas_nodes_upload_info.transfer_buf_location = {
// 		transfer_buffer = uni.tlas_nodes_transfer_buf,
// 		offset = 0,
// 	}

// 	uni.tlas_nodes_upload_info.transfer_buf_region = {
// 		buffer = uni.tlas_nodes_buf,
// 		offset = 0,
// 		size = cast(u32)required_byte_size,
// 	}
// }


// tlas_find_best_match :: proc(tlas_nodes : ^[dynamic]TLBvhNode, node_indecies : []u32, N : int, A : int) -> int {

// 	smallest_area : f32 = math.INF_F32;
// 	bestB : int = -1;

// 	for B : int = 0; B < N; B+=1 {
// 		if B == A {
// 			continue;
// 		}

// 		bmin := linalg.min(tlas_nodes[node_indecies[A]].aabb_min, tlas_nodes[node_indecies[B]].aabb_min);
// 		bmax := linalg.max(tlas_nodes[node_indecies[A]].aabb_max, tlas_nodes[node_indecies[B]].aabb_max);
// 		e : [3]f32 = bmax - bmin;
// 		surf_area : f32 = (e.x * e.y + e.y * e.z + e.z * e.x) * 2;
// 		if surf_area < smallest_area {
// 			smallest_area = surf_area;
// 			bestB = B;
// 		}
// 	}

// 	//engine_assert(bestB >= 0); why not ?

// 	return bestB;
// }