---------------------------------
--! @file OutPortDirectConsumer.lua
--! @brief ダイレクト接続OutPortConsumerの定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortDirectConsumer = {}
--_G["openrtm.OutPortDirectConsumer"] = OutPortDirectConsumer

local OutPortConsumer = require "openrtm.OutPortConsumer"
local Factory = require "openrtm.Factory"
local OutPortConsumerFactory = OutPortConsumer.OutPortConsumerFactory
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorListenerType = ConnectorListener.ConnectorListenerType
local ConnectorDataListenerType = ConnectorListener.ConnectorDataListenerType
local DataPortStatus = require "openrtm.DataPortStatus"

-- directインターフェースのOutPortConsumerオブジェクト初期化
-- @return directインターフェースのOutPortConsumerオブジェクト
OutPortDirectConsumer.new = function()
	local obj = {}
    setmetatable(obj, {__index=OutPortConsumer.new()})

    local Manager = require "openrtm.Manager"

	obj._rtcout = Manager:instance():getLogbuf("OutPortDSConsumer")
    obj._buffer = nil
    obj._profile = nil
    obj._listeners = nil


    -- 初期化時にプロパティ設定
	-- @param prop プロパティ
	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
    end

    -- データ取得
	-- @param data data._dataにデータを格納する
	-- @return UNKNOWN_ERROR
    function obj:get(data)
        self._rtcout:RTC_PARANOID("get()")
        return DataPortStatus.UNKNOWN_ERROR
    end


    -- バッファの設定
    -- @param buffer バッファ
	function obj:setBuffer(buffer)
		self._rtcout:RTC_TRACE("setBuffer()")
    end
    
    -- コールバック関数設定
    -- @param info プロファイル
    -- @param listeners コールバック関数
	function obj:setListener(info, listeners)
		self._rtcout:RTC_TRACE("setListener()")
		self._listeners = listeners
		self._profile = info
    end


    -- プロパティからインターフェース情報取得
    -- オブジェクトリファレンスの設定
    -- IOR文字列、もしくはリファレンスを取得
    -- dataport.corba_cdr.outport_ior
    -- dataport.corba_cdr.outport_ref
    -- @param properties プロパティ
    -- @return true：設定成功、false：設定失敗
	function obj:subscribeInterface(properties)
        self._rtcout:RTC_TRACE("subscribeInterface()")
        return true
    end


    -- プロパティからインターフェース設定解除-- IOR文字列、もしくはリファレンスを取得
    -- dataport.corba_cdr.outport_ior
    -- dataport.corba_cdr.outport_ref
    -- @param properties プロパティ
	function obj:unsubscribeInterface(properties)
        self._rtcout:RTC_TRACE("unsubscribeInterface()")
    end


    -- バッファ書き込み時のコールバック実行
	-- @param data データ
	function obj:onBufferWrite(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_WRITE]:notify(self._profile, data)
		end
	end
	-- バッファフル時のコールバック実行
	-- @param data データ
	function obj:onBufferFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_BUFFER_FULL]:notify(self._profile, data)
		end
	end
	-- データ受信時のコールバック実行
	-- @param data データ
	function obj:onReceived(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVED]:notify(self._profile, data)
		end
	end
	-- 受信データフルのコールバック実行
	-- @param data データ
	function obj:onReceiverFull(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connectorData_[ConnectorDataListenerType.ON_RECEIVER_FULL]:notify(self._profile, data)
		end
	end
	-- 送信データエンプティのコールバック実行
	-- @param data データ
	function obj:onSenderEmpty(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_SENDER_EMPTY]:notify(self._profile)
		end
	end
	-- 送信データ時間切れ時のコールバック実行
	-- @param data データ
	function obj:onSenderTimeout(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_SENDER_TIMEOUT]:notify(self._profile)
		end
	end
	-- 送信エラー時のコールバック実行
	-- @param data データ
	function obj:onSenderError(data)
		if self._listeners ~= nil and self._profile ~= nil then
			self._listeners.connector_[ConnectorListenerType.ON_SENDER_ERROR]:notify(self._profile)
		end
	end
    
    return obj
end


-- OutPortDirectConsumer生成ファクトリ登録関数
OutPortDirectConsumer.Init = function()
	OutPortConsumerFactory:instance():addFactory("direct",
		OutPortDirectConsumer.new,
		Factory.Delete)
end


return OutPortDirectConsumer
