package glslang

when ODIN_OS == .Windows {
	when ODIN_DEBUG{
		@(extra_linker_flags="/NODEFAULTLIB:libcmt")
		@(export) foreign import lib_glslang {
			"lib/debug/glslangd.lib",
			"lib/debug/glslang-default-resource-limitsd.lib",
			"lib/debug/SPIRV-Toolsd.lib",
			"lib/debug/SPIRV-Tools-optd.lib",

			// Not Needed Apparently
			// "lib/debug/SPIRVd.lib",
			// "lib/debug/SPVRemapperd.lib",
			// "lib/debug/OSDependentd.lib",
			// "lib/debug/MachineIndependentd.lib",
			// "lib/debug/GenericCodeGend.lib",
		}

	} else {
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
	}
} else when ODIN_OS == .Linux {
	#panic(true)
} else {
	#panic(true)
}