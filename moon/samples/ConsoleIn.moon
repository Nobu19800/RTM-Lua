---------------------------------
--! @file ConsoleIn.moon
--! @brief アウトポート出力のRTCサンプル
---------------------------------



openrtm  = require "openrtm"
openrtm_ms = require "openrtm_ms"


-- RTCの仕様をテーブルで定義する
consolein_spec = {
  ["implementation_id"]:"ConsoleIn",
  ["type_name"]:"ConsoleIn",
  ["description"]:"Console input component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script"}



-- @class ConfigSample
class ConsoleIn extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		-- データ格納変数
		self._d_out = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
		-- アウトポート生成
		self._outOut = openrtm_ms.OutPort("out",self._d_out,"::RTC::TimedLong")

	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- ポート追加
		@addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK


	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		io.write("Please input number: ")
		data = tonumber(io.read())
		-- 出力データ格納
		self._d_out.data = data
		-- 出力データにタイムスタンプ設定
		openrtm.OutPort.setTimestamp(self._d_out)
		-- データ書き込み
		self._outOut\write()
		return self._ReturnCode_t.RTC_OK
	
	

-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConsoleInInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:consolein_spec})
	manager\registerFactory(prof, ConsoleIn, openrtm.Factory.Delete)
	

-- ConsoleInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	ConsoleInInit(manager)
	comp = manager\createComponent("ConsoleIn")



-- ConsoleIn.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm.Manager.is_main()
--	manager = openrtm.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = ConsoleInInit
--	return obj

manager = openrtm.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

