--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local RTObjectStateMachine= {}
_G["openrtm.RTObjectStateMachine"] = RTObjectStateMachine


local StateMachine = require "openrtm.StateMachine"
StateHolder = StateMachine.StateHolder
local NVUtil = require "openrtm.NVUtil"

local NUM_OF_LIFECYCLESTATE = 4

local ActionPredicate = {}
ActionPredicate.new = function(object, func)
	local obj = {}
	obj.instance = object
	local call_func = function(self, state)
		func(self.instance, state)
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


RTObjectStateMachine.new = function(id, comp)
	local obj = {}
	local Manager = require "openrtm.Manager"
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue
	obj._LifeCycleState = Manager:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue
	obj._id = id
    obj._rtobj = comp
    obj._sm = StateMachine.new(NUM_OF_LIFECYCLESTATE)
    obj._ca   = false
    obj._dfc  = false
    obj._fsm  = false
    obj._mode = false
    obj._caVar   = nil
    obj._dfcVar  = nil
    obj._fsmVar  = nil
    obj._modeVar = nil
    obj._rtObjPtr = nil



	function obj:setComponentAction(comp)
		if comp.getObjRef == nil then
			self._caVar = comp
		else
			self._rtObjPtr = comp
			self._caVar = comp:getObjRef()
		end
	end
	function obj:setDataFlowComponentAction(comp)
	end
	function obj:setFsmParticipantAction(comp)
	end
	function obj:setMultiModeComponentAction(comp)
	end



	function obj:workerPreDo()
		return self._sm:worker_pre()
	end


	function obj:workerDo()
		return self._sm:worker_do()
	end

	function obj:workerPostDo()
		return self._sm:worker_post()
	end

	function obj:getState()
		--print(self._sm:getState())
		return self._sm:getState()-1
	end

	function obj:isCurrentState(state)
		--print(self:getState(),state)
		return (self:getState() == state)
	end


	function obj:isEquivalent(comp)
		--local Manager = require "openrtm.Manager"
		--orb = Manager:instance():getORB()
		--print(self._rtobj,comp)
		--print(comp:getInstanceName())
		--print(self._rtobj:getInstanceName())
		--return (orb:tostring(self._rtobj)==orb:tostring(comp))
		--print("abcde")


		--print(comp, self._rtobj)
		return NVUtil._is_equivalent(comp, self._rtobj, comp.getObjRef, self._rtobj.getObjRef)
		--return (comp:getInstanceName()==self._rtobj:getInstanceName())
	end

	function obj:goTo(state)
		self._sm:goTo(state+1)
    end

	function obj:getComponentObj()

		if self._rtObjPtr ~= nil then
			return self._rtObjPtr
		elseif self._caVar ~= nil then
			return self._caVar
		else
			return nil
		end
	end
	function obj:onStartup()
		local comp = self:getComponentObj()
		if comp ~= nil then
			comp:on_startup(self._id)
		end
	end
	function obj:onShutdown()
		local comp = self:getComponentObj()
		if comp ~= nil then
			comp:on_shutdown(self._id)
		end
	end
	function obj:onActivated(st)
		local comp = self:getComponentObj()
		--print(self._caVar)
		--print("test",self._caVar)
		if comp == nil then
			return
		end
		--local ret = self._caVar:on_activated(self._id)
		--print(type(ret), type(self._ReturnCode_t.RTC_OK))
		--if ret ~= "RTC_OK" then
		--print("aaaa")
		if NVUtil.getReturnCode(comp:on_activated(self._id)) ~= self._ReturnCode_t.RTC_OK then
			--print("onActivated:ERROR")
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
		--print("OK")
    end
	function obj:onDeactivated(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		comp:on_deactivated(self._id)
    end
	function obj:onAborting(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		comp:on_aborting(self._id)
    end
	function obj:onError(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		comp:on_error(self._id)
    end
	function obj:onReset(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		if NVUtil.getReturnCode(comp:on_reset(self._id)) ~= self._ReturnCode_t.RTC_OK then
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
    end
	function obj:onExecute(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		if NVUtil.getReturnCode(comp:on_execute(self._id)) ~= self._ReturnCode_t.RTC_OK then
			--print("onExecute:ERROR")
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
    end
	function obj:onStateUpdate(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		if NVUtil.getReturnCode(comp:on_state_update(self._id)) ~= self._ReturnCode_t.RTC_OK then
			--print("onStateUpdate:ERROR")
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
    end
	function obj:onRateChanged(st)
		local comp = self:getComponentObj()
		if comp == nil then
			return
		end
		local ret = comp:on_rate_changed(self._id)
		if ret ~= self._ReturnCode_t.RTC_OK then
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
		return ret
    end
	function obj:onAction(st)
		local comp = self:getComponentObj()
		if self._fsmVar == nil then
			return
		end
		if self._fsmVar:on_action(self._id) ~= self._ReturnCode_t.RTC_OK then
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
    end
	function obj:onModeChanged(st)
		local comp = self:getComponentObj()
		if self._modeVar == nil then
			return
		end
		if self._modeVar:on_mode_changed(self._id) ~= self._ReturnCode_t.RTC_OK then
			self._sm:goTo(self._LifeCycleState.ERROR_STATE+1)
		end
    end

	--print(comp)
	obj:setComponentAction(comp)
	--print(obj._caVar)
    obj:setDataFlowComponentAction(comp)
    obj:setFsmParticipantAction(comp)
    obj:setMultiModeComponentAction(comp)

    obj._sm:setListener(obj)
	--print(obj.onActivated)
	--obj:onActivated(1)
    obj._sm:setEntryAction(obj._LifeCycleState.ACTIVE_STATE+1,
							ActionPredicate.new(obj, obj.onActivated))
    obj._sm:setDoAction(obj._LifeCycleState.ACTIVE_STATE+1,
							ActionPredicate.new(obj, obj.onExecute))
    obj._sm:setPostDoAction(obj._LifeCycleState.ACTIVE_STATE+1,
							ActionPredicate.new(obj, obj.onStateUpdate))
    obj._sm:setExitAction(obj._LifeCycleState.ACTIVE_STATE+1,
							ActionPredicate.new(obj, obj.onDeactivated))
    obj._sm:setEntryAction(obj._LifeCycleState.ERROR_STATE+1,
							ActionPredicate.new(obj, obj.onAborting))
    obj._sm:setDoAction(obj._LifeCycleState.ERROR_STATE+1,
							ActionPredicate.new(obj, obj.onError))
    obj._sm:setExitAction(obj._LifeCycleState.ERROR_STATE+1,
							ActionPredicate.new(obj, obj.onReset))
    st = StateHolder.new()
    st.prev = obj._LifeCycleState.INACTIVE_STATE+1
    st.curr = obj._LifeCycleState.INACTIVE_STATE+1
    st.next = obj._LifeCycleState.INACTIVE_STATE+1
    obj._sm:setStartState(st)
    obj._sm:goTo(obj._LifeCycleState.INACTIVE_STATE+1)
	return obj
end


return RTObjectStateMachine
