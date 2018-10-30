# LuaJITの利用
## Windows

[ダウンロード](download.md)からLuaJIT用のバイナリを入手して利用してください。

まず初めに、以下のコマンドでモジュール検索パスを設定する必要があります。
パスはOpenRTM Luaを展開したフォルダによって適宜変更してください。

<pre>
> set LUA_PATH=openrtm-lua-0.4.0-LuaJIT-x86\\lua\\?.lua;
> set LUA_CPATH=openrtm-lua-0.4.0-LuaJIT-x86\\clibs\\?.dll;
</pre>

luajit.exeにLuaファイルをドラッグアンドドロップするか、以下のコマンドを入力することでRTCを起動できます。
ファイル名は適宜変更してください。

<pre>
> bin\luajit test.lua
</pre>



## Ubuntu

以下のコマンドでLuaJITをインストールして使用してください。

<pre>
$ sudo apt-get install luajit
</pre>

以下のコマンドを入力することでRTCを起動できます。

<pre>
$ luajit test.lua
</pre>
