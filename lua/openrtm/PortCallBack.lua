---------------------------------
--! @file PortCallBack.lua
--! @brief ポート関連のコールバック定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local PortCallBack= {}
--_G["openrtm.PortCallBack"] = PortCallBack

PortCallBack.new = function()
	local obj = {}
	return obj
end


return PortCallBack
