--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortConnector= {}
_G["openrtm.InPortConnectorBase"] = InPortConnector

local ConnectorBase = require "openrtm.ConnectorBase"

InPortConnector = {}
InPortConnector.new = function(info, buffer)
	local obj = {}
	setmetatable(obj, {__index=ConnectorBase.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("InPortConnector")
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue
    obj._profile = info
    obj._buffer = buffer
    obj._dataType = nil
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
	function obj:disconnect()
	end
	function obj:getBuffer()
		return self._buffer
	end
	function obj:read(data)

	end
	function obj:setConnectorInfo(profile)
		self._profile = profile
		return self._ReturnCode_t.RTC_OK
	end
	function obj:setDataType(data)
		self._dataType = data
		--print(self._dataType)
	end
	return obj
end


return InPortConnector
