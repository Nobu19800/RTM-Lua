---------------------------------
--! @file OutPortDirectProvider.lua
--! @brief ダイレクト接続OutPortProviderの定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortDirectProvider = {}
--_G["openrtm.OutPortDirectProvider"] = OutPortDirectProvider


local OutPortProvider = require "openrtm.OutPortProvider"
local Factory = require "openrtm.Factory"
local OutPortProviderFactory = OutPortProvider.OutPortProviderFactory
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorListenerType = ConnectorListener.ConnectorListenerType
local ConnectorDataListenerType = ConnectorListener.ConnectorDataListenerType

-- directインターフェースのOutPortProviderオブジェクト初期化
-- @return directインターフェースのOutPortProviderオブジェクト
OutPortDirectProvider.new = function()
	local obj = {}
    setmetatable(obj, {__index=OutPortProvider.new()})

    obj:setInterfaceType("direct")

    obj._listeners = nil
    obj._buffer = nil
    obj._profile   = nil


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
    

    -- コネクタ設定
	-- @param connector コネクタ
	function obj:setConnector(connector)
		self._connector = connector
    end
    

    -- バッファ書き込み時コールバック
	-- @param data データ
	function obj:onBufferRead(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_READ]:notify(self._profile, data)
		end
    end

    -- データ送信時コールバック
	-- @param data データ
	function obj:onSend(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_SEND]:notify(self._profile, data)
		end
    end

    -- バッファ空時コールバック
	function obj:onBufferEmpty()
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_BUFFER_EMPTY]:notify(self._profile)
		end
    end
    -- バッファ読み込みタイムアウト時コールバック
	function obj:onBufferReadTimeout()
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_BUFFER_READ_TIMEOUT]:notify(self._profile)
		end
    end
    -- 送信データ空時コールバック
	function obj:onSenderEmpty()
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_SENDER_EMPTY]:notify(self._profile)
		end
    end
    -- データ送信タイムアウト時コールバック
	function obj:onSenderTimeout()
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_SENDER_TIMEOUT]:notify(self._profile)
		end
    end
	-- データ送信エラー時コールバック
	function obj:onSenderError()
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_SENDER_ERROR]:notify(self._profile)
		end
    end

    return obj

end


-- OutPortDirectProvider生成ファクトリ登録関数
OutPortDirectProvider.Init = function()
	OutPortProviderFactory:instance():addFactory("direct",
        OutPortDirectProvider.new,
		Factory.Delete)
end


return OutPortDirectProvider
