local luaunit = require "luaunit"
local ExecutionContextBase = require "openrtm.ExecutionContextBase"
local Properties = require "openrtm.Properties"


TestExecutionContextBase = {}


function TestExecutionContextBase:test_init()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	local LifeCycleState = mgr:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue
	local ExecutionKind = mgr:instance():getORB().types:lookup("::RTC::ExecutionKind").labelvalue
	
	local ec = ExecutionContextBase.new("test")
	local prop = Properties.new()
	ec:init(prop)
	prop:setProperty("rate",100)
	luaunit.assertIsTrue(ec:setExecutionRate(prop))
	luaunit.assertEquals( ec:setRate(10), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec:setKind(ExecutionKind.PERIODIC), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec:get_kind(), ExecutionKind.PERIODIC )
	luaunit.assertEquals( ec:start(), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec:start(), ReturnCode_t.PRECONDITION_NOT_MET )
	luaunit.assertEquals( ec:get_rate(), 10 )
	luaunit.assertIsTrue( ec:is_running(), true)

	
	luaunit.assertEquals( ec:getKindString(ExecutionKind.PERIODIC), "PERIODIC")
	luaunit.assertEquals( ec:getKindString(ExecutionKind.EVENT_DRIVEN), "EVENT_DRIVEN")
	luaunit.assertEquals( ec:getKindString(ExecutionKind.OTHER), "OTHER")


	luaunit.assertEquals( ec:getStateString(LifeCycleState.CREATED_STATE), "CREATED_STATE")
	luaunit.assertEquals( ec:getStateString(LifeCycleState.INACTIVE_STATE), "INACTIVE_STATE")
	luaunit.assertEquals( ec:getStateString(LifeCycleState.ACTIVE_STATE), "ACTIVE_STATE")
	luaunit.assertEquals( ec:getStateString(LifeCycleState.ERROR_STATE), "ERROR_STATE")


	local prof = ec:get_profile()
	luaunit.assertEquals( prof.rate, 10)
	luaunit.assertEquals( prof.kind, ExecutionKind.PERIODIC)

	luaunit.assertEquals( ec:stop(), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec:stop(), ReturnCode_t.PRECONDITION_NOT_MET )
	
	ec:exit()
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
