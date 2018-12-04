# 開発メモ
## IDLファイルの読み込み失敗

OiLではOpenRTM.idlとDataPort.idlを同時に使用することができない。
OpenRTM.idlでは、以下のように接頭語が設定されていますが、DataPort.idlにはこれが記述されていません。
意図が分からないので、OpenRTM-aist 1.0開発時にミスがあったのかもしれません。

```IDL
#include "RTC.idl"

#pragma prefix "openrtm.aist.go.jp"

module OpenRTM
{
```

## コルーチン
Luaはマルチスレッドで動作させることができません。
そのためloopライブラリではコルーチンにより順番に処理を実行するようになっていますが、yieldによりコルーチンの動作を中断しないと他の処理が実行されないということになります。
ConsoleIn.luaのサンプルを試してみたら分かりますが、標準入力等で動作を止めてしまうと、ほかの処理も実行されず完全に停止します。
このためRTSystemEditorからの操作もできません。

## OiLのバージョン
OiLの最新版は2017年9月にリリースされた0.7.0なので、0.4はかなり古いです。最新版ではSSLの通信もできるらしいです。
ただLua for Windowsでインストールするのが簡単なので、0.4でとりあえず実装はしてあります。
Lua自体も5.1.5は古いので、5.2系には移行したいと思います。OiLの0.7系への対応もそのうちやります。

※ver.0.3.1でOiL 0.7、Lua 5.2.4に対応しました。

## Windows版LuaRocks

WindowsではOiLのインストールが上手くいかない。おそらくCのバイナリ生成時の問題。
luaidlのインストールはできるが、OiLのバージョンが0.4betaのままでluaidlだけ新しいバージョンに移行すると不具合が発生する。

lualoggingのインストールにも失敗するが、この原因は一切不明。

OiLもlualoggingもLua for Windowsに最初から入っているものを使えばいいため、現状問題は無い。

## OiL 0.7の問題

OiL 0.7は何故かoil.VERSIONで取得できるバージョンが0.6になっている。

また、Codec.luaのstruct関数455目に以下を追加しないと落ちることがある。

```Lua
if field.name == "port" then
	val = tonumber(val)
end
```

## ARMの問題
ARMアーキテクチャで動作させたときにFloat型、Double型のアンマーシャリングが失敗する。Raspbian、ev3devでは発生するが、Windows 10 IoTでは発生しない。これだからLinuxは困る。
この問題はOiL-0.5.2以前のバージョンの問題であるため、ARMアーキテクチャで動作させる場合はOiL-0.7のインストールが必要。

## OiL 0.7の機能

OiL 0.7では`pending`関数、`step`関数でタイムアウトを設定できる。

## OpenRTM.NETとの通信について
現在のところ、OpenRTM.NETのRTCと接続できません。
ログを見る限り、OpenRTM.NETの`IDL:OpenRTM/IIOP/Adapter/IDataFlowComponentAdapter:1.0`や`IDL:OpenRTM/IIOP/InPortCdrAdapter:1.0`が何者か分からないらしい。
OpenRTM.NETからOpenRTM Luaに通信できない理由は不明。

OiLとIIOP.NETの通信自体はできるようなので、OiL側で`IDL:OpenRTM/IIOP/InPortCdrAdapter:1.0`等を定義する必要があるのかもしれない。


## エンドポイントの設定
Windows以外のOSではエンドポイントを明示的に設定しない場合に、エンドポイントに`127.0.0.1`が設定される場合がほとんどであるため実質的にエンドポイントの設定は必須。

OiLがcorbaloc形式でアクセスする場合に、通信が失敗する場合がある。

omniORB側がサーバーだとして、エンドポイントを以下のように設定したとする。

<pre>
giop:tcp::8087
</pre>

この場合については問題はない。

<pre>
giop:tcp:localost:8087
</pre>

この場合はOiL側からの通信が失敗する。原因は不明。
