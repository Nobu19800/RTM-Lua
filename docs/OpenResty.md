# OpenResty上で動作するRTCの作成方法
## 概要
このページではWEBアプリサーバーOpenResty上で動作するRTCを作成して、以下のようにPython版サンプルコンポーネントのジョイスティックコンポーネントと接続してWEBブラウザ上でジョイスティックの位置を表示するシステムの作成を行います。

* [動画](https://www.youtube.com/watch?v=_-Kw8qv_keo)


従来はWEBブラウザ上でRTCのデータを表示等をする場合は、以下のようにRTCとWEBサーバーで通信を行う必要がありましたが、

<img src=https://user-images.githubusercontent.com/6216077/38496525-df36abee-3c38-11e8-9043-332ef49f2584.png height=250>

WEBサーバー上でRTCを起動することで、以下のように構成が簡単になります。

<img src=https://user-images.githubusercontent.com/6216077/38496798-c739dbd2-3c39-11e8-96e3-5580fd4c214e.png height=250>

この構成にする事によって、従来の方法では難しかったWEBブラウザでの操作のタイミングでOutPortからデータを送信する、サービスポートの操作を呼び出すという事が容易に実現できます。

※このような使い方を見たわけではありませんが、OpenRTM-aist Python版+Twisted(もしくはDjango)でも同じ構成は可能かもしれません。

## OpenRestyの入手
以下からopenresty-1.13.6.1-win32.zipをダウンロードして適当な場所に展開してください。

* https://openresty.org/en/download.html

## ディレクトリ構成
以下のサイトを参考にしてディレクトリを作成する。

* [OpenRestyはどれくらいお気軽なウェブアプリ環境なのか。](https://qiita.com/mah0x211/items/8870d7d1063f3d754076)

<pre>
rtc-server
    |
    |----conf
    |     |----mime.types
    |     |----nginx.conf
    |
    |----logs
    |     |----access.log
    |     |----error.log
    |
    |----luahooks
    |     |----image.lua
    |
    |
    |----public
    |      |----images
    |              |----index.html
    |              |----sample.html
    |              |----test.gif
</pre>

`nginx.conf`には以下のように記述してください。

<pre>
worker_processes    1;
events {
    worker_connections  1024;
    accept_mutex_delay  100ms;
}

http {
    sendfile            on;
    tcp_nopush          on;
    include             mime.types;
    default_type        text/html;
    index               index.html;

    #
    # log settings
    #
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  logs/access.log main;

    # 
    # lua global settings
    #
    lua_package_path        '$prefix/luahooks/?.lua;;';
    lua_check_client_abort  on;
    lua_code_cache          on;

    #
    # initialize script
    #
    #init_by_lua_file        luahooks/init.lua;

    #
    # public
    #
    server {
        listen      1080;
        root        public/images;

        #
        # content handler
        #
        location /index.html {
            default_type text/html;
            content_by_lua_file        luahooks/image.lua;
        }
    }
}
</pre>

`test.gif`には以下のような画像を用意してください。

![test](https://user-images.githubusercontent.com/6216077/38457885-4d09958c-3ad1-11e8-8d34-febc84097171.gif)

`sample.html`には以下のように記述してください。

* https://github.com/Nobu19800/RTM-Lua-Sample/blob/master/OpenRestySample/rtc-server/public/images/sample.html

## OpenRestyにOpenRTM Lua版をインストール


`rtc-server`のフォルダにOpenRTM Lua版の各ファイルをコピーします。

以下から32bit用のOpenRTM Lua版ファイル一式(OpenRTM Lua x.y.z LuaJIT 32bit)をダウンロードしてください。

* [ダウンロード](download.md)

OpenRTM Lua版からOpenRestyにファイルをコピーします。

`openrtm-lua-x.y.z(LuaJITx86)\lua`フォルダを、`rtc-server`以下にコピーしてください。

![openrtmlua720](https://user-images.githubusercontent.com/6216077/38462313-e53bedb6-3b1f-11e8-839a-f70f328d4d45.png)


`openrtm-lua-x.y.z(LuaJITx86)\lua\idl`フォルダを、`rtc-server`以下にコピーしてください。

![openrtmlua730](https://user-images.githubusercontent.com/6216077/38462315-f0f29a42-3b1f-11e8-87c9-c47c7efb0896.png)


`openrtm-lua-x.y.z(LuaJITx86)\clibs`フォルダを、`rtc-server`以下にコピーしてください。

![openrtmlua740](https://user-images.githubusercontent.com/6216077/38462319-02036ed8-3b20-11e8-92c1-40744722e55a.png)


`lua51.dll`の上書きが必要なため、`openrtm-lua-x.y.z(LuaJITx86)\bin\lua51.dll`を`openresty-1.13.6.1-win32\`以下にコピーしてください。

![openrtmlua750](https://user-images.githubusercontent.com/6216077/38462349-bf7488e4-3b20-11e8-8a0a-523a55d657f0.png)





### Lua CJSONのビルド

データはJSON形式で取得しますが、Lua CJSONはこちらでdllを用意していないのでビルドしてください。

以下からソースコードをダウンロードしてCMake、Visual Studioでビルドしてください。

* https://github.com/mpx/lua-cjson

Visual Stduio 2017の場合はビルド時にエラーが出ます。
CMakeLists.txtの以下の部分を削除してからビルドしてください。

<pre>
add_definitions(-Dsnprintf=_snprintf)
</pre>



![openrtmlua700](https://user-images.githubusercontent.com/6216077/38462323-1321d862-3b20-11e8-9f6a-51be9b210eb4.png)


## RTC作成

RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。

### 基本プロファイル
|||
|---|---|
|モジュール名|OpenRestySample|

### アクティビティ

`onExecute`を有効にしてください。

### インポート
|||
|---|---|
|ポート名|in|
|データ型|RTC::TimedFloatSeq|

### OpenRestySample.luaの編集

データを格納する変数、取得する関数を定義します。

<pre>
OpenRestySample.new = function(manager)
	local obj = {}
        (省略)
	obj.input_data = {0,0}
	function obj:getData()
		return self.input_data
	end
</pre>


`OpenRestySample.lua`の`onExecute`関数を以下のように編集してください。



<pre>
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			self.input_data[1] = data.data[1]
			self.input_data[2] = data.data[2]
		end
		return self._ReturnCode_t.RTC_OK
	end
</pre>

入力データは`getData`関数で取得できます。


編集した`OpenRestySample.lua`を`rtc-server\lua`にコピーしてください。

![openrtmlua710](https://user-images.githubusercontent.com/6216077/38462386-8d3d7d30-3b21-11e8-96c1-c048cc6ca738.png)


## `image.lua`の編集

`image.lua`に以下のように記述してください。

<pre>
package.path = package.path..";./lua/?.lua"
package.cpath = package.cpath..";./clibs/?.dll"
local oil  = require "oil"
local openrtm  = require "openrtm"
local OpenRestySample = require "OpenRestySample"
local cjson = require "cjson"

local args = ngx.req.get_uri_args()
local command = tostring( args.command )



if command == "start" then
	local f = io.open("public/images/sample.html", "r")
	local content = f:read("*all")
	f:close()
	

	local MyModuleInit = function(manager)
		OpenRestySample.Init(manager)
		local comp = manager:createComponent("OpenRestySample")
	end
	if oil.corba == nil then
		oil.corba = {}
		oil.corba.idl = {}
	end
	local manager = openrtm.Manager
	manager:init({"-o","logger.enable:NO","-o","exec_cxt.periodic.type:OpenHRPExecutionContext"})
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager(true)
	
	ngx.say(content)

elseif command == "update" then
	local x = 0
	local y = 0
	
	local manager = openrtm.Manager
	manager:step()
	local comp = manager:getComponent("OpenRestySample0")
	local ec = comp:get_owned_contexts()[1]
	ec:tick()
	local data = comp:getData()
	x = data[1]
	y = data[2]
	ngx.say(cjson.encode({x=x,y=y}))
end

</pre>


クエリパラメータ`command`が`start`の場合はRTCを起動します。

`command`が`update`の場合はRTCのステップ処理を更新して入力データを取得します。

JSON形式によりサーバークライアントでデータのやり取りを行います。



## 動作確認

### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](download.md)

### WEBサーバーの起動

`openresty-1.13.6.1-win32`以下のディレクトリを環境変数PATHに設定してください。

`rtc-server`の上のディレクトリで以下のコマンドを実行するとWEBサーバーが起動します。

<pre>
nginx.exe  -p ./
</pre>

### RTCの起動

Google Chrome等のWEBブラウザから`http://localhost:1080/index.html?command=start`にアクセスするとRTCが起動します。


### RTSystem作成

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。

![openrtmlua760](https://user-images.githubusercontent.com/6216077/38462641-97825578-3b25-11e8-9e18-da94cc81bb49.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![openrtmlua770](https://user-images.githubusercontent.com/6216077/38462646-ab925180-3b25-11e8-84a0-2f044d075103.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。

![openrtmlua780](https://user-images.githubusercontent.com/6216077/38462649-b72e60e2-3b25-11e8-9e29-038ee5dfeb6f.png)


`TkJoyStick0`の`pos`のOutPortを、`OpenRestySample0`の`in`のInPortにドラックアンドドロップしてください。

![openrtmlua790](https://user-images.githubusercontent.com/6216077/38462661-d3496f88-3b25-11e8-9bbf-ce674ebf62e5.png)

これで通信ができるようになります。

`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるためWEBブラウザ上の画像が動くようになります。

![openrtmlua800](https://user-images.githubusercontent.com/6216077/38462671-ed3290be-3b25-11e8-8096-69984792d907.png)


### コネクタ接続、RTCのアクティブ化の自動化

`imahe.lua`の`manager:init`関数の引数を以下のように変更してください。

<pre>
manager:init({"-o","logger.enable:NO","-o","exec_cxt.periodic.type:OpenHRPExecutionContext", "-o", "manager.components.preconnect:OpenRestySample0.in?port=rtcname://localhost/TkJoyStick0.pos", "-o", "manager.components.preactivation:OpenRestySample0,rtcname://localhost/TkJoyStick0"})
</pre>

`-o`オプションでパラメータの設定ができます。

* `"-o", "manager.components.preconnect:OpenRestySample0.in?port=rtcname://localhost/TkJoyStick0.pos"`

起動時に接続するポートを指定します。 この場合はOpenRestySample0というRTCのinというデータポートを、TkJoyStick0というRTCのposというポートに接続します。

ただし、`TkJoyStick0`は別プロセスで起動しているため、`rtcname形式`による指定が必要になります。 `rtcname形式`はネームサーバーからRTCを取得する方法です。`rtcname://アドレス/RTC名.ポート名`で指定します。


* `"-o","manager.components.preactivation:OpenRestySample0,rtcname://localhost/TkJoyStick0"`

起動時にアクティブ化するRTCを指定します。
