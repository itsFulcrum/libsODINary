package tvdb

when ODIN_OS == .Windows {
	@(extra_linker_flags="/NODEFAULTLIB:libcmt")
	@(export) foreign import tinyvdb {
		"lib/win_x64_release/TinyVDB_IO_Janga.lib",
	}
} else when ODIN_OS == .Linux {
	#panic(true)
} else {
	#panic(true)
}

import "core:c"

@(default_calling_convention = "c")
foreign tinyvdb { 

@(link_name = "tvdb_grid_set_background")
grid_set_background :: proc(grid : ^Grid, background : Value) ---;

// @(link_name = "tvdb_nodemask_set_on")
// static inline void tvdb_nodemask_set_on(tvdb_nodemask_t *m, int32_t i)

// @(link_name = "tvdb_nodemask_set_off")
// static inline void tvdb_nodemask_set_off(tvdb_nodemask_t *m, int32_t i)

// /* Nodemask helpers (for accessing tree data from application code) */
// @(link_name = "tvdb_nodemask_is_on")
// int    tvdb_nodemask_is_on(const tvdb_nodemask_t *m, int32_t i);
// @(link_name = "tvdb_nodemask_set_off")
// size_t tvdb_nodemask_count_on(const tvdb_nodemask_t *m);


@(link_name = "tvdb_file_open")
file_open :: proc(file : ^File, filepath_utf8 : cstring, allocator_t  : ^Allocator, err : ^Error) -> Status ---;

// @(link_name = "tvdb_file_open_memory")
// tvdb_status_t tvdb_file_open_memory(tvdb_file_t *file, const uint8_t *data, size_t data_len, const tvdb_allocator_t *alloc,tvdb_error_t *err);

// @(link_name = "tvdb_file_close")
// void tvdb_file_close(tvdb_file_t *file);

// @(link_name = "tvdb_file_close")
// tvdb_status_t tvdb_read_all_grids(tvdb_file_t *file, tvdb_error_t *err);

// @(link_name = "tvdb_file_close")
// size_t        tvdb_grid_count(const tvdb_file_t *file);
// @(link_name = "tvdb_file_close")
// const char   *tvdb_grid_name(const tvdb_file_t *file, size_t idx);
// @(link_name = "tvdb_file_close")
// const char   *tvdb_grid_type_name(const tvdb_file_t *file, size_t idx);

// @(link_name = "tvdb_file_close")
// const char   *tvdb_status_string(tvdb_status_t status);
// @(link_name = "tvdb_file_close")
// int           tvdb_is_big_endian(void);

// @(link_name = "tvdb_value_type_size")
// size_t        tvdb_value_type_size(tvdb_value_type_t type);



// /* ---- Writing API ---- */

// /* Write VDB data to a memory buffer.
//    Caller must free *out_data with the file's allocator (or free() if default).
//    compression_flags: combination of TVDB_COMPRESS_* flags.
//    compression_level: 1 (fastest) to 9 (best ratio), 0 for default (5). */
// @(link_name = "tvdb_write_to_memory")
// tvdb_status_t tvdb_write_to_memory(const tvdb_file_t *file, uint32_t compression_flags,int compression_level, uint8_t **out_data, size_t *out_size, tvdb_error_t *err);

// /* Write VDB data to a file.
//    use_mmap: if nonzero, use mmap for file I/O (ignored if TVDB_NO_MMAP).
//    compression_level: 1 (fastest) to 9 (best ratio), 0 for default (5). */
// @(link_name = "tvdb_file_save")
// tvdb_status_t tvdb_file_save(const tvdb_file_t *file,const char *filepath_utf8,uint32_t compression_flags,int compression_level,int use_mmap,tvdb_error_t *err);

// /* ---- Point grid helpers ---- */
// @(link_name = "tvdb_grid_is_point_data")
// int            tvdb_grid_is_point_data(const tvdb_file_t *file, size_t idx);
// @(link_name = "tvdb_grid_is_point_index")
// int            tvdb_grid_is_point_index(const tvdb_file_t *file, size_t idx);
// @(link_name = "tvdb_grid_point_data_blob")
// const uint8_t *tvdb_grid_point_data_blob(const tvdb_file_t *file, size_t idx);
// @(link_name = "tvdb_grid_point_data_blob_size")
// size_t         tvdb_grid_point_data_blob_size(const tvdb_file_t *file, size_t idx);
// @(link_name = "tvdb_grid_set_point_data_blob")
// tvdb_status_t  tvdb_grid_set_point_data_blob(tvdb_file_t *file, size_t idx,const uint8_t *data, size_t size, tvdb_error_t *err);

}