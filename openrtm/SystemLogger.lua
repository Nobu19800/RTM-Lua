--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SystemLogger= {}
_G["openrtm.SystemLogger"] = SystemLogger

SystemLogger.LogStream = {}
local NO_LOGGER = false
SystemLogger.LogStream.new = function()
	local obj = {}
	function obj:getLogger(name)
		local syslogger = self
		syslogger._logger_name = name
		return self
	end

	function obj:setLogLevel(level)

	end
	function obj:RTC_TRACE(msg, opt)
		if not NO_LOGGER then
			print("TRACE",msg)
		end
	end
	function obj:RTC_ERROR(msg, opt)
		if not NO_LOGGER then
			print("ERROR",msg)
		end
	end
	function obj:RTC_DEBUG(msg, opt)
		if not NO_LOGGER then
			print("DEBUG",msg)
		end
	end

	function obj:RTC_WARN(msg, opt)
		if not NO_LOGGER then
			print("WARN",msg)
		end
	end
	function obj:RTC_INFO(msg, opt)
		if not NO_LOGGER then
			print("INFO",msg)
		end
	end
	function obj:RTC_PARANOID(msg, opt)
		if not NO_LOGGER then
			print("PARANOID",msg)
		end
	end



	return obj
end




return SystemLogger
