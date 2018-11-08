local luaunit = require "luaunit"
local OutPortBase = require "openrtm.OutPortBase"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local InPortDSProvider = require "openrtm.InPortDSProvider"

TestOutPortBase = {}







function TestOutPortBase:test_outport()

	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)
	local orb = mgr:getORB()

	local ReturnCode_t  = mgr._ReturnCode_t

	local outOut = OutPortBase.new("out","::RTC::TimedLong")
	local prop = Properties.new()
	outOut:init(prop)
	
	local conn_prof = {name="name", 
					connector_id="", 
					ports={}, 
					properties={
						NVUtil.newNV("dataport.interface_type","data_service")
					}}
	local prop = Properties.new()
	prop:setProperty("interface_type", "data_service")

	local in_provider = outOut:createProvider(conn_prof, prop)
	luaunit.assertNotEquals(in_provider, nil)


	local prop2 = Properties.new()
	prop2:setProperty("interface_type", "dummy")
	local in_provider2 = outOut:createProvider(conn_prof, prop2)
	luaunit.assertEquals(in_provider2, nil)

	local in_provider = InPortDSProvider.new()
	local ior = orb:tostring(in_provider._svr)

	local conn_prof = {name="name", 
					connector_id="", 
					ports={}, 
					properties={
						NVUtil.newNV("dataport.data_service.inport_ior",ior)
					}}
	local in_consumer = outOut:createConsumer(conn_prof, prop)
	luaunit.assertNotEquals(in_consumer, nil)

	local prop2 = Properties.new()
	prop2:setProperty("interface_type", "dummy")
	local in_consumer2 = outOut:createConsumer(conn_prof, prop2)
	luaunit.assertEquals(in_consumer2, nil)
	--luaunit.assertEquals(outOut:name(), "in")
	
	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
