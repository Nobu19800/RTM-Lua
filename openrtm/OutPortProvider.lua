--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortProvider= {}
_G["openrtm.OutPortProvider"] = OutPortProvider

GlobalFactory = require "openrtm.GlobalFactory"
Factory = GlobalFactory.Factory

OutPortProvider.new = function()
	local obj = {}
	return obj
end

OutPortProvider.OutPortProviderFactory = {}
setmetatable(OutPortProvider.OutPortProviderFactory, {__index=Factory.new()})

function OutPortProvider.OutPortProviderFactory:instance()
	return self
end


return OutPortProvider
