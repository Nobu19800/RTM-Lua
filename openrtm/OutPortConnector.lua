--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortConnector= {}
_G["openrtm.OutPortConnector"] = OutPortConnector

local ConnectorBase = require "openrtm.ConnectorBase"

OutPortConnector.new = function(info)
	local obj = {}
	setmetatable(obj, {__index=ConnectorBase.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("OutPortConnector")
	--print(obj._rtcout)
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue
    obj._profile = info
    obj._endian = true
	function obj:profile()
		self._rtcout:RTC_TRACE("profile()")
		return self._profile
	end
	function obj:id()
		self._rtcout:RTC_TRACE("id() = "..self:profile().id)
		return self:profile().id
	end
	function obj:name()
		self._rtcout:RTC_TRACE("name() = "..self:profile().name)
		return self:profile().name
	end
	function obj:setConnectorInfo(profile)
		self._profile = profile
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end


return OutPortConnector
