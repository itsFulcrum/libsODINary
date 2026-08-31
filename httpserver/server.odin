package webserve

import "base:runtime"
import "core:mem"
import "core:net"
import "core:fmt"
import "core:strings"
import "core:bytes"
import "core:log"
import "core:time"

import "core:os"
import "core:path/filepath"
import "core:path/slashpath"


Server :: struct {

	root_dir : string,
}


main :: proc() {


	when ODIN_DEBUG {
		
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator);
		context.allocator = mem.tracking_allocator(&track);

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map));
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location);
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array));
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location);
				}
			}
			mem.tracking_allocator_destroy(&track);
		}
	}


	Logger_Opts : bit_set[runtime.Logger_Option] : log.Options{log.Options.Level, log.Options.Terminal_Color}
	console_logger := log.create_console_logger(log.Level.Debug)
	console_logger.options = Logger_Opts;
	context.logger = console_logger;
	defer log.destroy_console_logger(console_logger);

	server : ^Server = new(Server, context.allocator);

	ok := server_start(server);
	if !ok {
		return;
	}

	server_terminate(server)
	free(server);
	free_all(context.temp_allocator);

}

// entry point called from main()
server_start :: proc(server : ^Server) -> (ok : bool) {

	assert(server != nil);


	// Validate and Init Root Server Dir
	{
		// TODO: pass through command line arg
		root_dir : string = "../webby/"; 

		if !os.is_absolute_path(root_dir) {

			abs_path, abs_path_err := os.get_absolute_path(root_dir, context.temp_allocator)
			if abs_path_err != nil {
				log.errorf("Failed to get absolute path to: {}", root_dir);
				return false;
			}

			root_dir = abs_path;
		}

		clean_path, path_alloc_err := os.clean_path(root_dir, context.temp_allocator);
		if path_alloc_err != nil {
			log.errorf("Failed to allocate for cleaning filepath: Error: {}", path_alloc_err);
			return false;
		}

		if !os.exists(clean_path) || !os.is_directory(clean_path) {
			log.errorf("Server Root Directory does not exist at: {} ", clean_path);
			return false;
		}

		server.root_dir = strings.clone(clean_path, context.allocator); // now we actually allocate this.

		free_all(context.temp_allocator);
	}


	interface_endpoint := net.Endpoint{
		address = net.IP4_Address{127, 0,0, 1},
		port 	= 8080,
	}

	server_socket, err := net.listen_tcp(interface_endpoint, backlog = 1000);

	if err != nil {
		log.errorf("Failed to create server socket. Error: {}", err);
		return false;
	}
	defer net.close(server_socket);

	log.infof("Server Started: {}", interface_endpoint);
	log.infof("Server Root Dir: {}", server.root_dir);
	
	//
	// THE LOOP
	//
	running : bool = true;
	for running == true {

		client_socket, client_addr, client_err := net.accept_tcp(server_socket);
		if client_err != nil {
			log.errorf("Failed to accept client tcp. Error: {}", client_err);
			continue;
		}

		// @Note: since we are currently looping inside this until we break the connection
		// we would block other clients if more than one
		// until this one is finishes.. meh.
		handle_client(server, client_socket, client_addr);

		log.debugf("Waiting for requests..")
	}


	return true;
}


server_terminate :: proc(server : ^Server) {
	
	assert(server != nil);

	if len(server.root_dir) > 0 {
		delete_string(server.root_dir);
		server.root_dir = "";
	}
}

handle_client :: proc(server : ^Server, client : net.TCP_Socket, client_addr : net.Endpoint) -> (ok : bool) {
	
	defer net.close(client);
	log.debugf("Establish Client Connection: {}", client_addr);


	// Setup arena allocator for this client connection.
	client_arena : mem.Dynamic_Arena;
	mem.dynamic_arena_init(&client_arena, context.allocator, context.allocator, 2 * mem.Megabyte ,mem.DYNAMIC_ARENA_OUT_OF_BAND_SIZE_DEFAULT, mem.DEFAULT_ALIGNMENT);
	client_scratch_allocator : runtime.Allocator = mem.dynamic_arena_allocator(&client_arena);
	
	defer {
		free_all(client_scratch_allocator)
		mem.dynamic_arena_destroy(&client_arena);
	}

	context.temp_allocator = client_scratch_allocator;


	request_buf : []byte = make_slice([]byte, 4096, context.temp_allocator);
	response_builder : [dynamic]byte = make_dynamic_array_len_cap([dynamic]byte, len = 0, cap = 4096, allocator =  context.temp_allocator);
	

	connection_alive : bool = true;

	curr_req_buff_end : int = 0;
	for connection_alive {

		// @Note: We are receiving blobs of data through tcp. they may or may not be complete
		// so we accumulate until we find have a complete HTTP header
		// Technically though its possible to have 2 headers completed in the buffer but we only handle one 
		// which is not ideal. Further we are actually only checking right now if a HTTP header compleated 
		// but they can have a 'body' and other kinds of data i presume so need to check how to handle / determine that..
		
		bytes_read, read_err := net.recv(client, request_buf[curr_req_buff_end:]);
		if read_err != nil {
			log.errorf("Failed to read client request: Error: {}", read_err);
			// TODO: should prob send failed request or something back..
			break;
		}

		curr_req_buff_end += bytes_read;

		req_completed_at, is_complete := is_http_request_buffer_complete(request_buf[0:curr_req_buff_end]);

		if !is_complete {
			continue;
		}

		defer {
			if req_completed_at < curr_req_buff_end {
				// Copy remainder to the beginning of the buffer.
				num_remaining_bytes : int = curr_req_buff_end - req_completed_at;
				mem.copy(&request_buf[0], &request_buf[req_completed_at], num_remaining_bytes);
				curr_req_buff_end = num_remaining_bytes;
			} else {
				curr_req_buff_end = 0;
			}
		}

		request : Request = parse_http_request_buffer(request_buf[0:req_completed_at]);

		log.debugf("RequestRes: {}", request);

		// Response:
		clear(&response_builder);
		should_close_connection := build_http_response(server, request, &response_builder);

		if should_close_connection {
			log.debugf("Closing Client Connection: {}", client_addr);
			connection_alive = false;
		}


		written_bytes, send_err := net.send(client, response_builder[0:len(response_builder)]);
		if send_err != nil {
			log.errorf("Failed to send response to client {}. Error {}", client_addr, send_err);
		}

		log.infof("Send Response: ContentType: {}", request.content_type);
	}


	return true;
}


RequestType :: enum u32 {
	Unknown 	= 0,
	BadRequest  = 1,
	LoadContent,
}

ContentType :: enum {
	Unknown,
	NoContent204,
	TextHtml,
	TextCss,
	TextJavaScript,
	Image,
}

ConnectionType :: enum {
	Close = 0,
	KeepAlive,
}

Request :: struct {
	type : RequestType,
	content_type : ContentType,
	GET_path : string,
	connection : ConnectionType,
}

is_http_request_buffer_complete :: proc(buffer : []byte) -> (offset_where_completed : int, is_complete : bool) {

	buff_str := string(buffer[:]);

	index : int = strings.index(buff_str, "\r\n\r\n")
	if index == -1 {
		return 0, false;
	}

	return index + 4, true;
}

parse_http_request_buffer :: proc(request_buf : []byte) -> Request {

	req := Request{type = .Unknown, connection = .KeepAlive};

	if len(request_buf) <= 0 {
		return req;
	}
	
	request_str := string(request_buf[:]);

	log.debugf("\n");
	log.debugf("=== Incomming Request ===")

	for line in strings.split_lines_iterator(&request_str){

		log.debugf(line);

		if strings.has_prefix(line, "GET ") { // <- Dont remove the space there at the end.

			// TODO: store HTTP version as part of request.
			parts := strings.split_n(line, " ", 4, context.temp_allocator);
			// parts[0] == 'GET'
			// parts[1] ~= '/some/url/path/somewhere.maybeToFile'
			// parts[2] ~= 'HTTP/1.x' http version.
			// parts[4] ~= idk i think this would never exist in a valid 'GET' method?
			if len(parts) >= 3 {
				request_evaluate_and_update_GET_method_expr(parts[1], &req)
			} else {
				req.type = .BadRequest;
			}
			continue;
		}
		if strings.has_prefix(line, "Connection:"){
			// @Note: keep alive if not told otherwise. For now..
			if strings.contains(line, "close"){
				req.connection = .Close;
			}
			continue;
		}
	}

	log.debugf("=== End Request ===")
	log.debugf("\n")

	return req;
}


build_http_response :: proc(server : ^Server, request : Request, builder : ^[dynamic]byte) -> (close_connection : bool) {

	// Response:
	append(builder, "HTTP/1.1 ");

	if request.connection == .Close {
		close_connection = true;
	}

	if request.type == .Unknown {

		append(builder, "405 Method Not Allowed");
		close_connection = true;
		return close_connection;
	} else if request.type == .BadRequest {
		append(builder, "400 Bad Request");
		close_connection = true;
		return close_connection;
	}

	// only thing i support for now.
	assert(request.type == .LoadContent)

	
	// Validate that we can process the request. Then append '200 OK' or '404 Not Found'
	
	abs_filepath, valid_load_request := validate_load_content_request(server, request);

	// try load the file.
	file_data : []byte = nil;

	if valid_load_request {
		read_err : os.Error;
		file_data, read_err = os.read_entire_file_from_path(abs_filepath, context.temp_allocator)

		if read_err != nil {
			log.errorf("Failed to load valid file ?. Error: {}", read_err);
			valid_load_request = false;
		}
	}


	if !valid_load_request {

		close_connection = true;	
		log.errorf("Invalid Load Request");

		append(builder, "404 Not Found\r\n")
		
		append(builder, "Content-Type: text/html\r\n")
		append(builder, "Connection: close\r\n")
		append(builder, "\r\n");

		// 404 Not Found!
		response_404_html : string = "<html><body><h1>404 Not Found</h1><p>Woops Something wrong there!?</p></body></html>\r\n";
		append(builder, response_404_html);

		return close_connection;
	}
	

	append(builder, "200 OK\r\n")


	// If Client requests to close we do that too otherwise assume keep-alive
	if request.connection == .Close {
		close_connection = true;	
		append(builder, "Connection: close\r\n")
	} else {
		append(builder, "Connection: keep-alive\r\n")
	}

	switch request.content_type {
		case .Unknown: 	panic("Invalid Codepath"); // Prob should crash server but its okey for now
		case .TextHtml:	append(builder, "Content-Type: text/html\r\n")
		case .TextCss:	append(builder, "Content-Type: text/css\r\n")
		case .TextJavaScript:	append(builder, "Content-Type: text/javascript\r\n")
		case .Image:	unimplemented("Images not implemented yet!"); // 
	}

	content_len : int = len(file_data);
	content_len_str : string = fmt.aprintf("Content-Length: {}\r\n", content_len, allocator = context.temp_allocator);
	append(builder, content_len_str)
	
	append(builder, "\r\n");
	append(builder, ..file_data[:]);


	return close_connection;
}



validate_load_content_request :: proc(server : ^Server, request : Request) -> (out_abs_filepath : string, ok : bool) {

	assert(request.type == .LoadContent);

	
	if request.content_type == .Unknown {
		return "", false;
	}

	if len(request.GET_path) <= 0 {
		return "", false;
	}

	abs_path : string;
	
	{


		// it should be a relative path!
		// if os.is_absolute_path(request.GET_path) {
		// 	log.errorf("Request path is absolute: {}", request.GET_path)
		// 	return "", false;
		// }

		_abs_path, alloc_err := os.join_path({server.root_dir, request.GET_path}, context.temp_allocator);
		if alloc_err != nil {
			log.errorf("Mem Allocation Error: {}", alloc_err);
			return "", false;
		}

		_abs_path, alloc_err = os.clean_path(_abs_path, context.temp_allocator);

		// validate requested path is not outside of server root path
		rel , rel_err := filepath.rel(server.root_dir, _abs_path, context.temp_allocator);
		if rel_err != .None {
			log.errorf("Path is _Not_ relative to the server path: {}", _abs_path)
			return "", false;
		}

		abs_path = _abs_path;

		if !os.is_file(abs_path) {
			log.errorf("Client load request trying to access non existing file: {}", abs_path);
			return "", false;
		}
	}

	// at this point we know its a valid path to a file.

	// @Note: we already validated that file extentions are valid but for images or something we may want to handle them differently.
	// file_ext := os.ext(abs_path);


	return abs_path, true;
}


request_evaluate_and_update_GET_method_expr :: proc(expr : string, req : ^Request) {

	req.type = .Unknown;

	if len(expr) == 0 {
		req.type = .BadRequest;
		return;
	}

	if expr == "/" {
		req.type = .LoadContent;
		req.content_type = ContentType.TextHtml;
		req.GET_path = strings.clone("/index.html", context.temp_allocator);
		return;
	}


	file_ext := os.ext(expr);

	if len(file_ext) > 0 {

		switch file_ext {
			case ".html":
				req.type = .LoadContent;
				req.content_type = .TextHtml; 
				req.GET_path = strings.clone(expr, context.temp_allocator);
			case ".css":
				req.type = .LoadContent;
				req.content_type = .TextCss; 
				req.GET_path = strings.clone(expr, context.temp_allocator);
			case ".js":
				req.type = .LoadContent;
				req.content_type = .TextJavaScript; 
				req.GET_path = strings.clone(expr, context.temp_allocator);
			case ".ico": {
				if expr == "/favicon.ico" {
					req.type = .LoadContent;
					req.content_type = .NoContent204; 
					//req.GET_path = strings.clone(expr, context.temp_allocator);
				}

			}
		}

		if req.type != .Unknown {
			return;
		}

	
		is_image_file : bool = false;
		switch file_ext {
			case ".jpg":  is_image_file = true;
			case ".jpeg": is_image_file = true;
			case ".JPG":  is_image_file = true;
			case ".JPEG": is_image_file = true;
			case ".png":  is_image_file = true;
			case ".PNG":  is_image_file = true;
		}
		
		// Dont supprt it yet!
		if is_image_file {
			// req.type = .LoadContent;
			// req.content_type = .Image; 
			// req.GET_path = strings.clone(expr, context.temp_allocator);
		}	
	}

}


