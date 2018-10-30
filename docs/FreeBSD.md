# FreeBSDへのインストール手順

## Luaのインストール

以下のコマンドでLuaをインストールしてください。

<pre>
$ pkg install lua51-5.1.5_9
</pre>

Luaを実行するときは`lua51`コマンドで実行します。

## LuaRocksのインストール

pkgでインストールできるLuaRocksはLua5.2に対応しているため、Lua5.1でLuaRocksをビルドしてインストールします。

<pre>
$ pkg install gcc
$ pkg install gmake

$ wget http://luarocks.github.io/luarocks/releases/luarocks-3.0.3.tar.gz
$ tar xf luarocks-3.0.3.tar.gz
$ cd luarocks-3.0.3
$ ./configure --with-lua-version=5.1
$ make
$ make install
</pre>

実行時には以下のコマンドの実行結果を入力して環境変数を設定する必要があります。

<pre>
$ luarocks path
</pre>

ただしexportコマンドがエラーになるようなので、`setenv`に置き換えてから入力する必要があります。

## OpenRTM Luaのインストール
以下のコマンドでインストールしてください。

<pre>
$ luarocks install openrtm
</pre>


## omniORBのインストール
FreeBSD上でネームサーバーを起動するためにomniORBをインストールします。

<pre>
$ pkg install omniORB-4.2.2
</pre>

以下のコマンドでネームサーバーを起動します。

<pre>
$ omniNames -start 2809 -logdir ./ &
</pre>
