# EV3上で動作するRTCの作成方法
このページではLEGO Mindstorms EV3上で動作するRTCの作成を行います。

以下の作業は全てev3devにリモートログインして実行してください。


## ev3dev-langの導入

以下のコマンドでev3dev.luaを入手してください。

<pre>
git clone -b master https://github.com/Nobu19800/ev3dev-lang
</pre>

## ev3devの動作確認

`ev3dev-lang/lua/ev3dev.lua`を適当な場所にコピーしてください。
`ev3dev.lua`と同じディレクトリにLuaファイル(今回はtest_ev3.lua)を作成してください。

以降は`test_ev3.lua`を編集して動作確認します。

### ev3devモジュールのロード

`test_ev3.lua`に以下のように記述することでev3devモジュールをロードしてください。

<pre>
require 'ev3dev'
</pre>

### タッチセンサでオンオフを検出

<pre>
-- タッチセンサ初期化
s = TouchSensor()
-- ポートを指定する場合は、引数でポートを指定する。
-- s = TouchSensor("in1")
-- 接続したか確認
print(s:connected())
-- オンオフの確認
print(s:pressed())
</pre>


### ジャイロセンサで角度を検出

<pre>
-- ジャイロセンサ初期化
g = GyroSensor()
-- 接続したか確認
print(g:connected())
-- 角度の確認
print(g:value())
</pre>

### 超音波センサで距離を検出

<pre>
-- 超音波センサ初期化
u = UltrasonicSensor()
-- 接続したか確認
print(u:connected())
-- 距離の確認
print(u:value())
</pre>

### カラーセンサで反射光の強さを検出

<pre>
-- カラーセンサ初期化
c = ColorSensor()
-- 接続したか確認
print(c:connected())
-- 反射光の強さの確認
print(c:value())
</pre>

### バッテリーの電圧を確認

<pre>
print(Battery:voltageVolts())
</pre>

### Lモーター、Mモーターの位置制御

<pre>
-- Lモーター初期化
l = LargeMotor()
-- 以下はMモーターの場合
-- m = MediumMotor()
-- 接続したか確認
print(l:connected())
-- 速度の設定
l:setSpeedSP(500)
l:setPositionSP(0)
-- 位置制御開始
l:setCommand("run-to-abs-pos")
</pre>

### Lモーター、Mモーターの速度制御

<pre>
-- Lモーター初期化
l = LargeMotor()
-- 以下はMモーターの場合
-- m = MediumMotor()
-- 接続したか確認
print(l:connected())
l:setSpeedSP(500)
-- 標準入力待ち
l:stop()
</pre>


## RTC作成

RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。

### 基本プロファイル

|||
|---|---|
|モジュール名|EV3Sample|

### アクティビティ

`onActivated`、`onExecute`を有効にしてください。

### インポート

|||
|---|---|
|ポート名|velocity|
|データ型|TimedVelocity2D|


### アウトポート

|||
|---|---|
|ポート名|touch|
|データ型|TimedBooleanSeq|


### EV3Sample.luaの編集
