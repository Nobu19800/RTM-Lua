---------------------------------
--! @file ConfigSample.moon
--! @brief コンフィギュレーションパラメータ変更のRTCサンプル
---------------------------------




openrtm_ms = require "openrtm_ms"


-- RTCの仕様をテーブルで定義する
configsample_spec = {
  ["implementation_id"]:"ConfigSample",
  ["type_name"]:"ConfigSample",
  ["description"]:"Configuration example component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script",
  -- コンフィギュレーションパラメータは[conf.セット名.パラメータ名]=[値]で指定
  ["conf.default.int_param0"]:"0",
  ["conf.default.int_param1"]:"1",
  ["conf.default.double_param0"]:"0.11",
  ["conf.default.double_param1"]:"9.9",
  ["conf.default.str_param0"]:"hoge",
  ["conf.default.str_param1"]:"dara",
  ["conf.default.vector_param0"]:"0.0,1.0,2.0,3.0,4.0"}





-- @class ConfigSample
class ConfigSample extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		self._int_param0 = {_value:0}
		self._int_param1 = {_value:1}
		self._double_param0 = {_value:0.11}
		self._double_param1 = {_value:9.9}
		self._str_param0 = {_value:"hoge"}
		self._str_param1 = {_value:"dara"}
		self._vector_param0 = {_value:{0.0, 1.0, 2.0, 3.0, 4.0}}
		
	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- コンフィギュレーションパラメータを変数にバインドする
		@bindParameter("int_param0", self._int_param0, "0")
		@bindParameter("int_param1", self._int_param1, "1")
		@bindParameter("double_param0", self._double_param0, "0.11")
		@bindParameter("double_param1", self._double_param1, "9.9")
		@bindParameter("str_param0", self._str_param0, "hoge")
		@bindParameter("str_param1", self._str_param1, "dara")
		@bindParameter("vector_param0", self._vector_param0, "0.0,1.0,2.0,3.0,4.0")


		print("\n Please change configuration values from RTSystemEditor")
		return self._ReturnCode_t.RTC_OK
		
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		c = "                    "
		print("---------------------------------------")
		print(" Active Configuration Set: ", self._configsets\getActiveId(),c)
		print("---------------------------------------")

		print("int_param0:       ", self._int_param0._value, c)
		print("int_param1:       ", self._int_param1._value, c)
		print("double_param0:    ", self._double_param0._value, c)
		print("double_param1:    ", self._double_param1._value, c)
		print("str_param0:       ", self._str_param0._value, c)
		print("str_param1:       ", self._str_param1._value, c)

		for idx, value in ipairs(self._vector_param0._value)
			print("vector_param0[", idx, "]: ", value, c)

		print("---------------------------------------")

		--print("Updating.... ", ticktack(), c)
		return self._ReturnCode_t.RTC_OK






-- ConfigSampleコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConfigSampleInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:configsample_spec})
	manager\registerFactory(prof, ConfigSample, openrtm_ms.Factory.Delete)


-- ConfigSampleコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	ConfigSampleInit(manager)
	comp = manager\createComponent("ConfigSample")
	

-- ConfigSample.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
--if openrtm_ms.Manager.is_main()
--	manager = openrtm_ms.Manager
--	manager\init(arg)
--	manager\setModuleInitProc(MyModuleInit)
--	manager\activateManager()
--	manager\runManager()
--else
--	obj = {}
--	obj.Init = ConfigSampleInit
--	return obj

manager = openrtm_ms.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()


