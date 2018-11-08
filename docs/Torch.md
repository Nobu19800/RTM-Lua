# Torchによる会話コンポーネント作成
## 概要
TorchはLuaに対応した機械学習ライブラリです。
今回を以下のように入力した文字列に返答するシステムを作成します。

* 動画

[このサイト](http://blog.algolab.jp/post/2016/07/30/seq2seq-chatbot/)を参考にしたため、対話の学習まではほぼ同じ手順です。

以降の作業はUbuntu 18.04で行います。

## 環境構築

まずは必要なソフトウェアをインストールします。

<pre>
$ sudo apt install git cmake
$ sudo apt install luarocks luajit
$ sudo apt install libnanomsg-dev
</pre>

`Torch`をインストールします。
途中でエラーが出ますが、構わずインストールしてください。

<pre>
$ git clone https://github.com/torch/distro.git ~/torch --recursive
$ cd ~/torch
$ bash install-deps
$ ./install.sh
</pre>


`nn`をインストールします。

<pre>
$ sudo luarocks install nn
</pre>

`rnn`をインストールします。

<pre>
$ git clone https://github.com/torch/paths
$ cd paths
$ cp rocks/paths-scm-1.rockspec ./
$ sudo luarocks make
$ cd ..

$ git clone https://github.com/torch/cwrap
$ cd cwrap
$ cp rocks/cwrap-scm-1.rockspec ./
$ sudo luarocks make
$ cd ..

$ git clone https://github.com/torch/torch7
$ cd torch7
$ cp rocks/torch-scm-1.rockspec ./
$ sudo luarocks make
$ cd ..

$ sudo luarocks install --server=http://luarocks.org/dev luaffi

$ git clone https://github.com/torch/sys
$ cd sys
$ sudo luarocks make
$ cd ..

$ sudo luarocks install --server=http://luarocks.org/dev torchx
$ sudo luarocks install moses

$ git clone https://github.com/Element-Research/dpnn
$ cd dpnn
$ cp rocks/dpnn-scm-1.rockspec ./
$ sudo luarocks make
$ cd ..

$ git clone https://github.com/Element-Research/rnn
$ cd rnn
$ cp rocks/rnn-scm-1.rockspec ./
$ sudo luarocks make
$ cd ..
</pre>

## OpenRTM Luaのインストール
Lua 5.2に対応したライブラリをインストールする必要があります。
以下のコマンドで、コマンドを実行したディレクトリにOpenRTM-Luaがインストールされます。

<pre>
$ wget https://github.com/Nobu19800/RTM-Lua/releases/download/v0.4.0/openrtm-lua-0.4.0-x86-lua5.2.zip
$ unzip openrtm-lua-0.4.0-x86-lua5.2.zip
$ mv openrtm-lua-0.4.0-x86-lua5.2 openrtm-lua
$ wget https://github.com/Nobu19800/RTM-Lua/releases/download/v0.4.0/luamodule_ubuntu_lua51.tar.gz
$ tar xf luamodule_ubuntu_lua51.tar.gz
$ cp -rf luamodule_ubuntu_lua51/* openrtm-lua/clibs/
</pre>

