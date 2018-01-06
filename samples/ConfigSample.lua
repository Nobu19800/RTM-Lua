
openrtm_idl_path = "../idl/Filename"

local oil = require "oil"
local Manager = require "openrtm.Manager"
local Factory = require "openrtm.Factory"
local Properties = require "openrtm.Properties"
local RTObject = require "openrtm.RTObject"

local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local CorbaPort = require "openrtm.CorbaPort"


configsample_spec = {
  "implementation_id","ConfigSample",
  "type_name","ConfigSample",
  "description","MyService Consumer Sample component",
  "version","1.0",
  "vendor","Nobuhiko Miyamoto",
  "category","example",
  "activity_type","DataFlowComponent",
  "max_instance","10",
  "language","Lua",
  "lang_type","script",
  "conf.default.int_param0", "0",
  "conf.default.int_param1", "1",
  "conf.default.double_param0", "0.11",
  "conf.default.double_param1", "9.9",
  "conf.default.str_param0", "hoge",
  "conf.default.str_param1", "dara",
  "conf.default.vector_param0", "0.0,1.0,2.0,3.0,4.0"}










ConfigSample = {}
ConfigSample.new = function()
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	function obj:onInitialize()
		self._int_param0 = {_value=0}
		self._int_param1 = {_value=1}
		self._double_param0 = {_value=0.11}
		self._double_param1 = {_value=9.9}
		self._str_param0 = {_value="hoge"}
		self._str_param1 = {_value="dara"}
		self._vector_param0 = {_value={0.0, 1.0, 2.0, 3.0, 4.0}}


		self:bindParameter("int_param0", self._int_param0, "0")
		self:bindParameter("int_param1", self._int_param1, "1")
		self:bindParameter("double_param0", self._double_param0, "0.11")
		self:bindParameter("double_param1", self._double_param1, "9.9")
		self:bindParameter("str_param0", self._str_param0, "hoge")
		self:bindParameter("str_param1", self._str_param1, "dara")
		self:bindParameter("vector_param0", self._vector_param0, "0.0,1.0,2.0,3.0,4.0")


		print("\n Please change configuration values from RTSystemEditor")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onExecute(ec_id)
		local c = "                    "
		print("---------------------------------------")
		print(" Active Configuration Set: ", self._configsets:getActiveId(),c)
		print("---------------------------------------")

		print("int_param0:       ", self._int_param0._value, c)
		print("int_param1:       ", self._int_param1._value, c)
		print("double_param0:    ", self._double_param0._value, c)
		print("double_param1:    ", self._double_param1._value, c)
		print("str_param0:       ", self._str_param0._value, c)
		print("str_param1:       ", self._str_param1._value, c)

		for idx, value in ipairs(self._vector_param0._value) do
			print("vector_param0[", idx, "]: ", value, c)
		end

		print("---------------------------------------")

		--print("Updating.... ", ticktack(), c)
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

ConfigSampleInit = function(manager)
	local prof = Properties.new({defaults_str=configsample_spec})
	manager:registerFactory(prof, ConfigSample.new, Factory.Delete)
end

function MyModuleInit(manager)
	ConfigSampleInit(manager)
	local comp = manager:createComponent("ConfigSample")
end


manager = Manager
manager:init({})
manager:setModuleInitProc(MyModuleInit)
manager:activateManager()
manager:runManager()

