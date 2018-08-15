local luaunit = require "luaunit"
local ModuleManager = require "openrtm.ModuleManager"
local Properties = require "openrtm.Properties"

TestModuleManager = {}



function TestModuleManager:test_compparam()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local prop = Properties.new()
	prop:setProperty("manager.modules.Lua.suffixes","lua")
	local modmgr = ModuleManager.new(prop)
	local filename = modmgr:load("SampleModule","Init")
	luaunit.assertNotEquals(filename, "")
	local success, exception = oil.pcall(
		function()
			modmgr:load("dummy","Init")
		end
	)
	luaunit.assertEquals(exception.type, "FileNotFound")
	local filename = modmgr:findFile("dummy",{"./"})
	luaunit.assertEquals(filename, "")
	luaunit.assertIsFalse(modmgr:fileExist("dummy"))


	luaunit.assertNotEquals(modmgr:symbol("SampleModule","Init"), nil)

	local success, exception = oil.pcall(
		function()
			modmgr:symbol("dummy","Init")
		end
	)
	luaunit.assertEquals(exception.type, "ModuleNotFound")

	local success, exception = oil.pcall(
		function()
			modmgr:symbol("SampleModule","dummy")
		end
	)
	luaunit.assertEquals(exception.type, "SymbolNotFound")

	luaunit.assertEquals(#modmgr:getLoadedModules(),1)

	modmgr:unload("SampleModule")
	local success, exception = oil.pcall(
		function()
			modmgr:unload("SampleModule")
		end
	)
	luaunit.assertEquals(exception.type, "NotFound")

	modmgr:unloadAll()


	mgr:createShutdownThread(0.01)
end




local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
