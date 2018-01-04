--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortConsumer= {}
_G["openrtm.InPortConsumer"] = InPortConsumer

local GlobalFactory = require "openrtm.GlobalFactory"
local Factory = GlobalFactory.Factory

InPortConsumer.new = function()
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


InPortConsumer.InPortConsumerFactory = {}
setmetatable(InPortConsumer.InPortConsumerFactory, {__index=Factory.new()})

function InPortConsumer.InPortConsumerFactory:instance()
	return self
end


return InPortConsumer
