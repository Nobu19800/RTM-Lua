--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ManagerConfig= {}
_G["openrtm.ManagerConfig"] = ManagerConfig

local Properties = require "openrtm.Properties"
local default_config = require "openrtm.DefaultConfiguration"


local config_file_path = {"./rtc.conf"}
ManagerConfig.new = function(argv)
	local obj = {}
	obj._configFile = ""
    obj._argprop = Properties.new()
    obj._isMaster = false

	function obj:init(_argv)
		self:parseArgs(_argv)
	end
	function obj:configure(prop)
		prop:setDefaults(default_config)
		if self:findConfigFile() then
			local fd = io.open(self._configFile, "r")
			prop:load(fd)
			--print(prop)
			fd:close()
		end

		self:setSystemInformation(prop)
		if self._isMaster then
			prop:setProperty("manager.is_master","YES")
		end

		prop:mergeProperties(self._argprop)
		prop:setProperty("config_file", self._configFile)
		return prop
	end
	function obj:parseArgs(_argv)
	end

	function obj:findConfigFile()
	    if self._configFile ~= "" then
			if not self:fileExist(self._configFile) then
				return false
			end
			return true
		end
		for i,filename in ipairs(config_file_path) do
			if self:fileExist(filename) then
				self._configFile = filename
				return true
			end
		end
		return false
	end

	function obj:setSystemInformation(prop)
	end

	function obj:fileExist(filename)
		local fd = io.open(filename, "r")

		if fd == nil then
			return false
		else
			fd:close()
			return true
		end
	end
    if argv ~= nil then
		obj:init(argv)
	end
	return obj
end


return ManagerConfig
