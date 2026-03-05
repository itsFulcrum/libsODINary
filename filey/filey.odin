package filey

import "core:log"
import "core:os"
import "core:strings"
import "core:time"

FileWatcherData :: struct{
	// member variables, read only
	_filepaths: [dynamic]string,
	_last_write_times: [dynamic]time.Time,
}

add_file :: proc(file_watcher_data: ^FileWatcherData, filepath: string) {

	if file_watcher_data == nil {
		return;
	}

	if !os.exists(filepath) || !os.is_file(filepath) {
		return;
	}

	for &f in file_watcher_data._filepaths {
		if strings.compare(filepath,f) == 0 {
			return; // already exists.
		}
	}


	last_write, error := os.modification_time_by_path(filepath);

	if error != nil {
		log.errorf("FILEY: Error reading write time for file: {}", filepath);
		return;
	}

	append(&file_watcher_data._filepaths, strings.clone(filepath));
	append(&file_watcher_data._last_write_times, last_write);
}

// Add a list of files to the list
add_files :: proc(file_watcher_data: ^FileWatcherData, filepaths: []string){

	if file_watcher_data == nil {
		return;
	}

	for &path in filepaths {

		if !os.exists(path) || !os.is_file(path) {
			continue;
		}

		for &f in file_watcher_data._filepaths {
			if strings.compare(path, f) == 0 {
				continue; // already exists.
			}
		}


		last_write, error := os.modification_time_by_path(path);

		if error != nil {
			log.errorf("FILEY: error reading write time for file: {}", path);
			continue;
		}

		append(&file_watcher_data._filepaths, strings.clone(path));
		append(&file_watcher_data._last_write_times, last_write);
	}
}

clear_contents :: proc(file_watcher_data: ^FileWatcherData) {
	
	if file_watcher_data == nil {
		return;
	}

	for &str in file_watcher_data._filepaths{
		delete(str);
	}

	clear(&file_watcher_data._filepaths)
	clear(&file_watcher_data._last_write_times);
}

destroy :: proc(file_watcher_data: ^FileWatcherData) {
	
	if file_watcher_data == nil {
		return;
	}

	for &str in file_watcher_data._filepaths{
		delete(str);
	}

	delete(file_watcher_data._filepaths);
	delete(file_watcher_data._last_write_times);
}

// Check wheather any file has been written to.
did_any_file_change :: proc(file_watcher_data: ^FileWatcherData) -> bool {

	if file_watcher_data == nil {
		return false;
	}

	assert(len(file_watcher_data._filepaths) == len(file_watcher_data._last_write_times));

	for i in 0..<len(file_watcher_data._filepaths){

		last_write, error := os.modification_time_by_path(file_watcher_data._filepaths[i]);
		if error != nil {
			return true;
		}

		if last_write._nsec != file_watcher_data._last_write_times[i]._nsec {
			return true;
		}
	}

	return false;
}

// Update the write time for each entry.
update_all_write_times :: proc(file_watcher_data: ^FileWatcherData){
	
	if file_watcher_data == nil {
		return;
	}

	assert(len(file_watcher_data._filepaths) == len(file_watcher_data._last_write_times));

	for i in 0..< len(file_watcher_data._filepaths) {
		last_write, error := os.modification_time_by_path(file_watcher_data._filepaths[i]);
		
		if error != nil {
			log.errorf("FILEY: Error reading write time for file: {}", file_watcher_data._filepaths[i]);
		} else {
			file_watcher_data._last_write_times[i] = last_write;
		}
	}

}


