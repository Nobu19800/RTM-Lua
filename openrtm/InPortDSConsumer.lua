--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortDSConsumer= {}
_G["openrtm.InPortDSConsumer"] = InPortDSConsumer


local oil = require "oil"
local InPortConsumer = require "openrtm.InPortConsumer"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local DataPortStatus = require "openrtm.DataPortStatus"
local NVUtil = require "openrtm.NVUtil"

local Factory = require "openrtm.Factory"
local InPortConsumerFactory = InPortConsumer.InPortConsumerFactory




InPortDSConsumer.new = function()
	local obj = {}
	setmetatable(obj, {__index=InPortConsumer.new()})
	setmetatable(obj, {__index=CorbaConsumer.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("InPortDSConsumer")
    obj._properties = nil
	obj._PortStatus = Manager:instance():getORB().types:lookup("::RTC::PortStatus").labelvalue

	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		self._properties = prop
    end

	function obj:put(data)
		self._rtcout:RTC_PARANOID("put()")
		local ret = DataPortStatus.PORT_OK
		local success, exception = oil.pcall(
			function()
				local inportcdr = self:getObject()
				if inportcdr ~= oil.corba.idl.null then
					ret = self:convertReturnCode(inportcdr:push(data))
					ret = NVUtil.getPortStatus_RTC(ret)
					return
				end
				ret = DataPortStatus.CONNECTION_LOST
				return
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			return DataPortStatus.CONNECTION_LOST
		end
		return ret
	end

	function obj:publishInterfaceProfile(properties)
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
                                           "dataport.data_service.inport_ior")
		--print(index)
		if index < 0 then
			self._rtcout:RTC_ERROR("inport_ior not found")
			return false
		end

		local ior = ""
		if properties[index] ~= nil then
			ior = NVUtil.any_from_any(properties[index].value)
		end

		if ior == "" then
			self._rtcout:RTC_ERROR("inport_ior has no string")
			return false
		end

		local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()
		local _obj = orb:newproxy(ior,"IDL:omg.org/RTC/DataPushService:1.0")


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
										"dataport.data_service.inport_ref")
		if index < 0 then
			self._rtcout:RTC_ERROR("inport_ref not found")
			return false
		end

		local _obj = NVUtil.any_from_any(properties[index].value)

		local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()

		_obj = orb:narrow(_obj, "IDL:omg.org/RTC/DataPushService:1.0")


		if _obj == nil then
			self._rtcout:RTC_ERROR("prop[inport_ref] is not objref")
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
										"dataport.data_service.inport_ior")
		if index < 0 then
			self._rtcout:RTC_ERROR("inport_ior not found")
			return false
		end


		ior = NVUtil.any_from_any(properties[index].value)


		if ior == "" then
			self._rtcout:RTC_ERROR("prop[inport_ior] is not string")
			return false
		end

		local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()
		local var = orb:newproxy(ior,"IDL:omg.org/RTC/DataPushService:1.0")
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
										"dataport.data_service.inport_ref")

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

	function obj:convertReturnCode(ret)
		if ret == self._PortStatus.PORT_OK then
			return DataPortStatus.PORT_OK

		elseif ret == self._PortStatus.PORT_ERROR then
			return DataPortStatus.PORT_ERROR

		elseif ret == self._PortStatus.BUFFER_FULL then
			return DataPortStatus.SEND_FULL

		elseif ret == self._PortStatus.BUFFER_TIMEOUT then
			return DataPortStatus.SEND_TIMEOUT

		elseif ret == self._PortStatus.UNKNOWN_ERROR then
			return DataPortStatus.UNKNOWN_ERROR

		else
			return DataPortStatus.UNKNOWN_ERROR
		end
	end

	return obj
end


InPortDSConsumer.InPortDSConsumerInit = function()
	InPortConsumerFactory:instance():addFactory("data_service",
		InPortDSConsumer.new,
		Factory.Delete)
end

return InPortDSConsumer
