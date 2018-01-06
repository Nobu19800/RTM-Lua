--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortCorbaCdrProvider= {}
_G["openrtm.InPortCorbaCdrProvider"] = InPortCorbaCdrProvider



local oil = require "oil"
local InPortProvider = require "openrtm.InPortProvider"
local NVUtil = require "openrtm.NVUtil"
local BufferStatus = require "openrtm.BufferStatus"

local Factory = require "openrtm.Factory"
local InPortProviderFactory = InPortProvider.InPortProviderFactory


InPortCorbaCdrProvider.new = function()
	local obj = {}
	--print(InPortProvider.new)
	setmetatable(obj, {__index=InPortProvider.new()})
	local Manager = require "openrtm.Manager"
	obj._PortStatus = Manager:instance():getORB().types:lookup("::OpenRTM::PortStatus").labelvalue
    obj:setInterfaceType("corba_cdr")

	local orb = Manager:instance():getORB()
	local svr = orb:newservant(obj, nil, "IDL:openrtm.aist.go.jp/OpenRTM/InPortCdr:1.0")
	local str = orb:tostring(svr)
	obj._objref = orb:newproxy(str,"IDL:openrtm.aist.go.jp/OpenRTM/InPortCdr:1.0")


    obj._buffer = nil

    obj._profile = nil
    obj._listeners = nil



    table.insert(obj._properties, NVUtil.newNV("dataport.corba_cdr.inport_ior",
													str))
    --table.insert(obj._properties, NVUtil.newNV("dataport.corba_cdr.inport_ref",
	--												obj._objref))
	--print(obj._properties)
	--for i,v in ipairs(obj._properties) do
	--	print(i,v)
	--end


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
	function obj:put(data)
		--print("put")
		local status = self._PortStatus.PORT_OK
		local success, exception = oil.pcall(
			function()
				self._rtcout:RTC_PARANOID("InPortCorbaCdrProvider.put()")

				if self._buffer == nil then
					self:onReceiverError(data)
					return self._PortStatus.PORT_ERROR
				end

				self._rtcout:RTC_PARANOID("received data size: "..#data)

				self:onReceived(data)
				--print(self._connector)
				if self._connector == nil then
					status = self._PortStatus.PORT_ERROR
					return
				end
				--print("test,",data)
				local ret = self._connector:write(data)

				status = self:convertReturn(ret, data)
			end)

		if not success then
			self._rtcout:RTC_TRACE(exception)
			return self._PortStatus.UNKNOWN_ERROR
		end
		return status
	end
	function obj:convertReturn(status, data)
		if status == BufferStatus.BUFFER_OK then
			self:onBufferWrite(data)
			return self._PortStatus.PORT_OK

		elseif status == BufferStatus.BUFFER_ERROR then
			self:onReceiverError(data)
			return self._PortStatus.PORT_ERROR

		elseif status == BufferStatus.BUFFER_FULL then
			self:onBufferFull(data)
			self:onReceiverFull(data)
			return self._PortStatus.BUFFER_FULL

		elseif status == BufferStatus.BUFFER_EMPTY then
			return self._PortStatus.BUFFER_EMPTY

		elseif status == BufferStatus.PRECONDITION_NOT_MET then
			self:onReceiverError(data)
			return self._PortStatus.PORT_ERROR

		elseif status == BufferStatus.TIMEOUT then
			self:onBufferWriteTimeout(data)
			self:onReceiverTimeout(data)
			return self._PortStatus.BUFFER_TIMEOUT

		else
			self:onReceiverError(data)
			return self._PortStatus.UNKNOWN_ERROR
		end
	end
	function obj:onBufferWrite(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_WRITE]:notify(self._profile, data)
		end
    end
	function obj:onBufferFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_FULL]:notify(self._profile, data)
		end
    end
	function obj:onBufferWriteTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT]:notify(self._profile, data)
		end
    end
	function obj:onBufferWriteOverwrite(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_OVERWRITE]:notify(self._profile, data)
		end
    end
	function obj:onReceived(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVED]:notify(self._profile, data)
		end
    end
	function obj:onReceiverFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_FULL]:notify(self._profile, data)
		end
    end
	function obj:onReceiverTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_TIMEOUT]:notify(self._profile, data)
		end
    end
	function obj:onReceiverError(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_ERROR]:notify(self._profile, data)
		end
    end
	return obj
end


InPortCorbaCdrProvider.InPortCorbaCdrProviderInit = function()
	InPortProviderFactory:instance():addFactory("corba_cdr",
		InPortCorbaCdrProvider.new,
		Factory.Delete)
end


return InPortCorbaCdrProvider
