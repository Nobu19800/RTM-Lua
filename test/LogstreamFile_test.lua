local luaunit = require "luaunit"
local LogstreamFile = require "openrtm.LogstreamFile"
local Properties = require "openrtm.Properties"
local Logger = require "openrtm.SystemLogger"


TestLogstreamFile = {}


local listenerMock = {}
listenerMock.new = function()
	local obj = {}
	obj._value = 0
	function obj:test_func(v)
		self._value = v
	end
	return obj
end

function TestLogstreamFile:test_log()
	local prop = Properties.new()
	local logger = LogstreamFile.new()
	luaunit.assertIsFalse(logger:init(prop))
	prop:setProperty("file_name","stdout")
	luaunit.assertIsTrue(logger:init(prop))
	
	logger:setLogLevel(Logger.FATAL)
	logger:setLogLevel(Logger.ERROR)
	logger:setLogLevel(Logger.WARN)
	logger:setLogLevel(Logger.DEBUG)
	logger:setLogLevel(Logger.SILENT)
	logger:setLogLevel(Logger.TRACE)
	logger:setLogLevel(Logger.VERBOSE)
	logger:setLogLevel(Logger.INFO)
	logger:setLogLevel(Logger.PARANOID)

	logger:log("test1",Logger.FATAL,"name")
	logger:log("test1",Logger.ERROR,"name")
	logger:log("test1",Logger.WARN,"name")
	logger:log("test1",Logger.DEBUG,"name")
	logger:log("test1",Logger.SILENT,"name")
	logger:log("test1",Logger.TRACE,"name")
	logger:log("test1",Logger.VERBOSE,"name")
	logger:log("test1",Logger.PARANOID,"name")
	logger:log("test1",Logger.INFO,"name")

	luaunit.assertIsTrue(logger:shutdown())
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
