local luaunit = require "luaunit"
local OutPortProvider = require "openrtm.OutPortProvider"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"

TestOutPortProvider = {}





function TestOutPortProvider:test_provider()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local provider = OutPortProvider.new()
	provider:setInterfaceType("data_service")
	provider:setDataFlowType("push")
	provider:setSubscriptionType("flush")

	local prof = {
		NVUtil.newNV("dataport.interface_type", "data_service")
	}
	provider:publishInterface(prof)
	local prof = {}
	provider:publishInterfaceProfile(prof)
	local prop = Properties.new()

	NVUtil.copyToProperties(prop, prof)
	
	luaunit.assertEquals(prop:getProperty("dataport.interface_type"), "data_service")
	


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
