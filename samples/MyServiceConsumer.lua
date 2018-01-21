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


local myserviceconsumer_spec = {
  ["implementation_id"]="MyServiceConsumer",
  ["type_name"]="MyServiceConsumer",
  ["description"]="MyService Consumer Sample component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}



local seq_print  = {}


seq_print.new = function()
	local obj = {}
	obj._cnt  = 0
	local call_func = function(self, val)
		print(self._cnt, ": ", val)
		self._cnt = self._cnt + 1
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


local MyServiceConsumer = {}
MyServiceConsumer.new = function(manager)
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	function obj:onInitialize()
		self._myServicePort = CorbaPort.new("MyService")
		self._myservice0 = CorbaConsumer.new("IDL:SimpleService/MyService:1.0")
		self._myServicePort:registerConsumer("myservice0", "MyService", self._myservice0, "../idl/MyService.idl")
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end
	function obj:onExecute(ec_id)
		print("\n")
		print("Command list: ")
		print(" echo [msg]       : echo message.")
		print(" set_value [value]: set value.")
		print(" get_value        : get current value.")
		print(" get_echo_history : get input messsage history.")
		print(" get_value_history: get input value history.")
		io.write("> ")
		local args = io.read()

		local StringUtil = require "openrtm.StringUtil"
		local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
		local oil = require "oil"

		local argv = StringUtil.split(args, " ")
		argv[#argv] = StringUtil.eraseTailBlank(argv[#argv])

		local success, exception = oil.pcall(
			function()
				if argv[1] == "echo" and table.maxn(argv) > 1 then
					print("echo() finished: ", self._myservice0:_ptr():echo(argv[2]))
				elseif argv[1] == "set_value" and table.maxn(argv) > 1 then
					local val = tonumber(argv[2])
					self._myservice0:_ptr():set_value(val)
					print("Set remote value: ", val)
				elseif argv[1] == "get_value" then
					local retval = self._myservice0:_ptr():get_value()
					print("Current remote value: ", retval)
				elseif argv[1] == "get_echo_history" then
					CORBA_SeqUtil.for_each(self._myservice0:_ptr():get_echo_history(),
												  seq_print.new())
				elseif argv[1] == "get_value_history" then
					CORBA_SeqUtil.for_each(self._myservice0._ptr().get_value_history(),
												  seq_print.new())
				else
					print("Invalid command or argument(s).")
				end
			end)
		if not success then
			print(exception)
		end




		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

MyServiceConsumer.Init = function(manager)
	local prof = Properties.new({defaults_str=myserviceconsumer_spec})
	manager:registerFactory(prof, MyServiceConsumer.new, Factory.Delete)
end

local MyModuleInit = function(manager)
	MyServiceConsumer.Init(manager)
	local comp = manager:createComponent("MyServiceConsumer")
end


if Manager.is_main() then
	local manager = Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return MyServiceConsumer
end


