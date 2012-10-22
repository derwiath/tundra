
local common = {
	Env = {
		CPPPATH = {
			"$(OBJECTROOT)/_generated"
		},
		LIBS = {
			"protobuf"
		},
		PROTOPATH = ".",
	},
}
-- A rule to call out to a python file generator.
DefRule {
	-- The name by which this rule will be called in source lists.
	Name               = "ProtoToCpp",

	-- All invocations of this rule will run in this pass unless
	-- overridden on a per-invocation basis.
	Pass               = "CodeGeneration",

	-- Mark the rule as configuration invariant, so the outputs are
	-- shared between all configurations. This is only suitable if the
	-- generator always generates the same outputs regardless of
	-- active configuration.
	ConfigInvariant    = true,

	-- The command to run.
	-- $(<) - input filename
	-- $(@) - output filename
	Command = "protoc --proto_path=$(PROTOPATH) --cpp_out=$(OBJECTROOT)/_generated $(<)",

	-- A blueprint to match against invocations. This provides error
	-- checking and exposes the data keys to the Setup function.
	Blueprint = {
		Input = { Type = "string", Required = true },
	},

	-- The Setup function must return a table of two keys InputFiles
	-- and OutputFiles based on the invocation data. It can optionally
	-- modify the environment (e.g. to add command switches based on
	-- the invocation data).
	Setup = function (env, data)
		return {
			InputFiles = { data.Input .. ".proto" },
			OutputFiles = {
				"$(OBJECTROOT)/_generated/" .. data.Input .. ".pb.h",
				"$(OBJECTROOT)/_generated/" .. data.Input .. ".pb.cc",
			},
		}
	end,
}

Build {
	Units = function()


		-- A test program that uses the file. Try running tundra for both debug
		-- and release at the same time and you will see that they share the
		-- generated file as an input without problems.
		local testprog = Program {
			Name = "testprog",
			Sources = {
				"main.cc",
				ProtoToCpp { Input = "protobuf_data" },
			},
			ReplaceEnv = {
				LD = { "$(CXX)" ; Config = { "*-gcc-*" } },
			},
		}

		Default(testprog)
	end,

	Passes = {
		CodeGeneration = { Name="Generate sources", BuildOrder = 1 },
	},

	Configs = {
		{
			Name = "macosx-gcc",
			DefaultOnHost = "macosx",
			Inherit = common,
			Tools = { "gcc" },
		},
		{
			Name = "win32-msvc",
			DefaultOnHost = "windows",
			Inherit = common,
			Tools = { "msvc-vs2008" },
		},
	},
}
