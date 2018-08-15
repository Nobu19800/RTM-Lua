---------------------------------
--! @file ConsoleOut.moon
--! @brief インポート入力のRTCサンプル
---------------------------------






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


-- @class DataListener
class DataListener extends openrtm_ms.ConnectorDataListener
	-- コンストラクタ
	-- @param name コールバック名
	new: (name) =>
		super 
		self._name = name
	-- コールバック関数
	-- @param info コネクタ情報
	-- @param cdrdata データ(バイト列)
	-- @return リスナステータス
	call: (info, cdrdata) =>
		local data = self\__call__(info, cdrdata, "::RTC::TimedLong")
		print("------------------------------")
		print("Listener:       "..self._name)
		print("Profile::name:  "..info.name)
		print("Profile::id:    "..info.id)
		print("Data:           "..data.data)
		print("------------------------------")
		return openrtm_ms.ConnectorListenerStatus.NO_CHANGE


-- @class ConnListener
class ConnListener extends openrtm_ms.ConnectorListener
	-- コンストラクタ
	-- @param name コールバック名
	new: (name) =>
		super 
		self._name = name
	-- コールバック関数
	-- @param info コネクタ情報
	-- @return リスナステータス
	call: (info) =>
		print("------------------------------")
		print("Listener:       "..self._name)
		print("Profile::name:  "..info.name)
		print("Profile::id:    "..info.id)
		print("------------------------------")
		return openrtm_ms.ConnectorListenerStatus.NO_CHANGE



-- @class ConsoleOut
class ConsoleOut extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		-- データ格納変数
		self._d_in = openrtm_ms.RTCUtil.instantiateDataType("::RTC::TimedLong")
		-- インポート生成
		self._inIn = openrtm_ms.InPort("in",self._d_in,"::RTC::TimedLong")



		-- コネクタコールバック関数の設定
		self._inIn\addConnectorListener(openrtm_ms.ConnectorListenerType.ON_CONNECT,
									ConnListener("ON_CONNECT"))
		self._inIn\addConnectorListener(openrtm_ms.ConnectorListenerType.ON_DISCONNECT,
									ConnListener("ON_DISCONNECT"))



		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_WRITE,
									DataListener("ON_BUFFER_WRITE"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_FULL,
									DataListener("ON_BUFFER_FULL"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT,
									DataListener("ON_BUFFER_WRITE_TIMEOUT"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_OVERWRITE,
									DataListener("ON_BUFFER_OVERWRITE"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_READ,
									DataListener("ON_BUFFER_READ"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_SEND,
									DataListener("ON_SEND"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVED,
									DataListener("ON_RECEIVED"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVER_FULL,
									DataListener("ON_RECEIVER_FULL"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT,
									DataListener("ON_RECEIVER_TIMEOUT"))
		self._inIn\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVER_ERROR,
									DataListener("ON_RECEIVER_ERROR"))



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
	manager\registerFactory(prof, ConsoleOut, openrtm_ms.Factory.Delete)


-- ConsoleInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	ConsoleOutInit(manager)
	comp = manager\createComponent("ConsoleOut")


-- ConsoleOut.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm_ms.Manager.is_main()
--	manager = openrtm_ms.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = ConsoleOutInit
--	return obj

manager = openrtm_ms.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

