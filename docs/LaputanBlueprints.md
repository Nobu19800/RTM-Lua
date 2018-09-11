# Laputan Blueprints上で動作するRTCの作成方法
## 概要
このページでは物理シミュレータLaputan Blueprints上で動作する上で動作するRTCを作成して、以下のようにPython版サンプルコンポーネントのジョイスティックコンポーネントと接続して車体を操作するシステムの作成を行います。

* [動画](https://www.youtube.com/watch?v=FS52TlHDKiU)

## Laputan Blueprintsの入手
以下からLaputan Blueprintsを入手してください。

* [Laputan Blueprints](https://sites.google.com/site/laputanblueprints2016/do)

## Laputan BlueprintsにOpenRTM Lua版をインストール
Laputan Blueprintsを展開したフォルダにOpenRTM Lua版の各ファイルをコピーします。

以下から32bit用のOpenRTM Lua版ファイル一式(OpenRTM Lua 0.3.1 Lua5.1 32bit)をダウンロードしてください。

* [ダウンロード](download.md)

OpenRTM Lua版からLaputan Blueprintsにファイルをコピーします。

`openrtm-lua-x.y.z(x86)-lua5.1\lua\`以下のファイルの内`idl`フォルダ以外を全て`Laputan\Laputan Files\LuaModules\`以下にコピーしてください。
ファイルを上書きするかどうか聞かれますが、構わずコピーしてください。

![openrtmlua260](https://user-images.githubusercontent.com/6216077/37710287-86942c6a-2d50-11e8-8b74-a3ba3fadbaa8.png)



`idl`フォルダは`Laputan\Laputan Files\`以下にコピーしてください。

![openrtmlua290](https://user-images.githubusercontent.com/6216077/37710299-8fe0648c-2d50-11e8-90ac-0e018d95076f.png)



次に`openrtm-lua-x.y.z(x86)-lua5.1\clibs\`以下のファイルを全て`Laputan\Laputan Files\`以下にコピーしてください。

![openrtmlua270](https://user-images.githubusercontent.com/6216077/37710296-8d201ff8-2d50-11e8-9e48-4c41aec1d5de.png)


## Laputan Blueprintsの設定
`LB.exe`を実行してLaputan Blueprintsを起動してください。
`Help`->`Preference`を選択して設定ウインドウを開いてください。

![openrtmlua140](https://user-images.githubusercontent.com/6216077/37710208-4c02cef8-2d50-11e8-924a-3e5454fecbb3.png)


`Lua IO Lib`、`Lua OS Lib`のチェックボックスをオンにしてください。

![openrtmlua150](https://user-images.githubusercontent.com/6216077/37710209-4df6c296-2d50-11e8-89c8-720c434cadd3.png)


## RTC作成
RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。

### 基本プロファイル

|||
|---|---|
|モジュール名|LBSample|

### アクティビティ

`onExecute`を有効にしてください。

### インポート

|||
|---|---|
|ポート名|in|
|データ型|TimedFloatSeq|

### LBSample.luaの編集

`LBSample.lua`のonExecute関数を編集します。

<pre>
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			lb.controls.Accel.setvalue(data.data[2]/3)
			lb.controls.Handle.setvalue(-data.data[1]/2)
		end
		return self._ReturnCode_t.RTC_OK
	end
</pre>

InPortのデータを読み込んで、車のアクセル、ステアリングに入力しています。

編集した`LBSample.lua`を`Laputan\Laputan Files\LuaModules\`以下にコピーしてください。
![openrtmlua370](https://user-images.githubusercontent.com/6216077/37711256-7b70a36a-2d53-11e8-8780-568e7266ae59.png)

Laputan Blueprintsの関数については情報が少ないのですが、以下のサイトなどに少し情報があるみたいです。

* [RigidChips Wiki](https://www4.atwiki.jp/rigidchips/pages/47.html)


## LB-Dataファイルの編集
Laputan Blueprintsのサンプル`car.lbd`を編集します。
`Open bluprint`ボタンを押してファイルを選択してください。
![openrtmlua160](https://user-images.githubusercontent.com/6216077/37710218-541e0b66-2d50-11e8-802d-114a82b43e9b.png)

`car.lbd`を開いたら、`Edit Controls`ボタンを押して`Controls`ウインドウを開いてください。
![openrtmlua170](https://user-images.githubusercontent.com/6216077/37710221-567b8dfc-2d50-11e8-9d75-68941dc8fe0a.png)

右側に表示された`Controls`ウインドウの下の赤枠のタブを開いてボタンをクリックしてください。
![openrtmlua180](https://user-images.githubusercontent.com/6216077/37710237-650571da-2d50-11e8-8847-2509b2b7ee13.png)

`Lubricator`ウインドウに表示されたソースコードを編集します。
![openrtmlua190](https://user-images.githubusercontent.com/6216077/37710256-710a545a-2d50-11e8-8ca4-95b5828f7ce0.png)

以下のコードを上書きしてください。

<pre>
function OnFrame()
	lb.drawtext(32,32,"Welcome Laputan Blueprints world!")
	lb.drawtext(32,52,string.format("FPS=%.2f",lb.getfps()))
	lb.drawtext(32,72,string.format("OBJ=%d",lb.getobjectcount()))

	local openrtm = require "openrtm"
	local mgr = openrtm.Manager
	mgr:step()
	local comp = mgr:getComponent("LBSample0")
	local ec = comp:get_owned_contexts()[1]
	ec:tick()
end
function OnInit()
	lb.print(lb.gettime(),"Init")
	local openrtm = require "openrtm"

	local mgr = openrtm.Manager
	mgr:init({"-o","exec_cxt.periodic.type:OpenHRPExecutionContext","-o","manager.components.precreate:LBSample","-o","manager.components.preconnect:LBSample0.in?port=rtcname://localhost/TkJoyStick0.pos","-o","manager.components.preactivation:LBSample0,rtcname://localhost/TkJoyStick0"})
	mgr:activateManager()
	mgr:runManager(true)
end
function OnReset()
	lb.print(lb.gettime(),"Reset")
	local openrtm = require "openrtm"
	local mgr = openrtm.Manager
	mgr:createShutdownThread(1)
	mgr:unload("LBSample")
	mgr:unregisterFactory("LBSample")
end
</pre>


基本は上記のコードの`LBSample`の部分を変更すると、他のRTCにも適用できるようになります。

`mgr:init`関数の引数について説明します。
`-o`オプションの後にパラメータを指定します。

* `"-o","exec_cxt.periodic.type:OpenHRPExecutionContext"`

実行コンテキストの指定をしています。
Laputan Blueprints上ではRTCをステップ実行したいので`OpenHRPExecutionContext`という実行コンテキストを指定します。

<!--
* `"-o","manager.modules.load_path:LuaModules"`

モジュールを探索するパスを指定します。
`LBSample.lua`の存在するディレクトリを指定します。
-->

* `"-o","manager.components.precreate:LBSample"`

起動時に生成するRTC名を指定します。

* `"-o","manager.components.preconnect:LBSample0.in?port=rtcname://localhost/TkJoyStick0.pos"`

起動時に接続するポートを指定します。
この場合は`LBSample0`というRTCの`in`というデータポートを、`TkJoyStick0`というRTCの`pos`というポートに接続します。

ただし、`TkJoyStick0`は別プロセスで起動しているため、`rtcname形式`による指定が必要になります。
`rtcname形式`はネームサーバーからRTCを取得する方法です。`rtcname://アドレス/RTC名.ポート名`で指定します。


* `"-o","manager.components.preactivation:LBSample0,rtcname://localhost/TkJoyStick0"`

起動時にアクティブ化するRTCを指定します。


念のために`Save blueprint`ボタンを押してファイルを保存してください。
![openrtmlua200](https://user-images.githubusercontent.com/6216077/37710263-75e015f0-2d50-11e8-9bb0-362cf3cdb8c0.png)






## 動作確認
### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](download.md)

### RTC起動

LB上で`Experiment/Design`ボタンを押すとシミュレーションを開始します。
![openrtmlua210](https://user-images.githubusercontent.com/6216077/37710266-77d3511a-2d50-11e8-9953-a0d834e8e9ac.png)



### RTSystem作成

起動時にポートの接続、アクティブ化をオプションで設定しているため、RT System Editorでの操作は不要ですが、念のためRT System Editorによる操作手順も説明します。

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。

![openrtmlua460](https://user-images.githubusercontent.com/6216077/38156933-15829f1a-34bd-11e8-975f-d1e4f1b712b0.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![openrtmlua470](https://user-images.githubusercontent.com/6216077/38156959-3f7e86b2-34bd-11e8-8089-b8d87333e91f.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。

![openrtmlua480](https://user-images.githubusercontent.com/6216077/38157017-b6837524-34bd-11e8-8302-91c352f2e786.png)

`TkJoyStick0`の`pos`のOutPortを、`LBSample0`の`in`のInPortにドラックアンドドロップしてください。
これで通信ができるようになります。

![openrtmlua450](https://user-images.githubusercontent.com/6216077/38157072-3f5c6c02-34be-11e8-863a-d15396f7a821.png)

`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるため操作ができるようになります。

![openrtmlua490](https://user-images.githubusercontent.com/6216077/38157104-a941a66e-34be-11e8-874f-e97ef109481a.png)
