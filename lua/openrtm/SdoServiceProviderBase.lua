---------------------------------
--! @file SdoServiceProviderBase.lua
--! @brief SDOサービスプロバイダ基底クラス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SdoServiceProviderBase= {}
_G["openrtm.SdoServiceProviderBase"] = SdoServiceProviderBase

SdoServiceProviderBase.new = function()
	local obj = {}
	return obj
end


return SdoServiceProviderBase
