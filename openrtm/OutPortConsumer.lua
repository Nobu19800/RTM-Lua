--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortConsumer= {}
_G["openrtm.OutPortConsumer"] = OutPortConsumer

GlobalFactory = require "openrtm.GlobalFactory"
Factory = GlobalFactory.Factory

OutPortConsumer.new = function()
	local obj = {}
	obj.subscribe = {}
	obj.subscribe.new = function(prop)
		local obj = {}
		obj._prop = prop
		local call_func = function(self, consumer)
			consumer:subscribeInterface(self._prop)
		end
		setmetatable(obj, {__call=call_func})
		return obj
	end
	obj.unsubscribe = {}
	obj.unsubscribe.new = function(prop)
		local obj = {}
		obj._prop = prop
		local call_func = function(self, consumer)
			consumer:unsubscribeInterface(self._prop)
		end
		setmetatable(obj, {__call=call_func})
		return obj
	end
	return obj
end


OutPortConsumer.OutPortConsumerFactory = {}
setmetatable(OutPortConsumer.OutPortConsumerFactory, {__index=Factory.new()})

function OutPortConsumer.OutPortConsumerFactory:instance()
	return self
end


return OutPortConsumer
