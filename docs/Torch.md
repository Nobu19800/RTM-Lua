# Torchによる会話コンポーネント作成
## 概要
TorchはLuaに対応した機械学習ライブラリです。
今回を以下のように入力した文字列に返答するシステムを作成します。

* 動画

以下のサイトを参考にしたため、対話の学習まではほぼ同じ手順です。

* [Seq2Seqモデルを用いたチャットボット作成 〜英会話のサンプルをTorchで動かす〜](http://blog.algolab.jp/post/2016/07/30/seq2seq-chatbot/)

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

## 学習データ作成
上記のサイトと同じ手順で学習データを作成します。
まずは`neuralconvo `とデータセットを入手します。

<pre>
$ git clone https://github.com/macournoyer/neuralconvo.git
$ cd neuralconvo/data
$ wget http://www.mpi-sws.org/~cristian/data/cornell_movie_dialogs_corpus.zip
$ unzip cornell_movie_dialogs_corpus.zip
$ mv cornell\ movie-dialogs\ corpus cornell_movie_dialogs
$ cd ..
</pre>

学習を開始する前に、`seq2seq.lua`の`float`関数を編集してください。
この変更がない場合、学習時にエラーが発生します。

<pre>
function Seq2Seq:float()
  self.encoder:double()
  self.decoder:double()

  if self.criterion then
    self.criterion:double()
  end
end
</pre>


学習を開始します。
今回の手順ではCUDAをインストールしていないため`--cuda`オプションは外します。

<pre>
$ th train.lua --dataset 50000 --hiddenSize 1000
</pre>



## OpenRTM Luaのインストール
Lua 5.2に対応したライブラリをインストールする必要があります。
以下のコマンドで、コマンドを実行したディレクトリにOpenRTM-Luaがインストールされます。

<pre>
$ wget https://github.com/Nobu19800/RTM-Lua/releases/download/v0.4.1/openrtm-lua-0.4.1-x86-lua5.2.zip
$ unzip openrtm-lua-0.4.1-x86-lua5.2.zip
$ mv openrtm-lua-0.4.1-x86-lua5.2 openrtm-lua
$ wget https://github.com/Nobu19800/RTM-Lua/releases/download/v0.4.0/luamodule_ubuntu_lua51.tar.gz
$ tar xf luamodule_ubuntu_lua51.tar.gz
$ cp -rf luamodule_ubuntu_lua51/* openrtm-lua/clibs/
</pre>

OpenRTM Luaを使用する場合は、以下のようにLuaコード内でモジュール探索パスの設定をします。

<pre>
package.path="./lua/?.lua;"..package.path
package.cpath="./clibs/?.so;"..package.cpath
</pre>


## RTC作成
RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。


### 基本プロファイル

|||
|---|---|
|モジュール名|Conversation|


### アクティビティ

`onActivated`、`onExecute`を有効にしてください。



### インポート

|||
|---|---|
|ポート名|input_words|
|データ型|TimedString|


### アウトポート

|||
|---|---|
|ポート名|output_words|
|データ型|TimedString|


### Conversation.luaの編集
まずは、先頭付近でモジュール探索パスの設定、必要なモジュールをロードを行います。

<pre>
package.path="./lua/?.lua;"..package.path
package.cpath="./clibs/?.so;"..package.cpath
-- Import RTM module
local openrtm  = require "openrtm"
require 'neuralconvo'
local tokenizer = require "tokenizer"
local list = require "pl.List"
</pre>

`onActivated`関数を以下のように編集してください。
データセットの初期化、学習モデルのロードを実行します。

<pre>
	function obj:onActivated(ec_id)
		-- データセット初期化
		if self.dataset == nil then
			self.dataset = neuralconvo.DataSet()
		end
		-- 学習モデル初期化
		if self.model == nil then
			-- モデルファイルのロード
			self.model = torch.load(self._model_file._value)
		end

		return self._ReturnCode_t.RTC_OK
	end
</pre>

次に`onExecute`関数を以下のように編集してください。

<pre>
	function obj:onExecute(ec_id)
		-- InPortに入力があったかを確認
		if self._input_wordsIn:isNew() then
			-- 入力データを読み込み
			local data = self._input_wordsIn:read()
			-- 入力への返事を生成
			self._d_output_words.data = self:say(data.data)
			-- タイムスタンプ設定
			openrtm.OutPort.setTimestamp(self._d_output_words)
			-- データ転送
			self._output_wordsOut:write()
		end
		return self._ReturnCode_t.RTC_OK
	end
</pre>

以下の`pred2sent`関数、`say`関数を追加します。

<pre>
	function obj:pred2sent(wordIds)
		local words = {}
	  
		for _, wordId in ipairs(wordIds) do
			local word = self.dataset.id2word[wordId[1]]
			table.insert(words, word)
		end
	  
		return tokenizer.join(words)
	end

	function obj:say(text)
		local wordIds = {}

		for t, word in tokenizer.tokenize(text) do
			local id = self.dataset.word2id[word:lower()] or self.dataset.unknownToken
			table.insert(wordIds, id)
		end

		local input = torch.Tensor(list.reverse(wordIds))
		local wordIds, _ = self.model:eval(input)

		return self:pred2sent(wordIds)
	end
</pre>

Torchで実行する場合にConversation.luaを直接実行したかの判別ができないため、以下の部分を編集します。

<pre>
--if openrtm.Manager.is_main() then
	local manager = openrtm.Manager
	manager:init(arg)
	manager:setModuleInitProc(MyModuleInit)
	manager:activateManager()
	manager:runManager()
--else
--	return Conversation
--end
</pre>

## 動作確認

### StringOut、StringInコンポーネントの起動
動作確認用の`StringOut`、`StringIn`コンポーネントを入手します。
`StringOut`、`StringIn`コンポーネントの実行にはOpenRTM-aist Python版のインストールが必要です。

<pre>
git clone https://github.com/Nobu19800/StringIO
</pre>


以下のコマンドで`StringOut`コンポーネントを起動してください。

<pre>
cd StringIO/StringIn
python StringIn.py
</pre>

以下のコマンドで`StringIn`コンポーネントを起動してください。

<pre>
cd StringIO/StringOut
python StringOut.py
</pre>

### RTC起動

### RTSystem作成
