---------------------------------
--! @file InPortDirectConsumer.lua
--! @brief ダイレクト接続InPortConsumerの定義
---------------------------------


--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortDirectConsumer = {}
--_G["openrtm.InPortDirectConsumer"] = InPortDirectConsumer


local InPortConsumer = require "openrtm.InPortConsumer"
local Factory = require "openrtm.Factory"
local InPortConsumerFactory = InPortConsumer.InPortConsumerFactory



-- CorbaCdrインターフェースのInPortConsumerオブジェクト初期化
-- @return CorbaCdrインターフェースのInPortConsumerオブジェクト
InPortDirectConsumer.new = function()
	local obj = {}
    setmetatable(obj, {__index=InPortConsumer.new()})

    local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("InPortDirectConsumer")
    
    -- 初期化時にプロパティ設定
	-- @param prop プロパティ
	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		self._properties = prop
    end

    -- データ送信
	-- @param data 送信データ
	-- @return UNKNOWN_ERROR
    function obj:put(data)
        self._rtcout:RTC_PARANOID("put()")
        return DataPortStatus.UNKNOWN_ERROR
    end

    -- プロパティにインターフェース情報追加
	-- @param properties プロパティ
	function obj:publishInterfaceProfile(properties)
    end

    -- プロパティからインターフェース情報取得
    -- @param properties プロパティ
    -- @return true：設定成功、false：設定失敗
    function obj:subscribeInterface(properties)
        return true
    end

    -- プロパティからインターフェース設定解除
    -- @param properties プロパティ
	function obj:unsubscribeInterface(properties)
        self._rtcout:RTC_TRACE("unsubscribeInterface()")
    end


    return obj
end


-- InPortDirectConsumer生成ファクトリ登録関数
InPortDirectConsumer.Init = function()
	InPortConsumerFactory:instance():addFactory("direct",
		InPortDirectConsumer.new,
		Factory.Delete)
end

return InPortDirectConsumer
