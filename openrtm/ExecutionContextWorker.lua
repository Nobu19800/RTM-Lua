--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ExecutionContextWorker= {}
_G["openrtm.ExecutionContextWorker"] = ExecutionContextWorker



local RTObjectStateMachine = require "openrtm.RTObjectStateMachine"





ExecutionContextWorker.new = function()
	local obj = {}
	local RTObject = require "openrtm.RTObject"
	local ECOTHER_OFFSET = RTObject.ECOTHER_OFFSET
	local Manager = require "openrtm.Manager"
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue
	obj._LifeCycleState = Manager:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue

	obj._rtcout = Manager:instance():getLogbuf("ec_worker")
    obj._running = false
    obj._rtcout:RTC_TRACE("ExecutionContextWorker.__init__")
    obj._ref = nil
    obj._comps = {}
    obj._addedComps = {}
    obj._removedComps = {}
	function obj:exit()
		self._rtcout:RTC_TRACE("exit")
	end
	function obj:rateChanged()
		self._rtcout:RTC_TRACE("rateChanged()")
		ret = self._ReturnCode_t.RTC_OK
		for i,comp in ipairs(self._comps) do
			tmp = comp:onRateChanged()
			if tmp ~= self._ReturnCode_t.RTC_OK then
				ret = tmp
			end
		end
		return ret
	end
	function obj:setECRef(ref)
		self._ref = ref
    end
	function obj:bindComponent(rtc)
		self._rtcout:RTC_TRACE("bindComponent()")
		if rtc == nil then
			self._rtcout:RTC_ERROR("NULL pointer is given.")
			return self._ReturnCode_t.BAD_PARAMETER
		end
		local ec_ = self:getECRef()
		local id_ = rtc:bindContext(ec_)
		if id_ < 0 or id_ > ECOTHER_OFFSET then
			self._rtcout:RTC_ERROR("bindContext returns invalid id: "..id_)
			return self._ReturnCode_t.RTC_ERROR
		end

		self._rtcout:RTC_DEBUG("bindContext returns id = "..id_)

		--local comp_ = rtc:getObjRef()
		local comp_ = rtc
		table.insert(self._comps, RTObjectStateMachine.new(id_, comp_))
		self._rtcout:RTC_DEBUG("bindComponent() succeeded.")
		return self._ReturnCode_t.RTC_OK
    end
	function obj:getECRef()
		return self._ref
	end
	function obj:start()
		self._rtcout:RTC_TRACE("start()")
		if self._running then
			self._rtcout:RTC_WARN("ExecutionContext is already running.")
			return self._ReturnCode_t.PRECONDITION_NOT_MET
		end
		--print(#self._comps)

		for i, comp in ipairs(self._comps) do
			comp:onStartup()
		end

		self._rtcout:RTC_DEBUG(table.maxn(self._comps).." components started.")
		self._running = true
		return self._ReturnCode_t.RTC_OK
	end
	function obj:stop()
		self._rtcout:RTC_TRACE("stop()")

		if not self._running then
		  self._rtcout:RTC_WARN("ExecutionContext is already stopped.")
		  return self._ReturnCode_t.PRECONDITION_NOT_MET
		end

		self._running = false

		for i, comp in ipairs(self._comps) do
		  comp:onShutdown()
		end


		return self._ReturnCode_t.RTC_OK
	end
	function obj:invokeWorkerPreDo()
		self._rtcout:RTC_PARANOID("invokeWorkerPreDo()")
		for i, comp in ipairs(self._comps) do
			comp:workerPreDo()
		end
    end
	function obj:invokeWorkerDo()
		self._rtcout:RTC_PARANOID("invokeWorkerDo()")
		for i, comp in ipairs(self._comps) do
			comp:workerDo()
		end
    end
	function obj:invokeWorkerPostDo()
		self._rtcout:RTC_PARANOID("invokeWorkerPostDo()")
		for i, comp in ipairs(self._comps) do
			comp:workerPostDo()
		end
		self:updateComponentList()
    end
	function obj:activateComponent(comp, rtobj)
		self._rtcout:RTC_TRACE("activateComponent()")
		obj_ = self:findComponent(comp)
		if obj_ == nil then
			self._rtcout:RTC_ERROR("Given RTC is not participant of this EC.")
			return self._ReturnCode_t.BAD_PARAMETER
		end

		self._rtcout:RTC_DEBUG("Component found in the EC.")
		--print(obj_:isCurrentState(self._LifeCycleState.INACTIVE_STATE))
		--print(self._ReturnCode_t.INACTIVE_STATE)
		if not obj_:isCurrentState(self._LifeCycleState.INACTIVE_STATE) then
			self._rtcout:RTC_ERROR("State of the RTC is not INACTIVE_STATE.")
			return self._ReturnCode_t.PRECONDITION_NOT_MET
		end

		self._rtcout:RTC_DEBUG("Component is in INACTIVE state. Going to ACTIVE state.")
		--print("aaaaaa")
		obj_:goTo(self._LifeCycleState.ACTIVE_STATE)
		rtobj.object = obj_

		self._rtcout:RTC_DEBUG("activateComponent() done.")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:deactivateComponent(comp, rtobj)
		self._rtcout:RTC_TRACE("deactivateComponent()")
		obj_ = self:findComponent(comp)
		if obj_ == nil then
			self._rtcout:RTC_ERROR("Given RTC is not participant of this EC.")
			return self._ReturnCode_t.BAD_PARAMETER
		end

		self._rtcout:RTC_DEBUG("Component found in the EC.")

		if not obj_:isCurrentState(self._LifeCycleState.ACTIVE_STATE) then
			self._rtcout:RTC_ERROR("State of the RTC is not ACTIVE_STATE.")
			return self._ReturnCode_t.PRECONDITION_NOT_MET
		end



		obj_:goTo(self._LifeCycleState.INACTIVE_STATE)
		rtobj.object = obj_


		return self._ReturnCode_t.RTC_OK
	end
	function obj:resetComponent(comp, rtobj)
		self._rtcout:RTC_TRACE("resetComponent()")
		local obj_ = self:findComponent(comp)
		if obj_ == nil then
			self._rtcout:RTC_ERROR("Given RTC is not participant of this EC.")
			return self._ReturnCode_t.BAD_PARAMETER
		end

		self._rtcout:RTC_DEBUG("Component found in the EC.")

		if not obj_:isCurrentState(self._LifeCycleState.ERROR_STATE) then
			self._rtcout:RTC_ERROR("State of the RTC is not ERROR_STATE.")
			return self._ReturnCode_t.PRECONDITION_NOT_MET
		end



		obj_:goTo(self._LifeCycleState.INACTIVE_STATE)
		rtobj.object = obj_


		return self._ReturnCode_t.RTC_OK
	end
	function obj:findComponent(comp)
		for i, comp_ in ipairs(self._comps) do
			--print(comp_:isEquivalent(comp))
			if comp_:isEquivalent(comp) then
				return comp_
			end
		end
		return nil
	end

	function obj:updateComponentList()
	end

	function obj:getComponentState(comp)
		self._rtcout:RTC_TRACE("getComponentState()")

		local rtobj_ = self:findComponent(comp)
		if rtobj_ == nil then
			self._rtcout:RTC_WARN("Given RTC is not participant of this EC.")
			return self._LifeCycleState.CREATED_STATE
		end

		local state_ = rtobj_:getState()

		self._rtcout:RTC_DEBUG("getComponentState() = "..self:getStateString(state_).." done")
		return state_
	end

	function obj:getStateString(state)
		local st = {"CREATED_STATE",
			  "INACTIVE_STATE",
			  "ACTIVE_STATE",
			  "ERROR_STATE"}

		if st[state+1] == nil then
			return ""
		else
			return st[state+1]
		end
	end


	function obj:isRunning()
		self._rtcout:RTC_TRACE("isRunning()")
		return self._running
	end



	return obj
end


return ExecutionContextWorker
