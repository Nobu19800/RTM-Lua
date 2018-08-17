local luaunit = require "luaunit"
local PortBase = require "openrtm.PortBase"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local NVUtil = require "openrtm.NVUtil"
local PortConnectListener = require "openrtm.PortConnectListener"
local PortConnectListeners = PortConnectListener.PortConnectListeners


local RTObjectMock = {}
RTObjectMock.new = function(name)
	local obj = {}
	obj._name = name
	function obj:get_component_profile()
		return {instance_name=self._name,
				type_name = "type_name",
				description = "description",
				version = "version",
				vendor = "vendor",
				category = "category",
				port_profiles = {},
				parent = oil.corba.idl.null,
				properties = {}}
	end
	function obj:getObjRef()
		return self
	end
	
	return obj
end

local PortMock = {}
PortMock.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=PortBase.new(name)})
	function obj:publishInterfaces(connector_profile)
		table.insert(self._connectors, connector)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:subscribeInterfaces(connector_profile)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:unsubscribeInterfaces(connector_profile)
		return self._ReturnCode_t.RTC_OK
	end
	return obj
end

TestPortBase = {}


function TestPortBase:test_port()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t

	local orb = mgr:getORB()

	local port1 = PortMock.new("test1")
	port1:createRef()
	local comp1 = RTObjectMock.new("comp1")
	port1:setOwner(comp1)
	luaunit.assertEquals(port1:get_port_profile().name, "comp1.test1")

	local conn_prof = {name="name1", connector_id="con1", ports={port1}, properties={}}
	local ret, conprof = port1:connect(conn_prof)
	luaunit.assertEquals(ret,ReturnCode_t.RTC_OK)
	--luaunit.assertEquals(#port1:connectors(),1)
	local ret = port1:disconnect("con1")
	luaunit.assertEquals(ret,ReturnCode_t.RTC_OK)
	local ret, conprof = port1:notify_connect(conn_prof)
	luaunit.assertEquals(ret,ReturnCode_t.RTC_OK)
	local ret = port1:notify_disconnect("con1")
	luaunit.assertEquals(ret,ReturnCode_t.RTC_OK)
	
	port1:addProperty("test_param","test_value")
	local prof = port1:get_port_profile().properties
	local prop = Properties.new()
	NVUtil.copyToProperties(prop,prof)

	luaunit.assertEquals(prop:getProperty("test_param"), "test_value")

	local ret, conprof = port1:connect(conn_prof)
	port1:disconnect_all()

	luaunit.assertNotEquals(port1:getPortRef(),nil)
	port1:setPortConnectListenerHolder(PortConnectListeners.new())

	port1:setConnectionLimit(100)
	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
