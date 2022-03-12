---------------------------------
--! @file ConfigSample.lua
--! @brief コンフィギュレーションパラメータ変更のRTCサンプル
---------------------------------



local openrtm  = require "openrtm"



-- RTCの仕様をテーブルで定義する
local configsample_spec = {
  ["implementation_id"]="ConfigSample",
  ["type_name"]="ConfigSample",
  ["description"]="Configuration example component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script",
  -- コンフィギュレーションパラメータは[conf.セット名.パラメータ名]=[値]で指定
  ["conf.default.int_param0"]="0",
  ["conf.default.int_param1"]="1",
  ["conf.default.double_param0"]="0.11",
  ["conf.default.double_param1"]="9.9",
  ["conf.default.str_param0"]="hoge",
  ["conf.default.str_param1"]="dara",
  ["conf.default.vector_param0"]="0.0,1.0,2.0,3.0,4.0"}










local ConfigSample = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
ConfigSample.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	-- コンフィギュレーションパラメータをバインドする変数
	obj._int_param0 = {_value=0}
	obj._int_param1 = {_value=1}
	obj._double_param0 = {_value=0.11}
	obj._double_param1 = {_value=9.9}
	obj._str_param0 = {_value="hoge"}
	obj._str_param1 = {_value="dara"}
	obj._vector_param0 = {_value={0.0, 1.0, 2.0, 3.0, 4.0}}
	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()

		-- コンフィギュレーションパラメータを変数にバインドする
		self:bindParameter("int_param0", self._int_param0, "0")
		self:bindParameter("int_param1", self._int_param1, "1")
		self:bindParameter("double_param0", self._double_param0, "0.11")
		self:bindParameter("double_param1", self._double_param1, "9.9")
		self:bindParameter("str_param0", self._str_param0, "hoge")
		self:bindParameter("str_param1", self._str_param1, "dara")
		self:bindParameter("vector_param0", self._vector_param0, "0.0,1.0,2.0,3.0,4.0")


		print("\n Please change configuration values from RTSystemEditor")
		return self._ReturnCode_t.RTC_OK
	end
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	function obj:onExecute(ec_id)
		local c = "                    "
		print("---------------------------------------")
		print(" Active Configuration Set: ", self._configsets:getActiveId(),c)
		print("---------------------------------------")

		print("int_param0:       ", self._int_param0._value, c)
		print("int_param1:       ", self._int_param1._value, c)
		print("double_param0:    ", self._double_param0._value, c)
		print("double_param1:    ", self._double_param1._value, c)
		print("str_param0:       ", self._str_param0._value, c)
		print("str_param1:       ", self._str_param1._value, c)

		for idx, value in ipairs(self._vector_param0._value) do
			print("vector_param0[", idx, "]: ", value, c)
		end

		print("---------------------------------------")

		--print("Updating.... ", ticktack(), c)
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

-- ConfigSampleコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConfigSample.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=configsample_spec})
	manager:registerFactory(prof, ConfigSample.new, openrtm.Factory.Delete)
end

-- ConfigSampleコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	ConfigSample.Init(manager)
	manager:createComponent("ConfigSample")
end

-- ConfigSample.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return ConfigSample
end

