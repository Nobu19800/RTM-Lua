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
--_G["openrtm.SdoServiceProviderBase"] = SdoServiceProviderBase

SdoServiceProviderBase.new = function()
	local obj = {}

	-- オブジェクトリファレンス生成
	function obj:createRef()
		self._svr = self._orb:newservant(self, nil, "IDL:org.omg/SDOPackage/SDOService:1.0")
		self._objref = RTCUtil.getReference(self._orb, self._svr, "IDL:org.omg/SDOPackage/SDOService:1.0")
	end
	function obj:init(rtobj, profile)

	end
	function obj:reinit(profile)
		
	end
	function obj:getProfile()
		
	end
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
