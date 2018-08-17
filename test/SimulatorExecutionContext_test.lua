local luaunit = require "luaunit"
local SimulatorExecutionContext = require "openrtm.SimulatorExecutionContext"
local Properties = require "openrtm.Properties"
local RTObject = require "openrtm.RTObject"





TestSimulatorExecutionContext = {}


function TestSimulatorExecutionContext:test_ec()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	local orb = mgr:getORB()
	local LifeCycleState = orb.types:lookup("::RTC::LifeCycleState").labelvalue


	local ec = SimulatorExecutionContext.new()
	ec:init(Properties.new())

	local rtobj = RTObject.new(mgr)
	local prop = Properties.new()
	prop:setProperty("exec_cxt.periodic.type","SimulatorExecutionContext")
	rtobj:setProperties(prop)
	rtobj:createRef()
	oil.main(function()
		rtobj:initialize()
	end)

	luaunit.assertEquals(ec:add_component(rtobj:getObjRef()),ReturnCode_t.RTC_OK)

	luaunit.assertEquals(ec:activate_component(rtobj:getObjRef()),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(ec:activate_component(rtobj:getObjRef()),ReturnCode_t.PRECONDITION_NOT_MET)
	luaunit.assertEquals(ec:get_component_state(rtobj:getObjRef()),LifeCycleState.ACTIVE_STATE)
	luaunit.assertEquals(ec:deactivate_component(rtobj:getObjRef()),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(ec:deactivate_component(rtobj:getObjRef()),ReturnCode_t.PRECONDITION_NOT_MET)
	luaunit.assertEquals(ec:get_component_state(rtobj:getObjRef()),LifeCycleState.INACTIVE_STATE)
	luaunit.assertEquals(ec:deactivate_component(rtobj:getObjRef()),ReturnCode_t.PRECONDITION_NOT_MET)




	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
