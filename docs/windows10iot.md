# Windows 10 IoTへのインストール手順

## OpenRTM Luaの入手
Windows 10 IoTに以下のページから`OpenRTM Lua x.y.z Lua5.a ARM`をダウンロードしてWindows 10 IoTに転送します。
Luaのバージョンは5.1、5.2のどちらでも問題ありません。

* [ダウンロード](download.md)

ファイルを転送する際はエクスプローラーで`\\デバイス名\c$`にアクセスしてください。


## ネームサーバーの入手
またWindows 10 Iot用にビルドしたネームサーバーを転送します。
以下のページから`Windows 10 IoT用ネームサーバー`をダウンロードしてWindows 10 IoTに転送してください。

* [ダウンロード](download.md)


## ファイアーウォールの無効化
Windows 10 Iotで以下のコマンドを実行してファイアーウォールを無効にしてください。

<pre>
netsh advfirewall set allprofiles state off
</pre>

## ネームサーバー起動
Windows 10 Iotで`start-naming.bat`を実行してネームサーバーを起動します。

<pre>
start start-naming.bat
</pre>

あとはバッチファイルの実行でRTCを起動できます。
