---------------------------------
--! @file ConsoleIn.lua
--! @brief アウトポート出力のRTCサンプル
---------------------------------



local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local consolein_spec = {
  ["implementation_id"]="ConsoleIn",
  ["type_name"]="ConsoleIn",
  ["description"]="Console input component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}



local DataListener = {}


-- コネクタデータコールバック関数オブジェクト初期化
-- @param name コールバック名
-- @return 関数オブジェクト
DataListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=openrtm.ConnectorListener.ConnectorDataListener.new()})
	obj._name = name
	-- コネクタデータコールバック関数
	-- @param info コネクタ情報
	-- @param cdrdata データ(バイト列)
	-- @return リスナステータス
	function obj:call(info, cdrdata)
		local data = self:__call__(info, cdrdata, "::RTC::TimedLong")
		print("------------------------------")
		print("Listener:       "..self._name)
		print("Profile::name:  "..info.name)
		print("Profile::id:    "..info.id)
		print("Data:           "..data.data)
		print("------------------------------")
		return openrtm.ConnectorListener.ConnectorListenerStatus.NO_CHANGE
	end
	return obj
end


-- コネクタコールバック関数オブジェクト初期化
-- @param name コールバック名
-- @return 関数オブジェクト
local ConnListener = {}
ConnListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=openrtm.ConnectorListener.ConnectorListener.new()})
	obj._name = name
	-- コネクタコールバック関数
	-- @param info コネクタ情報
	-- @return リスナステータス
	function obj:call(info)
		print("------------------------------")
		print("Listener:       "..self._name)
		print("Profile::name:  "..info.name)
		print("Profile::id:    "..info.id)
		print("------------------------------")
		return openrtm.ConnectorListener.ConnectorListenerStatus.NO_CHANGE
	end
	return obj
end


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


	-- コネクタコールバック関数の設定
	obj._outOut:addConnectorListener(openrtm.ConnectorListener.ConnectorListenerType.ON_CONNECT,
									ConnListener.new("ON_CONNECT"))
	obj._outOut:addConnectorListener(openrtm.ConnectorListener.ConnectorListenerType.ON_DISCONNECT,
									ConnListener.new("ON_DISCONNECT"))

	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE,
										DataListener.new("ON_BUFFER_WRITE"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_FULL,
										DataListener.new("ON_BUFFER_FULL"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT,
										DataListener.new("ON_BUFFER_WRITE_TIMEOUT"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_OVERWRITE,
										DataListener.new("ON_BUFFER_OVERWRITE"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_READ,
										DataListener.new("ON_BUFFER_READ"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_SEND,
										DataListener.new("ON_SEND"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVED,
										DataListener.new("ON_RECEIVED"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_FULL,
										DataListener.new("ON_RECEIVER_FULL"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT,
										DataListener.new("ON_RECEIVER_TIMEOUT"))
	obj._outOut:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_ERROR,
										DataListener.new("ON_RECEIVER_ERROR"))

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
	manager:createComponent("ConsoleIn")
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

