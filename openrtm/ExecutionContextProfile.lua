--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ExecutionContextProfile= {}
_G["openrtm.ExecutionContextProfile"] = ExecutionContextProfile

local oil = require "oil"

local TimeValue = require "openrtm.TimeValue"
local NVUtil = require "openrtm.NVUtil"


local DEFAULT_PERIOD = 0.000001





ExecutionContextProfile.new = function(kind)
	local obj = {}
	local Manager = require "openrtm.Manager"
	obj._ExecutionKind = Manager:instance():getORB().types:lookup("::RTC::ExecutionKind").labelvalue
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue

	if kind == nil then
		kind = obj._ExecutionKind.PERIODIC
	end
	obj._rtcout = Manager:instance():getLogbuf("periodic_ecprofile")
	obj._period = TimeValue.new(DEFAULT_PERIOD)
    obj._rtcout:RTC_TRACE("ExecutionContextProfile.__init__()")
    obj._rtcout:RTC_DEBUG("Actual rate: "..obj._period:sec().." [sec], "..obj._period:usec().." [usec]")
    obj._ref = oil.corba.idl.null
    obj._profile = {kind=obj._ExecutionKind.PERIODIC,
					rate=1.0/obj._period:toDouble(),
					owner=oil.corba.idl.null, participants={},
					properties={}}
	function obj:exit()
		self._rtcout:RTC_TRACE("exit")
		self._profile.owner = oil.corba.idl.null
		self._profile.participants = {}
		self._profile.properties = {}
		self._ref = oil.corba.idl.null
	end
	function obj:setRate(rate)
		self._rtcout:RTC_TRACE("setRate("..rate..")")
		if rate <= 0.0 then
			return self._ReturnCode_t.BAD_PARAMETER
		end
		self._profile.rate = rate
		self._period = TimeValue.new(1.0 / rate)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:setProperties(props)
		self._rtcout:RTC_TRACE("setProperties()")
		self._rtcout:RTC_DEBUG(props)
		NVUtil.copyFromProperties(self._profile.properties, props)
	end
	function obj:setObjRef(ec_ptr)
		self._rtcout:RTC_TRACE("setObjRef()")
		self._ref = ec_ptr
	end
	function obj:getObjRef()
		self._rtcout:RTC_TRACE("getObjRef()")
		return self._ref
	end
	function obj:setKind(kind)
		if kind < self._ExecutionKind.PERIODIC or kind > self._ExecutionKind.OTHER then
			self._rtcout:RTC_ERROR("Invalid kind is given. "..kind)
			return self._ReturnCode_t.BAD_PARAMETER
		end

		self._rtcout:RTC_TRACE("setKind("..self:getKindString(kind)..")")
		--print(self:getKindString(kind))
		self._profile.kind = kind
		return self._ReturnCode_t.RTC_OK
	end
	function obj:getKindString(kind)
		kinds_ = {"PERIODIC", "EVENT_DRIVEN", "OTHER"}
		if kind == nil then
			kind_ = self._profile.kind
		else
			kind_ = kind
		end

		if kind_ < self._ExecutionKind.PERIODIC or kind_ > self._ExecutionKind.OTHER then
			return ""
		end

		return kinds_[kind_+1]
	end
	function obj:getPeriod()
		return self._period
	end
	function obj:getProfile()
		self._rtcout:RTC_TRACE("getProfile()")
		return self._profile
	end

	return obj
end


return ExecutionContextProfile
