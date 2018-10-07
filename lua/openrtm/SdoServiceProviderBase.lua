---------------------------------
--! @file SdoServiceProviderBase.lua
--! @brief SDOサービスプロバイダ基底クラス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SdoServiceProviderBase= {}
local GlobalFactory = require "openrtm.GlobalFactory"
local Factory = GlobalFactory.Factory
local RTCUtil = require "openrtm.RTCUtil"
--_G["openrtm.SdoServiceProviderBase"] = SdoServiceProviderBase


-- SDPサービスプロバイダ基底オブジェクト初期化
-- @return SDPサービスプロバイダ基底オブジェクト
SdoServiceProviderBase.new = function()
	local obj = {}
	local Manager = require "openrtm.Manager"
	obj._manager = Manager:instance()
	obj._orb = obj._manager:getORB()

	-- オブジェクトリファレンス生成
	function obj:createRef()
		self._svr = self._orb:newservant(self, nil, "IDL:org.omg/SDOPackage/SDOService:1.0")
		self._objref = RTCUtil.getReference(self._orb, self._svr, "IDL:org.omg/SDOPackage/SDOService:1.0")
	end

	-- 初期化
	-- @param rtobj RTC
	-- @param profile プロファイル
	-- @return true：初期化成功
	function obj:init(rtobj, profile)

	end

	-- 再初期化
	-- @param profile プロファイル
	-- @return true：再初期化成功
	function obj:reinit(profile)
		
	end

	-- プロファイル取得
	-- @return プロファイル
	function obj:getProfile()
		
	end

	-- 終了処理
	function obj:finalize()
		local Manager = require "openrtm.Manager"
		Manager:instance():getORB():deactivate(self._svr)
	end
	return obj
end


SdoServiceProviderBase.SdoServiceProviderFactory = {}
setmetatable(SdoServiceProviderBase.SdoServiceProviderFactory, {__index=Factory.new()})

function SdoServiceProviderBase.SdoServiceProviderFactory:instance()
	return self
end


return SdoServiceProviderBase
