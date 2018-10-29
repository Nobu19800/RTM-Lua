# OpenRTM Lua版
## 概要
このページではOpenRTM Lua版について説明します。

![openrtm-lua_logo2](https://user-images.githubusercontent.com/6216077/45281648-68ad6400-b513-11e8-9571-190a34a0198a.png)

* [ソースコード](https://github.com/Nobu19800/RTM-Lua)

### RTミドルウェアとは？
[RTミドルウェア(RTM)](http://www.openrtm.org/openrtm/ja)はソフトウェアモジュールを組み合わせてロボットシステムを構築するための標準規格です。
ソフトウェアモジュールを**RTコンポーネント(RTC)**、ロボットシステムを**RTシステム**と呼びます。
既存のRTミドルウェアの実装として以下のようなものがあります。


|名称|開発元|言語|OS|コメント|
|:---|:---|:---|:---|:---|
|[OpenRTM-aist](http://www.openrtm.org/openrtm/ja)|産総研|C++、Java、Python|Windows、Ubuntu、Debian、Fedora、VxWorks、QNX。Macは公式ではサポートしていない。|もっとも使われているRTM実装(広く使われているとは言っていない)。OpenRTM-aistにはキラーアプリケーションと呼べるものが何もないため今一つ流行っていない。|
|[OpenRTM.NET](http://www.sec.co.jp/robot/openrtmnet/introduction.html)|SEC|.NET(C#、Visual Basic.NET等)|Windows|.NET版RTミドルウェア。更新の頻度が少なく、最近はあまり使っていない。GUI等、上位のアプリケーション向け。|
|[RTM on Android](http://www.sec.co.jp/robot/rtm_on_android/introduction.html)|SEC|Java|Android|Android版RTミドルウェア。使っていない。|
|HRTM|本田R&D|C++|Windows、Ubuntu、VxWorks|FSM4RTCのサポート等。オープンソースではないため外部では使われていない。|
|[OpenRTM-erlang](https://github.com/gbiggs/openrtm-erl)|産総研|Erlang|Linux？|Erlangはあまり使ったことが無いのでよく分かりません。RTCが落ちてもすぐに再起動するのは見ていて面白い。|
|RTMSafety|SEC|C言語|QNX、TOPPERS、ETAS RTA-OS、OSなし|機能安全の認証対応のRTミドルウェア。使ったことない。|
|OPRoS|ETRI|||よく知りません|
|GostaiRTC|GOSTAI、THALES|C++||よく知りません|
|[ReactiveRTM](https://github.com/zoetrope/ReactiveRTM)||.NET|Windows？|使ったことないです。|
|OpenRTM Lua||Lua|Windows、Ubuntu、Debian、Mac OSX、Haiku|このページで説明します。|


### OpenRTM Lua版の特徴

OpenRTM Lua版を使用することにより、既存のアプリケーション上でRTCを起動してC++やPythonのRTCと接続したり、Luaのライブラリを活用したRTCを作成するという事ができます。


OpenRTM Lua版には以下の3つの特徴があります。
#### 軽量
ソフトウェア一式で2MB程度と、他のRTミドルウェアの実装に比べて非常に軽量です。

Lua(1.84MB)>LuaJIT(2.14MB)>>>>Python(7.65MB)>=C++(8.05MB)>>>Java(笑)

<!-- 
動作中のメモリ使用量もPython版と比較して小さくなっています。

以下はConsoleInコンポーネント実行時のメモリ使用量です。

C++(2.1MB)>>>Lua(12.5MB)>Python(15.3MB)>>Java(22.0MB)
-->

#### 他のソフトウェアへの組み込みが可能
Luaスクリプティング機能のあるソフトウェアであれば組み込み可能です。

以下は手元で動作確認したソフトウェアです。

AviUtlやNScripter2上でもRTCを起動できますが、実用性は皆無です。

剛体シミュレータ、ゲーム開発ツール等と相性がいいです。

例：

* V-REP(ロボットシミュレータ), [動画](https://www.youtube.com/watch?v=EaQ2oOxfhSY)
* BizHawk(ゲームエミュレータ), [動画](https://www.youtube.com/watch?v=5dYfUjRzzQ8)
* Laputan Blueprints(剛体シミュレータ), [動画](https://www.youtube.com/watch?v=FS52TlHDKiU)
* AviUtl(動画編集ソフト)
* NScripter2(スクリプトエンジン)
* LÖVE(2Dゲームエンジン), [動画](https://www.youtube.com/watch?v=2xYkcu1eFfM)
* Celestia(3D天体シミュレータ)
* OpenResty(WEBアプリサーバー), [動画1](https://www.youtube.com/watch?v=_-Kw8qv_keo), [動画2](https://www.youtube.com/watch?v=4qxKCBcIIEE)

##### 利用手順

* [V‐REP上で動作するRTCの作成方法](V-REP.md)
* [BizHawk上で動作するRTCの作成方法](BizHawk.md)
* [Laputan Blueprints上で動作するRTCの作成方法](LaputanBlueprints.md)
* [OpenResty上で動作するRTCの作成方法](OpenResty.md)
* [LÖVE上で動作するRTCの作成方法](love2d.md)


#### 高速
JITコンパイラのLuaJIT利用により、C++に匹敵する速度で動作が可能です。

* [実験結果](experiment.md)

### OpenRTM Lua版を使う事による、RTMユーザーにとってのメリット
既存のRTMに対応していないアプリケーションをRTC化することにより、様々なRTシステムが開発可能になります。

またPythonでは処理が遅い、メモリ使用量が大きい部分をLuaJITで動作するRTCで実装することで、スクリプト言語による効率的な開発と高速な処理を両立させることが可能です。

### OpenRTM Lua版を使う事による、非RTMユーザーにとってのメリット
Luaスクリプト機能をサポートしているアプリケーションを様々なデバイス、あるいは他のアプリケーションと接続可能にします。
例えばLaputan Blueprints上の車、飛行機等をLEGO Mindstorms EV3のデバイスで操作するということができます。

* LuaのRTCとPythonのRTCを接続
![system1](https://user-images.githubusercontent.com/6216077/45331814-d5723e00-b5a7-11e8-86bc-2b5cc3569e34.png)

* LuaのRTCとJavaのRTCを接続
![system2](https://user-images.githubusercontent.com/6216077/45331817-d73c0180-b5a7-11e8-8095-877b7bf50899.png)

* LuaのRTCとは別のマシンで起動したC++のRTCと接続
![system4](https://user-images.githubusercontent.com/6216077/45331818-d905c500-b5a7-11e8-9c54-21e7beaa2bb3.png)


## ダウンロード

* [ダウンロード](download.md)

## 動作確認
ダウンロードしたファイルを展開して、バッチファイルを起動するとサンプルコンポーネントが起動します。
サンプルコンポーネントの実行にはインストール不要です。

* ConsoleIn.bat
* ConsoleOut.bat
* SeqIn.bat
* SeqOut.bat
* MyServiceConsumer.bat
* MyServiceProvider.bat
* ConfigSample.bat
* Composite.bat

RTSystemEditor、ネームサーバーはOpenRTM-aistのものを使用してください。

* [OpenRTM-aist](http://www.openrtm.org/openrtm/ja/node/6026)

openrtm.orgが閉鎖している場合は以下のサイトから入手してください。
* [openrtm.github.io](https://openrtm.github.io/)

## インストール方法
以下のように様々なOSに対応しています。
OpenRTM Luaは世界で初めてHaiku OSに対応したロボット用ミドルウェアです。


* [Windows](Windows.md)
* [Windows 10 IoT](windows10iot.md)
* [Haiku](haiku.md)
* [Mac OSX](Mac.md)
* [Ubuntu](Ubuntu.md)
* [Raspbian](Raspbian.md)
* [ev3dev](ev3dev.md)





## RTC作成方法

※OpenRTM-aist 1.2.0のRTC Builderを使う場合は[RTC作成手順](RTC.md)を参考にしてください。

サンプルを例に、RTC作成方法を説明します。



### モジュールロード
以下のようにモジュールのロードを行います。

<pre>
local openrtm  = require "openrtm"
</pre>

### RTCの仕様を定義
以下のようにRTCの仕様を定義したテーブルを作成します。

<pre>
local consolein_spec = {
  ["implementation_id"]="ConsoleIn",
  ["type_name"]="ConsoleIn",
  ["description"]="Console output component",
  ["version"]="1.0",
  ["vendor"]="Vendor Name",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}
</pre>

### RTCのテーブル作成
RTCのテーブルを作成する関数を定義します。

<pre>
local ConsoleIn = {}
ConsoleIn.new = function(manager)
	local obj = {}
	-- RTObjectをメタオブジェクトに設定する
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	-- 初期化時のコールバック関数
	function obj:onInitialize()
	   (省略)
	end
	-- アクティブ状態の時の実行関数
	function obj:onExecute(ec_id)
	   (省略)
	end

	return obj
end
</pre>

### データポート
アウトポート、インポート、サービスポートをonInitialize関数で追加します。

#### アウトポート
<pre>
ConsoleIn.new = function(manager)
	(省略)
	-- データ格納変数
	obj._d_out = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
	-- アウトポート生成
	obj._outOut = openrtm.OutPort.new("out",obj._d_out,"::RTC::TimedLong")
	(省略)
	function obj:onInitialize()
		-- ポート追加
		self:addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

データの出力を行う場合は、`self._d_out`に送信データを格納後、`self._outOut`のwrite関数を実行します。

<pre>
-- 出力データ格納
self._d_out.data = 1
-- データ書き込み
self._outOut:write()
</pre>

#### インポート
<pre>
ConsoleOut.new = function(manager)
	(省略)
	-- データ格納変数
	obj._d_in = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
	-- インポート生成
	obj._inIn = openrtm.InPort.new("in",obj._d_in,"::RTC::TimedLong")
	(省略)
	function obj:onInitialize()
		-- ポート追加
		self:addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

`openrtm.RTCUtil.instantiateDataType`関数により、データを格納する変数を初期化できます。

`openrtm.OutPort.new("out",self._d_out,"::RTC::TimedLong")`のように、データ型は文字列で指定する必要があります。


入力データを読み込む場合は、`self._inIn`のread関数を使用します。


<pre>
-- バッファに新規データがあるかを確認
if self._inIn:isNew() then
	-- データ読み込み
	local data = self._inIn:read()
	print("Received: ", data.data)
end
</pre>

`isNew`関数で新規データの有無を確認できます。

### サービスポート

#### プロバイダ

プロバイダ側のサービスポートを生成するためには、まずプロバイダのテーブルを作成します。

<pre>
local MyServiceSVC_impl = {}
MyServiceSVC_impl.new = function()
	local obj = {}
		(省略)
	function obj:echo(msg)
		(省略)
	end
	function obj:get_echo_history()
		(省略)
	end
	function obj:set_value(value)
		(省略)
	end
	function obj:get_value()
		(省略)
	end
	function obj:get_value_history()
		(省略)
	end

	return obj
end
</pre>

onInitialize関数内でポートの生成、登録を行います。

<pre>
MyServiceProvider.new = function(manager)
	(省略)
	-- サービスポート生成
	obj._myServicePort = openrtm.CorbaPort.new("MyService")
	-- プロバイダオブジェクト生成
	obj._myservice0 = MyServiceSVC_impl.new()
	(省略)
	function obj:onInitialize()
		-- サービスポートにプロバイダオブジェクトを登録
		self._myServicePort:registerProvider("myservice0", "MyService", self._myservice0, "idl/MyService.idl", "IDL:SimpleService/MyService:1.0")
		-- ポート追加
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

`self._myServicePort:registerProvider("myservice0", "MyService", self._myservice0, "../idl/MyService.idl", "IDL:SimpleService/MyService:1.0")`のように、IDLファイル名、インターフェース名を文字列で指定する必要があります。

### サービスポート

#### コンシューマ

コンシューマ側のサービスポートを追加するには、以下のようにonInitialize関数内でポートの生成、追加を行います。
`self._myServicePort:registerConsumer("myservice0", "MyService", self._myservice0, "../idl/MyService.idl")`のようにIDLファイル名を文字列で指定する必要があります。

<pre>
MyServiceConsumer.new = function(manager)
	(省略)
	-- サービスポート生成
	obj._myServicePort = openrtm.CorbaPort.new("MyService")
	-- コンシューマオブジェクト生成
	obj._myservice0 = openrtm.CorbaConsumer.new("IDL:SimpleService/MyService:1.0")
	(省略)
	function obj:onInitialize()
		-- サービスポートにコンシューマオブジェクトを登録
		self._myServicePort:registerConsumer("myservice0", "MyService", self._myservice0, "idl/MyService.idl")
		-- ポート追加
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

オペレーションを呼び出す場合は、CorbaConsumerの_ptr関数でオブジェクトリファレンスを取得して関数を呼び出します。

<pre>
self._myservice0:_ptr():set_value(val)
</pre>

### コンフィギュレーションパラメータ設定
コンフィグレーションパラメータの設定には、まずRTCの仕様定義にコンフィグレーションパラメータを追加します。

<pre>
local configsample_spec = {
  (省略)
  ["conf.default.int_param0"]="0",
  ["conf.default.int_param1"]="1",
  ["conf.default.double_param0"]="0.11",
  ["conf.default.double_param1"]="9.9",
  ["conf.default.str_param0"]="hoge",
  ["conf.default.str_param1"]="dara",
  ["conf.default.vector_param0"]="0.0,1.0,2.0,3.0,4.0"}
</pre>

onInitialize関数で変数をバインドします。
値は`_value`というキーに格納されます。

<pre>
ConfigSample.new = function(manager)
	(省略)
	-- コンフィギュレーションパラメータをバインドする変数
	obj._int_param0 = {_value=0}
	(省略)
	function obj:onInitialize()
		-- コンフィギュレーションパラメータを変数にバインドする
		self._int_param0 = {_value=0}
		(省略)


		self:bindParameter("int_param0", self._int_param0, "0")
		(書略)
		return self._ReturnCode_t.RTC_OK
	end
</pre>


### コールバック定義
onExecuteコールバックなどを定義する場合についても、関数を定義して処理を記述します。

<pre>
	function obj:onExecute(ec_id)
		io.write("Please input number: ")
		local data = tonumber(io.read())
		self._d_out.data = data
		openrtm.OutPort.setTimestamp(self._d_out)
		self._outOut:write()
		return self._ReturnCode_t.RTC_OK
	end
</pre>



### RTC起動の関数定義


以下のようにRTCの登録、生成関数を定義します。

<pre>
ConsoleIn.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=consolein_spec})
	manager:registerFactory(prof, ConsoleIn.new, openrtm.Factory.Delete)
end

local MyModuleInit = function(manager)
	ConsoleIn.Init(manager)
	local comp = manager:createComponent("ConsoleIn")
end
</pre>

### マネージャ起動
以下のようにRTC生成関数を設定してマネージャを起動します。

<pre>
local manager = openrtm.Manager
manager:init(arg)
manager:setModuleInitProc(MyModuleInit)
manager:activateManager()
manager:runManager()
</pre>


## ライセンス
LGPLライセンス

## 依存ライブラリ

### Lua 5.1
* [Lua-5.1](https://www.lua.org/)(MITライセンス)
* [OiL-0.5](https://webserver2.tecgraf.puc-rio.br/~maia/oil/index.html)(MITライセンス)
* [LuaIDL](https://github.com/LuaDist/luaidl)(MITライセンス)
* [LOOP](https://github.com/LuaDist/loop)(MITライセンス)
* [LuaSocket](https://github.com/diegonehab/luasocket)(MITライセンス)



### Lua 5.2
* [Lua-5.2](https://www.lua.org/)(MITライセンス)
* [OiL-0.7](https://github.com/renatomaia/oil)(MITライセンス)
* [loop-collections](https://github.com/renatomaia/loop-collections)(MITライセンス)
* [LOOP](https://github.com/renatomaia/loop)(MITライセンス)
* [cothread](https://github.com/renatomaia/cothread)(MITライセンス)
* [LuaSocket](https://github.com/renatomaia/luasocket)(MITライセンス)
* [loop-compdev](https://github.com/renatomaia/loop-compdev)(MITライセンス)
* [luatuple](https://github.com/renatomaia/luatuple)(MITライセンス)
* [loop-serializing](https://github.com/renatomaia/loop-serializing)(MITライセンス)
* [loop-parsing](https://github.com/renatomaia/loop-parsing)(MITライセンス)
* [loop-objects](https://github.com/renatomaia/loop-objects)(MITライセンス)
* [loop-debugging](https://github.com/renatomaia/loop-debugging)(MITライセンス)
* [struct](https://luarocks.org/modules/luarocks/struct)(MITライセンス)


### Lua 5.1、5.2共通
* [LuaLogging](https://github.com/Neopallium/lualogging)(MITライセンス)
* [MoonScript](http://moonscript.org)(MITライセンス)
* [LPeg](https://luarocks.org/modules/gvvaughan/lpeg)(MITライセンス)
* [argparse](https://github.com/mpeterv/argparse)(MITライセンス)

### Ver. 0.3以降
* [uuid](https://github.com/Tieske/uuid)(Apache 2.0)

### Ver. 0.2以前
* [LUA-RFC-4122-UUID-Generator](https://github.com/tcjennings/LUA-RFC-4122-UUID-Generator)(MITライセンス)




## 他のRTM実装とデータポート通信する場合について
OpenRTM-aist 1.0系付属のDataPort.idlはOiLでは読み込めないため、OpenRTM-aist 2.0付属のDataPort.idlが必要になります。
現状、OpenRTM-aist 1.2以前、およびOpenRTM.NETと通信する手段はありませんが、開発中のOpenRTM-aist 2.0とは通信できます。

Python版のOpenRTM-aist 2.0(開発中)のインストール方法を説明します。

まずOpenRTM-aistをインストーラーでインストールしてください。
次に[TortoiseSVN](https://ja.osdn.net/projects/tortoisesvn/)等で以下からOpenRTM-aist Python版 2.0のソースコードを入手します。

* http://svn.openrtm.org/OpenRTM-aist-Python/trunk/OpenRTM-aist-Python/

setup.pyの以下の部分を変更します。

<pre>
#pkg_data_files_win32 = [("Scripts", ['OpenRTM_aist/utils/rtcd/rtcd_python.exe'])]
pkg_data_files_win32 = []
</pre>

OpenRTM-aist Python版 2.0のソースコードのディレクトリに移動して以下のコマンドを実行すると、インストーラーでインストールしたOpenRTM-aistを上書きします。※パスに日本語が含まれている場合に失敗することがあります。その場合はディレクトリを変更してコマンドを実行してください。

<pre>
python setup.py build
python setup.py install
</pre>

## LuaJITの利用

* [LuaJITの利用](LuaJIT.md)

## MoonScriptの利用

* [MoonScriptの利用](MoonScript.md)

## 開発メモ

* [開発メモ](memo.md)

## リリースノート

* [リリースノート](releasenote.md)

## 次期リリースでの追加、修正項目

* [次期リリースでの追加、修正項目](nextrelease.md)

## 単体テストの実行手順


* [単体テストの実行手順](unittest.md)
* [解析結果](report.html)

## その他

* [EV3での利用方法](EV3.md)
