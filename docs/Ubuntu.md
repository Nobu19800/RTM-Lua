# Ubuntuへのインストール手順

LuaとLuaRocksをインストールしてください。

<pre>
$ sudo apt-get install lua5.1
$ sudo apt-get install luarocks
</pre>

<!-- 
LuaSocket、LOOP、OiL、LuaLoggingをインストールしてください。
OiLのインストールだけで、LuaSocketとLOOPは自動的にインストールされるかもしれません。


<pre>
$ sudo luarocks install luasocket
$ sudo luarocks install loop
$ sudo luarocks install luaidl
$ sudo luarocks install oil
$ sudo luarocks install lualogging
$ sudo luarocks install uuid
</pre>
 -->
 
 
以下のコマンドでOpenRTM Luaをインストールしてください。

<pre>
$ sudo luarocks install openrtm
</pre>
 
 
<!--
 
## corba_cdr対応版のインストール
以下のコマンドでインストールしてください。

<pre>
$ git clone -b corba_cdr_support https://github.com/Nobu19800/RTM-Lua
$ cd RTM-Lua
$ cp spec/*.rockspec ./
$ luarocks make
</pre>


## 通常版のインストール
以下のコマンドを実行してください。

<pre>
$ sudo luarocks install openrtm
</pre>


何故かOiL等を自動でインストールしてくれない場合があるようなので、エラーが出た場合は以下のコマンドでOiLをインストールしてください。

<pre>
$ sudo luarocks install oil
</pre>

-->


<!-- 
## ソースコードからインストール
OpenRTM Lua版のインストールスクリプトを実行してください。

<pre>
$ git clone https://github.com/Nobu19800/RTM-Lua.git
$ cd RTM-Lua
$ sudo sh install.sh
</pre>
 -->
