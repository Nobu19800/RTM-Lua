--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local GlobalFactory= {}
_G["openrtm.GlobalFactory""] = GlobalFactory

GlobalFactory.init = function()
	local obj = {}
	return obj
end


return GlobalFactory
