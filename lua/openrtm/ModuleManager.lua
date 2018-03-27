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


local DLLPred = function(name, factory)
	local obj = {}
	if name ~= nil then
		obj._filepath = name
	end
	if factory ~= nil then
		obj._filepath = factory
	end
	local call_func = function(self, dll)
		return (self._filepath == dll.properties:getProperty("file_path"))
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


local ModuleManager.Error = {}
ModuleManager.Error.new = function(reason_)
	local obj = {}
	obj.reason = reason_
	return obj
end


local ModuleManager.NotFound = {}
ModuleManager.NotFound.new = function(name_)
	local obj = {}
	obj.name = name_
	return obj
end


local ModuleManager.FileNotFound = {}
ModuleManager.FileNotFound.new = function(name_)
	local obj = {}
	setmetatable(obj, {__index=NotFound.new(name_)})
	return obj
end

local ModuleManager.ModuleNotFound = {}
ModuleManager.ModuleNotFound.new = function(name_)
	local obj = {}
	setmetatable(obj, {__index=NotFound.new(name_)})
	return obj
end

local ModuleManager.SymbolNotFound = {}
ModuleManager.SymbolNotFound.new = function(name_)
	local obj = {}
	setmetatable(obj, {__index=NotFound.new(name_)})
	return obj
end


local ModuleManager.NotAllowedOperation = {}
ModuleManager.NotAllowedOperation.new = function(reason_)
	local obj = {}
	setmetatable(obj, {__index=Error.new(reason_)})
	return obj
end


local ModuleManager.InvalidArguments = {}
ModuleManager.InvalidArguments.new = function(reason_)
	local obj = {}
	setmetatable(obj, {__index=Error.new(reason_)})
	return obj
end


local ModuleManager.InvalidOperation = {}
ModuleManager.InvalidOperation.new = function(reason_)
	local obj = {}
	setmetatable(obj, {__index=Error.new(reason_)})
	return obj
end







ModuleManager.new = function(prop)
	local obj = {}

	function obj:exit()
		self:unloadAll()
	end

	function obj:load(file_name, init_func)
		string.gsub(file_name, "\\", "/")
		self._rtcout:RTC_TRACE("load(fname = "..file_name..")")
		if file_name == "" then
			error(ModuleManager.InvalidArguments.new("Invalid file name."))
		end
		if StringUtil.isURL(file_name) then
			if not self._downloadAllowed then
				error(ModuleManager.NotAllowedOperation.new("Downloading module is not allowed.")
			else
				error(ModuleManager.NotFound.new("Not implemented."))
			end
		end
		local import_name = os.path.split(file_name)[-1]
		local pathChanged=false
		local file_path = nil

		if StringUtil.isAbsolutePath(file_name) then
			if not self._absoluteAllowed then
				error(ModuleManager.NotAllowedOperation.new("Absolute path is not allowed"))
			else
				package.path = package.path..";"..StringUtil.dirname(file_name)

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

		with open(str(file_path)) as f
			if init_func ~= nil then
				if f.read().find(init_func) == -1
					error(ModuleManager.FileNotFound.new(file_name))
				end
			end
		end

		if not pathChanged then
			local splitted_name = os.path.split(file_path)
			sys.path.append(splitted_name[0])
		end

		local ext_pos = import_name.find(".lua")
		if ext_pos > 0 then
			import_name = import_name[:ext_pos]
		end

		local mo = __import__(str(import_name))

		if pathChanged then
			sys.path = save_path
		end

		file_path = file_path.replace("\\","/")
		file_path = file_path.replace("//","/")

		dll = DLLEntity.new(mo,Properties.new())
		dll.properties:setProperty("file_path",file_path)
		self._modules:registerObject(dll)


		if init_func == nil then
			return file_name
		end

		self.symbol(file_path,init_func)(self._mgr)

		return file_name
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
