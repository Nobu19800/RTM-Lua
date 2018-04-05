---------------------------------
--! @file SeqOut.moon
--! @brief シーケンス型出力のRTCサンプル
---------------------------------





openrtm  = require "openrtm"
openrtm_ms = require "openrtm_ms"


-- RTCの仕様をテーブルで定義する
seqout_spec = {
  ["implementation_id"]:"SeqOut",
  ["type_name"]:"SequenceOutComponent",
  ["description"]:"Sequence OutPort component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script"}




-- @class SeqOut
class SeqOut extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		
		-- データ格納変数
		self._d_octet = openrtm.RTCUtil.instantiateDataType("::RTC::TimedOctet")
		self._d_short = openrtm.RTCUtil.instantiateDataType("::RTC::TimedShort")
		self._d_long = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
		self._d_float = openrtm.RTCUtil.instantiateDataType("::RTC::TimedFloat")
		self._d_double = openrtm.RTCUtil.instantiateDataType("::RTC::TimedDouble")
		self._d_octetSeq = openrtm.RTCUtil.instantiateDataType("::RTC::TimedOctetSeq")
		self._d_shortSeq = openrtm.RTCUtil.instantiateDataType("::RTC::TimedShortSeq")
		self._d_longSeq = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLongSeq")
		self._d_floatSeq = openrtm.RTCUtil.instantiateDataType("::RTC::TimedFloatSeq")
		self._d_doubleSeq = openrtm.RTCUtil.instantiateDataType("::RTC::TimedDoubleSeq")

		-- アウトポート生成
		self._octetOut = openrtm_ms.OutPort("Octet",self._d_octet,"::RTC::TimedOctet")
		self._shortOut = openrtm_ms.OutPort("Short",self._d_short,"::RTC::TimedShort")
		self._longOut = openrtm_ms.OutPort("Long",self._d_long,"::RTC::TimedLong")
		self._floatOut = openrtm_ms.OutPort("Float",self._d_float,"::RTC::TimedFloat")
		self._doubleOut = openrtm_ms.OutPort("Double",self._d_double,"::RTC::TimedDouble")
		self._octetSeqOut = openrtm_ms.OutPort("OctetSeq",self._d_octetSeq,"::RTC::TimedOctetSeq")
		self._shortSeqOut = openrtm_ms.OutPort("ShortSeq",self._d_shortSeq,"::RTC::TimedShortSeq")
		self._longSeqOut = openrtm_ms.OutPort("LongSeq",self._d_longSeq,"::RTC::TimedLongSeq")
		self._floatSeqOut = openrtm_ms.OutPort("FloatSeq",self._d_floatSeq,"::RTC::TimedFloatSeq")
		self._doubleSeqOut = openrtm_ms.OutPort("DoubleSeq",self._d_doubleSeq,"::RTC::TimedDoubleSeq")


	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- ポート追加
		@addOutPort("Octet",self._octetOut)
		@addOutPort("Short",self._shortOut)
		@addOutPort("Long",self._longOut)
		@addOutPort("Float",self._floatOut)
		@addOutPort("Double",self._doubleOut)
		@addOutPort("OctetSeq",self._octetSeqOut)
		@addOutPort("ShortSeq",self._shortSeqOut)
		@addOutPort("LongSeq",self._longSeqOut)
		@addOutPort("FloatSeq",self._floatSeqOut)
		@addOutPort("DoubleSeq",self._doubleSeqOut)

		return self._ReturnCode_t.RTC_OK


	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		octetSeq  = ""
		shortSeq  = {}
		longSeq   = {}
		floatSeq  = {}
		doubleSeq = {}

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
		for i = 1,10
			octetSeq = octetSeq..string.char(math.random(0x41, 0x4a))
			shortSeq[i] = math.random(0, 10)
			longSeq[i] = math.random(0, 10)
			floatSeq[i] = math.random(0, 10.0)
			doubleSeq[i] = math.random(0, 10.0)

			print(string.format('%3.2s : %7s[%s] %10.8s %10.8s %10.8s %10.8s',
				tostring(i), string.byte(string.sub(octetSeq,i,i)), string.sub(octetSeq,i,i), shortSeq[i], longSeq[i], floatSeq[i], doubleSeq[i]))
		

		print("\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r")


		self._d_octetSeq.data = octetSeq
		self._d_shortSeq.data = shortSeq
		self._d_longSeq.data = longSeq
		self._d_floatSeq.data = floatSeq
		self._d_doubleSeq.data = doubleSeq

		-- データ書き込み
		self._octetOut\write()
		self._shortOut\write()
		self._longOut\write()
		self._floatOut\write()
		self._doubleOut\write()
		self._octetSeqOut\write()
		self._shortSeqOut\write()
		self._longSeqOut\write()
		self._floatSeqOut\write()
		self._doubleSeqOut\write()

		return self._ReturnCode_t.RTC_OK


-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
SeqOutInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:seqout_spec})
	manager\registerFactory(prof, SeqOut, openrtm.Factory.Delete)


-- ConsoleInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	SeqOutInit(manager)
	comp = manager\createComponent("SeqOut")



-- SeqOut.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm.Manager.is_main()
--	manager = openrtm.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = SeqOutInit
--	return obj


manager = openrtm.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

