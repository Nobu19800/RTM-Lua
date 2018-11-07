# Torchによる会話コンポーネント作成
## 概要
TorchはLuaに対応した機械学習ライブラリです。
今回を以下のように入力した文字列に返答するシステムを作成します。

* 動画

[このサイト](http://blog.algolab.jp/post/2016/07/30/seq2seq-chatbot/)を参考にしたため、対話の学習まではほぼ同じ手順です。


<pre>
$ sudo apt install git cmake
$ sudo apt install luarocks luajit
$ sudo apt install libnanomsg-dev
</pre>

<pre>
git clone https://github.com/torch/distro.git ~/torch --recursive
cd ~/torch
bash install-deps
./install.sh
</pre>

<pre>
sudo luarocks install nn

sudo luarocks install --server=http://luarocks.org/dev torchx
sudo luarocks install moses

git clone https://github.com/Element-Research/rnn
cd rnn
cp rocks/rnn-scm-1.rockspec ./
sudo luarocks make
cd ..
</pre>
