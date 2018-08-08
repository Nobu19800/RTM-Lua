# Laputan Blueprints上で動作するRTCの作成方法
## 概要
このページではゲームエミュレータBizHawk上で動作するRTCを作成して、以下のようにPython版サンプルコンポーネントのジョイスティックコンポーネントと接続してゲームを操作するシステムの作成を行います。

* https://www.youtube.com/watch?v=5dYfUjRzzQ8

## BizHawkの入手
以下からBizHawk 1.12.2をダウンロードして適当な場所に展開してください。

* https://github.com/TASVideos/BizHawk/releases/tag/1.12.2

※1.13.0以降のバージョンでは何故か動作できていません。

## BizHawkにOpenRTM Lua版をインストール
BizHawkを展開したフォルダにOpenRTM Lua版の各ファイルをコピーします。

以下から32bit用のOpenRTM Lua版ファイル一式(OpenRTM Lua x.y.z 32bit)をダウンロードしてください。

* [ダウンロード](download.md)

OpenRTM Lua版からBizHawkにファイルをコピーします。

`openrtm-lua-x.y.z(x86)\lua\`以下のファイルを全て`BizHawk-1.12.2\Lua\`以下にコピーしてください。

![openrtmlua220](https://user-images.githubusercontent.com/6216077/37710270-7aa40934-2d50-11e8-9f3c-0c654bc6bab6.png)


次に`openrtm-lua-x.y.z(x86)\clibs\`以下のファイルを全て`BizHawk-1.12.2\`以下にコピーしてください。

![openrtmlua230](https://user-images.githubusercontent.com/6216077/37710277-7d9883ae-2d50-11e8-953e-b110d209d5a4.png)


## RTC作成
RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。

### 基本プロファイル
|||
|---|---|
|モジュール名|BizHawkSample|

### アクティビティ

`onExecute`を有効にしてください。

### インポート
|||
|---|---|
|ポート名|in|
|データ型|RTC::TimedFloatSeq|

### BizHawkSample.luaの編集

`BizHawkSample.lua`の`onExecute`関数を以下のように編集してください。

<pre>
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			local buttons = {["Left"]=false, ["Right"]=false, ["A"]=false}
			if data.data[1] > 20 then
				buttons["Right"] = true
			elseif data.data[1] < -20 then
				buttons["Left"] = true
			end
			if data.data[2] > 70 then
				buttons["A"] = true
			end
			joypad.set(buttons, 1)
		end
		emu.frameadvance()
		return self._ReturnCode_t.RTC_OK
	end
</pre>

InPortの入力データを、コントローラーの入力に設定しています。
`emu.frameadvance()`でフレームを更新しています。


編集した`BizHawkSample.lua`を`BizHawk-1.12.2\Lua`にコピーしてください。

![openrtmlua240](https://user-images.githubusercontent.com/6216077/37710279-80d5d2ec-2d50-11e8-9fd7-e35613d4081e.png)



BizHawkの関数については、以下のページに説明があります。

- [TasVideos](http://tasvideos.org/Bizhawk/LuaFunctions.html)


## ROMの入手
BizHawkで動作可能なROMイメージを入手してください。
市販のゲームソフトのROMイメージのダウンロードは違法のため、以下のようなフリーのROMイメージを入手してください。

* [TkShoot 1.00(NES研究室)](http://hp.vector.co.jp/authors/VA042397/nes/games.html#TKSHOOT)

## 動作確認
### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](download.md)

### BizHawkの起動
`EmuHawk.exe`をダブルクリックして実行してください。

![openrtmlua70](https://user-images.githubusercontent.com/6216077/37710168-2e32b99c-2d50-11e8-9a67-2a6d3af88d08.png)

`Emulation`->`Pause`をクリックしてゲームを一時停止してください。

![openrtmlua90](https://user-images.githubusercontent.com/6216077/37710175-30e36b32-2d50-11e8-9dfc-8d26ec9e6102.png)


### RTC起動
`Tools`->`Lua Console`をクリックしてLua Consoleウインドウを表示してください。

![openrtmlua80](https://user-images.githubusercontent.com/6216077/37710172-2fb1a936-2d50-11e8-9c54-7d61c6ea57d0.png)

`Open Script`ボタンをクリックして`BizHawkSample.lua`を開いてください。

![openrtmlua100](https://user-images.githubusercontent.com/6216077/37710200-476d6538-2d50-11e8-8584-b5a318a818b3.png)

### RTSystem作成

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。

![openrtmlua500](https://user-images.githubusercontent.com/6216077/38160876-337f7352-34ff-11e8-83b1-75dac6663ad0.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![openrtmlua510](https://user-images.githubusercontent.com/6216077/38160886-61b28cfa-34ff-11e8-9d62-4e1f36788e20.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。

![openrtmlua520](https://user-images.githubusercontent.com/6216077/38160923-2a4c3418-3500-11e8-91e2-67b6bac78ff9.png)

`TkJoyStick0`の`pos`のOutPortを、`BizHawkSample0`の`in`のInPortにドラックアンドドロップしてください。

![openrtmlua530](https://user-images.githubusercontent.com/6216077/38462572-6f52e29e-3b24-11e8-818c-b191db0eef19.png)

これで通信ができるようになります。

`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるため操作ができるようになります。

![openrtmlua540](https://user-images.githubusercontent.com/6216077/38160938-b0843e68-3500-11e8-84cd-89c80e918d2c.png)



`Emulation`->`Pause`をクリックするとゲームを再開します。

![openrtmlua90](https://user-images.githubusercontent.com/6216077/37710175-30e36b32-2d50-11e8-9dfc-8d26ec9e6102.png)


### コネクタ接続、RTCのアクティブ化の自動化

`BizHawkSample.lua`の`manager:init`関数の引数を以下のように変更してください。

<pre>
manager:init({"-o", "manager.components.preconnect:BizHawkSample0.in?port=rtcname://localhost/TkJoyStick0.pos", "-o", "manager.components.preactivation:BizHawkSample0,rtcname://localhost/TkJoyStick0"})
</pre>

`-o`オプションでパラメータの設定ができます。

* `"-o", "manager.components.preconnect:BizHawkSample0.in?port=rtcname://localhost/TkJoyStick0.pos"`

起動時に接続するポートを指定します。 この場合はBizHawkSample0というRTCのinというデータポートを、TkJoyStick0というRTCのposというポートに接続します。

ただし、`TkJoyStick0`は別プロセスで起動しているため、`rtcname形式`による指定が必要になります。 `rtcname形式`はネームサーバーからRTCを取得する方法です。`rtcname://アドレス/RTC名.ポート名`で指定します。


* `"-o","manager.components.preactivation:BizHawkSample0,rtcname://localhost/TkJoyStick0"`

起動時にアクティブ化するRTCを指定します。
