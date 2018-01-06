
openrtm_idl_path = "../idl"


local Manager = require "openrtm.Manager"
local Factory = require "openrtm.Factory"
local Properties = require "openrtm.Properties"
local RTObject = require "openrtm.RTObject"

local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local CorbaPort = require "openrtm.CorbaPort"


myserviceprovider_spec = {
  "implementation_id","MyServiceProvider",
  "type_name","MyServiceProvider",
  "description","MyService Provider Sample component",
  "version","1.0",
  "vendor","Nobuhiko Miyamoto",
  "category","example",
  "activity_type","DataFlowComponent",
  "max_instance","10",
  "language","Lua",
  "lang_type","script"}



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


MyServiceSVC_impl = {}
MyServiceSVC_impl.new = function()
	local obj = {}
	obj._echoList = {}
    obj._valueList = {}
    obj._value = 0
	function obj:echo(msg)
		table.insert(self._echoList, msg)
		print("MyService::echo() was called.")
		local oil = require "oil"
		for i =1,10 do
			print("Message: ", msg)
			oil.tasks:suspend(0.1)
		end
		print("MyService::echo() was finished.")
		return msg
	end
	function obj:get_echo_history()
		local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
		print("MyService::get_echo_history() was called.")
		CORBA_SeqUtil.for_each(self._echoList, seq_print.new())
		return self._echoList
	end
	function obj:set_value(value)
		table.insert(self._valueList, value)
		self._value = value
		print("MyService::set_value() was called.")
		print("Current value: ", self._value)
	end
	function obj:get_value()
		print("MyService::get_value() was called.")
		print("Current value: ", self._value)
		return self._value
	end
	function obj:get_value_history()
		local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
		print("MyService::get_value_history() was called.")
		CORBA_SeqUtil.for_each(self._valueList, seq_print.new())
		return self._valueList
	end

	return obj
end


MyServiceProvider = {}
MyServiceProvider.new = function()
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	function obj:onInitialize()
		self._myServicePort = CorbaPort.new("MyService")
		self._myservice0 = MyServiceSVC_impl.new()
		self._myServicePort:registerProvider("myservice0", "MyService", self._myservice0, "../idl/MyService.idl", "IDL:SimpleService/MyService:1.0")

		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end



	return obj
end

MyServiceProviderInit = function(manager)
	local prof = Properties.new({defaults_str=myserviceprovider_spec})
	manager:registerFactory(prof, MyServiceProvider.new, Factory.Delete)
end

function MyModuleInit(manager)
	MyServiceProviderInit(manager)
	local comp = manager:createComponent("MyServiceProvider")
end


manager = Manager
manager:init({})
manager:setModuleInitProc(MyModuleInit)
manager:activateManager()
manager:runManager()

