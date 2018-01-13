--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CorbaConsumer= {}
_G["openrtm.CorbaConsumer"] = CorbaConsumer


local oil = require "oil"
local RTCUtil = require "openrtm.RTCUtil"


CorbaConsumer.CorbaConsumerBase = {}

CorbaConsumer.CorbaConsumerBase.new = function(consumer)
	local obj = {}

	if consumer ~= nil then
		obj._objref = consumer._objref
	else
		obj._objref = oil.corba.idl.null
	end

	function obj:setObject(_obj)
		return self:_setObject(_obj)
	end
	function obj:_setObject(_obj)

		if _obj == nil then
			return false
		end

		self._objref = _obj
		return true
	end

	function obj:getObject()
		--print(self._objref)
		return self._objref
	end

	function obj:releaseObject()
		self:_releaseObject()
	end
	function obj:_releaseObject()
		self._objref = oil.corba.idl.null
	end

	return obj
end

CorbaConsumer.new = function(interfaceType, consumer)
	local obj = {}
	obj._interfaceType = interfaceType
	setmetatable(obj, {__index=CorbaConsumer.CorbaConsumerBase.new(consumer)})
	if consumer ~= nil then
		obj._var = consumer._var
	end
	function obj:setObject(obj)

		if not self:_setObject(obj) then
			self:releaseObject()
			return false
		end

		self._var = self._objref
		return true
	end
	function obj:_ptr(get_ref)
		if get_ref == nil then
			get_ref = false
		end
		return self._var
	end
	function obj:setIOR(ior)
		local ret = true
		local success, exception = oil.pcall(
			function()
				--print(ior)
				--print(self._interfaceType)
				local Manager = require "openrtm.Manager"
				local orb = Manager:instance():getORB()
				local obj_ = RTCUtil.newproxy(orb, ior,self._interfaceType)
				if not self:_setObject(obj_) then
					self:releaseObject()
					ret = false
				end
				self._var = self._objref
			end)
		if not success then
			print(exception)
			return false
		end


		return ret
	end

	function obj:releaseObject()
		self:_releaseObject(self)
		self._var = CORBA.Object._nil
		self._sev = nil
	end
	return obj
end


return CorbaConsumer
