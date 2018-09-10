# LuaJITの利用
## Windows

[ダウンロード](download.md)からLuaJIT用のバイナリを入手して利用してください。

luajit.exeにLuaファイルをドラッグアンドドロップするか、以下のコマンドを入力してください。

<pre>
bin\luajit test.lua
</pre>

ただしOpenRTM Luaを使用する場合は、以下のコマンドでモジュール検索パスを設定する必要があります。
パスはOpenRTM Luaを展開したフォルダによって適宜変更してください。

<pre>
set LUA_PATH=..\\lua\\?.lua;
set LUA_CPATH=..\\clibs\\?.dll;
</pre>

## Ubuntu

以下のコマンドでインストールして使用してください。

<pre>
sudo apt-get install luajit
</pre>
