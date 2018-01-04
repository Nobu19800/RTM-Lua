--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local NamingManager= {}
_G["openrtm.NamingManager"] = NamingManager

local oil = require "oil"
local CorbaNaming = require "openrtm.CorbaNaming"



NamingManager.NamingBase = {}
NamingManager.NamingBase.new = function()
	local obj = {}
	function obj:bindObject(name, rtobj)
	end
	function obj:bindPortObject(name, port)
	end
	function obj:unbindObject(name)
	end
	function obj:isAlive()
		return true
	end
	function obj:string_to_component(name)
		return {}
	end


	return obj
end

NamingManager.NamingOnCorba = {}

NamingManager.NamingOnCorba.new = function(orb, names)
	local obj = {}
	setmetatable(obj, {__index=NamingManager.NamingBase.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("manager.namingoncorba")
	obj._cosnaming = CorbaNaming.new(orb,names)
	obj._endpoint = ""
    obj._replaceEndpoint = false

	function obj:bindObject(name, rtobj)

		self._rtcout:RTC_TRACE("bindObject(name = "..name..", rtobj or mgr)")
		local success, exception = oil.pcall(
			function()

				self._cosnaming:rebindByString(name, rtobj:getObjRef(), true)

			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
		end

    end

	return obj
end



NamingManager.NamingOnManager = {}

NamingManager.NamingOnManager.new = function(orb, mgr)
	local obj = {}
	setmetatable(obj, {__index=NamingManager.NamingBase.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("manager.namingonmanager")
	obj._cosnaming = nil
	obj._orb = orb
    obj._mgr = mgr

	return obj
end

NamingManager.NameServer = {}
NamingManager.NameServer.new = function(meth, name, naming)
	local obj = {}
	obj.method = meth
	obj.nsname = name
	obj.ns     = naming
	return obj
end


NamingManager.Comps = {}
NamingManager.Comps.new = function(n, obj)
	local obj = {}
	obj.name = n
	obj.rtobj = obj
	return obj
end


NamingManager.new = function(manager)
	local obj = {}
	obj._manager = manager
    obj._rtcout = manager:getLogbuf('manager.namingmanager')
    obj._names = {}
    obj._compNames = {}
    obj._mgrNames  = {}
    obj._portNames = {}
	function obj:registerNameServer(method, name_server)
		--print(self._rtcout)
		self._rtcout:RTC_TRACE("NamingManager::registerNameServer("..method..", "..name_server..")")
		name = self:createNamingObj(method, name_server)
		--print(name)
		table.insert(self._names, NamingManager.NameServer.new(method, name_server, name))
	end
	function obj:createNamingObj(method, name_server)
		self._rtcout:RTC_TRACE("createNamingObj(method = "..method..", nameserver = "..name_server..")")

		mth = method

		if mth == "corba" then
			ret = nil
			local success, exception = oil.pcall(
				function()
					name = NamingManager.NamingOnCorba.new(self._manager:getORB(),name_server)

					self._rtcout:RTC_INFO("NameServer connection succeeded: "..method.."/"..name_server)
					ret = name
				end)
			if not success then
				print(exception)
				self._rtcout:RTC_INFO("NameServer connection failed: "..method.."/"..name_server)
			end
			return ret
		elseif mth == "manager" then
			name = NamingManager.NamingOnManager(self._manager:getORB(), self._manager)
			return name
		end
		return nil
	end
	function obj:bindObject(name, rtobj)
		self._rtcout:RTC_TRACE("NamingManager::bindObject("..name..")")
		for i, n in ipairs(self._names) do
			if n.ns ~= nil then
				local success, exception = oil.pcall(
					function()
						n.ns:bindObject(name, rtobj)
					end)
				if not success then
					n.ns = nil
				end
			end
		end

		self:registerCompName(name, rtobj)
	end
	function obj:registerCompName(name, rtobj)
		for i, compName in ipairs(self._compNames) do
			if compName.name == name then
				compName.rtobj = rtobj
				return
			end
		end
		table.insert(self._compNames, NamingManager.Comps.new(name, rtobj))
    end
	return obj
end



return NamingManager
