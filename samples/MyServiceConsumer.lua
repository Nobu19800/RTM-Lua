---------------------------------
--! @file MyServiceConsumer.lua
--! @brief サービスポート(コンシューマ側)のRTCサンプル
---------------------------------

package.path = "..\\lua\\?.lua"
package.cpath = "..\\clibs\\?.dll;"



local openrtm  = require "openrtm"

-- RTCの仕様をテーブルで定義する
local myserviceconsumer_spec = {
  ["implementation_id"]="MyServiceConsumer",
  ["type_name"]="MyServiceConsumer",
  ["description"]="MyService Consumer Sample component",
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


local MyServiceConsumer = {}

-- RTCの初期化
-- @param manager マネージャ
-- @return RTC
MyServiceConsumer.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	
	-- サービスポート生成
	obj._myServicePort = openrtm.CorbaPort.new("MyService")
	-- コンシューマオブジェクト生成
	obj._myservice0 = openrtm.CorbaConsumer.new("IDL:SimpleService/MyService:1.0")
	-- 初期化時のコールバック関数
	-- @return リターンコード
	function obj:onInitialize()
		-- サービスポートにコンシューマオブジェクトを登録
		self._myServicePort:registerConsumer("myservice0", "MyService", self._myservice0, "../idl/MyService.idl")
		-- ポート追加
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end
	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	function obj:onExecute(ec_id)
		print("\n")
		print("Command list: ")
		print(" echo [msg]       : echo message.")
		print(" set_value [value]: set value.")
		print(" get_value        : get current value.")
		print(" get_echo_history : get input messsage history.")
		print(" get_value_history: get input value history.")
		io.write("> ")
		local args = io.read()


		local oil = require "oil"

		local argv = openrtm.StringUtil.split(args, " ")
		argv[#argv] = openrtm.StringUtil.eraseTailBlank(argv[#argv])

		local success, exception = oil.pcall(
			function()
				if argv[1] == "echo" and table.maxn(argv) > 1 then
					-- echoオペレーション実行
					print("echo() finished: ", self._myservice0:_ptr():echo(argv[2]))
				elseif argv[1] == "set_value" and table.maxn(argv) > 1 then
					local val = tonumber(argv[2])
					-- set_valueオペレーション実行
					self._myservice0:_ptr():set_value(val)
					print("Set remote value: ", val)
				elseif argv[1] == "get_value" then
					-- get_valueオペレーション実行
					local retval = self._myservice0:_ptr():get_value()
					print("Current remote value: ", retval)
				elseif argv[1] == "get_echo_history" then
					-- get_echo_historyオペレーション実行
					openrtm.CORBA_SeqUtil.for_each(self._myservice0:_ptr():get_echo_history(),
												  seq_print.new())
				elseif argv[1] == "get_value_history" then
					-- get_value_historyオペレーション実行
					openrtm.CORBA_SeqUtil.for_each(self._myservice0._ptr().get_value_history(),
												  seq_print.new())
				else
					print("Invalid command or argument(s).")
				end
			end)
		if not success then
			print(exception)
		end




		return self._ReturnCode_t.RTC_OK
	end

	return obj
end

-- MyServiceConsumerコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
MyServiceConsumer.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=myserviceconsumer_spec})
	manager:registerFactory(prof, MyServiceConsumer.new, openrtm.Factory.Delete)
end

-- MyServiceConsumerコンポーネント生成
-- @param manager マネージャ
local MyModuleInit = function(manager)
	MyServiceConsumer.Init(manager)
	local comp = manager:createComponent("MyServiceConsumer")
end

-- MyServiceConsumer.luaを直接実行している場合はマネージャの起動を行う
-- ロードして実行している場合はテーブルを返す
if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
else
	return MyServiceConsumer
end


