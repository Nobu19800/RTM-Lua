local luaunit = require "luaunit"
local OutPortDSConsumer = require "openrtm.OutPortDSConsumer"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local oil = require "oil"
local RTCUtil = require "openrtm.RTCUtil"
local DataPortStatus = require "openrtm.DataPortStatus"
local CdrBufferBase = require "openrtm.CdrBufferBase"
local CdrBufferFactory = CdrBufferBase.CdrBufferFactory
local RTCUtil = require "openrtm.RTCUtil"
local DataPortStatus = require "openrtm.DataPortStatus"


TestOutPortDSConsumer = {}



local OutPortDSProviderMoc = {}
OutPortDSProviderMoc.new = function()
	local obj = {}
	obj._count = 0
	local Manager = require "openrtm.Manager"
	local orb = Manager:instance():getORB()
	obj._PortStatus = Manager:instance():getORB().types:lookup("::RTC::PortStatus").labelvalue

	obj._svr = orb:newservant(obj, nil, "IDL:omg.org/RTC/DataPullService:1.0")
	local str = orb:tostring(obj._svr)
	obj._objref = RTCUtil.getReference(orb, obj._svr, "IDL:omg.org/RTC/DataPullService:1.0")
	function obj:pull()
		self._count = self._count + 1
		local mgr = require "openrtm.Manager"
		local d_out = {tm={sec=0,nsec=0},data=0}
		local data = mgr:instance():cdrMarshal(d_out, "::RTC::TimedLong")

		return self._PortStatus.PORT_OK, data
	end
	function obj:getObjRef()
		return self._objref
	end
	return obj
end




function TestOutPortDSConsumer:test_consumer()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)
	local orb = mgr:getORB()
	local PortStatus = orb.types:lookup("::RTC::PortStatus").labelvalue

	local consumer = OutPortDSConsumer.new()
	consumer:init(Properties.new())
	consumer:setBuffer(CdrBufferFactory:instance():createObject("ring_buffer"))

	local provider = OutPortDSProviderMoc.new()
	local ior = orb:tostring(provider._svr)

	local ret = consumer:subscribeInterface({NVUtil.newNV("dataport.data_service.outport_ior",ior)})
	luaunit.assertIsTrue(ret)
	local ret = consumer:subscribeInterface({NVUtil.newNV("dataport.data_service.outport_ior","")})
	luaunit.assertIsFalse(ret)
	local ret = consumer:subscribeInterface({})
	luaunit.assertIsFalse(ret)
	
	
	
		
	local data = {_data=""}
	luaunit.assertEquals(consumer:get(data), DataPortStatus.PORT_OK)
	luaunit.assertEquals(provider._count, 1)
	
	consumer:unsubscribeInterface({NVUtil.newNV("dataport.data_service.outport_ior",ior)})
	--consumer:unsubscribeInterface({NVUtil.newNV("dataport.data_service.outport_ior","dummy")})
	--consumer:unsubscribeInterface({})


	luaunit.assertEquals(consumer:convertReturn(PortStatus.PORT_OK,""),DataPortStatus.PORT_OK)
	luaunit.assertEquals(consumer:convertReturn(PortStatus.PORT_ERROR,""),DataPortStatus.PORT_ERROR)
	luaunit.assertEquals(consumer:convertReturn(PortStatus.BUFFER_FULL,""),DataPortStatus.BUFFER_FULL)
	luaunit.assertEquals(consumer:convertReturn(PortStatus.BUFFER_TIMEOUT,""),DataPortStatus.BUFFER_TIMEOUT)
	luaunit.assertEquals(consumer:convertReturn(PortStatus.UNKNOWN_ERROR,""),DataPortStatus.UNKNOWN_ERROR)


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
