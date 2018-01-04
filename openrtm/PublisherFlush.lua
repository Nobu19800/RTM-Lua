--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local PublisherFlush= {}
_G["openrtm.PublisherFlush"] = PublisherFlush

local DataPortStatus = require "openrtm.DataPortStatus"
local PublisherBase = require "openrtm.PublisherBase"
local PublisherFactory = PublisherBase.PublisherFactory
local Factory = require "openrtm.Factory"


PublisherFlush.new = function()
	local obj = {}
	setmetatable(obj, {__index=PublisherBase.new(info, provider)})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("PublisherFlush")
    obj._consumer  = nil
    obj._active    = false
    obj._profile   = nil
    obj._listeners = nil
    obj._retcode   = DataPortStatus.PORT_OK

	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		return DataPortStatus.PORT_OK
	end
	function obj:setConsumer(consumer)
		self._rtcout:RTC_TRACE("setConsumer()")
		if consumer == nil then
			return DataPortStatus.INVALID_ARGS
		end

		self._consumer = consumer

		return DataPortStatus.PORT_OK
	end
	function obj:setBuffer(buffer)
		self._rtcout:RTC_TRACE("setBuffer()")
		return DataPortStatus.PORT_OK
	end
	function obj:setListener(info, listeners)
		self._rtcout:RTC_TRACE("setListeners()")

		if listeners == nil then
			self._rtcout:RTC_ERROR("setListeners(listeners == 0): invalid argument")
			return DataPortStatus.INVALID_ARGS
		end

		self._profile = info
		self._listeners = listeners

		return DataPortStatus.PORT_OK
	end

	function obj:write(data, sec, usec)
		self._rtcout:RTC_PARANOID("write()")
		if self._consumer == nil or self._listeners == nil then
			return DataPortStatus.PRECONDITION_NOT_MET
		end

		if self._retcode == DataPortStatus.CONNECTION_LOST then
			self._rtcout:RTC_DEBUG("write(): connection lost.")
			return self._retcode
		end

		self:onSend(data)

		self._retcode = self._consumer:put(data)

		if self._retcode == DataPortStatus.PORT_OK then
			self:onReceived(data)
			return self._retcode
		elseif self._retcode == DataPortStatus.PORT_ERROR then
			self:onReceiverError(data)
			return self._retcode
		elseif self._retcode == DataPortStatus.SEND_FULL then
			self:onReceiverFull(data)
			return self._retcode
		elseif self._retcode == DataPortStatus.SEND_TIMEOUT then
			self:onReceiverTimeout(data)
			return self._retcode
		elseif self._retcode == DataPortStatus.CONNECTION_LOST then
			self:onReceiverTimeout(data)
			return self._retcode
		elseif self._retcode == DataPortStatus.UNKNOWN_ERROR then
			self:onReceiverError(data)
			return self._retcode
		else
			self:onReceiverError(data)
			return self._retcode
		end
	end

	function obj:isActive()
		return self._active
	end

	function obj:activate()
		if self._active then
			return DataPortStatus.PRECONDITION_NOT_MET
		end

		self._active = true

		return DataPortStatus.PORT_OK
	end

	function obj:deactivate()
		if not self._active then
			return DataPortStatus.PRECONDITION_NOT_MET
		end

		self._active = false

		return DataPortStatus.PORT_OK
	end


	function obj:onSend(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_SEND]:notify(self._profile, dat
		end
	end

	function obj:onReceived(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVED]:notify(self._profile, dat
		end
	end

	function obj:onReceiverFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_FULL]:notify(self._profile, dat
		end
	end

	function obj:onReceiverTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_TIMEOUT]:notify(self._profile, dat
		end
	end

	function obj:onReceiverError(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_ERROR]:notify(self._profile, dat
		end
	end

	return obj
end


PublisherFlush.PublisherFlushInit = function()
	PublisherFactory:instance():addFactory("flush",
		PublisherFlush.new,
		Factory.Delete)
end


return PublisherFlush
