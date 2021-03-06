# ev3devへのインストール手順

Luaをインストールしてください。

<pre>
$ sudo apt-get install lua5.2
</pre>

以下のコマンドで、コマンドを実行したディレクトリにOpenRTM-Luaがインストールされます。

<pre>
$ wget https://github.com/Nobu19800/RTM-Lua/releases/download/v0.4.1/openrtm-lua-0.4.1-cc-x86-lua5.2.zip
$ unzip openrtm-lua-0.4.1-cc-x86-lua5.2.zip
$ mv openrtm-lua-0.4.1-cc-x86-lua5.2 openrtm-lua
$ wget https://github.com/Nobu19800/RTM-Lua/releases/download/v0.3.1/luamodule_ev3.tar.gz
$ tar xf luamodule_ev3.tar.gz
$ cp -rf luamodule_ev3/* openrtm-lua/clibs/
</pre>



RTCの実行時には、以下のように環境変数`LUA_PATH`と`LUA_CPATH`を設定してください。

<pre>
$ export LUA_PATH='./?.lua;/home/robot/openrtm-lua/lua/?.lua'
$ export LUA_CPATH='./?.so;/home/robot/openrtm-lua/clibs/?.so'
</pre>

## omniORBのインストール
ネームサーバー等が使えたほうが便利なため、以下のコマンドでomniORBをインストールしてください。

<pre>
$ sudo apt-get install omniorb-nameserver
</pre>

