---------------------------------
--! @file InPortDirectProvider.lua
--! @brief ダイレクト接続InPortProviderの定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortDirectProvider = {}
--_G["openrtm.InPortDirectProvider"] = InPortDirectProvider

local InPortProvider = require "openrtm.InPortProvider"
local Factory = require "openrtm.Factory"
local InPortProviderFactory = InPortProvider.InPortProviderFactory
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorDataListenerType = ConnectorListener.ConnectorDataListenerType


-- directインターフェースのInPortProviderオブジェクト初期化
-- @return directインターフェースのInPortProviderオブジェクト
InPortDirectProvider.new = function()
    local obj = {}
    setmetatable(obj, {__index=InPortProvider.new()})

    obj:setInterfaceType("direct")

    -- 終了処理
    function obj:exit()
    end
    -- 初期化時にプロパティ設定
	-- @param prop プロパティ
    function obj:init(prop)
    end
    -- バッファ設定
    -- @param buffer バッファ
    function obj:setBuffer(buffer)
		self._buffer = buffer
    end
    -- コールバック関数設定
	-- @param info プロファイル
	-- @param listeners コールバック関数
    function obj:setListener(info, listeners)
		self._profile = info
		self._listeners = listeners
    end

    -- バッファ書き込み時コールバック
	-- @param data データ
	function obj:onBufferWrite(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_WRITE]:notify(self._profile, data)
		end
    end
    -- バッファフル時コールバック
	-- @param data データ
	function obj:onBufferFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_FULL]:notify(self._profile, data)
		end
    end
    -- バッファ書き込みタイムアウト時コールバック
	-- @param data データ
	function obj:onBufferWriteTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT]:notify(self._profile, data)
		end
    end
    -- バッファ上書き時コールバック
	-- @param data データ
	function obj:onBufferWriteOverwrite(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_OVERWRITE]:notify(self._profile, data)
		end
    end
    -- 受信時コールバック
	-- @param data データ
	function obj:onReceived(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVED]:notify(self._profile, data)
		end
    end
    -- 受信バッファフル時コールバック
	-- @param data データ
	function obj:onReceiverFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_FULL]:notify(self._profile, data)
		end
    end
    -- 受信タイムアウト時コールバック
	-- @param data データ
	function obj:onReceiverTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_TIMEOUT]:notify(self._profile, data)
		end
    end
    -- 受信エラー時コールバック
	-- @param data データ
	function obj:onReceiverError(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_ERROR]:notify(self._profile, data)
		end
	end
    
    return obj
end

-- InPortDirectProvider生成ファクトリ登録関数
InPortDirectProvider.Init = function()
	InPortProviderFactory:instance():addFactory("direct",
		InPortDirectProvider.new,
		Factory.Delete)
end


return InPortDirectProvider
