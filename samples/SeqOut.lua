---------------------------------
--! @file SeqOut.lua
--! @brief シーケンス型出力のRTCサンプル
---------------------------------

package.path = "..\\lua\\?.lua"
package.cpath = "..\\clibs\\?.dll;"



local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local seqout_spec = {
  ["implementation_id"]="SeqOut",
  ["type_name"]="SequenceOutComponent",
  ["description"]="Sequence OutPort component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}




local SeqOut = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
SeqOut.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()
		-- データ格納変数
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

		-- アウトポート生成
		self._octetOut = openrtm.OutPort.new("Octet",self._d_octet,"::RTC::TimedOctet")
		self._shortOut = openrtm.OutPort.new("Short",self._d_short,"::RTC::TimedShort")
		self._longOut = openrtm.OutPort.new("Long",self._d_long,"::RTC::TimedLong")
		self._floatOut = openrtm.OutPort.new("Float",self._d_float,"::RTC::TimedFloat")
		self._doubleOut = openrtm.OutPort.new("Double",self._d_double,"::RTC::TimedDouble")
		self._octetSeqOut = openrtm.OutPort.new("OctetSeq",self._d_octetSeq,"::RTC::TimedOctetSeq")
		self._shortSeqOut = openrtm.OutPort.new("ShortSeq",self._d_shortSeq,"::RTC::TimedShortSeq")
		self._longSeqOut = openrtm.OutPort.new("LongSeq",self._d_longSeq,"::RTC::TimedLongSeq")
		self._floatSeqOut = openrtm.OutPort.new("FloatSeq",self._d_floatSeq,"::RTC::TimedFloatSeq")
		self._doubleSeqOut = openrtm.OutPort.new("DoubleSeq",self._d_doubleSeq,"::RTC::TimedDoubleSeq")

		-- ポート追加
		self:addOutPort("Octet",self._octetOut)
		self:addOutPort("Short",self._shortOut)
		self:addOutPort("Long",self._longOut)
		self:addOutPort("Float",self._floatOut)
		self:addOutPort("Double",self._doubleOut)
		self:addOutPort("OctetSeq",self._octetSeqOut)
		self:addOutPort("ShortSeq",self._shortSeqOut)
		self:addOutPort("LongSeq",self._longSeqOut)
		self:addOutPort("FloatSeq",self._floatSeqOut)
		self:addOutPort("DoubleSeq",self._doubleSeqOut)

		return self._ReturnCode_t.RTC_OK
	end
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	function obj:onExecute(ec_id)
		local octetSeq  = ""
		local shortSeq  = {}
		local longSeq   = {}
		local floatSeq  = {}
		local doubleSeq = {}

		self._d_octet.data = math.random(0x41, 0x4a)
		self._d_short.data = math.random(0, 10)
		self._d_long.data = math.random(0, 10)
		self._d_float.data = math.random(0.0, 10.0)
		self._d_double.data = math.random(0.0, 10.0)


		print(string.format('%3.2s   %10.8s %10.8s %10.8s %10.8s %10.8s',
			' ', 'octet', 'short', 'long', 'float', 'double'))
		print(string.format('%3.2s   %7s[%s] %10.8s %10.8s %10.8s %10.8s',
			' ', self._d_octet.data, string.char(self._d_octet.data), self._d_short.data, self._d_long.data, self._d_float.data, self._d_double.data))
		print("-------------------------------------------------------------")
		print("                 Sequence Data                     ")
		print("-------------------------------------------------------------")
		for i = 1,10 do
			octetSeq = octetSeq..string.char(math.random(0x41, 0x4a))
			shortSeq[i] = math.random(0, 10)
			longSeq[i] = math.random(0, 10)
			floatSeq[i] = math.random(0, 10.0)
			doubleSeq[i] = math.random(0, 10.0)

			print(string.format('%3.2s : %7s[%s] %10.8s %10.8s %10.8s %10.8s',
				tostring(i), string.byte(string.sub(octetSeq,i,i)), string.sub(octetSeq,i,i), shortSeq[i], longSeq[i], floatSeq[i], doubleSeq[i]))
		end

		print("\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r")


		self._d_octetSeq.data = octetSeq
		self._d_shortSeq.data = shortSeq
		self._d_longSeq.data = longSeq
		self._d_floatSeq.data = floatSeq
		self._d_doubleSeq.data = doubleSeq

		-- データ書き込み
		self._octetOut:write()
		self._shortOut:write()
		self._longOut:write()
		self._floatOut:write()
		self._doubleOut:write()
		self._octetSeqOut:write()
		self._shortSeqOut:write()
		self._longSeqOut:write()
		self._floatSeqOut:write()
		self._doubleSeqOut:write()

		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
SeqOut.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=seqout_spec})
	manager:registerFactory(prof, SeqOut.new, openrtm.Factory.Delete)
end

-- ConsoleInコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	SeqOut.Init(manager)
	local comp = manager:createComponent("SeqOut")
end


-- SeqOut.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return SeqOut
end

