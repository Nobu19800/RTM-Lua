--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local Singleton= {}
_G["openrtm.Singleton""] = Singleton

Singleton.init = function()
	local obj = {}
	return obj
end


return Singleton
