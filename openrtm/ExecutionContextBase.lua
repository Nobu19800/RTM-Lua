--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ExecutionContextBase= {}
_G["openrtm.ExecutionContextBase"] = ExecutionContextBase


local TimeValue = require "openrtm.TimeValue"
local ExecutionContextWorker = require "openrtm.ExecutionContextWorker"
local ExecutionContextProfile = require "openrtm.ExecutionContextProfile"
local GlobalFactory = require "openrtm.GlobalFactory"
local NVUtil = require "openrtm.NVUtil"
local Properties = require "openrtm.Properties"


local DEFAULT_EXECUTION_RATE = 1000

ExecutionContextBase.new = function(name)
	local obj = {}
	local Manager = require "openrtm.Manager"
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue
	obj._LifeCycleState = Manager:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue

	obj._rtcout = Manager:instance():getLogbuf("ec_base")
    obj._activationTimeout   = TimeValue.new(0.5)
    obj._degetConfigvationTimeout = TimeValue.new(0.5)
    obj._resetTimeout        = TimeValue.new(0.5)
    obj._syncActivation   = true
    obj._syncDeactivation = true
    obj._syncReset        = true
    obj._worker  = ExecutionContextWorker.new()
    obj._profile = ExecutionContextProfile.new()
	function obj:init(props)
		self._rtcout:RTC_TRACE("init()")
		self._rtcout:RTC_DEBUG(props)
		--print(props)
		self:setExecutionRate(props)
		self:setProperties(props)

		self._syncActivation   = false
		self._syncDeactivation = false
		self._syncReset        = false
	end
	function obj:exit()
		self._rtcout:RTC_TRACE("exit()")
		self._profile:exit()
		self._worker:exit()
	end
	function obj:setExecutionRate(props)
		if props:findNode("rate") then
			rate_ = tonumber(props:getProperty("rate"))
			if rate_ ~= nil then
				self:setRate(rate_)
				return true
			end
		end
		return false
	end

	function obj:setRate(rate)
		self._rtcout:RTC_TRACE("setRate("..rate..")")
		ret_ = self._profile:setRate(self:onSettingRate(rate))
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("Setting execution rate failed. "..rate)
			return ret_
		end

		ret_ = self._worker:rateChanged()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("Invoking on_rate_changed() for each RTC failed.")
			return ret_
		end

		ret_ = self:onSetRate(rate)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onSetRate("..rate..") failed.")
			return ret_
		end
		self._rtcout:RTC_INFO("setRate("..rate..") done")
		return ret_
	end

	function obj:onSettingRate(rate)
		--print(rate)
		return rate
	end

	function obj:onSetRate(rate)
		return self._ReturnCode_t.RTC_OK
	end



	function obj:setProperties(props)
		self._profile:setProperties(props)
	end

	function obj:setObjRef(ec_ptr)
		self._worker:setECRef(ec_ptr)
		self._profile:setObjRef(ec_ptr)
    end
	function obj:setKind(kind)
		return self._profile:setKind(kind)
	end

	function obj:bindComponent(rtc)
		return self._worker:bindComponent(rtc)
	end


	function obj:getObjRef()
		return self._profile:getObjRef()
	end

	function obj:start()
		self._rtcout:RTC_TRACE("start()")
		ret_ = self:onStarting()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onStarting() failed. Starting EC aborted.")
			return ret_
		end

		ret_ = self._worker:start()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("Invoking on_startup() for each RTC failed.")
			return ret_
		end

		ret_ = self:onStarted()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onStartted() failed. Started EC aborted..")
			self._worker:stop()
			self._rtcout:RTC_ERROR("on_shutdown() was invoked, because of onStarted")
			return ret_
		end

		return ret_
	end
	function obj:onIsRunning(running)
		return running
	end
	function obj:onStarting()
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onStarted()
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onStopping()
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onStopped()
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onGetRate(rate)
		return rate
	end
	function obj:onSettingRate(rate)
		return rate
	end
	function obj:onSetRate(rate)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onAddingComponent(rtobj)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onAddedComponent(rtobj)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onRemovingComponent(rtobj)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onRemovedComponent(rtobj)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onActivating(comp)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onWaitingActivated(comp, count)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onActivated(comp, count)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onActivating()
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onDeactivating(comp)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onWaitingDeactivated(comp, count)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onDeactivated(comp, count)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onResetting(comp)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onWaitingReset(comp, count)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onReset(comp, count)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onGetComponentState(state)
		return state
	end
	function obj:onGetKind(kind)
		return kind
	end
	function obj:onGetProfile(profile)
		return profile
	end

	function obj:invokeWorkerPreDo()
		self._worker:invokeWorkerPreDo()
    end
	function obj:invokeWorkerDo()
		self._worker:invokeWorkerDo()
    end
	function obj:invokeWorkerPostDo()
		self._worker:invokeWorkerPostDo()
    end
	function obj:getPeriod()
		return self._profile:getPeriod()
	end
	function obj:activateComponent(comp)
		self._rtcout:RTC_TRACE("activateComponent()")
		ret_ = self:onActivating(comp)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onActivating() failed.")
			return ret_
		end

		rtobj_ = {object=nil}
		ret_ = self._worker:activateComponent(comp, rtobj_)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			return ret_
		end

		if not self._syncActivation then
			ret_ = self:onActivated(rtobj_[0], -1)
			if ret_ ~= self._ReturnCode_t.RTC_OK then

				self._rtcout:RTC_ERROR("onActivated() failed.")
			end
			--print(ret_)
			return ret_
		end


		self._rtcout:RTC_DEBUG("Synchronous activation mode. ")
        self._rtcout:RTC_DEBUG("Waiting for the RTC to be ACTIVE state. ")
		return self:waitForActivated(rtobj_.object)
	end
	function obj:waitForActivated(rtobj)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:deactivateComponent(comp)
		self._rtcout:RTC_TRACE("deactivateComponent()")
		ret_ = self:onDeactivating(comp)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onDeactivating() failed.")
			return ret_
		end

		rtobj_ = {object=nil}
		ret_ = self._worker:deactivateComponent(comp, rtobj_)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			return ret_
		end

		if not self._syncDeactivation then
			ret_ = self:onDeactivated(rtobj_[0], -1)
			if ret_ ~= self._ReturnCode_t.RTC_OK then
				self._rtcout:RTC_ERROR("onActivated() failed.")
			end
			return ret_
		end

		self._rtcout:RTC_DEBUG("Synchronous deactivation mode. ")
        self._rtcout:RTC_DEBUG("Waiting for the RTC to be INACTIVE state. ")
		return self:waitForDeactivated(rtobj_.object)

	end
	function obj:waitForDeactivated(rtobj)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:resetComponent(comp)
		self._rtcout:RTC_TRACE("resetComponent()")
		ret_ = self:onResetting(comp)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onResetting() failed.")
			return ret_
		end

		rtobj_ = {object=nil}
		ret_ = self._worker:resetComponent(comp, rtobj_)
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			return ret_
		end

		if not self._syncReset then
			ret_ = self:onReset(rtobj_[0], -1)
			if ret_ ~= self._ReturnCode_t.RTC_OK then
				self._rtcout:RTC_ERROR("onReset() failed.")
			end
			return ret_
		end

		self._rtcout:RTC_DEBUG("Synchronous deactivation mode. ")
        self._rtcout:RTC_DEBUG("Waiting for the RTC to be INACTIVE state. ")
		return self:waitForReset(rtobj_.object)

	end
	function obj:waitForReset(rtobj)
		return self._ReturnCode_t.RTC_OK
	end


	function obj:isRunning()
		self._rtcout:RTC_TRACE("isRunning()")
		return self._worker:isRunning()
	end




	function obj:is_running()
		self._rtcout:RTC_TRACE("is_running()")
		return self:isRunning()
	end
	function obj:get_rate()
		return self:getRate()
	end
	function obj:set_rate(rate)
		return self:setRate(rate)
	end
	function obj:activate_component(comp)
		--print("activate_component")
		return self:activateComponent(comp)
	end
	function obj:deactivate_component(comp)
		return self:deactivateComponent(comp)
	end
	function obj:reset_component(comp)
		return self:resetComponent(comp)
	end
	function obj:get_component_state(comp)
		return self:getComponentState(comp)
	end
	function obj:get_kind()
		return self:getKind()
	end
	function obj:add_component(comp)
		return self:addComponent(comp)
	end
	function obj:remove_component(comp)
		return self:removeComponent(comp)
	end
	function obj:get_profile()
		return self:getProfile()
	end

	function obj:getProfile()
		self._rtcout:RTC_TRACE("getProfile()")
		local prof_ = self._profile:getProfile()
		self._rtcout:RTC_DEBUG("kind: "..self:getKindString(prof_.kind))
		self._rtcout:RTC_DEBUG("rate: "..prof_.rate)
		self._rtcout:RTC_DEBUG("properties:")
		local props_ = Properties.new()
		NVUtil.copyToProperties(props_, prof_.properties)
		self._rtcout:RTC_DEBUG(props_)
		return self:onGetProfile(prof_)
	end
	function obj:getKindString(kind)
		return self._profile:getKindString(kind)
	end


	function obj:getComponentState(comp)
		local state_ = self._worker:getComponentState(comp)
		self._rtcout:RTC_TRACE("getComponentState() = "..self:getStateString(state_))
		if state_ == self._LifeCycleState.CREATED_STATE then
			self._rtcout:RTC_ERROR("CREATED state: not initialized "..
								 "RTC or unknwon RTC specified.")
		end

		return self:onGetComponentState(state_)
	end

	function obj:getStateString(state)
		return self._worker:getStateString(state)
	end


	function obj:stop()
		self._rtcout:RTC_TRACE("stop()")
		local ret_ = self:onStopping()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onStopping() failed. Stopping EC aborted.")
			return ret_
		end

		ret_ = self._worker:stop()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("Invoking on_shutdown() for each RTC failed.")
			return ret_
		end

		ret_ = self:onStopped()
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("onStopped() failed. Stopped EC aborted.")
			return ret_
		end

		return ret_
	end



	return obj
end


ExecutionContextBase.ExecutionContextFactory = {}
setmetatable(ExecutionContextBase.ExecutionContextFactory, {__index=GlobalFactory.Factory.new()})

function ExecutionContextBase.ExecutionContextFactory:instance()
	return self
end

return ExecutionContextBase
