local luaunit = require "luaunit"

local CorbaPort = require "openrtm.CorbaPort"
local RTCUtil = require "openrtm.RTCUtil"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local StringUtil = require "openrtm.StringUtil"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local NVUtil = require "openrtm.NVUtil"


local MyServiceSVC_impl = {}
MyServiceSVC_impl.new = function()
	local obj = {}
	function obj:echo(msg)
		return msg
	end
	function obj:get_echo_history()
		return {}
	end
	function obj:set_value(value)
	end
	function obj:get_value()
		return 0
	end
	function obj:get_value_history()
		return {}
	end

	return obj
end

TestCorbaPort = {}
function TestCorbaPort:test_port()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	

	local myServicePort1 = CorbaPort.new("MyService1")
	myServicePort1:init(Properties.new())

	local myservice0 = MyServiceSVC_impl.new()

	local fpath = StringUtil.dirname(debug.getinfo(1)["short_src"])
	local _str = string.gsub(fpath,"\\","/").."MyService.idl"

	
	luaunit.assertIsTrue(myServicePort1:registerProvider("myservice0", "MyService", myservice0, _str, "IDL:SimpleService/MyService:1.0"))

	local myservice0 = CorbaConsumer.new("IDL:SimpleService/MyService:1.0")

	luaunit.assertIsTrue(myServicePort1:registerConsumer("myservice0", "MyService", myservice0, _str))

	myServicePort1:activateInterfaces()
	myServicePort1:deactivateInterfaces()
	
	local conn_prof = {name="name1",
						connector_id="con1", 
						ports={}, 
						properties={}}

	local ret = myServicePort1:publishInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	

	local prop = Properties.new()
	NVUtil.copyToProperties(prop, conn_prof.properties)
	luaunit.assertNotEquals(prop:getProperty("unknown.port.MyService1.provided.MyService.myservice0"),"")
	luaunit.assertNotEquals(prop:getProperty("port.MyService.myservice0"),"")
	

	local ret = myServicePort1:subscribeInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	
	myServicePort1:unsubscribeInterfaces(conn_prof)

	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
