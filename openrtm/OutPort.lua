--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPort= {}
_G["openrtm.OutPort"] = OutPort


local TimeValue = require "openrtm.TimeValue"
local OutPortBase = require "openrtm.OutPortBase"
local DataPortStatus = require "openrtm.DataPortStatus"

OutPort.setTimestamp = function(data)
	local tm = TimeValue.new(os.clock())
	data.tm.sec  = tm:sec()
	data.tm.nsec = tm:usec() * 1000
end

OutPort.new = function(name, value, data_type, buffer)
	local obj = {}
	setmetatable(obj, {__index=OutPortBase.new(name, data_type)})

	obj._value          = value
    obj._OnWrite        = nil
    obj._OnWriteConvert = nil
	function obj:write(value)
		if value == nil then
			value = self._value
		end
		--print(self._value.data)


		if self._OnWrite ~= nil then
			self._OnWrite(value)
		end

		local conn_size = #self._connectors
		if conn_size == 0 then
			return false
		end



		if self._OnWriteConvert ~= nil then
			value = self._OnWriteConvert(value)
		end

		local result = true

		for i, con in ipairs(self._connectors) do
			ret = con:write({_data=value, _type=self._data_type})
			if ret ~= DataPortStatus.PORT_OK then
				result = false
				if ret == DataPortStatus.CONNECTION_LOST then
					self:disconnect(con:id())
				end
			end
		end

		return result
	end
	function obj:setOnWrite(on_write)
		self._OnWrite = on_write
	end
	function obj:setOnWriteConvert(on_wconvert)
		self._OnWriteConvert = on_wconvert
	end
	function obj:getPortDataType()
		return self._data_type
	end


	return obj
end


return OutPort
