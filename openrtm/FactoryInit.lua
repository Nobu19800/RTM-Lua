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
	local InPortDSConsumer = require "openrtm.InPortDSConsumer"
	local OutPortDSProvider = require "openrtm.OutPortDSProvider"
	local OutPortDSConsumer = require "openrtm.OutPortDSConsumer"
	local NumberingPolicy = require "openrtm.NumberingPolicy"
	local ProcessUniquePolicy = NumberingPolicy.ProcessUniquePolicy
	local CdrRingBuffer = require "openrtm.CdrRingBuffer"
	local PublisherFlush = require "openrtm.PublisherFlush"

	CdrRingBuffer.Init()

	--InPortCorbaCdrConsumerInit()
	--InPortCorbaCdrProviderInit()
	--OutPortCorbaCdrConsumerInit()
	--OutPortCorbaCdrProviderInit()
	InPortDSConsumer.Init()
	InPortDSProvider.Init()
	OutPortDSConsumer.Init()
	OutPortDSProvider.Init()
	ProcessUniquePolicy.Init()

	PublisherFlush.Init()
end

_G["openrtm.FactoryInit"] = FactoryInit




return FactoryInit
