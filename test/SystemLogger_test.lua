local luaunit = require "luaunit"
local SystemLogger = require "openrtm.SystemLogger"
local Properties = require "openrtm.Properties"
local LogstreamBase = require "openrtm.LogstreamBase"


LogstreamMock = {}
LogstreamMock.new = function()
	local obj = {}
	setmetatable(obj, {__index=LogstreamBase.new()})
	return obj
end


TestSystemLogger = {}


function TestSystemLogger:test_logger()
	local ret = SystemLogger.strToLogLevel("SILENT")
	luaunit.assertEquals(ret, SystemLogger.SILENT)
	local ret = SystemLogger.strToLogLevel("FATAL")
	luaunit.assertEquals(ret, SystemLogger.FATAL)
	local ret = SystemLogger.strToLogLevel("ERROR")
	luaunit.assertEquals(ret, SystemLogger.ERROR)
	local ret = SystemLogger.strToLogLevel("WARN")
	luaunit.assertEquals(ret, SystemLogger.WARN)
	local ret = SystemLogger.strToLogLevel("INFO")
	luaunit.assertEquals(ret, SystemLogger.INFO)
	local ret = SystemLogger.strToLogLevel("DEBUG")
	luaunit.assertEquals(ret, SystemLogger.DEBUG)
	local ret = SystemLogger.strToLogLevel("TRACE")
	luaunit.assertEquals(ret, SystemLogger.TRACE)
	local ret = SystemLogger.strToLogLevel("VERBOSE")
	luaunit.assertEquals(ret, SystemLogger.VERBOSE)
	local ret = SystemLogger.strToLogLevel("PARANOID")
	luaunit.assertEquals(ret, SystemLogger.PARANOID)

	local logger = SystemLogger.LogStream.new()
	local log = LogstreamMock.new()
	logger:addLogger(log)
	logger:setLogLevel("SILENT")
	logger:setLogLevel("FATAL")
	logger:setLogLevel("ERROR")
	logger:setLogLevel("WARN")
	logger:setLogLevel("INFO")
	logger:setLogLevel("DEBUG")
	logger:setLogLevel("TRACE")
	logger:setLogLevel("VERBOSE")
	logger:setLogLevel("PARANOID")

	local logger2 = logger:getLogger("test")


	logger2:RTC_LOG(SystemLogger.SILENT, "message")
	logger2:RTC_FATAL("message")
	logger2:RTC_ERROR("message")
	logger2:RTC_WARN("message")
	logger2:RTC_INFO("message")
	logger2:RTC_DEBUG("message")
	logger2:RTC_TRACE("message")
	logger2:RTC_VERBOSE("message")
	logger2:RTC_PARANOID("message")

	logger:shutdown()

	
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
