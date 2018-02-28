---------------------------------
--! @file ModuleManager.lua
--! @brief モジュール管理マネージャ定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ModuleManager= {}
--_G["openrtm.ModuleManager"] = ModuleManager

ModuleManager.new = function()
	local obj = {}
	return obj
end


return ModuleManager
