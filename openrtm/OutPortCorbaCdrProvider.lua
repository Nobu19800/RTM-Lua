--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortCorbaCdrProvider= {}
_G["openrtm.OutPortCorbaCdrProvider"] = OutPortCorbaCdrProvider

local OutPortProvider = require "openrtm.OutPortProvider"
local BufferStatus = require "openrtm.BufferStatus"

local Factory = require "openrtm.Factory"
local OutPortProviderFactory = OutPortProvider.OutPortProviderFactory

OutPortCorbaCdrProvider.new = function()
	local obj = {}
	setmetatable(obj, {__index=OutPortProvider.new()})
	local Manager = require "openrtm.Manager"
	obj._PortStatus = Manager:instance():getORB().types:lookup("::OpenRTM::PortStatus").labelvalue


	obj:setInterfaceType("corba_cdr")
	obj._buffer = nil

	local orb = Manager:instance():getORB()
	local svr = orb:newservant(obj, nil, "IDL:openrtm.aist.go.jp/OpenRTM/OutPortCdr:1.0")
	local str = orb:tostring(svr)
	obj._objref = orb:newproxy(str,"IDL:openrtm.aist.go.jp/OpenRTM/OutPortCdr:1.0")

	table.insert(obj._properties, NVUtil.newNV("dataport.corba_cdr.outport_ior",
													str))
    --table.insert(obj._properties, NVUtil.newNV("dataport.corba_cdr.outport_ref",
	--												obj._objref))

	obj._listeners = nil
    obj._connector = nil
    obj._profile   = nil


	function obj:exit()
	end

	function obj:init(prop)
	end

	function obj:setBuffer(buffer)
		self._buffer = buffer
	end

	function obj:setListener(info, listeners)
		self._profile = info
		self._listeners = listeners
	end

	function obj:setConnector(connector)
		self._connector = connector
	end


	function obj:get()
		self._rtcout:RTC_PARANOID("OutPortCorbaCdrProvider.get()")
		if self._buffer == nil then
			self:onSenderError()
			return self._PortStatus.UNKNOWN_ERROR, ""
		end


		if self._buffer:empty() then
			self._rtcout:RTC_ERROR("buffer is empty.")
			return self._PortStatus.BUFFER_EMPTY, ""
		end

		local cdr = {_data=""}
		local ret = self._buffer:read(cdr)

		if ret == BufferStatus.BUFFER_OK then
			if cdr._data == "" then
				self._rtcout:RTC_ERROR("buffer is empty.")
				return self._PortStatus.BUFFER_EMPTY, ""
			end
		end
		return self:convertReturn(ret, cdr._data)
	end

	function obj:onBufferRead(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_READ]:notify(self._profile, data)
		end
    end

	function obj:onSend(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_SEND]:notify(self._profile, data)
		end
    end

	function obj:onBufferEmpty()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_BUFFER_EMPTY]:notify(self._profile)
		end
    end

	function obj:onBufferReadTimeout()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_BUFFER_READ_TIMEOUT]:notify(self._profile)
		end
    end

	function obj:onSenderEmpty()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_SENDER_EMPTY]:notify(self._profile)
		end
    end

	function obj:onSenderTimeout()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_SENDER_TIMEOUT]:notify(self._profile)
		end
    end

	function obj:onSenderError()
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_SENDER_ERROR]:notify(self._profile)
		end
    end

	function obj:convertReturn(status, data)
		if status == BufferStatus.BUFFER_OK then
			self:onBufferRead(data)
			self:onSend(data)
			return self._PortStatus.PORT_OK, data
		elseif status == BufferStatus.BUFFER_ERROR then
			self:onSenderError()
			return self._PortStatus.PORT_ERROR, data
		elseif status == BufferStatus.BUFFER_FULL then
		  return self._PortStatus.BUFFER_FULL, data
		elseif status == BufferStatus.BUFFER_EMPTY then
			self:onBufferEmpty()
			self:onSenderEmpty()
			return self._PortStatus.BUFFER_EMPTY, data
		elseif status == BufferStatus.PRECONDITION_NOT_MET then
			self:onSenderError()
			return self._PortStatus.PORT_ERROR, data
		elseif status == BufferStatus.TIMEOUT then
			self:onBufferReadTimeout()
			self:onSenderTimeout()
			return self._PortStatus.BUFFER_TIMEOUT, data
		else
			return self._PortStatus.UNKNOWN_ERROR, data
		end
	end





	return obj
end


OutPortCorbaCdrProvider.OutPortCorbaCdrProviderInit = function()
	OutPortProviderFactory:instance():addFactory("corba_cdr",
		OutPortCorbaCdrProvider.new,
		Factory.Delete)
end


return OutPortCorbaCdrProvider
