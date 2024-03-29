local luaunit = require "luaunit"
local InPortBase = require "openrtm.InPortBase"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local OutPortDSProvider = require "openrtm.OutPortDSProvider"

TestInPortBase = {}







function TestInPortBase:test_inport()

	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)
	local orb = mgr:getORB()

	local ReturnCode_t  = mgr._ReturnCode_t

	local inIn = InPortBase.new("in","::RTC::TimedLong")
	local prop = Properties.new()
	inIn:init(prop)
	
	local conn_prof = {name="name", 
					connector_id="", 
					ports={}, 
					properties={
						NVUtil.newNV("dataport.interface_type","data_service")
					}}
	local prop = Properties.new()
	prop:setProperty("interface_type", "data_service")

	local in_provider = inIn:createProvider(conn_prof, prop)
	luaunit.assertNotEquals(in_provider, nil)

	local prop2 = Properties.new()
	prop2:setProperty("interface_type", "dummy")
	local in_provider2 = inIn:createProvider(conn_prof, prop2)
	luaunit.assertEquals(in_provider2, nil)

	local out_provider = OutPortDSProvider.new()
	local ior = orb:tostring(out_provider._svr)

	local conn_prof = {name="name", 
					connector_id="", 
					ports={}, 
					properties={
						NVUtil.newNV("dataport.data_service.outport_ior",ior)
					}}
	local out_consumer = inIn:createConsumer(conn_prof, prop)
	luaunit.assertNotEquals(out_consumer, nil)
	--luaunit.assertEquals(inIn:name(), "in")
	local prop2 = Properties.new()
	prop2:setProperty("interface_type", "dummy")
	local out_consumer2 = inIn:createConsumer(conn_prof, prop2)
	luaunit.assertEquals(out_consumer2, nil)
	
	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
