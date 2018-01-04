--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortCorbaCdrConsumer= {}
_G["openrtm.OutPortCorbaCdrConsumer"] = OutPortCorbaCdrConsumer

local oil = require "oil"
local OutPortConsumer = require "openrtm.OutPortConsumer"
local NVUtil = require "openrtm.NVUtil"
local BufferStatus = require "openrtm.BufferStatus"

local Factory = require "openrtm.Factory"
local OutPortConsumerFactory = OutPortConsumer.OutPortConsumerFactory


OutPortCorbaCdrConsumer.new = function()
	local obj = {}
	setmetatable(obj, {__index=OutPortConsumer.new()})
	setmetatable(obj, {__index=CorbaConsumer.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("OutPortCorbaCdrConsumer")
    obj._buffer = nil
    obj._profile = nil
    obj._listeners = nil

	function obj:init(prop):
		self._rtcout:RTC_TRACE("init()")
    end
	function obj:setBuffer(buffer)
		self._rtcout:RTC_TRACE("setBuffer()")
		self._buffer = buffer
    end
	function obj:setListener(info, listeners):
		self._rtcout:RTC_TRACE("setListener()")
		self._listeners = listeners
		self._profile = info
    end


	return obj
end


return OutPortCorbaCdrConsumer
