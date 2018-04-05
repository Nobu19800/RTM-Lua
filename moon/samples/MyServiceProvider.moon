---------------------------------
--! @file MyServiceProvider.moon
--! @brief サービスポート(コンシューマ側)のRTCサンプル
---------------------------------





openrtm  = require "openrtm"
openrtm_ms = require "openrtm_ms"


-- RTCの仕様をテーブルで定義する
myserviceprovider_spec = {
  ["implementation_id"]:"MyServiceProvider",
  ["type_name"]:"MyServiceProvider",
  ["description"]:"MyService Provider Sample component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script"}




-- @class seq_print
-- 配列を標準出力する関数オブジェクト
class seq_print
	-- コンストラクタ
	new: () =>
		self._cnt  = 0
	-- 配列を標準出力する
	-- @param val 要素
	__call: (val) =>
		print(self._cnt, ": ", val)
		self._cnt = self._cnt + 1

-- @class MyServiceSVC_impl
-- サービスプロバイダ
class MyServiceSVC_impl
	-- コンストラクタ
	new: () =>
		self._echoList = {}
		self._valueList = {}
		self._value = 0
		
    -- echoオペレーション
    -- @param msg 入力文字列
    -- @return msgと同じ文字列
	echo: (msg) =>
		table.insert(self._echoList, msg)
		print("MyService::echo() was called.")
		oil = require "oil"
		for i =1,10
			print("Message: ", msg)
			openrtm.Timer.sleep(0.1)
		
		print("MyService::echo() was finished.")
		return msg

	-- get_echo_historyオペレーション
    -- @return echoリスト
	get_echo_history: () =>
		CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
		print("MyService::get_echo_history() was called.")
		openrtm.CORBA_SeqUtil.for_each(self._echoList, seq_print())
		return self._echoList

	-- set_valueオペレーション
    -- @param value 設定値
	set_value: (value) =>
		table.insert(self._valueList, value)
		self._value = value
		print("MyService::set_value() was called.")
		print("Current value: ", self._value)


	-- get_valueオペレーション
    -- @return 現在の設定値
	get_value: () =>
		print("MyService::get_value() was called.")
		print("Current value: ", self._value)
		return self._value
    
	-- get_value_historyオペレーション
    -- @return 値リスト
	get_value_history: () =>
		CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
		print("MyService::get_value_history() was called.")
		openrtm.CORBA_SeqUtil.for_each(self._valueList, seq_print)
		return self._valueList
		


-- @class MyServiceProvider
class MyServiceProvider extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		-- サービスポート生成
		self._myServicePort = openrtm_ms.CorbaPort("MyService")
		-- プロバイダオブジェクト生成
		self._myservice0 = MyServiceSVC_impl()

	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- サービスポートにプロバイダオブジェクトを登録
		fpath = openrtm.StringUtil.dirname(debug.getinfo(1)["short_src"])
		_str = string.gsub(fpath,"\\","/").."idl/MyService.idl"
		
		self._myServicePort\registerProvider("myservice0", "MyService", self._myservice0, _str, "IDL:SimpleService/MyService:1.0")
		-- ポート追加
		@addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
		


-- MyServiceProviderコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
MyServiceProviderInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:myserviceprovider_spec})
	manager\registerFactory(prof, MyServiceProvider, openrtm.Factory.Delete)


-- MyServiceProviderコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	MyServiceProviderInit(manager)
	comp = manager\createComponent("MyServiceProvider")


-- MyServiceProvider.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm.Manager.is_main()
--	manager = openrtm.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = MyServiceProviderInit
--	return obj



manager = openrtm.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()
