local luaunit = require "luaunit"
local InPortDSConsumer = require "openrtm.InPortDSConsumer"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local oil = require "oil"
local RTCUtil = require "openrtm.RTCUtil"
local DataPortStatus = require "openrtm.DataPortStatus"

TestInPortDSConsumer = {}



local InPortDSProviderMoc = {}
InPortDSProviderMoc.new = function()
	local obj = {}
	obj._count = 0
	local Manager = require "openrtm.Manager"
	local orb = Manager:instance():getORB()
	obj._PortStatus = Manager:instance():getORB().types:lookup("::RTC::PortStatus").labelvalue

	obj._svr = orb:newservant(obj, nil, "IDL:omg.org/RTC/DataPushService:1.0")
	local str = orb:tostring(obj._svr)
	obj._objref = RTCUtil.getReference(orb, obj._svr, "IDL:omg.org/RTC/DataPushService:1.0")
	function obj:push(data)
		self._count = self._count + 1
		return self._PortStatus.PORT_OK
	end
	function obj:getObjRef()
		return self._objref
	end
	return obj
end




function TestInPortDSConsumer:test_consumer()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local orb = mgr:getORB()
	local PortStatus = orb.types:lookup("::RTC::PortStatus").labelvalue
	

	local consumer = InPortDSConsumer.new()
	consumer:init(Properties.new())

	local provider = InPortDSProviderMoc.new()
	local ior = orb:tostring(provider._svr)

	local ret = consumer:subscribeInterface({NVUtil.newNV("dataport.data_service.inport_ior",ior)})
	luaunit.assertIsTrue(ret)
	local ret = consumer:subscribeInterface({})
	luaunit.assertIsFalse(ret)
	local ret = consumer:subscribeInterface({NVUtil.newNV("dataport.data_service.inport_ior","")})
	luaunit.assertIsFalse(ret)
		
	luaunit.assertEquals(consumer:put(""), DataPortStatus.PORT_OK)
	luaunit.assertEquals(provider._count, 1)
	
	consumer:unsubscribeInterface({NVUtil.newNV("dataport.data_service.inport_ior",ior)})
	consumer:unsubscribeInterface({NVUtil.newNV("dataport.data_service.inport_ior","")})
	consumer:unsubscribeInterface({})


	luaunit.assertEquals(consumer:convertReturnCode(PortStatus.PORT_OK),DataPortStatus.PORT_OK)
	luaunit.assertEquals(consumer:convertReturnCode(PortStatus.PORT_ERROR),DataPortStatus.PORT_ERROR)
	luaunit.assertEquals(consumer:convertReturnCode(PortStatus.BUFFER_FULL),DataPortStatus.SEND_FULL)
	luaunit.assertEquals(consumer:convertReturnCode(PortStatus.BUFFER_TIMEOUT),DataPortStatus.SEND_TIMEOUT)
	luaunit.assertEquals(consumer:convertReturnCode(PortStatus.UNKNOWN_ERROR),DataPortStatus.UNKNOWN_ERROR)



	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
