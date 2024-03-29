---------------------------------
--! @file OutPort.lua
--! @brief アウトポート定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPort= {}
--_G["openrtm.OutPort"] = OutPort


local TimeValue = require "openrtm.TimeValue"
local OutPortBase = require "openrtm.OutPortBase"
local DataPortStatus = require "openrtm.DataPortStatus"

-- データ変数に時刻を設定する
-- @param data データ変数
OutPort.setTimestamp = function(data)
	local tm = TimeValue.new(os.time())
	data.tm.sec  = tm:sec()
	data.tm.nsec = tm:usec() * 1000
end

-- アウトポート初期化
-- @param name ポート名
-- @param value データ変数
-- @param data_type データ型
-- @param buffer バッファ
-- アウトポート
OutPort.new = function(name, value, data_type, buffer)
	local obj = {}

	setmetatable(obj, {__index=OutPortBase.new(name, data_type)})

	obj._value          = value
    obj._OnWrite        = nil
	obj._OnWriteConvert = nil

	obj._directNewData = false
    obj._directValue = value

	function obj:name()
		return self._name
	end

    -- データ書き込み
    -- @param value_ 送信データ
    -- @return true：送信成功、false：送信失敗
	function obj:write(value_)
		if value_ == nil then
			value_ = self._value
		end
		--print(self._value.data)


		if self._OnWrite ~= nil then
			self._OnWrite:call(value_)
		end

		local conn_size = #self._connectors
		if conn_size == 0 then
			return false
		end



		if self._OnWriteConvert ~= nil then
			value_ = self._OnWriteConvert:call(value_)
		end

		local result = true

		for i, con in ipairs(self._connectors) do
			if not con:directMode() then
				local ret = con:write({_data=value_, _type=self._data_type})
				if ret ~= DataPortStatus.PORT_OK then
					result = false
					if ret == DataPortStatus.CONNECTION_LOST then
						self:disconnect(con:id())
					end
				end
			else
				self._directValue = value_
				self._directNewData = true
			end
		end

		return result
	end
	-- データ書き込み時コールバック関数の設定
	-- @param on_write コールバック関数
	function obj:setOnWrite(on_write)
		self._OnWrite = on_write
	end
	-- データ変換関数の設定
	-- @param on_wconvert データ変換関数
	function obj:setOnWriteConvert(on_wconvert)
		self._OnWriteConvert = on_wconvert
	end
	-- データ型取得
	-- @return データ型
	function obj:getPortDataType()
		return self._data_type
	end


	function obj:read(data)
		self._directNewData = false
		data._data = self._directValue
		if self._OnWriteConvert ~= nil then
			data._data = self._OnWriteConvert(data._data)
		end
	end

	function obj:isEmpty()
		return (not self._directNewData)
	end


	return obj
end


return OutPort
