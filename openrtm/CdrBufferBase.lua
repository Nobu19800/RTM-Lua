--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CdrBufferBase= {}
_G["openrtm.CdrBufferBase"] = CdrBufferBase

GlobalFactory = require "openrtm.GlobalFactory"
Factory = GlobalFactory.Factory
BufferBase = require "openrtm.BufferBase"

CdrBufferBase.new = function()
	local obj = {}
	setmetatable(obj, {__index=BufferBase.new()})
	return obj
end


CdrBufferBase.CdrBufferFactory = {}
setmetatable(CdrBufferBase.CdrBufferFactory, {__index=Factory.new()})

function CdrBufferBase.CdrBufferFactory:instance()
	return self
end


return CdrBufferBase
