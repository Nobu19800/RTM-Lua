---------------------------------
--! @file SeqIn.moon
--! @brief シーケンス型入力のRTCサンプル
---------------------------------





openrtm  = require "openrtm"
openrtm_ms = require "openrtm_ms"


-- RTCの仕様をテーブルで定義する
seqin_spec = {
  ["implementation_id"]:"SeqIn",
  ["type_name"]:"SequenceInComponent",
  ["description"]:"Sequence InPort component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script"}




-- @class SeqIn
class SeqIn extends openrtm_ms.RTObject
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

		-- インポート生成
		self._octetIn = openrtm_ms.InPort("Octet",self._d_octet,"::RTC::TimedOctet")
		self._shortIn = openrtm_ms.InPort("Short",self._d_short,"::RTC::TimedShort")
		self._longIn = openrtm_ms.InPort("Long",self._d_long,"::RTC::TimedLong")
		self._floatIn = openrtm_ms.InPort("Float",self._d_float,"::RTC::TimedFloat")
		self._doubleIn = openrtm_ms.InPort("Double",self._d_double,"::RTC::TimedDouble")
		self._octetSeqIn = openrtm_ms.InPort("OctetSeq",self._d_octetSeq,"::RTC::TimedOctetSeq")
		self._shortSeqIn = openrtm_ms.InPort("ShortSeq",self._d_shortSeq,"::RTC::TimedShortSeq")
		self._longSeqIn = openrtm_ms.InPort("LongSeq",self._d_longSeq,"::RTC::TimedLongSeq")
		self._floatSeqIn = openrtm_ms.InPort("FloatSeq",self._d_floatSeq,"::RTC::TimedFloatSeq")
		self._doubleSeqIn = openrtm_ms.InPort("DoubleSeq",self._d_doubleSeq,"::RTC::TimedDoubleSeq")



	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- ポート追加
		@addInPort("Octet",self._octetIn)
		@addInPort("Short",self._shortIn)
		@addInPort("Long",self._longIn)
		@addInPort("Float",self._floatIn)
		@addInPort("Double",self._doubleIn)
		@addInPort("OctetSeq",self._octetSeqIn)
		@addInPort("ShortSeq",self._shortSeqIn)
		@addInPort("LongSeq",self._longSeqIn)
		@addInPort("FloatSeq",self._floatSeqIn)
		@addInPort("DoubleSeq",self._doubleSeqIn)

		return self._ReturnCode_t.RTC_OK


	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		-- データ読み込み
		octet_  = self._octetIn\read()
		short_  = self._shortIn\read()
		long_   = self._longIn\read()
		float_  = self._floatIn\read()
		double_ = self._doubleIn\read()

		octetSeq_  = self._octetSeqIn\read()
		shortSeq_  = self._shortSeqIn\read()
		longSeq_   = self._longSeqIn\read()
		floatSeq_  = self._floatSeqIn\read()
		doubleSeq_ = self._doubleSeqIn\read()

		octetSize_  = #octetSeq_.data
		shortSize_  = table.maxn(shortSeq_.data)
		longSize_   = table.maxn(longSeq_.data)
		floatSize_  = table.maxn(floatSeq_.data)
		doubleSize_ = table.maxn(doubleSeq_.data)


		octetSeqDisp_ = {}
		for i = 1,octetSize_
			octetSeqDisp_[i] = string.sub(octetSeq_.data,i,i)




		maxsize = math.max(octetSize_, shortSize_, longSize_, floatSize_, doubleSize_)


		octetDisp_ = string.byte(octet_.data)

		print(string.format('%3.2s %10.8s %10.8s %10.8s %10.8s %10.8s',
				' ', 'octet', 'short', 'long', 'float', 'double'))
		print(string.format('%3.2s %7s[%s] %10.8s %10.8s %10.8s %10.8s',
				' ', octet_.data, octetDisp_, short_.data, long_.data, float_.data, double_.data))
		print("-----------------------------------------------------------")
		print("                 Sequence Data                     ")
		print("-----------------------------------------------------------")
		for i =1,maxsize
			--print(octetDisp_)
			if octetSeqDisp_[i] == nil
				octetSeqDisp_[i] = string.char(0)

			if shortSeq_.data[i] == nil
				shortSeq_.data[i] = 0

			if longSeq_.data[i] == nil
				longSeq_.data[i] = 0

			if floatSeq_.data[i] == nil
				floatSeq_.data[i] = 0

			if doubleSeq_.data[i] == nil
				doubleSeq_.data[i] = 0

			octetDisp_ = string.byte(octetSeqDisp_[i])
			print(string.format('%3.2s %7s[%s] %10.8s %10.8s %10.8s %10.8s',
					i, octetSeqDisp_[i], octetDisp_, shortSeq_.data[i], longSeq_.data[i], floatSeq_.data[i], doubleSeq_.data[i]))


		print("\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r")



		return self._ReturnCode_t.RTC_OK




-- SeqInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
SeqInInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:seqin_spec})
	manager\registerFactory(prof, SeqIn, openrtm.Factory.Delete)
	

-- SeqInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	SeqInInit(manager)
	comp = manager\createComponent("SeqIn")



-- SeqIn.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm.Manager.is_main()
--	manager = openrtm.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = SeqInInit
--	return obj

manager = openrtm.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

