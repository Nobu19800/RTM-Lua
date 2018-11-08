local luaunit = require "luaunit"
local StateMachine = require "openrtm.StateMachine"
local StateHolder = StateMachine.StateHolder
local Properties = require "openrtm.Properties"






TestStateMachine = {}


function TestStateMachine:test_state()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local LifeCycleState = mgr:getORB().types:lookup("::RTC::LifeCycleState").labelvalue

	local sm = StateMachine.new(4)

	local ret1 = false
	local dummy_func1 = function(st)
		ret1 = true
	end
	local ret2 = false
	local dummy_func2 = function(st)
		ret2 = true
	end
	local ret3 = false
	local dummy_func3 = function(st)
		ret3 = true
	end
	local ret4 = false
	local dummy_func4 = function(st)
		ret4 = true
	end
	local ret5 = false
	local dummy_func5 = function(st)
		ret5 = true
	end
	local st = StateHolder.new()
    st.prev = LifeCycleState.INACTIVE_STATE+1
    st.curr = LifeCycleState.INACTIVE_STATE+1
    st.next = LifeCycleState.INACTIVE_STATE+1

	sm:setStartState(st)
	sm:setEntryAction(LifeCycleState.ACTIVE_STATE+1, dummy_func1)
	sm:setDoAction(LifeCycleState.ACTIVE_STATE+1, dummy_func2)
	sm:setExitAction(LifeCycleState.ACTIVE_STATE+1, dummy_func3)
	sm:setPreDoAction(LifeCycleState.ACTIVE_STATE+1, dummy_func4)
	sm:setPostDoAction(LifeCycleState.ACTIVE_STATE+1, dummy_func5)


	sm:goTo(LifeCycleState.ACTIVE_STATE+1)
	sm:worker_pre()
	luaunit.assertIsTrue(ret1)
	luaunit.assertIsFalse(ret2)
	luaunit.assertIsFalse(ret3)
	luaunit.assertIsFalse(ret4)
	luaunit.assertIsFalse(ret5)

	sm:worker_do()
	luaunit.assertIsTrue(ret2)
	luaunit.assertIsFalse(ret3)
	luaunit.assertIsFalse(ret4)
	luaunit.assertIsFalse(ret5)

	sm:worker_post()
	luaunit.assertIsFalse(ret3)
	luaunit.assertIsFalse(ret4)
	luaunit.assertIsTrue(ret5)

	sm:worker_pre()
	luaunit.assertIsFalse(ret3)
	luaunit.assertIsTrue(ret4)


	sm:goTo(LifeCycleState.INACTIVE_STATE+1)
	sm:worker_pre()
	luaunit.assertIsTrue(ret3)

	
	

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
