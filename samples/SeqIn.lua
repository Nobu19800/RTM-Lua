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


local seqin_spec = {
  ["implementation_id"]="SeqIn",
  ["type_name"]="SequenceInComponent",
  ["description"]="Sequence InPort component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}




local SeqIn = {}
SeqIn.new = function(manager)
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	function obj:onInitialize()
		self._d_octet = {tm={sec=0,nsec=0},data=0}
		self._d_short = {tm={sec=0,nsec=0},data=0}
		self._d_long = {tm={sec=0,nsec=0},data=0}
		self._d_float = {tm={sec=0,nsec=0},data=0}
		self._d_double = {tm={sec=0,nsec=0},data=0}
		self._d_octetSeq = {tm={sec=0,nsec=0},data=""}
		self._d_shortSeq = {tm={sec=0,nsec=0},data={}}
		self._d_longSeq = {tm={sec=0,nsec=0},data={}}
		self._d_floatSeq = {tm={sec=0,nsec=0},data={}}
		self._d_doubleSeq = {tm={sec=0,nsec=0},data={}}

		self._octetIn = InPort.new("Octet",self._d_octet,"::RTC::TimedOctet")
		self._shortIn = InPort.new("Short",self._d_short,"::RTC::TimedShort")
		self._longIn = InPort.new("Long",self._d_long,"::RTC::TimedLong")
		self._floatIn = InPort.new("Float",self._d_float,"::RTC::TimedFloat")
		self._doubleIn = InPort.new("Double",self._d_double,"::RTC::TimedDouble")
		self._octetSeqIn = InPort.new("OctetSeq",self._d_octetSeq,"::RTC::TimedOctetSeq")
		self._shortSeqIn = InPort.new("ShortSeq",self._d_shortSeq,"::RTC::TimedShortSeq")
		self._longSeqIn = InPort.new("LongSeq",self._d_longSeq,"::RTC::TimedLongSeq")
		self._floatSeqIn = InPort.new("FloatSeq",self._d_floatSeq,"::RTC::TimedFloatSeq")
		self._doubleSeqIn = InPort.new("DoubleSeq",self._d_doubleSeq,"::RTC::TimedDoubleSeq")


		self:addInPort("Octet",self._octetIn)
		self:addInPort("Short",self._shortIn)
		self:addInPort("Long",self._longIn)
		self:addInPort("Float",self._floatIn)
		self:addInPort("Double",self._doubleIn)
		self:addInPort("OctetSeq",self._octetSeqIn)
		self:addInPort("ShortSeq",self._shortSeqIn)
		self:addInPort("LongSeq",self._longSeqIn)
		self:addInPort("FloatSeq",self._floatSeqIn)
		self:addInPort("DoubleSeq",self._doubleSeqIn)

		return self._ReturnCode_t.RTC_OK
	end
	function obj:onExecute(ec_id)
		local octet_  = self._octetIn:read()
		local short_  = self._shortIn:read()
		local long_   = self._longIn:read()
		local float_  = self._floatIn:read()
		local double_ = self._doubleIn:read()

		local octetSeq_  = self._octetSeqIn:read()
		local shortSeq_  = self._shortSeqIn:read()
		local longSeq_   = self._longSeqIn:read()
		local floatSeq_  = self._floatSeqIn:read()
		local doubleSeq_ = self._doubleSeqIn:read()

		local octetSize_  = #octetSeq_.data
		local shortSize_  = table.maxn(shortSeq_.data)
		local longSize_   = table.maxn(longSeq_.data)
		local floatSize_  = table.maxn(floatSeq_.data)
		local doubleSize_ = table.maxn(doubleSeq_.data)


		octetSeqDisp_ = {}
		for i = 1,octetSize_ do
			octetSeqDisp_[i] = string.sub(octetSeq_.data,i,i)
		end



		local maxsize = math.max(octetSize_, shortSize_, longSize_, floatSize_, doubleSize_)


		local octetDisp_ = string.byte(octet_.data)

		print(string.format('%3.2s %10.8s %10.8s %10.8s %10.8s %10.8s',
				' ', 'octet', 'short', 'long', 'float', 'double'))
		print(string.format('%3.2s %7s[%s] %10.8s %10.8s %10.8s %10.8s',
				' ', octet_.data, octetDisp_, short_.data, long_.data, float_.data, double_.data))
		print("-----------------------------------------------------------")
		print("                 Sequence Data                     ")
		print("-----------------------------------------------------------")
		for i =1,maxsize do
			--print(octetDisp_)
			if octetSeqDisp_[i] == nil then
				octetSeqDisp_[i] = string.char(0)
			end
			if shortSeq_.data[i] == nil then
				shortSeq_.data[i] = 0
			end
			if longSeq_.data[i] == nil then
				longSeq_.data[i] = 0
			end
			if floatSeq_.data[i] == nil then
				floatSeq_.data[i] = 0
			end
			if doubleSeq_.data[i] == nil then
				doubleSeq_.data[i] = 0
			end
			octetDisp_ = string.byte(octetSeqDisp_[i])
			print(string.format('%3.2s %7s[%s] %10.8s %10.8s %10.8s %10.8s',
					i, octetSeqDisp_[i], octetDisp_, shortSeq_.data[i], longSeq_.data[i], floatSeq_.data[i], doubleSeq_.data[i]))

		end
		print("\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r")



		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

SeqIn.Init = function(manager)
	local prof = Properties.new({defaults_str=seqin_spec})
	manager:registerFactory(prof, SeqIn.new, Factory.Delete)
end

local MyModuleInit = function(manager)
	SeqIn.Init(manager)
	local comp = manager:createComponent("SeqIn")
end



if Manager.is_main() then
	local manager = Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return SeqIn
end

