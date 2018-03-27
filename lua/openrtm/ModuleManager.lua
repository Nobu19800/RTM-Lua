---------------------------------
--! @file ModuleManager.lua
--! @brief モジュール管理マネージャ定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local StringUtil = require "openrtm.StringUtil"
local ObjectManager = require "openrtm.ObjectManager"
local Properties = require "openrtm.Properties"



local ModuleManager= {}
--_G["openrtm.ModuleManager"] = ModuleManager


local CONFIG_EXT    = "manager.modules.config_ext"
local CONFIG_PATH   = "manager.modules.config_path"
local DETECT_MOD    = "manager.modules.detect_loadable"
local MOD_LOADPTH   = "manager.modules.load_path"
local INITFUNC_SFX  = "manager.modules.init_func_suffix"
local INITFUNC_PFX  = "manager.modules.init_func_prefix"
local ALLOW_ABSPATH = "manager.modules.abs_path_allowed"
local ALLOW_URL     = "manager.modules.download_allowed"
local MOD_DWNDIR    = "manager.modules.download_dir"
local MOD_DELMOD    = "manager.modules.download_cleanup"
local MOD_PRELOAD   = "manager.modules.preload"


local DLL = {}
DLL.new = function(dll)
	local obj = {}
	obj.dll = dll
	return obj
end


local DLLEntity = {}
DLLEntity.new = function(dll,prop)
	local obj = {}
	obj.dll = dll
	obj.properties = prop
	return obj
end


local DLLPred = function(argv)
	local obj = {}
	if argv.name ~= nil then
		obj._filepath = argv.name
	end
	if argv.factory ~= nil then
		obj._filepath = argv.factory
	end
	local call_func = function(self, dll)
		--print(self._filepath, dll.properties:getProperty("file_path"))
		return (self._filepath == dll.properties:getProperty("file_path"))
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


ModuleManager.Error = {}
ModuleManager.Error.new = function(reason_)
	local obj = {}
	obj.reason = reason_
	return obj
end


ModuleManager.NotFound = {}
ModuleManager.NotFound.new = function(name_)
	local obj = {}
	obj.name = name_
	obj.type = "NotFound"
	return obj
end


ModuleManager.FileNotFound = {}
ModuleManager.FileNotFound.new = function(name_)
	local obj = {}
	setmetatable(obj, {__index=ModuleManager.NotFound.new(name_)})
	obj.type = "FileNotFound"
	return obj
end

ModuleManager.ModuleNotFound = {}
ModuleManager.ModuleNotFound.new = function(name_)
	local obj = {}
	setmetatable(obj, {__index=ModuleManager.NotFound.new(name_)})
	obj.type = "ModuleNotFound"
	return obj
end

ModuleManager.SymbolNotFound = {}
ModuleManager.SymbolNotFound.new = function(name_)
	local obj = {}
	setmetatable(obj, {__index=ModuleManager.NotFound.new(name_)})
	obj.type = "SymbolNotFound"
	return obj
end


ModuleManager.NotAllowedOperation = {}
ModuleManager.NotAllowedOperation.new = function(reason_)
	local obj = {}
	setmetatable(obj, {__index=ModuleManager.Error.new(reason_)})
	obj.type = "NotAllowedOperation"
	return obj
end


ModuleManager.InvalidArguments = {}
ModuleManager.InvalidArguments.new = function(reason_)
	local obj = {}
	setmetatable(obj, {__index=ModuleManager.Error.new(reason_)})
	obj.type = "InvalidArguments"
	return obj
end


ModuleManager.InvalidOperation = {}
ModuleManager.InvalidOperation.new = function(reason_)
	local obj = {}
	setmetatable(obj, {__index=ModuleManager.Error.new(reason_)})
	obj.type = "InvalidOperation"
	return obj
end







ModuleManager.new = function(prop)
	local obj = {}

	function obj:exit()
		self:unloadAll()
	end

	function obj:load(file_name, init_func)
		file_name = string.gsub(file_name, "\\", "/")
		self._rtcout:RTC_TRACE("load(fname = "..file_name..")")
		if file_name == "" then
			error(ModuleManager.InvalidArguments.new("Invalid file name."))
		end
		if StringUtil.isURL(file_name) then
			if not self._downloadAllowed then
				error(ModuleManager.NotAllowedOperation.new("Downloading module is not allowed."))
			else
				error(ModuleManager.NotFound.new("Not implemented."))
			end
		end
		local import_name = StringUtil.basename(file_name)
		local pathChanged=false
		local file_path = nil
		local save_path = ""
		
		
		if StringUtil.isAbsolutePath(file_name) then
			if not self._absoluteAllowed then
				error(ModuleManager.NotAllowedOperation.new("Absolute path is not allowed"))
			else
				save_path = package.path
				package.path = package.path..";"..StringUtil.dirname(file_name).."?.lua"

				pathChanged = true
				import_name = StringUtil.basename(file_name)
				file_path = file_name
			end

		else
			file_path = self:findFile(file_name, self._loadPath)
			if file_path == nil then
				error(ModuleManager.FileNotFound.new(file_name))
			end
		end
		
		
		
		if not self:fileExist(file_path) then
			
			error(ModuleManager.FileNotFound.new(file_name))
		end
		
		

		local f = io.open(file_path, "r")
		if init_func ~= nil then
			if string.find(f:read("*a"), init_func) == nil then
				
				error(ModuleManager.FileNotFound.new(file_name))
			end
		end
		f:close()
		
		
		
		if not pathChanged then
			package.path = package.path..";"..StringUtil.dirname(file_path).."?.lua"
		end

		local ext_pos = string.find(import_name, ".lua")
		if ext_pos ~= nil then
			import_name = string.sub(import_name,1,ext_pos-1)
		end

		--print(import_name)
		--print("testModule", tostring(import_name))
		local mo = require(tostring(import_name))
		--local mo = require "testModule"
		--print(mo)
		--print(package.path)

		if pathChanged then
			package.path = save_path
		end

		
		file_path = string.gsub(file_path, "\\", "/")
		file_path = string.gsub(file_path, "//", "/")
		
		--print(mo,type(mo))
		local dll = DLLEntity.new(mo,Properties.new())
		
		dll.properties:setProperty("file_path",file_path)
		self._modules:registerObject(dll)

		
		if init_func == nil then
			return file_name
		end
		
		self:symbol(file_path,init_func)(self._mgr)

		return file_name
	end


	function obj:findFile(fname, load_path)
		file_name = fname
		
		for k, path in ipairs(load_path) do
			local f = nil
			local suffix = self._properties:getProperty("manager.modules.Lua.suffixes")
			if string.find(fname, "."..suffix) == nil then
				f = tostring(path).."/"..tostring(file_name).."."..suffix
			else
				f = tostring(path).."/"..tostring(file_name)
			end
			--print(self:fileExist(f))
			if self:fileExist(f) then
				f = string.gsub(f,"\\","/")
				f = string.gsub(f,"//","/")
				return f
			end
			--local filelist = {}
			--StringUtil.findFile(path,file_name,filelist)
			
			--if len(filelist) > 0 then
			--	return filelist[1]
			--end
		end
		return ""
	end

	function obj:fileExist(filename)
		local fname = filename
		local suffix = self._properties:getProperty("manager.modules.Lua.suffixes")
		if string.find(fname, "."..suffix) == nil then
			fname = tostring(filename).."."..suffix
		end
		--print(fname)
		
		--if os.path.isfile(fname)
		--	return True
		--end
		--print(fname)
		
		local f = io.open(fname, "r")
		if f ~= nil then
			return true
		end
		return false
			
		--return false
	end

	function obj:symbol(file_name, func_name)
		local dll = self._modules:find(file_name)
		--print(dll, file_name)
		if dll == nil then
			error(ModuleManager.ModuleNotFound.new(file_name))
		end
		
		local func = dll.dll[func_name]
		
		if func == nil then
			error(ModuleManager.SymbolNotFound.new(func_name))
		end
		
		return func
	end

	obj._properties = prop
	obj._configPath = StringUtil.split(prop:getProperty(CONFIG_PATH), ",")

	for k, v in pairs(obj._configPath) do
		obj._configPath[k] = StringUtil.eraseHeadBlank(v)
	end
	obj._loadPath = StringUtil.split(prop:getProperty(MOD_LOADPTH,"./"), ",")
	for k, v in pairs(obj._loadPath) do
		obj._loadPath[k] = StringUtil.eraseHeadBlank(v)
	end

	obj._absoluteAllowed = StringUtil.toBool(prop:getProperty(ALLOW_ABSPATH),
							"yes", "no", false)

	obj._downloadAllowed = StringUtil.toBool(prop:getProperty(ALLOW_URL),
							"yes", "no", false)

	obj._initFuncSuffix = prop:getProperty(INITFUNC_SFX)
	obj._initFuncPrefix = prop:getProperty(INITFUNC_PFX)
	obj._modules = ObjectManager.new(DLLPred)
	obj._rtcout = nil
	local Manager = require "openrtm.Manager"
	obj._mgr = Manager:instance()
	if obj._rtcout == nil then
		obj._rtcout = obj._mgr:getLogbuf("ModuleManager")
	end

	obj._modprofs = {}
	return obj
end


return ModuleManager
