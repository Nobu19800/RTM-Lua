---------------------------------
--! @file ManagerInfo.lua
--! @brief マネージャの情報取得
---------------------------------

--[[
Copyright (c) 2018 Nobuhiko Miyamoto
]]

local ManagerInfo= {}
--_G["openrtm.ManagerInfo"] = ManagerInfo

ManagerInfo.getfilepath = function()
	return string.sub(debug.getinfo(1)["source"],2)
end


ManagerInfo.is_main = function()
	return (debug.getinfo(5 + (offset or 0)) == nil)
end

return ManagerInfo
