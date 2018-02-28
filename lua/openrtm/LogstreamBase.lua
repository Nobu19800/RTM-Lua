---------------------------------
--! @file LogstreamBase.lua
--! @brief ロガーストリーム基底クラス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local LogstreamBase= {}
--_G["openrtm.LogstreamBase"] = LogstreamBase

LogstreamBase.new = function()
	local obj = {}
	return obj
end


return LogstreamBase
