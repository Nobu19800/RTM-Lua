local luaunit = require "luaunit"
local ConfigAdmin = require "openrtm.ConfigAdmin"
local Properties = require "openrtm.Properties"

local ConfigurationListener = require "openrtm.ConfigurationListener"


local ConfigurationParamListener = {}
ConfigurationParamListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=ConfigurationListener.ConfigurationParamListener.new()})
	obj._name = name
	function obj:call(config_set_name, config_param_name)
	end
	return obj
end


local ConfigurationSetNameListener = {}
ConfigurationSetNameListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=ConfigurationListener.ConfigurationSetNameListener.new()})
	obj._name = name
	function obj:call(config_set_name)
	end
	return obj
end


local ConfigurationSetListener = {}
ConfigurationSetListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=ConfigurationListener.ConfigurationSetListener.new()})
	obj._name = name
	function obj:call(config_set)
	end
	return obj
end


TestConfigAdmin = {}
function TestConfigAdmin:test_ConfigAdmin()
	local properties = Properties.new()
	
	local config = ConfigAdmin.new(properties)
	config:activateConfigurationSet("default")
	config:update("default")
	local var = {_value="a"}

	config:setOnUpdateParam(ConfigurationParamListener.new("ON_UPDATE_CONFIG_PARAM"))
	config:setOnUpdate(ConfigurationSetNameListener.new("ON_UPDATE_CONFIG_SET"))
	config:setOnSetConfigurationSet(ConfigurationSetListener.new("ON_SET_CONFIG_SET"))
	config:setOnAddConfigurationSet(ConfigurationSetListener.new("ON_ADD_CONFIG_SET"))
	config:setOnRemoveConfigurationSet(ConfigurationSetNameListener.new("ON_REMOVE_CONFIG_SET"))
	config:setOnActivateSet(ConfigurationSetNameListener.new("ON_ACTIVATE_CONFIG_SET"))
	

	luaunit.assertIsTrue(config:bindParameter("test",var))
	luaunit.assertIsTrue(config:isExist("test"))

	local properties3 = Properties.new()
	properties3.name = "testset3"
	properties3:setProperty("test","value1")
	luaunit.assertIsTrue(config:addConfigurationSet(properties3))

	properties3:setProperty("test","value2")
	luaunit.assertIsTrue(config:setConfigurationSetValues(properties3))
	luaunit.assertIsTrue(config:activateConfigurationSet("testset3"))
	config:update()
	luaunit.assertEquals(var._value,"value2")
	luaunit.assertIsTrue(config:unbindParameter("test"))

	--config:addConfigurationSet()
	

	config:getActiveConfigurationSet()

	local properties2 = Properties.new()
	properties2.name = "testset1"
	luaunit.assertIsFalse(config:setConfigurationSetValues(properties2))
	luaunit.assertIsTrue(config:addConfigurationSet(properties2))
	luaunit.assertIsTrue(config:setConfigurationSetValues(properties2))
	luaunit.assertIsTrue(config:haveConfig("testset1"))
	luaunit.assertIsTrue(config:activateConfigurationSet("testset1"))
	luaunit.assertIsTrue(config:activateConfigurationSet("default"))
	luaunit.assertIsTrue(config:isActive())
	luaunit.assertIsTrue(config:removeConfigurationSet("testset1"))
	luaunit.assertIsFalse(config:isActive())
	
	
	
	
	--luaunit.assertEquals( ExecutionContextActionListener.toString(ExecutionContextActionListenerType.EC_DETACHED), 'EC_DETACHED' )
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
