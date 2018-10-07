---------------------------------
--! @file Motor.lua
--! @brief 複合コンポーネントのサンプル
---------------------------------



local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local motor_spec = {
  ["implementation_id"]="Motor",
  ["type_name"]="Motor",
  ["description"]="Motor component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}







local Motor = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
Motor.new = function(manager)
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
		--print("Motor")
		if self._inIn:isNew() then
    		local data = self._inIn:read()
    		print("Motor Received data: ", data.data)
    		self._d_out.data = data.data *2
			self._outOut:write()
		end
		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

-- Motorコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
Motor.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=motor_spec})
	manager:registerFactory(prof, Motor.new, openrtm.Factory.Delete)
end

-- Motorコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	Motor.Init(manager)
	local comp = manager:createComponent("Motor")
end


-- Motor.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return Motor
end

