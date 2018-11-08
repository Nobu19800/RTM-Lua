local luaunit = require "luaunit"
local SdoConfiguration = require "openrtm.SdoConfiguration"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local ConfigAdmin = require "openrtm.ConfigAdmin"
local NVUtil = require "openrtm.NVUtil"

TestSdoConfiguration = {}


local SdoServiceAdminMock = {}
SdoServiceAdminMock.new = function()
	local obj = {}
	function obj:addSdoServiceConsumer(prof)
		return true
	end
	function obj:removeSdoServiceConsumer(id)
		return true
	end
	return obj
end





function TestSdoConfiguration:test_conf()
	local mgr = require "openrtm.Manager"
	mgr:init({})--,"-o","logger.file_name: stdout"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	
	local orb = mgr:getORB()

	local LifeCycleState = orb.types:lookup("::RTC::LifeCycleState").labelvalue

	local prop = Properties.new()
	prop:setProperty("default.param1","value1")
	prop:setProperty("confset1.param1","value1")
	configsets = ConfigAdmin.new(prop)
	configsets:activateConfigurationSet("default")
	configsets:update("default")
	
	local conf = SdoConfiguration.Configuration_impl.new(configsets,SdoServiceAdminMock.new())
	luaunit.assertNotEquals(conf:getObjRef(),nil)

	local confset = conf:get_configuration_set("default")
	local prop2 = Properties.new()
	NVUtil.copyToProperties(prop2, confset.configuration_data)
	luaunit.assertEquals(prop2:getProperty("param1"),"value1")

	local success, exception = pcall(
		function()
			conf:get_configuration_set("")
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)

	local success, exception = pcall(
		function()
			conf:get_configuration_set("dummy")
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)


	prop2:setProperty("param2","value2")
	NVUtil.copyFromProperties(confset.configuration_data,prop2)
	
	conf:set_configuration_set_values(confset)

	local configset1 = {id="",description="",configuration_data={}}
	
	luaunit.assertIsFalse(success)
	local success, exception = pcall(
		function()
			conf:set_configuration_set_values(configset1)
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)

	
	luaunit.assertIsTrue(conf:activate_configuration_set("default"))
	
	local success, exception = pcall(
		function()
			conf:activate_configuration_set("")
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)
	local success, exception = pcall(
		function()
			conf:activate_configuration_set("dummy")
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)

	local confset = conf:get_active_configuration_set()
	prop2 = Properties.new()
	NVUtil.copyToProperties(prop2, confset.configuration_data)
	luaunit.assertEquals(prop2:getProperty("param2"),"value2")
	

	luaunit.assertIsTrue(conf:activate_configuration_set("confset1"))

	
	luaunit.assertEquals(#conf:get_configuration_sets(),2)


	luaunit.assertIsTrue(conf:add_service_profile({id="id1",interface_type="type",properties={},service=nil}))

	
	local success, exception = pcall(
		function()
			conf:add_service_profile(nil)
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)


	local success, exception = pcall(
		function()
			conf:remove_service_profile("")
		end
	)
	--print(exception)
	luaunit.assertIsFalse(success)



	luaunit.assertIsTrue(conf:remove_service_profile("id1"))


	conf:deactivate()

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
