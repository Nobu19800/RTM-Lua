local luaunit = require "luaunit"
local ExecutionContextWorker = require "openrtm.ExecutionContextWorker"
local Properties = require "openrtm.Properties"


TestExecutionContextWorker = {}


function TestExecutionContextWorker:test_init()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	local LifeCycleState = mgr:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue
	local ExecutionKind = mgr:instance():getORB().types:lookup("::RTC::ExecutionKind").labelvalue
	
	local ec_worker = ExecutionContextWorker.new()
	
	luaunit.assertEquals( ec_worker:start(), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec_worker:start(), ReturnCode_t.PRECONDITION_NOT_MET )

	

	
	luaunit.assertEquals( ec_worker:getStateString(LifeCycleState.CREATED_STATE), "CREATED_STATE")
	luaunit.assertEquals( ec_worker:getStateString(LifeCycleState.INACTIVE_STATE), "INACTIVE_STATE")
	luaunit.assertEquals( ec_worker:getStateString(LifeCycleState.ACTIVE_STATE), "ACTIVE_STATE")
	luaunit.assertEquals( ec_worker:getStateString(LifeCycleState.ERROR_STATE), "ERROR_STATE")

	luaunit.assertIsTrue(ec_worker:isRunning())
	

	luaunit.assertEquals( ec_worker:stop(), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec_worker:stop(), ReturnCode_t.PRECONDITION_NOT_MET )



	ec_worker:exit()
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
