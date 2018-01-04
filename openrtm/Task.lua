--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local Task= {}
_G["openrtm.Task"] = Task

local oil = require "oil"



--[[
Task.new = function(object)
	local obj = {}
	obj._instance = object

	local call_func = function(self)
		self._instance:svc()
	end
	setmetatable(obj, {__call=call_func})
	return obj
end
]]


Task.start = function(object)
	oil.newthread(function()
					object:svc()
				end)
end



return Task
