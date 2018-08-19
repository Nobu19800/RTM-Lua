---------------------------------
--! @file ConsoleIn.moon
--! @brief アウトポート出力のRTCサンプル
---------------------------------



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



-- @class DataListener
class DataListener extends openrtm_ms.ConnectorDataListener
	-- コンストラクタ
	-- @param name コールバック名
	new: (name) =>
		super!
		self._name = name
	-- コールバック関数
	-- @param info コネクタ情報
	-- @param cdrdata データ(バイト列)
	-- @return リスナステータス
	call: (info, cdrdata) =>
		data = @__call__(info, cdrdata, "::RTC::TimedLong")
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
		super!
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



-- @class ConsoleIn
class ConsoleIn extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		-- データ格納変数
		self._d_out = openrtm_ms.RTCUtil.instantiateDataType("::RTC::TimedLong")
		-- アウトポート生成
		self._outOut = openrtm_ms.OutPort("out",self._d_out,"::RTC::TimedLong")


		-- コネクタコールバック関数の設定
		self._outOut\addConnectorListener(openrtm_ms.ConnectorListenerType.ON_CONNECT,
									ConnListener("ON_CONNECT"))
		self._outOut\addConnectorListener(openrtm_ms.ConnectorListenerType.ON_DISCONNECT,
									ConnListener("ON_DISCONNECT"))



		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_WRITE,
									DataListener("ON_BUFFER_WRITE"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_FULL,
									DataListener("ON_BUFFER_FULL"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT,
									DataListener("ON_BUFFER_WRITE_TIMEOUT"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_OVERWRITE,
									DataListener("ON_BUFFER_OVERWRITE"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_BUFFER_READ,
									DataListener("ON_BUFFER_READ"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_SEND,
									DataListener("ON_SEND"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVED,
									DataListener("ON_RECEIVED"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVER_FULL,
									DataListener("ON_RECEIVER_FULL"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT,
									DataListener("ON_RECEIVER_TIMEOUT"))
		self._outOut\addConnectorDataListener(openrtm_ms.ConnectorDataListenerType.ON_RECEIVER_ERROR,
									DataListener("ON_RECEIVER_ERROR"))

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
		openrtm_ms.setTimestamp(self._d_out)
		-- データ書き込み
		self._outOut\write()
		return self._ReturnCode_t.RTC_OK
	
	

-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConsoleInInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:consolein_spec})
	manager\registerFactory(prof, ConsoleIn, openrtm_ms.Factory.Delete)
	

-- ConsoleInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	ConsoleInInit(manager)
	comp = manager\createComponent("ConsoleIn")



-- ConsoleIn.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm_ms.Manager.is_main()
--	manager = openrtm_ms.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = ConsoleInInit
--	return obj

manager = openrtm_ms.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

