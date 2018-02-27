---------------------------------
--! @file InPortPushConnector.lua
--! @brief Push型通信InPortConnector定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortPushConnector= {}
_G["openrtm.InPortPushConnector"] = InPortPushConnector

local InPortConnector = require "openrtm.InPortConnector"
local DataPortStatus = require "openrtm.DataPortStatus"
local BufferStatus = require "openrtm.BufferStatus"
local InPortProvider = require "openrtm.InPortProvider"
local InPortProviderFactory = InPortProvider.InPortProviderFactory
local CdrBufferBase = require "openrtm.CdrBufferBase"
local CdrBufferFactory = CdrBufferBase.CdrBufferFactory

-- Push型通信InPortConnectorの初期化
-- @param info プロファイル
-- @param provider プロバイダ
-- @param listeners コールバック
-- @param buffer バッファ
-- @return Push型通信InPortConnector
InPortPushConnector.new = function(info, provider, listeners, buffer)
	local obj = {}
	--print(buffer)
	setmetatable(obj, {__index=InPortConnector.new(info, buffer)})


	-- データ読み込み
	-- @param data data._dataにデータを格納
	-- @return リターンコード
	function obj:read(data)
		self._rtcout:RTC_TRACE("read()")

		local ret = BufferStatus.BUFFER_OK
		if self._buffer == nil then
			return DataPortStatus.PRECONDITION_NOT_MET
		end

		if type(data) == "table" then
			--print(self._buffer.write, self._buffer.read)
			--print(self._buffer)
			ret = self._buffer:read(data)
			--print(data._data)
		else
			local tmp = {_data=data}
			ret = self._buffer:read(tmp)
		end


		if ret == BufferStatus.BUFFER_OK then
			return DataPortStatus.PORT_OK

		elseif ret == BufferStatus.BUFFER_EMPTY then
			return DataPortStatus.BUFFER_EMPTY

		elseif ret == BufferStatus.TIMEOUT then
			return DataPortStatus.BUFFER_TIMEOUT

		elseif ret == BufferStatus.PRECONDITION_NOT_MET then
			return DataPortStatus.PRECONDITION_NOT_MET
		end

		return DataPortStatus.PORT_ERROR
	end
	-- コネクタ切断
	-- @return リターンコード
	function obj:disconnect()
		self._rtcout:RTC_TRACE("disconnect()")
		self:onDisconnect()

		if self._provider ~= nil then
			cfactory = InPortProviderFactory:instance()
			cfactory:deleteObject(self._provider)

			self._provider:exit()
		end

		self._provider = nil


		if self._buffer ~= nil and self._deleteBuffer == true then
			bfactory = CdrBufferFactory:instance()
			bfactory:deleteObject(self._buffer)
		end

		self._buffer = nil

		return DataPortStatus.PORT_OK
	end
	-- アクティブ化
	function obj:activate()
    end
	-- 非アクティブ化
	function obj:deactivate()
    end
	-- バッファ作成
	-- @param profile コネクタプロファイル
	-- @return バッファ
	function obj:createBuffer(profile)
		buf_type = profile.properties:getProperty("buffer_type","ring_buffer")
		return CdrBufferFactory:instance():createObject(buf_type)
    end
	-- データ書き込み
	-- @param data データ(CDR)
	-- @return リターンコード
	function obj:write(data)
		--print(self._dataType)
		--print("write")

		if self._dataType == nil then
			return BufferStatus.PRECONDITION_NOT_MET
		end

		local Manager = require "openrtm.Manager"

		local _data = Manager:instance():cdrUnmarshal(data, self._dataType)
		--print(_data.data)
		return self._buffer:write(_data)
	end

	-- コネクタ接続時のコールバック呼び出し
	function obj:onConnect()
		--print("onConnect")
		if self._listeners ~= nil and self._profile ~= nil then
			--self._listeners.connector_[ConnectorListenerType.ON_CONNECT]:notify(self._profile)
		end
	end

	-- コネクタ切断時のコールバック呼び出し
	function obj:onDisconnect()
		if self._listeners and self._profile then
			--self._listeners.connector_[OpenRTM_aist.ConnectorListenerType.ON_DISCONNECT]:notify(self._profile)
		end
    end

	obj._provider = provider
    obj._listeners = listeners

	--print(buffer)
    if buffer ~= nil then
		obj._deleteBuffer = true
    else
		obj._deleteBuffer = false
	end


    if obj._buffer == nil then
		obj._buffer = obj:createBuffer(info)
	end


    if obj._buffer == nil or obj._provider == nil then
		error("")
	end

    obj._buffer:init(info.properties:getNode("buffer"))
    obj._provider:init(info.properties)
    obj._provider:setBuffer(obj._buffer)
    obj._provider:setListener(info, obj._listeners)

    obj:onConnect()
	return obj
end


return InPortPushConnector
