---------------------------------
--! @file ConsoleIn.lua
--! @brief アウトポート出力のRTCサンプル
---------------------------------



local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local consolein_spec = {
  ["implementation_id"]="ConsoleIn",
  ["type_name"]="ConsoleIn",
  ["description"]="Console output component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}




local ConsoleIn = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
ConsoleIn.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	-- データ格納変数
	obj._d_out = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
	-- アウトポート生成
	obj._outOut = openrtm.OutPort.new("out",obj._d_out,"::RTC::TimedLong")
	
	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()
		-- ポート追加
		self:addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK
	end
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	function obj:onExecute(ec_id)
		io.write("Please input number: ")
		local data = tonumber(io.read())
		-- 出力データ格納
		self._d_out.data = data
		-- 出力データにタイムスタンプ設定
		openrtm.OutPort.setTimestamp(self._d_out)
		-- データ書き込み
		self._outOut:write()
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConsoleIn.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=consolein_spec})
	manager:registerFactory(prof, ConsoleIn.new, openrtm.Factory.Delete)
end

-- ConsoleInコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	ConsoleIn.Init(manager)
	local comp = manager:createComponent("ConsoleIn")
end


-- ConsoleIn.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return ConsoleIn
end

