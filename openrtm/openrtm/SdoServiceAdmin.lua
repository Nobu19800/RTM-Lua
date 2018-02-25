---------------------------------
--! @file SdoServiceAdmin.lua
--! @brief SDOサービス管理クラス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SdoServiceAdmin= {}
_G["openrtm.SdoServiceAdmin"] = SdoServiceAdmin


-- SDOサービス管理オブジェクト初期化
-- @param rtobj RTC
-- @return SDOサービス管理オブジェクト
SdoServiceAdmin.new = function(rtobj)
	local obj = {}
	obj._rtobj = rtobj
    obj._consumerTypes = {}
    obj._providers = {}
	obj._consumers = {}
    obj._allConsumerEnabled = false
    -- 初期化時にRTC設定
    -- @param rtobj RTC
	function obj:init(rtobj)
	end
	-- 終了処理
	function obj:exit()

		for i, provider in ipairs(self._providers) do
			provider:finalize()
		end

		self._providers = {}


		for i, consumer in ipairs(self._consumers) do
			consumer:finalize()
		end

		self._consumers = {}
    end
	return obj
end


return SdoServiceAdmin
