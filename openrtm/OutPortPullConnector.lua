--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortPullConnector= {}
_G["openrtm.OutPortPullConnector"] = OutPortPullConnector

local OutPortConnector = require "openrtm.OutPortConnector"
local DataPortStatus = require "openrtm.DataPortStatus"
local CdrBufferBase = require "openrtm.CdrBufferBase"
local CdrBufferFactory = CdrBufferBase.CdrBufferFactory
local OutPortProvider = require "openrtm.OutPortProvider"
local OutPortProviderFactory = OutPortProvider.OutPortProviderFactory

OutPortPullConnector.new = function(info, provider, listeners, buffer)
	local obj = {}
	setmetatable(obj, {__index=OutPortConnector.new(info)})

	function obj:write(data)
		local Manager = require "openrtm.Manager"

		local cdr_data = Manager:instance():cdrMarshal(data._data, data._type)
		--print(cdr_data)


		if self._buffer ~= nil then
			self._buffer:write(cdr_data)
		else
			return DataPortStatus.UNKNOWN_ERROR
		end
		return DataPortStatus.PORT_OK
	end


	function obj:disconnect()
		self._rtcout:RTC_TRACE("disconnect()")
		self:onDisconnect()

		if self._provider ~= nil then
			OutPortProviderFactory:instance():deleteObject(self._provider)
			self._provider:exit()
		end
		self._provider = nil


		if self._buffer ~= nil then
			CdrBufferFactory:instance():deleteObject(self._buffer)
		end
		self._buffer = nil


		return DataPortStatus.PORT_OK
	end

	function obj:getBuffer()
		return self._buffer
	end

	function obj:activate()
	end

	function obj:deactivate()
	end

	function obj:createBuffer(info)
		local buf_type = info.properties:getProperty("buffer_type","ring_buffer")
		return CdrBufferFactory:instance():createObject(buf_type)
	end

	function obj:onConnect()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_CONNECT]:notify(self._profile)
		end
	end

	function obj:onDisconnect()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_DISCONNECT]:notify(self._profile)
		end
	end

	function obj:setInPort()
		return false
	end

	function obj:read()
		return false
	end

	function obj:isNew()
		return self._directNewData
	end



	obj._provider = provider
    obj._listeners = listeners
    obj._buffer = buffer

    obj._directInPort = nil
    obj._inPortListeners = nil

    obj._directNewData = false

    obj._value = nil

    if obj._buffer == nil then
		obj._buffer = obj:createBuffer(info)
	end

    if obj._provider == nil or obj._buffer == nil then
		obj._rtcout:RTC_ERROR("Exeption: in OutPortPullConnector.__init__().")
		error("")
	end

    obj._buffer:init(info.properties:getNode("buffer"))
    obj._provider:init(info.properties)
    obj._provider:setBuffer(obj._buffer)
    obj._provider:setConnector(obj)
    obj._provider:setListener(info, obj._listeners)
    obj:onConnect()
	return obj
end


return OutPortPullConnector
