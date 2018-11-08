local luaunit = require "luaunit"
local ExecutionContextProfile = require "openrtm.ExecutionContextProfile"
local Properties = require "openrtm.Properties"


TestExecutionContextProfile = {}


function TestExecutionContextProfile:test_init()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	local LifeCycleState = mgr:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue
	local ExecutionKind = mgr:instance():getORB().types:lookup("::RTC::ExecutionKind").labelvalue
	
	local ec_prof = ExecutionContextProfile.new(ExecutionKind.PERIODIC)
	
	
	luaunit.assertEquals( ec_prof:getKindString(ExecutionKind.PERIODIC), "PERIODIC")
	luaunit.assertEquals( ec_prof:getKindString(ExecutionKind.EVENT_DRIVEN), "EVENT_DRIVEN")
	luaunit.assertEquals( ec_prof:getKindString(ExecutionKind.OTHER), "OTHER")

	
	local prop = Properties.new()
	ec_prof:setProperties(prop)

	luaunit.assertEquals( ec_prof:setRate(10), ReturnCode_t.RTC_OK )



	local prof = ec_prof:getProfile()
	luaunit.assertEquals( prof.rate, 10)
	luaunit.assertEquals( prof.kind, ExecutionKind.PERIODIC)

	luaunit.assertEquals( ec_prof:setKind(ExecutionKind.EVENT_DRIVEN), ReturnCode_t.RTC_OK )
	luaunit.assertEquals( ec_prof:getKind(), ExecutionKind.EVENT_DRIVEN )


	ec_prof:exit()
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
