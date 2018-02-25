---------------------------------
--! @file SystemLogger.lua
--! @brief ロガー管理クラス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SystemLogger= {}
_G["openrtm.SystemLogger"] = SystemLogger

SystemLogger.LogStream = {}
local NO_LOGGER = true
SystemLogger.LogStream.new = function()
	local obj = {}
	function obj:getLogger(name)
		local syslogger = self
		syslogger._logger_name = name
		return self
	end

	function obj:setLogLevel(level)

	end
	function obj:RTC_TRACE(msg, ...)
		if not NO_LOGGER then
			print("TRACE",msg)
		end
	end
	function obj:RTC_ERROR(msg, ...)
		if not NO_LOGGER then
			print("ERROR",msg)
		end
	end
	function obj:RTC_DEBUG(msg, ...)
		if not NO_LOGGER then
			print("DEBUG",msg)
		end
	end

	function obj:RTC_WARN(msg, ...)
		if not NO_LOGGER then
			print("WARN",msg)
		end
	end
	function obj:RTC_INFO(msg, ...)
		if not NO_LOGGER then
			print("INFO",msg)
		end
	end
	function obj:RTC_PARANOID(msg, ...)
		if not NO_LOGGER then
			print("PARANOID",msg)
		end
	end



	return obj
end




return SystemLogger
