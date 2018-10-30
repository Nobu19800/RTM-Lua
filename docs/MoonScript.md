# MoonScriptの利用
## MoonScriptとは？

* [MoonScript](https://moonscript.org/)

Luaトランスレータ言語です。ロゴがダサいのが特徴です。

Luaは言語仕様が小さいため非常に軽量に動作するという特徴がありますが、クラス、配列のようなものを定義したい場合は全てテーブルを駆使してトリッキーなコードを記述する必要があります。

MoonScriptは以下のように、他のオブジェクト指向言語と近い形式でクラスや継承を記述できます。

<pre>
class BaseClass
    new: (v1) =>
        self.v1 = v1

    print_func: =>
        print(self.v1)

class SubClass extends BaseClass
    new: (v1,v2) =>
        super v1
        self.v2 = v2

    print_func: =>
        super!
        self.v2 += 1
        print(self.v2)

test_func = (bc) -> 
    bc\print_func!

obj = SubClass(1,2)
test_func(obj)
test_func(obj)
test_func(obj)

</pre>


見た目はLuaとだいぶ違いますが、このコードをLuaに変換して実行しています。

* Pythonのようなインデント記法
* オブジェクト指向(class)、クラスの継承
* `+=`、`-=`等の演算子
* `->`による関数定義
* オブジェクトの関数を呼び出す場合は、`\`記号で関数名を区切る
* `local`を使わなくてもローカル変数になる


他にもいろいろと違いはあるのですが、それについては以下のサイトなどを参考にしてください。

* [MoonScript 0.5.0 - Language Guide](http://moonscript.org/reference/)


## インストール
### Windows

OpenRTM Lua版にMoonScriptの実行環境も含めてあります。

* [ダウンロード](download.md)



以下のコマンドでモジュール検索パスを設定する必要があります。
パスはOpenRTM Luaを展開したフォルダによって適宜変更してください。

<pre>
> set LUA_PATH=openrtm-lua-0.3.0(x86)\\lua\\?.lua;openrtm-lua-0.3.0(x86)\\moon\\lua\\?.lua
> set LUA_CPATH=openrtm-lua-0.3.0(x86)\\clibs\\?.dll;openrtm-lua-0.3.0(x86)\\moon\\clibs\\?.dll;
</pre>


その後、以下のコマンドでRTCが起動できます。
ファイル名は適宜変更してください。

<pre>
> lua openrtm-lua-0.3.0(x86)/moon/bin/moon test.lua
</pre>



### Ubuntu

LuaRocksでインストールします。

<pre>
$ sudo luarocks install moonscript
</pre>

以下のコマンドで実行します。

<pre>
$ moon test.lua
</pre>


## RTCの作成

サンプルを例に、RTC作成方法を説明します。

### モジュールロード
以下のようにモジュールのロードを行います。

<pre>
openrtm_ms = require "openrtm_ms"
</pre>


###RTCの仕様を定義

以下のようにRTCの仕様を定義したテーブルを作成します。

<pre>
consolein_spec = {
  ["implementation_id"]:"ConsoleIn",
  ["type_name"]:"ConsoleIn",
  ["description"]:"Console input component",
  ["version"]:"1.0",
  ["vendor"]:"Nobuhiko Miyamoto",
  ["category"]:"example",
  ["activity_type"]:"DataFlowComponent",
  ["max_instance"]:"10",
  ["language"]:"MoonScript",
  ["lang_type"]:"script"}
</pre>


### RTCのテーブル作成

RTCをクラスで定義します。

<pre>
class ConsoleIn extends openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		super manager
		(省略)

	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		(省略)


	-- アクティブ状態の時の実行関数
	-- @param ec_id 実行コンテキストのID
	-- @return リターンコード
	onExecute: (ec_id) =>
		(省略)
</pre>


### データポート
アウトポート、インポート、サービスポートをonInitialize関数で追加します。

#### アウトポート

<pre>
	new: (manager) =>
		super manager
		-- データ格納変数
		self._d_out = openrtm_ms.RTCUtil.instantiateDataType("::RTC::TimedLong")
		-- アウトポート生成
		self._outOut = openrtm_ms.OutPort("out",self._d_out,"::RTC::TimedLong")

	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- ポート追加
		@addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK
</pre>


データの出力を行う場合は、`self._d_out`に送信データを格納後、`self._outOut`のwrite関数を実行します。


<pre>
-- 出力データ格納
self._d_out.data = 1
-- データ書き込み
self._outOut\write()
</pre>


#### インポート

<pre>
	new: (manager) =>
		super manager
		-- データ格納変数
		self._d_in = openrtm_ms.RTCUtil.instantiateDataType("::RTC::TimedLong")
		-- インポート生成
		self._inIn = openrtm_ms.InPort("in",self._d_in,"::RTC::TimedLong")


	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- ポート追加
		@addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
</pre>

`openrtm_ms.RTCUtil.instantiateDataType`関数により、データを格納する変数を初期化できます。

`openrtm_ms.OutPort.new("out",self._d_out,"::RTC::TimedLong")`のように、データ型は文字列で指定する必要があります。

入力データを読み込む場合は、`self._inIn`の`read`関数を使用します。


<pre>
-- バッファに新規データがあるかを確認
if self._inIn\isNew()
	-- データ読み込み
	data = self._inIn\read()
	print("Received: ", data)
	print("Received: ", data.data)
</pre>


### サービスポート

#### プロバイダ

プロバイダ側のサービスポートを生成するためには、まずプロバイダのクラスを定義します。

<pre>
class MyServiceSVC_impl
	-- コンストラクタ
	new: () =>
		(省略)
	
	echo: (msg) =>
		(省略)

	get_echo_history: () =>
		(省略)

	set_value: (value) =>
		(省略)

	get_value: () =>
		(省略)
    
	get_value_history: () =>
		(省略)
</pre>


onInitialize関数内でポートの生成、登録を行います。

<pre>
	new: (manager) =>
		super manager
		-- サービスポート生成
		self._myServicePort = openrtm_ms.CorbaPort("MyService")
		-- プロバイダオブジェクト生成
		self._myservice0 = MyServiceSVC_impl()

	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- サービスポートにプロバイダオブジェクトを登録	
		self._myServicePort\registerProvider("myservice0", "MyService", self._myservice0, "idl/MyService.idl", "IDL:SimpleService/MyService:1.0")
		-- ポート追加
		@addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
</pre>

`self._myServicePort\registerProvider("myservice0", "MyService", self._myservice0, "../idl/MyService.idl", "IDL:SimpleService/MyService:1.0")`のように、IDLファイル名、インターフェース名を文字列で指定する必要があります。



### サービスポート

#### コンシューマ

コンシューマ側のサービスポートを追加するには、以下のようにonInitialize関数内でポートの生成、追加を行います。 `self._myServicePort\registerConsumer("myservice0", "MyService", self._myservice0, "../idl/MyService.idl")`のようにIDLファイル名を文字列で指定する必要があります。


<pre>
	new: (manager) =>
		super manager
		-- サービスポート生成
		self._myServicePort = openrtm_ms.CorbaPort("MyService")
		-- コンシューマオブジェクト生成
		self._myservice0 = openrtm_ms.CorbaConsumer("IDL:SimpleService/MyService:1.0")



	-- 初期化時のコールバック関数
	-- @return リターンコード
	onInitialize: =>
		-- サービスポートにコンシューマオブジェクトを登録
		self._myServicePort\registerConsumer("myservice0", "MyService", self._myservice0, "idl/MyService.idl")
		-- ポート追加
		@addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
</pre>

オペレーションを呼び出す場合は、CorbaConsumerの`_ptr`関数でオブジェクトリファレンスを取得して関数を呼び出します。


<pre>
self._myservice0\_ptr()\set_value(val)
</pre>


### コンフィギュレーションパラメータ設定

コンフィグレーションパラメータの設定には、まずRTCの仕様にコンフィグレーションパラメータを追加します。


<pre>
configsample_spec = {
  (省略)
  ["conf.default.int_param0"]:"0",
  ["conf.default.int_param1"]:"1",
  ["conf.default.double_param0"]:"0.11",
  ["conf.default.double_param1"]:"9.9",
  ["conf.default.str_param0"]:"hoge",
  ["conf.default.str_param1"]:"dara",
  ["conf.default.vector_param0"]:"0.0,1.0,2.0,3.0,4.0"}
</pre>

onInitialize関数で変数をバインドします。 値は`_value`というキーに格納されます。

<pre>
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
</pre>


### コールバック定義

onExecuteコールバックなどを定義する場合についても、関数を定義して処理を記述します。

<pre>
	onExecute: (ec_id) =>
		io.write("Please input number: ")
		data = tonumber(io.read())
		-- 出力データ格納
		self._d_out.data = data
		-- 出力データにタイムスタンプ設定
		openrtm_ms.setTimestamp(self._d_out)
		-- データ書き込み
		self._outOut\write()
		return self._ReturnCode_t.RTC_OK
</pre>


### RTC起動の関数定義

以下のようにRTCの登録、生成関数を定義します。

<pre>
-- ConsoleInコンポーネントの生成ファクトリ登録関数
-- @param manager マネージャ
ConsoleInInit = (manager) -> 
	prof = openrtm_ms.Properties({defaults_map:consolein_spec})
	manager\registerFactory(prof, ConsoleIn, openrtm_ms.Factory.Delete)
	

-- ConsoleInコンポーネント生成
-- @param manager マネージャ
MyModuleInit = (manager) -> 
	ConsoleInInit(manager)
	comp = manager\createComponent("ConsoleIn")
</pre>


### マネージャ起動

<pre>
manager = openrtm_ms.Manager
manager\init(arg)
manager\setModuleInitProc(MyModuleInit)
manager\activateManager()
manager\runManager()
</pre>
