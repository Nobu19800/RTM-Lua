# Ubuntuへのインストール手順

LuaとLuaRocksをインストールしてください。

<pre>
$ sudo apt-get install lua5.1
$ sudo apt-get install luarocks
</pre>


LuaSocket、LOOP、OiL、LuaLoggingをインストールしてください。
OiLのインストールだけで、LuaSocketとLOOPは自動的にインストールされるかもしれません。

<pre>
$ sudo luarocks install luasocket
$ sudo luarocks install loop
$ sudo luarocks install oil
$ sudo luarocks install lualogging
</pre>

OpenRTM Lua版のインストールスクリプトを実行してください。

<pre>
$ git clone https://github.com/Nobu19800/RTM-Lua.git
$ cd RTM-Lua
$ sudo sh install.sh
</pre>
