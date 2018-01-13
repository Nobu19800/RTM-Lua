--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPort= {}
_G["openrtm.InPort"] = InPort


local InPortBase = require "openrtm.InPortBase"
local DataPortStatus = require "openrtm.DataPortStatus"


InPort.new = function(name, value, data_type, buffer, read_block, write_block, read_timeout, write_timeout)
	if read_block == nil then
		read_block = false
	end
	if write_block == nil then
		write_block = false
	end
	if read_timeout == nil then
		read_timeout = 0
	end
	if write_timeout == nil then
		write_timeout = 0
	end
	local obj = {}
	--print(data_type)
	setmetatable(obj, {__index=InPortBase.new(name, data_type)})
	obj._name           = name
    obj._value          = value
    obj._OnRead         = nil
    obj._OnReadConvert  = nil

    obj._directNewData = false

    obj._outPortConnectorList = {}

	function obj:name()
		return self._name
	end

	function obj:isNew()
		self._rtcout:RTC_TRACE("isNew()")



		if #self._connectors == 0 then
			self._rtcout:RTC_DEBUG("no connectors")
			return false
		end

		r = self._connectors[1]:getBuffer():readable()
		if r > 0 then
			self._rtcout:RTC_DEBUG("isNew() = True, readable data: "..r)
			return true
		end

		self._rtcout:RTC_DEBUG("isNew() = False, no readable data")
		return false
	end

	function obj:isEmpty()
		self._rtcout:RTC_TRACE("isEmpty()")
		if #self._connectors == 0 then
			self._rtcout:RTC_DEBUG("no connectors")
			return true
		end

		r = self._connectors[1]:getBuffer():readable()
		if r == 0 then
			self._rtcout:RTC_DEBUG("isEmpty() = true, buffer is empty")
			return true
		end

		self._rtcout:RTC_DEBUG("isEmpty() = false, data exists in the buffer")
		return false
	end


	function obj:read()
		self._rtcout:RTC_TRACE("DataType read()")

		if self._OnRead ~= nil then
			self._OnRead()
			self._rtcout:RTC_TRACE("OnRead called")
		end




		if #self._outPortConnectorList > 0 then
			ret, data = self._outPortConnectorList[1]:read()

			if ret then
				self._value = data
				if self._OnReadConvert ~= nil then
					self._value = self._OnReadConvert(self._value)
					self._rtcout:RTC_TRACE("OnReadConvert for direct data called")
					return self._value
				end
			end
		end

		if #self._connectors == 0 then
			self._rtcout:RTC_DEBUG("no connectors")
			return self._value
		end


		cdr = {_data=self._value}
		ret = self._connectors[1]:read(cdr)


		if ret == DataPortStatus.PORT_OK then
			self._rtcout:RTC_DEBUG("data read succeeded")
			self._value = cdr._data

			if self._OnReadConvert ~= nil then
				self._value = self._OnReadConvert(self._value)
				self._rtcout:RTC_DEBUG("OnReadConvert called")
				return self._value
			end
			return self._value


		elseif ret == DataPortStatus.BUFFER_EMPTY then
			self._rtcout:RTC_WARN("buffer empty")
			return self._value

		elseif ret == DataPortStatus.BUFFER_TIMEOUT then
			self._rtcout:RTC_WARN("buffer read timeout")
			return self._value
		end

		self._rtcout:RTC_ERROR("unknown retern value from buffer.read()")
		return self._value
	end
	function obj:update()
		self:read()
	end
	function obj:setOnRead(on_read)
		self._OnRead = on_read
	end
	function obj:setOnReadConvert(on_read)
		self._OnReadConvert = on_rconvert
	end



	return obj
end


return InPort
