---------------------------------
--! @file ConsoleOut.lua
--! @brief インポート入力のRTCサンプル
---------------------------------





local openrtm  = require "openrtm"


-- RTCの仕様をテーブルで定義する
local consoleout_spec = {
  ["implementation_id"]="ConsoleOut",
  ["type_name"]="ConsoleOut",
  ["description"]="Console output component",
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


local ConnListener = {}

-- コネクタコールバック関数オブジェクト初期化
-- @param name コールバック名
-- @return 関数オブジェクト
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


	-- コネクタコールバック関数の設定
	obj._inIn:addConnectorListener(openrtm.ConnectorListener.ConnectorListenerType.ON_CONNECT,
									ConnListener.new("ON_CONNECT"))
	obj._inIn:addConnectorListener(openrtm.ConnectorListener.ConnectorListenerType.ON_DISCONNECT,
									ConnListener.new("ON_DISCONNECT"))


	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE,
										DataListener.new("ON_BUFFER_WRITE"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_FULL,
										DataListener.new("ON_BUFFER_FULL"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT,
										DataListener.new("ON_BUFFER_WRITE_TIMEOUT"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_OVERWRITE,
										DataListener.new("ON_BUFFER_OVERWRITE"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_BUFFER_READ,
										DataListener.new("ON_BUFFER_READ"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_SEND,
										DataListener.new("ON_SEND"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVED,
										DataListener.new("ON_RECEIVED"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_FULL,
										DataListener.new("ON_RECEIVER_FULL"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT,
										DataListener.new("ON_RECEIVER_TIMEOUT"))
	obj._inIn:addConnectorDataListener(openrtm.ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_ERROR,
										DataListener.new("ON_RECEIVER_ERROR"))


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
	manager:createComponent("ConsoleOut")
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


