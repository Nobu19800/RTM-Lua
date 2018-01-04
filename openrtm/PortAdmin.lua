--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local PortAdmin= {}
_G["openrtm.PortAdmin"] = PortAdmin


local oil = require "oil"
local ObjectManager = require "openrtm.ObjectManager"
local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"


function comp_op(argv)
	local obj = {}
	if argv.name ~= nil then
		obj._name = argv.name
	elseif argv.factory ~= nil then
		obj._name = argv.factory:getProfile().name
	end

	local call_func = function(self, obj)
		name_ = obj:getProfile().name
		return (self._name == name_)
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


find_port_name = {}
find_port_name.new = function(name)
	local obj = {}
	obj._name = name
	local call_func = function(self, p)
		local prof = p:get_port_profile()
		local name_ = prof.name
		--print(self._name, name_)
		return (self._name == name_)
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


PortAdmin.new = function(orb)
	local obj = {}
	obj._orb = orb
	obj._portRefs = {}
	obj._portServants = ObjectManager.new(comp_op)
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("PortAdmin")

	function obj:activatePorts()
		--print("activatePorts1")
		ports = self._portServants:getObjects()
		for i, port in pairs(ports) do
			port:activateInterfaces()
		end
		--print("activatePorts2")
    end
	function obj:deactivatePorts()
		ports = self._portServants:getObjects()
		for i, port in pairs(ports) do
			port:deactivateInterfaces()
		end
    end
	function obj:getPortProfileList()
		local ret = {}
		for i, p in ipairs(self._portRefs) do
			table.insert(ret, p:get_port_profile())
		end
		return ret
	end


	function obj:addPort(port)
		local index = CORBA_SeqUtil.find(self._portRefs,
									find_port_name.new(port:getName()))
		if index >= 0 then
			return false
		end
		--print(port:getPortRef())
		table.insert(self._portRefs, port:getPortRef())
		return self._portServants:registerObject(port)
	end

	function obj:removePort(port)
		local ret = false
		local success, exception = oil.pcall(
			function()

			port:disconnect_all()
			tmp = port:getProfile().name
			--print(#self._portRefs)
			CORBA_SeqUtil.erase_if(self._portRefs, find_port_name.new(tmp))
			--print(#self._portRefs)


			port:setPortRef(oil.corba.idl.null)

			if not self._portServants:unregisterObject(tmp) then
				ret = false
				return
			end
			ret = true
			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
			return false
		end
		return ret
	end

	function obj:getPortServiceList()
		return self._portRefs
	end


	return obj
end


return PortAdmin
