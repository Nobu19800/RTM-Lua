--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local Factory= {}
_G["openrtm.Factory"] = Factory

local oil = require "oil"



Factory.Delete = function(rtc)
end

Factory.FactoryBase = {}

Factory.FactoryBase.new = function(profile)
	local obj = {}
	function obj:init()
		self._Profile = profile
		self._Number = -1
	end
	function obj:create(mgr)
	end
	function obj:destroy(mgr)
	end
	function obj:profile()
		return self._Profile
	end
	function obj:number()
		return self._Number
	end


	obj:init()
	return obj
end



Factory.FactoryLua = {}

Factory.FactoryLua.new = function(profile, new_func, delete_func, policy)
	local obj = {}
	setmetatable(obj, {__index=Factory.FactoryBase.new(profile)})
	function obj:init()
		if policy == nil then
			local NumberingPolicy = require "openrtm.NumberingPolicy"
			self._policy = DefaultNumberingPolicy.new()
		else
			self._policy = policy
		end
		self._New = new_func
		self._Delete = delete_func
	end
	function obj:create(mgr)
		local ret = nil
		local success, exception = oil.pcall(
			function()
				local rtobj = self:_New(mgr)
				if rtobj == nil then
					return nil
				end
				self._Number = self._Number + 1
				rtobj:setProperties(self:profile())
				local instance_name = rtobj:getTypeName()
				local instance_name = instance_name..self._policy:onCreate(rtobj)
				rtobj:setInstanceName(instance_name)
				ret = rtobj
			end)
		if not success then
			print(exception)
		end
		return ret
	end
	function obj:destroy(mgr)
		self._Number = self._Number - 1
		self._policy:onDelete(comp)
		self:_Delete(comp)
	end



	obj:init()
	return obj
end



return Factory
