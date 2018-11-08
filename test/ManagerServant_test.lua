local luaunit = require "luaunit"
local ManagerServant = require "openrtm.ManagerServant"
local RTObject = require "openrtm.RTObject"
local Properties = require "openrtm.Properties"
local Factory = require "openrtm.Factory"
local oil = require "oil"
local NVUtil = require "openrtm.NVUtil"

TestManagerServant = {}



local testcomp_spec = {
	["implementation_id"]="TestComp",
	["type_name"]="TestComp",
	["description"]="TestComp",
	["version"]="1.0",
	["vendor"]="Sample",
	["category"]="example",
	["activity_type"]="DataFlowComponent",
	["max_instance"]="10",
	["language"]="Lua",
	["lang_type"]="script",
	["conf.default.test_param0"]="0"
}




local MyModuleInit = function(manager)
	local prof = Properties.new({defaults_map=testcomp_spec})
	manager:registerFactory(prof, RTObject.new, Factory.Delete)
end


function TestManagerServant:test_compparam()
	local compparam = ManagerServant.CompParam.new("RTC:vendor:category:implementation_id:language:version?param1=xxx&param2=yyy")
	luaunit.assertEquals(compparam._type, "RTC")
	luaunit.assertEquals(compparam:vendor(), "vendor")
	luaunit.assertEquals(compparam:category(), "category")
	luaunit.assertEquals(compparam:impl_id(), "implementation_id")
	luaunit.assertEquals(compparam:language(), "language")
	luaunit.assertEquals(compparam:version(), "version")
	local compparam = ManagerServant.CompParam.new("RTC:vendor:category:implementation_id::version?param1=xxx&param2=yyy")
	luaunit.assertEquals(compparam:language(), "Lua")

end


function TestManagerServant:test_servant()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext","-o"})--,"logger.file_name:stdout"})
	mgr:setModuleInitProc(MyModuleInit)
	mgr:activateManager()
	mgr:runManager(true)
	local ReturnCode_t  = mgr._ReturnCode_t

	local mgrservant1 = mgr:getManagerServant()
	local comps = mgrservant1:get_components_by_name("*/TestComp0")
	luaunit.assertEquals(#comps, 0)
	mgr:getConfig():setProperty("manager.name","manager2")
	local mgrservant2 = ManagerServant.new()
	mgr:getConfig():setProperty("manager.name","manager3")
	local mgrservant3 = ManagerServant.new()

	local ret = mgrservant2:add_master_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = mgrservant2:add_master_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)
	
	luaunit.assertEquals(#mgrservant2:get_master_managers(),1)
	
	local ret = mgrservant2:remove_master_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = mgrservant2:remove_master_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)


	local ret = mgrservant2:add_slave_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = mgrservant2:add_slave_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)

	luaunit.assertEquals(#mgrservant2:get_slave_managers(),1)
	
	luaunit.assertEquals(mgrservant2:load_module("SampleModule","Init"),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(#mgrservant2:get_loaded_modules(), 1)
	luaunit.assertEquals(mgrservant2:unload_module("SampleModule","Init"),ReturnCode_t.RTC_OK)

	
	local ret = mgrservant2:remove_slave_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = mgrservant2:remove_slave_manager(mgrservant3)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)

	local comp0 = nil
	oil.main(function()
		comp0 = mgrservant2:create_component("TestComp")
		--mgrservant2:delete_component("TestComp0")
	end)

	
	luaunit.assertNotEquals(comp0, nil)
	luaunit.assertEquals(#mgrservant2:get_components(), 1)
	local profs = mgrservant2:get_component_profiles()
	luaunit.assertEquals(profs[1].instance_name, "TestComp0")

	local comps = mgrservant1:get_components_by_name("*/TestComp0")
	luaunit.assertEquals(#comps, 1)
	local comps = mgrservant1:get_components_by_name("TestComp0")
	luaunit.assertEquals(#comps, 1)
	local comps = mgrservant1:get_components_by_name("example/TestComp0")
	luaunit.assertEquals(#comps, 1)

	local prof = mgrservant3:get_profile()
	local prop = Properties.new()
	NVUtil.copyToProperties(prop, prof.properties)

	luaunit.assertEquals(prop:getProperty("name"),"manager3")

	mgrservant2:set_configuration("testparam","testvalue")

	local conf = mgrservant2:get_configuration()
	local prop = Properties.new()
	NVUtil.copyToProperties(prop, conf)
	
	luaunit.assertEquals(prop:getProperty("testparam"),"testvalue")

	luaunit.assertIsFalse(mgrservant2:is_master())

	
	luaunit.assertNotEquals(#mgrservant2:get_factory_profiles(), 0)

	local str = mgrservant2:getParameterByModulename("testparam",{"RTC?testparam=100"})
	luaunit.assertEquals(str,"100")
	local str = mgrservant2:getParameterByModulename("testparam",{"RTC&testparam=100"})
	luaunit.assertEquals(str,"100")
	
	local str = mgrservant2:getParameterByModulename("testparam",{"RTC?testparam=100&param2=101"})
	luaunit.assertEquals(str,"100")



	local ret = mgrservant3:add_master_manager(mgrservant2)
	local ret = mgrservant3:add_slave_manager(mgrservant2)

	luaunit.assertEquals(mgrservant3:load_module("SampleModule","Init"),ReturnCode_t.RTC_OK)
	mgrservant3._isMaster = true

	luaunit.assertNotEquals(#mgrservant3:get_loaded_modules(), 0)
	luaunit.assertNotEquals(#mgrservant3:get_factory_profiles(), 0)


	local comp1 = nil
	oil.main(function()
		comp1 = mgrservant3:create_component("TestComp")
	end)

	
	luaunit.assertNotEquals(comp1, nil)


	oil.main(function()
		luaunit.assertEquals(mgrservant3:delete_component("TestComp1"), ReturnCode_t.RTC_OK)
		luaunit.assertEquals(mgrservant3:delete_component("TestComp1"), ReturnCode_t.BAD_PARAMETER)
	end)
	luaunit.assertIsTrue(mgrservant3:is_master())


	mgr:getConfig():setProperty("manager.name","manager4")
	mgr:getConfig():setProperty("manager.is_master","YES")
	local mgrservant4 = ManagerServant.new()

	mgrservant3._isMaster = false
	--mgrservant1:exit()
	mgrservant2:exit()
	mgrservant3:exit()
	mgrservant4:exit()


	mgrservant1:shutdown()
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
