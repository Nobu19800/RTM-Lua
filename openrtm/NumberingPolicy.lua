--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local NumberingPolicy= {}
_G["openrtm.NumberingPolicy"] = NumberingPolicy

local Factory = require "openrtm.Factory"
local NumberingPolicyBase = require "openrtm.NumberingPolicyBase"
local NumberingPolicyFactory = NumberingPolicyBase.NumberingPolicyFactory
local StringUtil = require "openrtm.StringUtil"


NumberingPolicy = {}
NumberingPolicy.new = function()
	local obj = {}
	function obj:onCreate(obj)
	end
	function obj:onDelete(obj)
	end
	return obj
end


NumberingPolicy.ProcessUniquePolicy = {}

NumberingPolicy.ProcessUniquePolicy.new = function()
	local obj = {}
	obj._num = 0
	obj._objects = {}
	setmetatable(obj, {__index=NumberingPolicy.new()})
	function obj:onCreate(obj)
		self._num = self._num + 1
		pos = self:find(nil)
		if pos < 0 then
			pos = 1
		end
		self._objects[pos] = obj
		return StringUtil.otos(pos-1)
	end
	function obj:onDelete(obj)
		pos = self:find(obj)
		if pos >= 0 then
			self._objects[pos] = nil
			self._num = self._num - 1
		end
	end
	function obj:find(obj)
		for i, obj_ in pairs(self._objects) do
			if obj_ == obj then
				return i
			end
		end
		return -1
	end
	return obj
end

NumberingPolicy.ProcessUniquePolicy.Init = function()
	NumberingPolicyFactory:instance():addFactory("process_unique",
		NumberingPolicy.ProcessUniquePolicy.new,
		Factory.Delete)
end


return NumberingPolicy
