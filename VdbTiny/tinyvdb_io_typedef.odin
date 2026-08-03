package tvdb

import "core:c"

/* ========================================================================== */
/*  Compile-time configuration                                                */
/* ========================================================================== */
TVDB_MAX_TREE_DEPTH :: 8
TVDB_MAX_ERROR_MSG :: 512

/* ========================================================================== */
/*  Status codes                                                              */
/* ========================================================================== */

//  tvdb_status_t;
Status :: enum u32 {
    OK = 0,
    ERROR_INVALID_FILE,
    ERROR_INVALID_HEADER,
    ERROR_INVALID_DATA,
    ERROR_INVALID_ARGUMENT,
    ERROR_UNSUPPORTED_VERSION,
    ERROR_UNSUPPORTED_GRID_TYPE,
    ERROR_UNSUPPORTED_COMPRESSION,
    ERROR_UNSUPPORTED_TRANSFORM,
    ERROR_DECOMPRESSION_FAILED,
    ERROR_OUT_OF_MEMORY,
    ERROR_IO,
    ERROR_MMAP_FAILED,
    ERROR_PATH_CONVERSION,
    ERROR_UNIMPLEMENTED
}; 

/* ========================================================================== */
/*  Error context                                                             */
/* ========================================================================== */

// tvdb_error_t;
Error :: struct {
    status : Status,
    message : [TVDB_MAX_ERROR_MSG]u8,
    byte_offset : u64,
    grid_index : i32,
}

/* ========================================================================== */
/*  Custom memory allocator                                                   */
/* ========================================================================== */

// TODO: 

// tvdb_allocator_t
Allocator ::  struct {
    _ : proc(),
    _ : proc(),
    _ : proc(),
   user_ctx : rawptr,
    //void *(*malloc_fn)(size_t size, void *user_ctx);
    //void *(*realloc_fn)(void *ptr, size_t old_size, size_t new_size, void *user_ctx);
    //void (*free_fn)(void *ptr, size_t size, void *user_ctx);
    //void *user_ctx;
}

/* ========================================================================== */
/*  Value types                                                               */
/* ========================================================================== */

// tvdb_value_type_t;
ValueType :: enum u32 {
    NULL = 0,
    BOOL,
    INT32,
    INT64,
    FLOAT,
    DOUBLE,
    HALF,
    VEC3I,
    VEC3F,
    VEC3D,
    STRING
} 

// tvdb_value_t;
Value :: struct {
    type : ValueType,
    u : struct #raw_union {
        _bool 	: c.int,
        _i32  	: i32,
        _i64  	: i64,
        _float  : f32,
        _double : f64,
        _vec3i : [3]i32,
        _vec3f : [3]f32,
        _vec3d : [3]f64,
        s : struct {
            str : cstring,
            len : c.size_t,
        },
    },
}

/* ========================================================================== */
/*  Node / tree types                                                         */
/* ========================================================================== */

// tvdb_node_type_t;
NodeType :: enum u32 {
    ROOT = 0,
    INTERNAL,
    LEAF
}

/* ========================================================================== */
/*  Bitset & node mask                                                        */
/* ========================================================================== */

// tvdb_bitset_t
BitSet :: struct {
    data : [^]u8,
    num_bits  : c.size_t,
    num_bytes : c.size_t,
    alloc : ^Allocator,
}

// tvdb_nodemask_t;
NodeMask :: struct {
    bits : BitSet,
    log2dim : i32,
    bitsize : i32, /* 1 << (3 * log2dim) */
} 

/* ========================================================================== */
/*  Metadata                                                                  */
/* ========================================================================== */

// tvdb_meta_entry_t;
MetaEntry :: struct  {
    name : cstring,
    type_name : cstring,
    value : Value,
    raw_data : [^]byte,
    raw_data_len : c.size_t,
} 

// tvdb_metadata_t;
Metadata :: struct {
    entries : [^]MetaEntry,
    count   : c.size_t,
    capacity: c.size_t,
    alloc : Allocator,
} 

/* ========================================================================== */
/*  Grid descriptor                                                           */
/* ========================================================================== */

// tvdb_grid_descriptor_t
GridDescriptor :: struct {
    grid_name : cstring,
    unique_name : cstring,
    grid_type : cstring,
    instance_parent_name : cstring,
    save_float_as_half : c.int,
    grid_byte_offset : u64,
    block_byte_offset : u64,
    end_byte_offset : u64,
}

/* ========================================================================== */
/*  Header                                                                    */
/* ========================================================================== */

// tvdb_header_t;
Header :: struct {
    file_version  : u32,
    major_version : u32,
    minor_version : u32,
    compression_flags : u32,
    has_grid_offsets : c.int,
    half_precision : c.int,
    uuid : [37]byte, /* 36 chars + NUL */
    offset_to_data : u64,
} 

/* ========================================================================== */
/*  Transform                                                                 */
/* ========================================================================== */

// tvdb_transform_type_t;
TransformType :: enum u32 {
	UNIFORM_SCALE,
	UNIFORM_SCALE_TRANSLATE,
	SCALE,
	SCALE_TRANSLATE,
	TRANSLATION,
	AFFINE,
	UNKNOWN
} 

// tvdb_transform_t;
Transform :: struct {
    type : TransformType,
    scale_values: [3]f64,
    voxel_size : [3]f64,
    translation : [3]f64,
    transform_mat : #row_major matrix [4,4]f64, /* for AffineMap: row-major 4x4 */
} 


/* ========================================================================== */
/*  Grid layout                                                               */
/* ========================================================================== */

// tvdb_node_info_t;
NodeInfo :: struct {
    node_type : NodeType,
    value_type : ValueType,
    log2dim : u32,
} 

// tvdb_grid_layout_t;
GridLayout :: struct {
    levels    : [TVDB_MAX_TREE_DEPTH]NodeInfo,
    num_levels : c.int,
}

/* ========================================================================== */
/*  Tree nodes                                                                */
/* ========================================================================== */

// tvdb_root_node_t;
RootNode :: struct {
    background : Value,
    num_tiles 	: u32,
    num_children : u32,
    tile_origins : [^]i32,   /* [num_tiles * 3] */  
    tile_values : [^]Value,
    tile_active : [^]c.int,
    child_origins : [^]i32,  /* [num_children * 3] */
    child_indices : [^]c.size_t,  /* indices into tree.nodes[] */
} 

// tvdb_internal_node_t;
InternalNode :: struct {
    child_mask : NodeMask,
    value_mask : NodeMask,
    values : [^]u8,
    values_size : c.size_t,
    child_indices : [^]c.size_t, /* sparse: count_on(child_mask) entries */
    num_children : c.size_t,
} 

// tvdb_leaf_node_t;
LeafNode :: struct {
    value_mask : NodeMask,
    data : [^]u8,
    data_size : c.size_t,
    num_voxels : u32,

    /* PointIndexGrid leaf payload (OpenVDB tools::PointIndexLeafNode). */
    point_indices : [^]i32,
    num_point_indices : u64,
    point_aux_data : [^]u8,
    point_aux_data_size : u64
} 

// tvdb_tree_node_t;
TreeNode :: struct  {
    type : NodeType,
    level : c.int,
    origin : [3]i32,
    node : union {
        RootNode,
        InternalNode,
        LeafNode,
    },
} 

// tvdb_tree_t;
Tree :: struct {
    nodes : [^]TreeNode,
    num_nodes : c.size_t,
    nodes_capacity : c.size_t,
    layout : GridLayout,
    is_point_data_grid  : c.int,
    is_point_index_grid : c.int,
    alloc : ^Allocator,
} 


/* ========================================================================== */
/*  Grid                                                                      */
/* ========================================================================== */

Grid :: struct  {
    descriptor : GridDescriptor,
    metadata : Metadata,
    transform : Transform,

    tree : Tree,
    compression_flags : u32, // TODO: make into bitset
    /* Raw PointDataGrid payload (treebase+topology+buffers), preserved
       opaquely for round-trip serialization. */
    point_data_blob : [^]byte,
    point_data_blob_size : c.size_t,                 
};


/* ========================================================================== */
/*  mmap                                                                      */
/* ========================================================================== */

when ODIN_OS == .Windows {
    // tvdb_mmap_t;
    MMap :: struct {
        data : [^]byte,
        mapped_len : u64,
        file_size : u64,
        	file_handle_ : rawptr,
        	map_handle_ : rawptr,
        	base_addr_ : rawptr,
    }
} else {
    MMap :: struct {
        data : [^]byte,
        mapped_len : u64,
        file_size : u64,
        fd_ : c.int,
        base_addr_ : rawptr,
        base_len_ : u64,
    }
}



/* ========================================================================== */
/*  File data source                                                          */
/* ========================================================================== */

// tvdb_source_type_t;
SourceType :: enum u32 {
    NONE = 0,
    MMAP,
    BUFFER,
    EXTERNAL
} 

// tvdb_file_data_t;
FileData :: struct {
    data : [^]byte,
    data_len : u64,
    source : SourceType,
  	mmap : MMap,
    buffer : [^]byte,
    alloc : Allocator,
} 

/* ========================================================================== */
/*  Top-level file context                                                    */
/* ========================================================================== */

// tvdb_file_t;
File :: struct {
    header : Header,
    file_metadata : Metadata,
    grids : [^]Grid,
    num_grids : c.size_t,
    alloc : Allocator,
    file_data : FileData,
} 