---------------------------------
--! @file ConsoleOut.moon
--! @brief インポート入力のRTCサンプル
---------------------------------





openrtm  = require "openrtm"
openrtm_ms = require "openrtm_ms"


-- RTCの仕様をテーブルで定義する
consoleout_spec = {
  ["implementation_id"]:"ConsoleOut",
  ["type_name"]:"ConsoleOut",
  ["description"]:"Console output component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script"}



-- @class ConsoleOut
class ConsoleOut extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		-- データ格納変数
		self._d_in = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
		-- インポート生成
		self._inIn = openrtm_ms.InPort("in",self._d_in,"::RTC::TimedLong")


	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- ポート追加
		@addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
		
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		-- バッファに新規データがあるかを確認
		if self._inIn\isNew()
			-- データ読み込み
			data = self._inIn\read()
			print("Received: ", data)
			print("Received: ", data.data)
			print("TimeStamp: ", data.tm.sec, "[s] ", data.tm.nsec, "[ns]")
			
		return self._ReturnCode_t.RTC_OK





-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConsoleOutInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:consoleout_spec})
	manager\registerFactory(prof, ConsoleOut, openrtm.Factory.Delete)


-- ConsoleInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	ConsoleOutInit(manager)
	comp = manager\createComponent("ConsoleOut")


-- ConsoleOut.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm.Manager.is_main()
--	manager = openrtm.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = ConsoleOutInit
--	return obj

manager = openrtm.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

