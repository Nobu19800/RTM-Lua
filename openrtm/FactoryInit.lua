--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local FactoryInit= function()
	--local InPortCorbaCdrProvider = require "openrtm.InPortCorbaCdrProvider"
	--local InPortCorbaCdrProviderInit = InPortCorbaCdrProvider.InPortCorbaCdrProviderInit
	--local InPortCorbaCdrConsumer = require "openrtm.InPortCorbaCdrConsumer"
	--local InPortCorbaCdrConsumerInit = InPortCorbaCdrConsumer.InPortCorbaCdrConsumerInit
	--local OutPortCorbaCdrProvider = require "openrtm.OutPortCorbaCdrProvider"
	--local OutPortCorbaCdrProviderInit = OutPortCorbaCdrProvider.OutPortCorbaCdrProviderInit
	--local OutPortCorbaCdrConsumer = require "openrtm.OutPortCorbaCdrConsumer"
	--local OutPortCorbaCdrConsumerInit = OutPortCorbaCdrConsumer.OutPortCorbaCdrConsumerInit
	local InPortDSProvider = require "openrtm.InPortDSProvider"
	local InPortDSProviderInit = InPortDSProvider.InPortDSProviderInit
	local InPortDSConsumer = require "openrtm.InPortDSConsumer"
	local InPortDSConsumerInit = InPortDSConsumer.InPortDSConsumerInit
	local OutPortDSProvider = require "openrtm.OutPortDSProvider"
	local OutPortDSProviderInit = OutPortDSProvider.OutPortDSProviderInit
	local OutPortDSConsumer = require "openrtm.OutPortDSConsumer"
	local OutPortDSConsumerInit = OutPortDSConsumer.OutPortDSConsumerInit
	local NumberingPolicy = require "openrtm.NumberingPolicy"
	local DefaultNumberingPolicyInit = NumberingPolicy.DefaultNumberingPolicyInit
	local CdrRingBuffer = require "openrtm.CdrRingBuffer"
	local CdrRingBufferInit = CdrRingBuffer.CdrRingBufferInit
	local PublisherFlush = require "openrtm.PublisherFlush"
	local PublisherFlushInit = PublisherFlush.PublisherFlushInit

	CdrRingBufferInit()

	--InPortCorbaCdrConsumerInit()
	--InPortCorbaCdrProviderInit()
	--OutPortCorbaCdrConsumerInit()
	--OutPortCorbaCdrProviderInit()
	InPortDSConsumerInit()
	InPortDSProviderInit()
	OutPortDSConsumerInit()
	OutPortDSProviderInit()
	DefaultNumberingPolicyInit()

	PublisherFlushInit()
end

_G["openrtm.FactoryInit"] = FactoryInit




return FactoryInit
