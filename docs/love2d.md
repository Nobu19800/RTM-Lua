# LÖVE上で動作するRTCの作成方法
## 概要
このページではゲームエンジンLÖVE上で動作する上で動作するRTCを作成して、以下のようにPython版サンプルコンポーネントのジョイスティックコンポーネントと接続して物体を操作するシステムの作成を行います。

* [動画](https://www.youtube.com/watch?v=2xYkcu1eFfM)

## LÖVEの入手
以下からLÖVEを入手してください。

* [LÖVE - Free 2D Game Engine](https://love2d.org/)

※LÖVEの新しいバージョンで色が描画されない不具合があります。問題が発生した場合はLÖVEの0.10.2を入手してください。

* [https://bitbucket.org/rude/love/downloads/](https://bitbucket.org/rude/love/downloads/)

## LÖVEにOpenRTM Lua版をインストール
LÖVEを展開したフォルダにOpenRTM Lua版の各ファイルをコピーします。

以下からOpenRTM Lua版ファイル一式(OpenRTM Lua x.y.z Lua5.1 64bit(もしくは32bit))をダウンロードしてください。
32bit版のLÖVEを使用する場合は32bit版、64bit版のLÖVEを使用する場合は64bit版を使用します。

* [ダウンロード](download.md)

OpenRTM Lua版からLÖVEにファイルをコピーします。

`openrtm-lua-x.y.z-x64-lua5.1\lua`フォルダを`love-11.1.0-win64\`以下にコピーしてください。

![love2d-1](https://user-images.githubusercontent.com/6216077/45256448-938f9f00-b3d1-11e8-93b5-d9c84c6646f8.png)



次に`openrtm-lua-x.y.z-x64-lua5.1\clibs\`以下のファイルを全て`love-11.1.0-win64\`以下にコピーしてください。

![love2d-2](https://user-images.githubusercontent.com/6216077/45256531-88893e80-b3d2-11e8-940e-c9178a4b6f57.png)



## RTC作成
RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。

### 基本プロファイル

|||
|---|---|
|モジュール名|LOVESample|

### アクティビティ

`onExecute`を有効にしてください。

### インポート

|||
|---|---|
|ポート名|in|
|データ型|TimedFloatSeq|

### LOVESample.luaの編集

`LOVESample.lua`に物理オブジェクトを設定するためのsetObject関数を追加します。

<pre>
LOVESample.new = function(manager)
	local obj = {}
  (省略)
	function obj:setObject(objects)
		self._objects = objects
	end
</pre>

`LOVESample.lua`のonExecute関数を編集します。

<pre>
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			self._objects.ball.body:applyForce(data.data[1], 0)
			if data.data[2] > 100 then
				self._objects.ball.body:setPosition(650/2, 650/2)
				self._objects.ball.body:setLinearVelocity(0, 0)
			end
		end
		return self._ReturnCode_t.RTC_OK
	end
</pre>

InPortのデータを読み込んで、左右の操作でボールに力を加える。
上に動かした場合はボールの位置、速度を初期化する。


編集した`LOVESample.lua`を`love-11.1.0-win64\lua\`以下にコピーしてください。

![love2d-3](https://user-images.githubusercontent.com/6216077/45259442-1f242280-b408-11e8-9d1a-8f6b7ccbc448.png)





## 新規ゲームの作成
適当な場所にフォルダ(今回はLOVESampleGameフォルダ)を新規作成してください。
その中に`main.lua`を作成してください。

今回は[Physicsのチュートリアル](https://love2d.org/wiki/Tutorial:Physics_(%E6%97%A5%E6%9C%AC%E8%AA%9E))のソースコードを変更したものを作成します。

まず、初期化時に一度だけ呼び出される`love.load()`関数を編集します。

LÖVEは内部でLuaSocketをロードするため、全て無効化します。

<pre>
function love.load()
    package.preload["mime.core"] = nil
    package.preload["socket.ftp"] = nil
    package.preload["socket.headers"] = nil
    package.preload["socket.url"] = nil
    package.preload["socket.smtp"] = nil
    package.preload["socket.http"] = nil
    package.preload["socket.core"] = nil
    package.preload["socket.tp"] = nil
    package.preload["mime"] = nil
    package.preload["socket"] = nil

    local openrtm = require "openrtm"


    local mgr = openrtm.Manager
    mgr:init({"-o","exec_cxt.periodic.type:OpenHRPExecutionContext","-o","manager.components.precreate:LOVESample","-o","manager.components.preconnect:LOVESample0.in?port=rtcname://localhost/TkJoyStick0.pos","-o","manager.components.preactivation:LOVESample0,rtcname://localhost/TkJoyStick0"})
    mgr:activateManager()
    mgr:runManager(true)
    
    -- チュートリアルのコード
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    (省略)
    love.window.setMode(650, 650) --set the window dimensions to 650 by 650
    -------------------------------------------------------------------------
    
    
    local comp = mgr:getComponent("LOVESample0")
    comp:setObject(objects)
</pre>



基本は上記のコードの`LOVESample`の部分を変更すると、他のRTCにも適用できるようになります。

`mgr:init`関数の引数について説明します。
`-o`オプションの後にパラメータを指定します。

* `"-o","exec_cxt.periodic.type:OpenHRPExecutionContext"`

実行コンテキストの指定をしています。
LÖVE上ではRTCをステップ実行したいので`OpenHRPExecutionContext`という実行コンテキストを指定します。


* `"-o","manager.components.precreate:LOVESample"`

起動時に生成するRTC名を指定します。

* `"-o","manager.components.preconnect:LOVESample0.in?port=rtcname://localhost/TkJoyStick0.pos"`

起動時に接続するポートを指定します。
この場合は`LOVESample0`というRTCの`in`というデータポートを、`TkJoyStick0`というRTCの`pos`というポートに接続します。

ただし、`TkJoyStick0`は別プロセスで起動しているため、`rtcname形式`による指定が必要になります。
`rtcname形式`はネームサーバーからRTCを取得する方法です。`rtcname://アドレス/RTC名.ポート名`で指定します。


* `"-o","manager.components.preactivation:LOVESample0,rtcname://localhost/TkJoyStick0"`

起動時にアクティブ化するRTCを指定します。


`love.update`関数は以下のように編集します。

<pre>
function love.update(dt)
    world:update(dt)
    
    local openrtm = require "openrtm"
    local mgr = openrtm.Manager
    mgr:step()

    local comp = mgr:getComponent("LOVESample0")
    local ec = comp:get_owned_contexts()[1]
    ec:tick()
end
</pre>



`love.draw`関数はチュートリアルのコードと同じです。


## 動作確認
### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](download.md)

### RTC起動

`LOVESampleGame`フォルダを`love.exe`にドラッグアンドドロップするとゲームを開始します。

![love2d-4](https://user-images.githubusercontent.com/6216077/45259640-3238f180-b40c-11e8-935e-d265ba75e354.png)



### RTSystem作成

起動時にポートの接続、アクティブ化をオプションで設定しているため、RT System Editorでの操作は不要ですが、念のためRT System Editorによる操作手順も説明します。

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。

![love2d-5](https://user-images.githubusercontent.com/6216077/45259750-c4da9000-b40e-11e8-9676-abed8c79d976.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![love2d-6](https://user-images.githubusercontent.com/6216077/45259751-cf952500-b40e-11e8-9b97-f2434af75045.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。

![love2d-7](https://user-images.githubusercontent.com/6216077/45259754-d7ed6000-b40e-11e8-8cae-3fce419ccc8c.png)


`TkJoyStick0`の`pos`のOutPortを、`LOVESample0`の`in`のInPortにドラックアンドドロップしてください。
これで通信ができるようになります。

![love2d-8](https://user-images.githubusercontent.com/6216077/45259759-e9366c80-b40e-11e8-8080-e5c49552ba52.png)


`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるため操作ができるようになります。

![love2d-9](https://user-images.githubusercontent.com/6216077/45259761-fc493c80-b40e-11e8-8494-a4f592712476.png)


## 注意事項
今回はInPortのみを使用しましたが、OutPortを使用する場合についてはデータ転送の際に以下のように`oil.main`関数で実行する必要があります。
また、サービスポートのプロバイダ側についても同じです。
`oil.main`関数で実行する必要があるのは、今回のようにORBをステップ実行した時のみです。

<pre>
oil.main(function()
	self._outOut:write()
end)
</pre>
