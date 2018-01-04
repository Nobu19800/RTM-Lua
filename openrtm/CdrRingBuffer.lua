--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CdrRingBuffer= {}
_G["openrtm.CdrRingBuffer"] = CdrRingBuffer


local RingBuffer = require "openrtm.RingBuffer"
local Factory = require "openrtm.Factory"
local CdrBufferBase = require "openrtm.CdrBufferBase"
local CdrBufferFactory = CdrBufferBase.CdrBufferFactory

CdrRingBuffer.new = function()
	local obj = {}
	setmetatable(obj, {__index=RingBuffer.new()})
	return obj
end


CdrRingBuffer.CdrRingBufferInit = function()
	CdrBufferFactory:instance():addFactory("ring_buffer",
		CdrRingBuffer.new,
		Factory.Delete)
end


return CdrRingBuffer
