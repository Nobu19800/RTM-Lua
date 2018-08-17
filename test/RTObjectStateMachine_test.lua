local luaunit = require "luaunit"
local RTObjectStateMachine = require "openrtm.RTObjectStateMachine"
local Properties = require "openrtm.Properties"
local oil = require "oil"


TestRTObjectStateMachine = {}


local rtobj = {}
rtobj.new = function(mgr)
	local obj = {}
	obj._mgr = mgr
	obj._ReturnCode_t  = mgr._ReturnCode_t
	function obj:getObjRef()
		return self
	end
	function obj:on_startup(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_shutdown(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_activated(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_deactivated(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_aborting(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_error(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_reset(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_execute(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_state_update(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:on_rate_changed(ec_id)
		return self._ReturnCode_t.RTC_OK
	end
	
	
	return obj
end


function TestRTObjectStateMachine:test_state()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})--,"-o","logger.file_name: stdout"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	
	local orb = mgr:getORB()

	local LifeCycleState = orb.types:lookup("::RTC::LifeCycleState").labelvalue

	
	local sm = RTObjectStateMachine.new(1,rtobj.new(mgr))

	luaunit.assertEquals(sm:getState(),LifeCycleState.INACTIVE_STATE)
	luaunit.assertIsTrue(sm:isCurrentState(LifeCycleState.INACTIVE_STATE))

	

	sm:goTo(LifeCycleState.ACTIVE_STATE)
	sm:workerPreDo()
	sm:workerDo()
	sm:workerPostDo()

	luaunit.assertIsTrue(sm:isCurrentState(LifeCycleState.ACTIVE_STATE))

	sm:onStartup()
	sm:onShutdown()
	local StateHolderMock = {
		curr = nil,
		prev = nil,
		next = nil
	}
	sm:onActivated(StateHolderMock)
	sm:onDeactivated(StateHolderMock)
	sm:onAborting(StateHolderMock)
	sm:onError(StateHolderMock)
	sm:onReset()
	sm:onExecute()
	sm:onStateUpdate()
	sm:onRateChanged()
	luaunit.assertEquals(sm:getExecutionContextHandle(),1)
	


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
