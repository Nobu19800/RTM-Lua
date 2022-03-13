---------------------------------
--! @file MyServiceConsumer.moon
--! @brief サービスポート(コンシューマ側)のRTCサンプル
---------------------------------






openrtm_ms = require "openrtm_ms"

-- RTCの仕様をテーブルで定義する
myserviceconsumer_spec = {
  ["implementation_id"]:"MyServiceConsumer",
  ["type_name"]:"MyServiceConsumer",
  ["description"]:"MyService Consumer Sample component",
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
		self._cnt += 1




-- @class MyServiceConsumer
class MyServiceConsumer extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		-- サービスポート生成
		self._myServicePort = openrtm_ms.CorbaPort("MyService")
		-- コンシューマオブジェクト生成
		self._myservice0 = openrtm_ms.CorbaConsumer("IDL:SimpleService/MyService:1.0")



	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- サービスポートにコンシューマオブジェクトを登録
		fpath = openrtm_ms.StringUtil.dirname(debug.getinfo(1)["short_src"])
		_str = string.gsub(fpath,"\\","/").."idl/MyService.idl"

		self._myServicePort\registerConsumer("myservice0", "MyService", self._myservice0, _str)
		-- ポート追加
		@addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK



	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		print("\n")
		print("Command list: ")
		print(" echo [msg]       : echo message.")
		print(" set_value [value]: set value.")
		print(" get_value        : get current value.")
		print(" get_echo_history : get input messsage history.")
		print(" get_value_history: get input value history.")
		io.write("> ")
		args = io.read()


		oil = require "oil"

		argv = openrtm_ms.StringUtil.split(args, " ")
		argv[#argv] = openrtm_ms.StringUtil.eraseTailBlank(argv[#argv])

		
		func = ->
			if argv[1] == "echo" and #argv > 1
				-- echoオペレーション実行
				print("echo() finished: ", self._myservice0\_ptr()\echo(argv[2]))
			elseif argv[1] == "set_value" and #argv > 1 then
				val = tonumber(argv[2])
				-- set_valueオペレーション実行
				self._myservice0\_ptr()\set_value(val)
				print("Set remote value: ", val)
			elseif argv[1] == "get_value"
				-- get_valueオペレーション実行
				retval = self._myservice0\_ptr()\get_value()
				print("Current remote value: ", retval)
			elseif argv[1] == "get_echo_history"
				-- get_echo_historyオペレーション実行
				openrtm_ms.CORBA_SeqUtil.for_each(self._myservice0\_ptr()\get_echo_history(),
											  seq_print())
			elseif argv[1] == "get_value_history"
				-- get_value_historyオペレーション実行
				openrtm_ms.CORBA_SeqUtil.for_each(self._myservice0\_ptr()\get_value_history(),
											  seq_print())
			else
				print("Invalid command or argument(s).")
				
				
		success, exception = oil.pcall(func)

			
		if not success
			print(exception)

		return self._ReturnCode_t.RTC_OK





-- MyServiceConsumerコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
MyServiceConsumerInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:myserviceconsumer_spec})
	manager\registerFactory(prof, MyServiceConsumer, openrtm_ms.Factory.Delete)


-- MyServiceConsumerコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	MyServiceConsumerInit(manager)
	comp = manager\createComponent("MyServiceConsumer")


-- MyServiceConsumer.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm_ms.Manager.is_main()
--	manager = openrtm_ms.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = MyServiceConsumerInit
--	return obj


manager = openrtm_ms.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()

