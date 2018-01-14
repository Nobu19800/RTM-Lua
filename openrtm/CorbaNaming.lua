--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CorbaNaming= {}
_G["openrtm.CorbaNaming"] = CorbaNaming

local oil = require "oil"
local StringUtil = require "openrtm.StringUtil"
local RTCUtil = require "openrtm.RTCUtil"



CorbaNaming.new = function(orb, name_server)
	local obj = {}
	obj._orb = orb
    obj._nameServer = ""
    obj._rootContext = oil.corba.idl.null
    obj._blLength = 100

	if name_server ~= nil then
		obj._nameServer = "corbaloc:iiop:"..name_server.."/NameService"
		local success, exception = oil.pcall(
			function()
				obj._rootContext = RTCUtil.newproxy(obj._orb, obj._nameServer,"IDL:omg.org/CosNaming/NamingContext:1.0")
				--print(self._rootContext)
				--if self._rootContext == nil then
				--	print("CorbaNaming: Failed to narrow the root naming context.")
				--end
			end)
		if not success then
			print(exception)
		end
	end
	function obj:rebindByString(string_name, obj, force)
		if force == nil then
			force = true
		end
		--print(self:toName(string_name))
		self:rebind(self:toName(string_name), obj, force)
	end
	function obj:rebind(name_list, obj, force)
		if force == nil then
			force = true
		end
		local success, exception = oil.pcall(
			function()
				--error("")
				self._rootContext:rebind(name_list, obj)
			end)
		if not success then
			--print(exception)
			if force then
				--print("test1")
				self:rebindRecursive(self._rootContext, name_list, obj)
				--print("test2")
			else
				print(exception)
				error(exception)
			end
		end
	end
	function obj:rebindRecursive(context, name_list, obj)
		local length = #name_list
		for i =1,length do
			if i == length then
				--print("test1")
				context:rebind(self:subName(name_list, i, i), obj)
				--print("test2")
				return
			else
				if self:objIsNamingContext(context) then
					local success, exception = oil.pcall(
						function()
							context = context:bind_new_context(self:subName(name_list, i, i))
						end)
					if not success then
						--print(exception)
						context = context:resolve(self:subName(name_list, i, i))
					end
				else
					error("CosNaming.NamingContext.CannotProceed")
				end
			end
		end
	end
	function obj:objIsNamingContext(obj)
		return true
	end

	function obj:toName(sname)
		if sname == nil then
			error("CosNaming.NamingContext.InvalidName")
		end
		local string_name = sname
		local name_comps = {}
		--print(string_name)
		name_comps = StringUtil.split(string_name,"/")
		local name_list = {}
		for i, comp in ipairs(name_comps) do
			local s = StringUtil.split(comp,"%.")
			name_list[i] = {}
			if #s == 1 then
				name_list[i].id = comp
				name_list[i].kind = ""
			else
				local n = ""
				for i=1,#s-1 do
					n = n..s[i]
					if i ~= #s-1 then
						n = n.."."
					end
				end
				name_list[i].id = n
				name_list[i].kind = s[#s]
			end
		end
		return name_list
	end
	function obj:subName(name_list, begin, _end)
		if _end == nil  or _end < 1 then
			_end = #name_list
		end
		sub_name = {}
		for i =begin,_end do
			table.insert(sub_name, name_list[i])
		end
		return sub_name

	end

	function obj:unbind(name)
		local name_ = name
		if type(name) == "string" then
			name_ = self:toName(name)
		end

		local success, exception = oil.pcall(
			function()
				self._rootContext:unbind(name_)
			end)
		if not success then
			print(exception)
		end
    end

	return obj
end


return CorbaNaming
