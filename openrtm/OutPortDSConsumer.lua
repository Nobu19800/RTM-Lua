--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortDSConsumer= {}
_G["openrtm.OutPortDSConsumer"] = OutPortDSConsumer

local oil = require "oil"
local OutPortConsumer = require "openrtm.OutPortConsumer"
local NVUtil = require "openrtm.NVUtil"
local BufferStatus = require "openrtm.BufferStatus"
local DataPortStatus = require "openrtm.DataPortStatus"
local CorbaConsumer = require "openrtm.CorbaConsumer"

local Factory = require "openrtm.Factory"
local OutPortConsumerFactory = OutPortConsumer.OutPortConsumerFactory


OutPortDSConsumer.new = function()
	local obj = {}
	setmetatable(obj, {__index=OutPortConsumer.new()})
	setmetatable(obj, {__index=CorbaConsumer.new()})
	local Manager = require "openrtm.Manager"
	obj._PortStatus = Manager:instance():getORB().types:lookup("::RTC::PortStatus").labelvalue

	obj._rtcout = Manager:instance():getLogbuf("OutPortDSConsumer")
    obj._buffer = nil
    obj._profile = nil
    obj._listeners = nil

	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
    end
	function obj:setBuffer(buffer)
		self._rtcout:RTC_TRACE("setBuffer()")
		self._buffer = buffer
    end
	function obj:setListener(info, listeners)
		self._rtcout:RTC_TRACE("setListener()")
		self._listeners = listeners
		self._profile = info
    end


	function obj:get(data)
		self._rtcout:RTC_PARANOID("get()")

		local ret = self._PortStatus.PORT_OK
		local cdr_data = ""
		local success, exception = oil.pcall(
			function()
				local outportcdr = self:getObject()
				--print(outportcdr)

				if outportcdr ~= oil.corba.idl.null then
					ret,cdr_data = outportcdr:pull()
					ret = NVUtil.getPortStatus_RTC(ret)
					return
				end
					ret = DataPortStatus.CONNECTION_LOST
					return
				end)
		if not success then
			self._rtcout:RTC_WARN("Exception caught from OutPort.pull().")
			self._rtcout:RTC_ERROR(exception)
			return DataPortStatus.CONNECTION_LOST
		end
		--print(ret, DataPortStatus.CONNECTION_LOST)
		if ret == self._PortStatus.PORT_OK then
			self._rtcout:RTC_DEBUG("get() successful")
			data._data = cdr_data
			self:onReceived(data._data)
			self:onBufferWrite(data._data)

			if self._buffer:full() then
				self._rtcout:RTC_INFO("InPort buffer is full.")
				self:onBufferFull(data._data)
				self:onReceiverFull(data._data)
			end

			self._buffer:put(data._data)
			self._buffer:advanceWptr()
			self._buffer:advanceRptr()
			return DataPortStatus.PORT_OK
		end
		return self:convertReturn(ret,data[0])
	end

	function obj:subscribeInterface(properties)
		self._rtcout:RTC_TRACE("subscribeInterface()")
		if self:subscribeFromIor(properties) then
			return true
		end
		if self:subscribeFromRef(properties) then
			return true
		end
		return false
    end
	function obj:unsubscribeInterface(properties)
		self._rtcout:RTC_TRACE("unsubscribeInterface()")

		if self:unsubscribeFromIor(properties) then
			return
		end

		self:unsubscribeFromRef(properties)
    end


	function obj:subscribeFromIor(properties)
		self._rtcout:RTC_TRACE("subscribeFromIor()")

		local index = NVUtil.find_index(properties,
                                           "dataport.corba_cdr.outport_ior")
		--print(index)
		if index < 0 then
			self._rtcout:RTC_ERROR("outport_ior not found")
			return false
		end

		local ior = ""
		if properties[index] ~= nil then
			ior = NVUtil.any_from_any(properties[index].value)
		end

		if ior == "" then
			self._rtcout:RTC_ERROR("dataport.corba_cdr.outport_ior")
			return false
		end

		local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()
		local _obj = orb:newproxy(ior,"IDL:omg.org/RTC/DataPullService:1.0")


		if _obj == nil then
			self._rtcout:RTC_ERROR("invalid IOR string has been passed")
			return false
		end

		if not self:setObject(_obj) then
			self._rtcout:RTC_WARN("Setting object to consumer failed.")
			return false
		end

		return true
	end




	function obj:subscribeFromRef(properties)
		self._rtcout:RTC_TRACE("subscribeFromRef()")
		local index = NVUtil.find_index(properties,
										"dataport.corba_cdr.outport_ior")
		if index < 0 then
			self._rtcout:RTC_ERROR("outport_ref not found")
			return false
		end

		local _obj = NVUtil.any_from_any(properties[index].value)

		local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()

		_obj = orb:narrow(_obj, "IDL:omg.org/RTC/DataPullService:1.0")


		if _obj == nil then
			self._rtcout:RTC_ERROR("prop[outport_ref] is not objref")
			return false
		end


		if not self:setObject(obj) then
			self._rtcout:RTC_ERROR("Setting object to consumer failed.")
			return false
		end

		return true
	end




	function obj:unsubscribeFromIor(properties)
		self._rtcout:RTC_TRACE("unsubscribeFromIor()")
		local index = NVUtil.find_index(properties,
										"dataport.corba_cdr.outport_ior")
		if index < 0 then
			self._rtcout:RTC_ERROR("outport_ior not found")
			return false
		end


		ior = NVUtil.any_from_any(properties[index].value)


		if ior == "" then
			self._rtcout:RTC_ERROR("prop[outport_ior] is not string")
			return false
		end

		local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()
		local var = orb:newproxy(ior,"IDL:omg.org/RTC/DataPullService:1.0")
		if not NVUtil._is_equivalent(self:_ptr(true), var) then
			self._rtcout:RTC_ERROR("connector property inconsistency")
			return false
		end

		self:releaseObject()
		return true
	end

	function obj:unsubscribeFromRef(self, properties)
		self._rtcout:RTC_TRACE("unsubscribeFromRef()")
		local index = NVUtil.find_index(properties,
										"dataport.corba_cdr.outport_ref")

		if index < 0 then
			return false
		end


		local _obj = NVUtil.any_from_any(properties[index].value)


		if obj == nil then
			return false
		end

		local obj_ptr = self:_ptr(true)

		if obj_ptr == nil or not NVUtil._is_equivalent(obj_ptr, obj) then
			return false
		end

		self:releaseObject()
		return true
	end


	function obj:convertReturn(status, data)
		if status == self._PortStatus.PORT_OK then

		  return DataPortStatus.PORT_OK

		elseif status == self._PortStatus.PORT_ERROR then
			self:onSenderError()
			return DataPortStatus.PORT_ERROR

		elseif status == self._PortStatus.BUFFER_FULL then

			return DataPortStatus.BUFFER_FULL

		elseif status == self._PortStatus.BUFFER_EMPTY then
			self:onSenderEmpty()
			return DataPortStatus.BUFFER_EMPTY

		elseif status == self._PortStatus.BUFFER_TIMEOUT then
			self:onSenderTimeout()
			return DataPortStatus.BUFFER_TIMEOUT

		elseif status == self._PortStatus.UNKNOWN_ERROR then
			self:onSenderError()
			return DataPortStatus.UNKNOWN_ERROR

		else
			self:onSenderError()
			return DataPortStatus.UNKNOWN_ERROR
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
	function obj:onSenderEmpty(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorDataListenerType.ON_SENDER_EMPTY]:notify(self._profile)
		end
	end
	function obj:onSenderTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorDataListenerType.ON_SENDER_TIMEOUT]:notify(self._profile)
		end
	end
	function obj:onSenderError(data)
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorDataListenerType.ON_SENDER_ERROR]:notify(self._profile)
		end
	end

	return obj
end


OutPortDSConsumer.OutPortDSConsumerInit = function()
	OutPortConsumerFactory:instance():addFactory("data_service",
		OutPortDSConsumer.new,
		Factory.Delete)
end


return OutPortDSConsumer
