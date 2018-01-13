package.path = "..\\lua\\?.lua"
package.cpath = "..\\clibs\\?.dll;"
openrtm_idl_path = "../idl"


local Manager = require "openrtm.Manager"
local Factory = require "openrtm.Factory"
local Properties = require "openrtm.Properties"
local RTObject = require "openrtm.RTObject"

local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local CorbaPort = require "openrtm.CorbaPort"


local consolein_spec = {
  "implementation_id","ConsoleIn",
  "type_name","ConsoleIn",
  "description","Console output component",
  "version","1.0",
  "vendor","Nobuhiko Miyamoto",
  "category","example",
  "activity_type","DataFlowComponent",
  "max_instance","10",
  "language","Lua",
  "lang_type","script"}




local ConsoleIn = {}
ConsoleIn.new = function(manager)
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	function obj:onInitialize()
		self._d_out = {tm={sec=0,nsec=0},data=0}
		self._outOut = OutPort.new("out",self._d_out,"::RTC::TimedLong")
		self:addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK
	end
	function obj:onExecute(ec_id)
		io.write("Please input number: ")
		local data = tonumber(io.read())
		self._d_out.data = data
		OutPort.setTimestamp(self._d_out)
		self._outOut:write()
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

local ConsoleInInit = function(manager)
	local prof = Properties.new({defaults_str=consolein_spec})
	manager:registerFactory(prof, ConsoleIn.new, Factory.Delete)
end

local MyModuleInit = function(manager)
	ConsoleInInit(manager)
	local comp = manager:createComponent("ConsoleIn")
end



if Manager.is_main() then
	local manager = Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	ConsoleIn.Init = ConsoleInInit
	return ConsoleIn
end

