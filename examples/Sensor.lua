---------------------------------
--! @file Sensor.lua
--! @brief 複合コンポーネントのサンプル
---------------------------------



local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local sensor_spec = {
  ["implementation_id"]="Sensor",
  ["type_name"]="Sensor",
  ["description"]="Sensor component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}







local Sensor = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
Sensor.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})


	-- データ格納変数
	obj._d_out = {tm={sec=0,nsec=0},data=0}
	-- アウトポート生成
	obj._outOut = openrtm.OutPort.new("out",obj._d_out,"::RTC::TimedLong")
	-- データ格納変数
	obj._d_in = {tm={sec=0,nsec=0},data=0}
	-- インポート生成
	obj._inIn = openrtm.InPort.new("in",obj._d_in,"::RTC::TimedLong")



	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()
		-- ポート追加
		self:addOutPort("out",self._outOut)
		self:addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
	end
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	function obj:onExecute(ec_id)
		--print("Sensor")
		if self._inIn:isNew() then
			local data = self._inIn:read()
			print("Sensor Received data: ", data.data)
			self._d_out.data = data.data *2
			self._outOut:write()
		end
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

-- Sensorコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
Sensor.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=sensor_spec})
	manager:registerFactory(prof, Sensor.new, openrtm.Factory.Delete)
end

-- Sensorコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	Sensor.Init(manager)
	manager:createComponent("Sensor")
end


-- Sensor.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)

	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return Sensor
end

