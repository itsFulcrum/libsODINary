package platformly

import "core:os"
import "core:sys/windows"

// open the system file browser at the given path.
open_system_folder_at_path :: proc(path : string) -> (ok : bool){

	// Validate path..
	if !os.exists(path) {
		return false;
	}

	dir_path : string = path;

	if os.is_file(path) {

		p , _ := os.split_path(path);
		dir_path = p;
	}

	/*
		ShellExecuteW :: proc "stdcall" (
			hwnd:         HWND, 
			lpOperation:  cstring16, 
			lpFile:       cstring16, 
			lpParameters: cstring16, 
			lpDirectory:  cstring16, 
			nShowCmd:     i32, 
		) 
	*/

	handle := windows.ShellExecuteW(
    	nil,
    	nil,
    	"explorer.exe", //windows.utf8_to_wstring_alloc("explorer.exe", context.temp_allocator),
    	windows.utf8_to_wstring_alloc(dir_path, context.temp_allocator),
    	nil,
    	windows.SW_SHOWNORMAL,
	)

	return handle != nil;
}



is_empty_directory_by_path :: proc(path : string) -> bool {

	files, read_dir_err := os.read_directory_by_path(path, n = 1, allocator = context.temp_allocator);
	if read_dir_err != os.ERROR_NONE {
		return false;
	}

	is_empty : bool = files == nil || len(files) == 0;

	return is_empty;
}