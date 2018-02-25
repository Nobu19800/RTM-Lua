---------------------------------
--! @file LogstreamFile.lua
--! @brief ファイル出力ロガーストリーム定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local LogstreamFile= {}
_G["openrtm.LogstreamFile"] = LogstreamFile

LogstreamFile.new = function()
	local obj = {}
	return obj
end


return LogstreamFile
