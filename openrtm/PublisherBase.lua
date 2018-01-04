--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local PublisherBase= {}
_G["openrtm.PublisherBase"] = PublisherBase


GlobalFactory = require "openrtm.GlobalFactory"
Factory = GlobalFactory.Factory

PublisherBase.new = function()
	local obj = {}
	function obj:init(prop)
	end
	function obj:setConsumer(consumer)
	end
	function obj:setBuffer(buffer)
	end
	function obj:setListener(info, listeners)
	end
	function obj:write(data, sec, usec)
	end
	function obj:isActive()
	end
	function obj:activate()
	end
	function obj:deactivate()
	end
	return obj
end


PublisherBase.PublisherFactory = {}
setmetatable(PublisherBase.PublisherFactory, {__index=Factory.new()})

function PublisherBase.PublisherFactory:instance()
	return self
end

return PublisherBase
