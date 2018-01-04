--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local FactoryInit= function()
	local InPortCorbaCdrProvider = require "openrtm.InPortCorbaCdrProvider"
	local InPortCorbaCdrProviderInit = InPortCorbaCdrProvider.InPortCorbaCdrProviderInit
	local InPortCorbaCdrConsumer = require "openrtm.InPortCorbaCdrConsumer"
	local InPortCorbaCdrConsumerInit = InPortCorbaCdrConsumer.InPortCorbaCdrConsumerInit
	local NumberingPolicy = require "openrtm.NumberingPolicy"
	local DefaultNumberingPolicyInit = NumberingPolicy.DefaultNumberingPolicyInit
	local CdrRingBuffer = require "openrtm.CdrRingBuffer"
	local CdrRingBufferInit = CdrRingBuffer.CdrRingBufferInit
	local PublisherFlush = require "openrtm.PublisherFlush"
	local PublisherFlushInit = PublisherFlush.PublisherFlushInit

	CdrRingBufferInit()

	InPortCorbaCdrConsumerInit()
	InPortCorbaCdrProviderInit()
	DefaultNumberingPolicyInit()

	PublisherFlushInit()
end

_G["openrtm.FactoryInit"] = FactoryInit




return FactoryInit
