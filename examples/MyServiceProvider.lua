---------------------------------
--! @file MyServiceProvider.lua
--! @brief サービスポート(コンシューマ側)のRTCサンプル
---------------------------------





local openrtm  = require "openrtm"

-- RTCの仕様をテーブルで定義する
local myserviceprovider_spec = {
  ["implementation_id"]="MyServiceProvider",
  ["type_name"]="MyServiceProvider",
  ["description"]="MyService Provider Sample component",
  ["version"]="1.0",
  ["vendor"]="Nobuhiko Miyamoto",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}



local seq_print  = {}

-- 配列を標準出力する関数オブジェクト
-- @return 関数オブジェクト
seq_print.new = function()
	local obj = {}
	obj._cnt  = 0
	-- 配列を標準出力する
	-- @param self 自身のオブジェクト
	-- @param val 要素
	local call_func = function(self, val)
		print(self._cnt, ": ", val)
		self._cnt = self._cnt + 1
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


local MyServiceSVC_impl = {}

-- サービスプロバイダ初期化
-- @return サービスプロバイダ
MyServiceSVC_impl.new = function()
	local obj = {}
	obj._echoList = {}
	obj._valueList = {}
	obj._value = 0
	-- echoオペレーション
	-- @param msg 入力文字列
	-- @return msgと同じ文字列
	function obj:echo(msg)
		table.insert(self._echoList, msg)
		print("MyService::echo() was called.")
		for i =1,10 do
			print("Message: ", msg)
			openrtm.Timer.sleep(0.1)
		end
		print("MyService::echo() was finished.")
		return msg
	end
	-- get_echo_historyオペレーション
	-- @return echoリスト
	function obj:get_echo_history()
		print("MyService::get_echo_history() was called.")
		openrtm.CORBA_SeqUtil.for_each(self._echoList, seq_print.new())
		return self._echoList
	end
	-- set_valueオペレーション
	-- @param value 設定値
	function obj:set_value(value)
		table.insert(self._valueList, value)
		self._value = value
		print("MyService::set_value() was called.")
		print("Current value: ", self._value)
	end
	-- get_valueオペレーション
	-- @return 現在の設定値
	function obj:get_value()
		print("MyService::get_value() was called.")
		print("Current value: ", self._value)
		return self._value
	end
	-- get_value_historyオペレーション
	-- @return 値リスト
	function obj:get_value_history()
		print("MyService::get_value_history() was called.")
		openrtm.CORBA_SeqUtil.for_each(self._valueList, seq_print.new())
		return self._valueList
	end

	return obj
end


local MyServiceProvider = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
MyServiceProvider.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})

	-- サービスポート生成
	obj._myServicePort = openrtm.CorbaPort.new("MyService")
	-- プロバイダオブジェクト生成
	obj._myservice0 = MyServiceSVC_impl.new()


	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()
		-- サービスポートにプロバイダオブジェクトを登録
		local fpath = openrtm.StringUtil.dirname(string.sub(debug.getinfo(1)["source"],2))
		local _str = string.gsub(fpath,"\\","/").."idl/MyService.idl"

		self._myServicePort:registerProvider("myservice0", "MyService", self._myservice0, _str,
												"IDL:SimpleService/MyService:1.0")
		-- ポート追加
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end



	return obj
end

-- MyServiceProviderコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
MyServiceProvider.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=myserviceprovider_spec})
	manager:registerFactory(prof, MyServiceProvider.new, openrtm.Factory.Delete)
end

-- MyServiceProviderコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	MyServiceProvider.Init(manager)
	manager:createComponent("MyServiceProvider")
end

-- MyServiceProvider.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return MyServiceProvider
end
