---------------------------------
--! @file ConsoleOut.lua
--! @brief インポート入力のRTCサンプル
---------------------------------





local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local consoleout_spec = {
  ["implementation_id"]="ConsoleOut",
  ["type_name"]="ConsoleOut",
  ["description"]="Console input component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}




local ConsoleOut = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
ConsoleOut.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	
	-- データ格納変数
	obj._d_in = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
	-- インポート生成
	obj._inIn = openrtm.InPort.new("in",obj._d_in,"::RTC::TimedLong")
		
	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()
		
		-- ポート追加
		self:addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
	end
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	function obj:onExecute(ec_id)
		-- バッファに新規データがあるかを確認
		if self._inIn:isNew() then
			-- データ読み込み
			local data = self._inIn:read()
			print("Received: ", data)
			print("Received: ", data.data)
			print("TimeStamp: ", data.tm.sec, "[s] ", data.tm.nsec, "[ns]")
		end
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end


-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConsoleOut.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=consoleout_spec})
	manager:registerFactory(prof, ConsoleOut.new, openrtm.Factory.Delete)
end

-- ConsoleInコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	ConsoleOut.Init(manager)
	local comp = manager:createComponent("ConsoleOut")
end

-- ConsoleOut.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return ConsoleOut
end


