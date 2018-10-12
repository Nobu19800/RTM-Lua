# Mac OSXへのインストール手順

[Homebrew](https://brew.sh/index_ja)をインストールしてください。

<pre>
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
</pre>


Homebrewによりlua-5.1とluarocksをインストールしてください。

<pre>
brew install lua51
brew install luarocks
</pre>


luarocksによりopenrtmをインストールしてください。

<pre>
luarocks --lua-dir=/usr/local/opt/lua@5.1 install openrtm
luarocks --lua-dir=/usr/local/opt/lua@5.1 path
</pre>


これでインストール完了です。
実行する場合は`lua-5.1`コマンドで実行してください。

<pre>
lua-5.1 ConsoleIn.lua
</pre>

OpenRTM-aistのインストールなどは以下のページを参考にしてください。

* [Mac OSX + OpenRTM-aistパッケージ](http://sugarsweetrobotics.com/?page_id=111)
* [OpenRTM-aistをMac OS X Mavericksにインストールする](https://qiita.com/switchback_sus4/items/25a969fcc30da2cdff3b)
* [OpenRTMのOSXへのインストール](http://docs.fabo.io/openrtm/installosx.html)
