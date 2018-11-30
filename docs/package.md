# パッケージ管理システム

OpenRTM LuaではLuaRocksを利用したパッケージ管理システムを用意しています。

## 自作モジュールのインストール

RTC Builderでコード生成を行うとrockspecファイルが生成されます。
rockspecファイルはモジュールの仕様、依存関係、インストールされるファイルの情報を記載したファイルです。

![rockspec](https://user-images.githubusercontent.com/6216077/49258724-d6658e00-f479-11e8-813d-082f4a381c8a.png)


自作のRTCをインストールするためには、rockspecファイルの存在するフォルダに移動してluarocksコマンドを実行します。

<pre>
> luarocks make
</pre>

## インストールしたモジュールの利用

[OpenRTM Lua](https://github.com/Nobu19800/RTM-Lua)に付属している`rtcd.lua`を使用してインストールしたRTCを起動することができます。

まずOpenRTM-aistやOpenRTM Luaの基本的な仕組みとして、まずRTCを管理するマネージャが起動して、マネージャがRTCを単一、もしくは複数起動するということになっています。
詳しくは[このページ](glossary.html#マネージャ)に記載してあります。


つまりRTC Builderで生成したLuaファイルマネージャの起動とRTCの起動を行っているということになります。

対して`rtcd.lua`は何も設定しなければマネージャの起動しか実行しません。
RTCを起動する場合は、RTCのLuaファイルをロードする必要があります。

[rtc.conf](glossary.html#rtcconf)に以下のように記述してください。
RTCの名前は適宜変更してください。

<pre>
manager.components.precreate: Sample_RTComponent
</pre>


`rtc.conf`を`rtcd.lua`と同じフォルダに配置するか、コマンドラインオプションで`rtc.conf`を指定して`rtcd.lua`を実行します。

<pre>
> lua rtcd.lua -f rtc.conf 
</pre>

`rtc.conf`を使用しない場合でも、コマンドラインオプションで設定することもできます。

<pre>
> lua rtcd.lua -o manager.components.precreate:Sample_RTComponent
</pre>


## 自作モジュールのLuaRocksへの登録

自作モジュールを[LuaRocks](https://luarocks.org)に登録することで、ユーザーが簡単にモジュールを導入することができます。

### ソースコードの公開

まずはソースコードをGitHub等で公開してください。ソースコードがダウンロードできる状態であれば問題ありません。

### LuaRocksへの登録、キーの取得

次に(LuaRocks)[https://luarocks.org/login]にログインしてください。
GitHubのアカウントでログインできますが、持っていない場合は[ユーザー登録](https://luarocks.org/register)をしてください。

ログイン後、`Settings`->`API kays`のページを開いて新規にキーを作成します。

![luarocks](https://user-images.githubusercontent.com/6216077/49260252-221b3600-f480-11e8-81e3-04465b69be81.png)


### rockspecファイルの編集

rockspecファイルにGitHub等のリポジトリを指定する必要があるため編集します。
リポジトリは適宜変更してください。GitHubのリポジトリの場合は最初に`git://`と記述します。
ZIPファイルなどの場所を指定する場合は`http://`からはじめてください。

<pre>
source = {
   url = "git://github.com/UserName/Sample_RTComponent",
   dir = "",
}
</pre>



RTC Builderで作成したRTCのフォルダに移動して以下のコマンドを実行します。rockspecファイルの名前は適宜変更してください。
何故かWindowsでは失敗することがあるようです。その場合はLuaRocksの管理画面から登録してください。

<pre>
$ luarocks upload sample_rtcomponent-1.0.0-1.rockspec --api-key=*******
</pre>


これで登録完了です。
インストールするときは以下のコマンドを実行します。インストールはWindowsでも問題ありません。

<pre>
> luarocks install sample_rtcomponent
</pre>
