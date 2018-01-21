package.path = "..\\lua\\?.lua"
package.cpath = "..\\clibs\\?.dll;"



local Manager = require "openrtm.Manager"
local Factory = require "openrtm.Factory"
local Properties = require "openrtm.Properties"
local RTObject = require "openrtm.RTObject"

local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local CorbaPort = require "openrtm.CorbaPort"


local consoleout_spec = {
  ["implementation_id"]="ConsoleOut",
  ["type_name"]="ConsoleOut",
  ["description"]="Console input component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}




local ConsoleOut = {}
ConsoleOut.new = function(manager)
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	function obj:onInitialize()
		self._d_in = {tm={sec=0,nsec=0},data=0}
		self._inIn = InPort.new("in",self._d_in,"::RTC::TimedLong")
		self:addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
	end
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			print("Received: ", data)
			print("Received: ", data.data)
			print("TimeStamp: ", data.tm.sec, "[s] ", data.tm.nsec, "[ns]")
		end
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

ConsoleOut.Init = function(manager)
	local prof = Properties.new({defaults_str=consoleout_spec})
	manager:registerFactory(prof, ConsoleOut.new, Factory.Delete)
end

local MyModuleInit = function(manager)
	ConsoleOut.Init(manager)
	local comp = manager:createComponent("ConsoleOut")
end


if Manager.is_main() then
	local manager = Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return ConsoleOut
end


