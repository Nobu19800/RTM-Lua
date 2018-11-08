local luaunit = require "luaunit"

local CorbaPort = require "openrtm.CorbaPort"
local RTCUtil = require "openrtm.RTCUtil"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local StringUtil = require "openrtm.StringUtil"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local NVUtil = require "openrtm.NVUtil"
local CorbaPort = require "openrtm.CorbaPort"
local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"


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
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local orb = mgr:getORB()

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

	local conn_prof = {name="name2",
						connector_id="con2", 
						ports={}, 
						properties={}}
	
	local provider = orb:newservant(MyServiceSVC_impl.new(), nil, "IDL:SimpleService/MyService:1.0")
	local prop = Properties.new()
	prop:setProperty("unknown.port.MyService1.required.MyService.myservice0","test.sample")
	prop:setProperty("test.sample",orb:tostring(provider))
	NVUtil.copyFromProperties(conn_prof.properties, prop)
	
	local ret = myServicePort1:subscribeInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	myServicePort1:unsubscribeInterfaces(conn_prof)


	local conn_prof = {name="name6",
						connector_id="con6", 
						ports={}, 
						properties={}}
	

	local prop = Properties.new()
	prop:setProperty("unknown.port.MyService1.required.MyService.myservice0","test.sample")
	prop:setProperty("test.sample","")
	NVUtil.copyFromProperties(conn_prof.properties, prop)
	
	local ret = myServicePort1:subscribeInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)

	
	local conn_prof = {name="name3",
						connector_id="con3", 
						ports={}, 
						properties={}}
	local prop = Properties.new()
	prop:setProperty("unknown.port.MyService1.required.MyService.myservice0","")
	prop:setProperty("port.connection.strictness", "best_effort")
	NVUtil.copyFromProperties(conn_prof.properties, prop)
	local ret = myServicePort1:subscribeInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)



	local conn_prof = {name="name4",
						connector_id="con4", 
						ports={}, 
						properties={}}
	local prop = Properties.new()
	prop:setProperty("unknown.port.MyService1.required.MyService.myservice0","")
	prop:setProperty("port.connection.strictness", "strict")
	NVUtil.copyFromProperties(conn_prof.properties, prop)
	local ret = myServicePort1:subscribeInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_ERROR)



	local conn_prof = {name="name5",
						connector_id="con5", 
						ports={}, 
						properties={}}
	local prop = Properties.new()
	prop:setProperty("port.MyService.myservice0","")
	prop:setProperty("port.connection.strictness", "strict")
	NVUtil.copyFromProperties(conn_prof.properties, prop)
	local ret = myServicePort1:subscribeInterfaces(conn_prof)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_ERROR)
	myServicePort1:unsubscribeInterfaces(conn_prof)


	
	
	


	local myServicePort2 = CorbaPort.new("MyService1")
	myServicePort2:init(Properties.new())
	myServicePort2:registerConsumer("myservice0", "MyService", myservice0, _str)


	CORBA_RTCUtil.connect("testcon",Properties.new(),myServicePort1,myServicePort2)

	--myServicePort2:releaseObject()
	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
