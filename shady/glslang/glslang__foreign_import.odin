package glslang

when ODIN_OS == .Windows {
	@(extra_linker_flags="/NODEFAULTLIB:libcmt")
	@(export) foreign import lib_glslang {
		"lib/release/glslang.lib",
		"lib/release/glslang-default-resource-limits.lib",
		"lib/release/SPIRV-Tools.lib",
		"lib/release/SPIRV-Tools-opt.lib",

		// Not Needed Apparently
		// "lib/release/SPIRV.lib",
		// "lib/release/SPVRemapper.lib",
		// "lib/release/OSDependent.lib",
		// "lib/release/MachineIndependent.lib",
		// "lib/release/GenericCodeGen.lib",
	}
} else when ODIN_OS == .Linux {
	#panic(true)
} else {
	#panic(true)
}