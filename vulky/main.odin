package vulky

import "base:runtime"
import "core:log"
import "core:slice"
import "core:strings"
import "core:fmt"
import "core:mem"
import "core:c"
import "vendor:glfw"

import vk "vendor:vulkan"

import "../picy"


Globals :: struct {

	ctxt : runtime.Context,

	persist_arena     : mem.Dynamic_Arena,
	persist_allocator : runtime.Allocator,

	window : glfw.WindowHandle,

	vk_instance : vk.Instance,
	physical_device : vk.PhysicalDevice,
	device : vk.Device,
	window_surface : vk.SurfaceKHR,

	queue_family_info : QueueFamilyInfo,
	graphics_queue    : vk.Queue,
	present_queue     : vk.Queue,

	swapchain_details : SwapchainSupportDetails,
	swapchain         : SwapchainVK,

	initialized_dbg_messenger : bool,
	dbg_messenger : vk.DebugUtilsMessengerEXT,
}

QueueFamilyInfo :: struct {
	supported_queues : vk.QueueFlags,
	
	graphics : u32,
	compute  : u32,
	transfer : u32,

	present  : u32,
	present_supported : bool, // suck that this isnt part of flags. maybe make own queue flags type ?
}

global : Globals

main :: proc() {

	// ========================================================================================================
	// Use Tracking Mem allocator when in debug build

	when ODIN_DEBUG {
		
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}


	Logger_Opts : bit_set[runtime.Logger_Option] : log.Options{log.Options.Level, log.Options.Terminal_Color}

	console_logger := log.create_console_logger(log.Level.Debug)
	console_logger.options = Logger_Opts
	context.logger         = console_logger
	defer log.destroy_console_logger(console_logger)


	global.ctxt = context;

	mem.dynamic_arena_init(&global.persist_arena, context.allocator, context.allocator,  1 * mem.Megabyte, mem.DYNAMIC_ARENA_OUT_OF_BAND_SIZE_DEFAULT, mem.DEFAULT_ALIGNMENT);
	global.persist_allocator = mem.dynamic_arena_allocator(&global.persist_arena);
	defer mem.dynamic_arena_destroy(&global.persist_arena);

	log.errorf("Test!!")
	picy.test_writer("7.jpg", picy.FileFormat.HDR, "hdr_writer_test")


	return

	// ok := init(&global)
	// if !ok {
	// 	return
	// }

	
	// run(&global)

	// deinit(&global)	
}

init :: proc(globals : ^Globals) -> bool {

	glfw_init_ok := glfw.Init()
	assert(cast(bool)glfw_init_ok)

	glfw.WindowHint( glfw.CLIENT_API, glfw.NO_API)
	glfw.WindowHint( glfw.RESIZABLE, glfw.FALSE)


	window := glfw.CreateWindow(900, 600, "Vulky", nil, nil)
	assert(window != nil)
	globals.window = window


	vk.load_proc_addresses_global(rawptr(glfw.GetInstanceProcAddress))
	assert(vk.CreateInstance != nil, "vulkan function pointers not loaded")

	log.debugf("glfw init")

	validation_layers : bool = true
	vk_instance, vkres := init_vulkan_instance(&global, validation_layers)
	if vkres != .SUCCESS {
		log.errorf("Failed to create vulkan instance: Error: {}", vkres)	
		return false
	}

	global.vk_instance = vk_instance


	surf_create_res := glfw.CreateWindowSurface(global.vk_instance, global.window, nil, &global.window_surface )
	assert(surf_create_res == .SUCCESS)

	global.physical_device = pick_best_physical_device(global.window_surface) or_return



	global.queue_family_info = physical_device_get_queue_family_info(global.physical_device, global.window_surface)

	assert(global.queue_family_info.present_supported)
	assert(.GRAPHICS in global.queue_family_info.supported_queues)
	assert(.TRANSFER in global.queue_family_info.supported_queues)
	assert(.COMPUTE  in global.queue_family_info.supported_queues)

	log.debugf("supported_queues: {}, present: {}", globals.queue_family_info.supported_queues, globals.queue_family_info.present_supported)
	//queue_fam_indecies [vk.QueueFlag]u32


	device_extensions := []cstring{
		vk.KHR_SWAPCHAIN_EXTENSION_NAME,
	}

	// Note: These check should idealy be performed during physical device selection.
	extensions_supported := check_device_extention_support(global.physical_device, device_extensions)
	if !extensions_supported {
		log.errorf("Not all device extentions are supoorted for the chosen physical_device")
	}
	
	global.swapchain_details = query_swapchain_support_details(global.physical_device, global.window_surface, global.persist_allocator)

	assert(len(global.swapchain_details.supported_formats) > 0)
	assert(.FiFo in global.swapchain_details.supported_present_modes) // Vsync should always be supported..

	global.device = create_logical_device(global.physical_device, global.queue_family_info, device_extensions) or_return

	vk.GetDeviceQueue(globals.device, globals.queue_family_info.graphics, 0, &globals.graphics_queue)
	vk.GetDeviceQueue(globals.device, globals.queue_family_info.present , 0, &globals.present_queue)


	global.swapchain = create_swapchain(global.device, global.window, global.window_surface, &global.swapchain_details, global.queue_family_info) or_return


	return true
}


run :: proc(globals : ^Globals) {

	for !glfw.WindowShouldClose(globals.window) {
		glfw.PollEvents()


		free_all(context.temp_allocator)
	}
}


deinit :: proc(globals : ^Globals) {

	vk.DestroySwapchainKHR(globals.device, globals.swapchain.handle, nil)
	vk.DestroySurfaceKHR(globals.vk_instance, globals.window_surface, nil)

	vk.DestroyDevice(globals.device, nil)

	if globals.initialized_dbg_messenger {
		vk.DestroyDebugUtilsMessengerEXT(globals.vk_instance, globals.dbg_messenger, nil)
	}

	vk.DestroyInstance(globals.vk_instance, nil);
	
	glfw.DestroyWindow(globals.window)
	glfw.Terminate()

	free_all(context.temp_allocator)
	
}

vk_messenger_callback :: proc "system" ( messageSeverity: vk.DebugUtilsMessageSeverityFlagsEXT, messageTypes: vk.DebugUtilsMessageTypeFlagsEXT,	pCallbackData: ^vk.DebugUtilsMessengerCallbackDataEXT, pUserData: rawptr, ) -> b32 {
	context = global.ctxt

	level: log.Level
	if .ERROR in messageSeverity {
		level = .Error
	} else if .WARNING in messageSeverity {
		level = .Warning
	} else if .INFO in messageSeverity {
		level = .Info
	} else {
		level = .Debug
	}

	log.logf(level, "vulkan[%v]: %s", messageTypes, pCallbackData.pMessage)
	return false
}


init_vulkan_instance :: proc(globals : ^Globals, request_validation_layers : bool) -> (vk.Instance, vk.Result)  {

	enable_validation_layer : bool = request_validation_layers

	if enable_validation_layer && !check_validation_layers_support(){
		enable_validation_layer = false
		log.warnf("Requested vulkan validation layers but not available. continuing without em.")
	}

	extensions := slice.clone_to_dynamic(glfw.GetRequiredInstanceExtensions(), context.temp_allocator)

	app_info := vk.ApplicationInfo {
		sType              = vk.StructureType.APPLICATION_INFO,
		pNext              = nil,
		pApplicationName   = "vuky",
		applicationVersion = vk.MAKE_VERSION(0,1,0),
		pEngineName        = "No Engine", // whats this ?
		engineVersion      = vk.MAKE_VERSION(0,1,0),
		apiVersion         = vk.API_VERSION_1_0,
	}

	create_info := vk.InstanceCreateInfo{
		sType                   = vk.StructureType.INSTANCE_CREATE_INFO,
		// pNext:                   rawptr,
		pApplicationInfo        = &app_info,
		
		// required for mac i think
		// flags                   = vk.InstanceCreateFlags{.ENUMERATE_PORTABILITY_KHR },
	}
	


	dbg_create_info : vk.DebugUtilsMessengerCreateInfoEXT

	
	if enable_validation_layer {
		create_info.ppEnabledLayerNames = raw_data([]cstring{"VK_LAYER_KHRONOS_validation"})
		create_info.enabledLayerCount = 1

		append(&extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)

		// Severity based on logger level.
		severity : vk.DebugUtilsMessageSeverityFlagsEXT
		if context.logger.lowest_level <= .Error {
			severity |= {.ERROR}
		}
		if context.logger.lowest_level <= .Warning {
			severity |= {.WARNING}
		}
		if context.logger.lowest_level <= .Info {
			severity |= {.INFO}
		}
		if context.logger.lowest_level <= .Debug {
			severity |= {.VERBOSE}
		}

		dbg_create_info.sType           = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
		dbg_create_info.messageSeverity = severity
		// dbg_create_info.messageType     = {.GENERAL, .VALIDATION, .PERFORMANCE, .DEVICE_ADDRESS_BINDING} // all of them.
		dbg_create_info.messageType     = {.VALIDATION, .PERFORMANCE} // all of them.
		dbg_create_info.pfnUserCallback = vk_messenger_callback

		create_info.pNext = &dbg_create_info
	}


	create_info.enabledExtensionCount   = cast(u32)len(extensions)
	create_info.ppEnabledExtensionNames = &extensions[0]

	instance : vk.Instance
	res : vk.Result = vk.CreateInstance(&create_info, nil, &instance)


	vk.load_proc_addresses_instance(instance)

	// this has to happen after create instance.
	if enable_validation_layer && res == .SUCCESS {
		dbg_create_info.messageType     = {.GENERAL, .VALIDATION, .PERFORMANCE, .DEVICE_ADDRESS_BINDING} // all of them.

		dbg_res := vk.CreateDebugUtilsMessengerEXT(instance, &dbg_create_info, nil, &globals.dbg_messenger)
		assert(dbg_res == .SUCCESS)
		globals.initialized_dbg_messenger = true
	}

	return instance, res
}

check_validation_layers_support :: proc() -> bool {

	avail_layer_count : u32 = 0
	vk.EnumerateInstanceLayerProperties(&avail_layer_count, nil)


	if avail_layer_count <= 0 {
		return false;
	}

	avail_layers : [^]vk.LayerProperties = make_multi_pointer([^]vk.LayerProperties, int(avail_layer_count), context.temp_allocator);
	vk.EnumerateInstanceLayerProperties(&avail_layer_count, avail_layers);


	required_validation_layers : []string = []string{"VK_LAYER_KHRONOS_validation"}

	for &required_layer in required_validation_layers {

		found : bool = false

		for i in 0..<avail_layer_count {
			prop := &avail_layers[i]

			layer_name_cstring := cstring(&prop.layerName[0])
			layer_name_str := strings.clone_from_cstring(layer_name_cstring, context.temp_allocator)
			if layer_name_str == required_layer {
				found = true
				break
			}

		}

		if !found {
			return false
		}
	}

	return true
}

pick_best_physical_device :: proc(surface : vk.SurfaceKHR) -> (vk.PhysicalDevice, bool) {


	num_avail_devices : u32 = 0
	vk.EnumeratePhysicalDevices(global.vk_instance, &num_avail_devices, nil);

	if num_avail_devices == 0 {
		return vk.PhysicalDevice{}, false
	}

	avail_physical_devices := make_slice([]vk.PhysicalDevice, int(num_avail_devices), context.temp_allocator)
	vk.EnumeratePhysicalDevices(global.vk_instance, &num_avail_devices, raw_data(avail_physical_devices))

	best : u32 = 0
	best_score : int = -1

	for i in 0..<num_avail_devices {

		device_props : vk.PhysicalDeviceProperties
		vk.GetPhysicalDeviceProperties(avail_physical_devices[i], &device_props)

		score : int = 0

		if device_props.deviceType == .DISCRETE_GPU  {
			score += 1000
		} else if device_props.deviceType == .INTEGRATED_GPU {
			score += 50
		}

		// TODO: score highest memory
		// TODO: check for required extentions/features.
		
		// Score Queue support

		queue_info := physical_device_get_queue_family_info(avail_physical_devices[i], surface)
		for _ in queue_info.supported_queues {
			score += 100
		}
		score += queue_info.present_supported ? 100 : -1000


		if score > best_score {
			best = i
			best_score = score
		}
	}


	physical_device : vk.PhysicalDevice = avail_physical_devices[best]

	return physical_device, true
}

physical_device_get_queue_family_info :: proc(physical_device : vk.PhysicalDevice, surface : vk.SurfaceKHR) -> QueueFamilyInfo {

	out_indecies : QueueFamilyInfo

	num_queue_fams : u32 = 0
	vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &num_queue_fams, nil)

	if num_queue_fams > 0 {

		queue_fam_props := make_slice([]vk.QueueFamilyProperties, int(num_queue_fams), context.temp_allocator)
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &num_queue_fams, raw_data(queue_fam_props))

		for queue_fam, index in queue_fam_props {
			
			if !out_indecies.present_supported {

				present_support : b32 = false
				vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, u32(index), surface, &present_support);
				if present_support {
					out_indecies.present = u32(index)
					out_indecies.present_supported = true
				}
			}
			
			for queue in vk.QueueFlag {

				if queue in out_indecies.supported_queues {
					continue // already found one
				}


				if queue in queue_fam.queueFlags {
					out_indecies.supported_queues += vk.QueueFlags{queue}
					
					if queue == .GRAPHICS {
						out_indecies.graphics = u32(index)
					}

					if queue == .COMPUTE {
						out_indecies.compute = u32(index)
					}

					if queue == .TRANSFER {
						out_indecies.transfer = u32(index)
					}
				}
			}

		}
	}

	return out_indecies
}

create_logical_device :: proc(physical_device : vk.PhysicalDevice, queue_fam_ids : QueueFamilyInfo, device_extensions : []cstring) -> (vk.Device, bool) {

	assert(vk.QueueFlag.GRAPHICS in queue_fam_ids.supported_queues)

	queue_prio : f32 = 1.0


	indecies_set := make(map[u32]b8, context.temp_allocator)

	queue_create_infos : [dynamic]vk.DeviceQueueCreateInfo = make_dynamic_array([dynamic]vk.DeviceQueueCreateInfo, allocator = context.temp_allocator);

	if vk.QueueFlag.GRAPHICS in queue_fam_ids.supported_queues do indecies_set[queue_fam_ids.graphics] = true;
	if vk.QueueFlag.COMPUTE  in queue_fam_ids.supported_queues do indecies_set[queue_fam_ids.compute]  = true;
	if vk.QueueFlag.TRANSFER in queue_fam_ids.supported_queues do indecies_set[queue_fam_ids.transfer] = true;
	if queue_fam_ids.present_supported do indecies_set[queue_fam_ids.present]  = true;

	for key, val in indecies_set {
		
		queue_create_info := vk.DeviceQueueCreateInfo{
			sType = vk.StructureType.DEVICE_QUEUE_CREATE_INFO,
			queueFamilyIndex = key,
			queueCount = 1,
			pQueuePriorities = &queue_prio,
		}

		append(&queue_create_infos,queue_create_info )
	}

	features := vk.PhysicalDeviceFeatures{}

	device_create_info := vk.DeviceCreateInfo{
		sType = vk.StructureType.DEVICE_CREATE_INFO,
		pQueueCreateInfos    = raw_data(queue_create_infos),
		queueCreateInfoCount = cast(u32)len(queue_create_infos),
		pEnabledFeatures = &features,

		// apparently modern drivers ignore this ?
		// enabledLayerCount:       u32,
		// ppEnabledLayerNames:     [^]cstring,
		
		enabledExtensionCount   = cast(u32)len(device_extensions),
		ppEnabledExtensionNames = raw_data(device_extensions),
	}

	device : vk.Device
	res := vk.CreateDevice(physical_device, &device_create_info, nil,  &device)

	if res != .SUCCESS {
		log.errorf("Failed to create logical device: Error: {}", res)
		return device, false
	}


	return device, true
}

// returns true when all specified extentions are supported and false otherwise
check_device_extention_support :: proc(physical_device : vk.PhysicalDevice, extensions : []cstring) -> bool {

	if len(extensions) == 0 {
		return true
	}

	num_extentions : u32 = 0
	vk.EnumerateDeviceExtensionProperties(physical_device, nil, &num_extentions, nil)

	if num_extentions == 0 {
		return false
	}

	avail_extensions := make_slice([]vk.ExtensionProperties, int(num_extentions), context.temp_allocator)
	vk.EnumerateDeviceExtensionProperties(physical_device, nil, &num_extentions, raw_data(avail_extensions))

	outer: for requested_ext in extensions {

		found : bool = false

		inner: for &avail_ext in avail_extensions {


			avail_ext_name := cstring(&avail_ext.extensionName[0])

			if requested_ext == avail_ext_name {
				found = true
				break inner
			}
		}

		if !found {
			return false
		}
	}

	return true
}


PresentMode :: enum u32 {
	Immediate = 0,
	Mailbox      ,
	FiFo         ,
	FiFo_Relaxed ,
}

SwapchainSupportDetails :: struct {
	capabilities : vk.SurfaceCapabilitiesKHR,
	supported_formats : [dynamic]vk.SurfaceFormatKHR,
	supported_present_modes : bit_set[PresentMode],
}

query_swapchain_support_details :: proc(physical_device : vk.PhysicalDevice, surface : vk.SurfaceKHR, allocator := context.allocator) -> (details : SwapchainSupportDetails) {


	vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &details.capabilities)

	//
	// Formats
	// 
	format_count : u32 = 0
	vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, nil)
	if format_count > 0 {
		details.supported_formats = make_dynamic_array_len_cap([dynamic]vk.SurfaceFormatKHR, int(format_count), int(format_count), allocator)
		vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, raw_data(details.supported_formats))
	}

	// 
	// Present Modes
	// 

	present_count : u32 = 0
	vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &present_count, nil)
	if present_count > 0{

		modes := make_slice([]vk.PresentModeKHR, int(present_count), context.temp_allocator)
		vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &present_count, raw_data(modes))

		for mode in modes {
			#partial switch mode {
				case .IMMEDIATE:    details.supported_present_modes += {.Immediate}
				case .MAILBOX:      details.supported_present_modes += {.Mailbox}
				case .FIFO:         details.supported_present_modes += {.FiFo}
				case .FIFO_RELAXED: details.supported_present_modes += {.FiFo_Relaxed}
			}
		}
	}

	return details
}

// on high dpi displays pixels are not the same as screen coordinates.
get_swapchain_extent_in_pixels :: proc(window : glfw.WindowHandle, capabilities : vk.SurfaceCapabilitiesKHR) -> vk.Extent2D {

	// this can be set to special value of max u32 which means
	// that the window manager allows us to differ from the current windows pixel size
	// in which case we will get the current size from glfw window and clamp in to the min max values defined in capabilities
	if capabilities.currentExtent.width != c.UINT32_MAX {
		return capabilities.currentExtent
	}

	// this should return the size in pixels.
	width, height := glfw.GetFramebufferSize(window)

	return vk.Extent2D{
		clamp(cast(u32)width , capabilities.minImageExtent.width , capabilities.maxImageExtent.width),
		clamp(cast(u32)height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
	}
}


SwapchainVK :: struct {
	handle : vk.SwapchainKHR,
	images : []vk.Image,
	curr_format       : vk.SurfaceFormatKHR,
	curr_extent       : [2]u32,
	curr_present_mode : PresentMode,
}

create_swapchain :: proc(device : vk.Device, window : glfw.WindowHandle, surface : vk.SurfaceKHR, details : ^SwapchainSupportDetails, queue_info : QueueFamilyInfo) -> (SwapchainVK, bool) {

	// TODO: make swapchain format and present mode as input parameters which get check for support here.

	// select default swapchain params
	swapchain_format : vk.SurfaceFormatKHR = details.supported_formats[0] // fallback to first one
	for format in details.supported_formats {

		// for windows at least b8g8r8a8_srgb is common.
		if format.format == vk.Format.B8G8R8A8_SRGB && format.colorSpace == vk.ColorSpaceKHR.SRGB_NONLINEAR {
			swapchain_format = format
			break
		}
	}

	swapchain_present_mode := vk.PresentModeKHR.FIFO // always supported

	// get swapchain size

	swapchain_extent := get_swapchain_extent_in_pixels(global.window, details.capabilities)

	// 
	// number images
	// 
	frames_in_flight : u32 = 2

	image_count : u32 = max(details.capabilities.minImageCount, frames_in_flight) 
	// if maxImageCount is 0 it means there is no limit.
	if details.capabilities.maxImageCount > 0 {
		image_count = min(details.capabilities.minImageCount, image_count)
	}


	create_info := vk.SwapchainCreateInfoKHR {
		sType = vk.StructureType.SWAPCHAIN_CREATE_INFO_KHR,
		// pNext:                 rawptr,
		// flags:                 SwapchainCreateFlagsKHR,
		surface                = surface,
		minImageCount          = image_count,
		imageFormat            = swapchain_format.format,
		imageColorSpace        = swapchain_format.colorSpace,
		imageExtent            = swapchain_extent,
		imageArrayLayers       = 1,
		// NOTE: "It is also possible that you'll render images to a separate image first to perform operations 
		// like post-processing. In that case you may use a value like VK_IMAGE_USAGE_TRANSFER_DST_BIT instead and 
		// use a memory operation to transfer the rendered image to a swap chain image."  - https://vulkan-tutorial.com/en/Drawing_a_triangle/Presentation/Swap_chain
		imageUsage             = vk.ImageUsageFlags{.COLOR_ATTACHMENT},
		// imageSharingMode:      SharingMode,
		// queueFamilyIndexCount: u32,
		// pQueueFamilyIndices:   [^]u32,
		preTransform           = details.capabilities.currentTransform, // i think for android/mobile you can use this for rotating..
		compositeAlpha         = vk.CompositeAlphaFlagsKHR{.OPAQUE}, // funny purref style transparent windows
		presentMode            = swapchain_present_mode,
		clipped                = true,
		// oldSwapchain:          SwapchainKHR,
	}

	queue_family_indecies := [2]u32{queue_info.graphics, queue_info.present}

	if queue_info.graphics != queue_info.present {
		// EXCLUSIVE is more performant but requirese explicit transfer of ownership
		// when swapchain is acceced by differnt queues. 
		// may still be worth it though since probably one will do offscreen rendering and
		// only blit to swapchain at the very end.
		create_info.imageSharingMode      = vk.SharingMode.CONCURRENT
		create_info.queueFamilyIndexCount = 2
		create_info.pQueueFamilyIndices   = &queue_family_indecies[0]
	} else {
		create_info.imageSharingMode      = vk.SharingMode.EXCLUSIVE
		create_info.queueFamilyIndexCount = 0
		create_info.pQueueFamilyIndices   = nil
	}

	swap_vk := SwapchainVK{
		curr_format       = swapchain_format,
		curr_extent       = [2]u32{swapchain_extent.width, swapchain_extent.height},
		curr_present_mode = cast(PresentMode)swapchain_present_mode,
	}
	res := vk.CreateSwapchainKHR(device, &create_info, nil, &swap_vk.handle)

	if res != .SUCCESS {
		log.errorf("Failed to create swapchain: {}", res)
		return SwapchainVK{}, false
	}


	actual_count : u32 = 0
	vk.GetSwapchainImagesKHR(device, swap_vk.handle, &actual_count, nil)
	swap_vk.images = make_slice([]vk.Image, int(actual_count), context.allocator)
	vk.GetSwapchainImagesKHR(device, swap_vk.handle, &actual_count, raw_data(swap_vk.images))

	return swap_vk, true
}