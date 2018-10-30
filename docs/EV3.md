# EV3上で動作するRTCの作成方法
このページではLEGO Mindstorms EV3上で動作するRTCの作成を行います。

以下の作業は全てev3devにリモートログインして実行してください。


## ev3dev-langの導入

以下のコマンドでev3dev.luaを入手してください。

<pre>
$ git clone -b master https://github.com/Nobu19800/ev3dev-lang
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
-- 速度調整機能をオンにします
-- ev3devのstretchではオンオフを切り替えることができないためpcallで呼び出す
pcall(
	function()
		l:setSpeedRegulationEnabled("on")
	end
)

speed = 360
-- 速度の設定
-- カウント数を入力する
l:setSpeedSP(math.floor(speed/360*l:countPerRot()))

pos = 180
-- 位置の設定
-- カウント数を入力する
l:setPositionSP(math.floor(pos/360*l:countPerRot()))
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

-- 速度調整機能をオンにします
-- ev3devのstretchではオンオフを切り替えることができないためpcallで呼び出す
pcall(
	function()
		l:setSpeedRegulationEnabled("on")
	end
)

speed = 360
-- 速度の設定
-- カウント数を入力する
l:setSpeedSP(math.floor(speed/360*l:countPerRot()))
-- 速度制御開始
l:setCommand("run-forever")
-- 標準入力待ち
io.read()
-- 停止
l:setCommand("stop")
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

`onActivated`、`onDeactivated`、`onExecute`を有効にしてください。

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

先頭付近で`ev3dev`のモジュールのロードを行ってください。
`ev3dev.lua`はEV3Sample.luaと同じディレクトリに配置してください。

<pre>
require 'ev3dev'
</pre>

`onActivated`関数を以下のように編集してください。
タッチセンサ、Lモーターの初期化を行います。

<pre>
	function obj:onActivated(ec_id)
		-- ポート1に接続したタッチセンサの初期化
		self._touchsensor1 = TouchSensor("in1")
		-- 接続失敗でエラーに遷移
		if not self._touchsensor1:connected() then
			return self._ReturnCode_t.RTC_ERROR
		end
		-- ポート3に接続したタッチセンサの初期化
		self._touchsensor2 = TouchSensor("in3")
		-- 接続失敗でエラーに遷移
		if not self._touchsensor2:connected() then
			return self._ReturnCode_t.RTC_ERROR
		end

		-- ポートBに接続したLモーターの初期化
		-- 右側の車輪を回転させるモーター
		self._lmotor1 = LargeMotor("outB")
		-- 接続失敗でエラーに遷移
		if not self._lmotor1:connected() then
			return self._ReturnCode_t.RTC_ERROR
		end
		-- 速度調整機能をオンにする
		-- ev3devのstretchではオンオフを切り替えることができないためpcallで呼び出す
		pcall(
			function()
				self._lmotor1:setSpeedRegulationEnabled("on")
			end
		)

		-- ポートCに接続したLモーターの初期化
		-- 左側の車輪を回転させるモーター
		self._lmotor2 = LargeMotor("outC")
		-- 接続失敗でエラーに遷移
		if not self._lmotor2:connected() then
			return self._ReturnCode_t.RTC_ERROR
		end

		-- 速度調整機能をオンにする
		-- ev3devのstretchではオンオフを切り替えることができないためpcallで呼び出す
		pcall(
			function()
				self._lmotor2:setSpeedRegulationEnabled("on")
			end
		)
		
		return self._ReturnCode_t.RTC_OK
	end
</pre>


`onDeactivated`関数を以下のように編集してください。
Lモーターを停止する処理を書きます。

<pre>
	function obj:onDeactivated(ec_id)
		-- ポートAのLモーターを停止
		if self._lmotor1 ~= nil then
			self._lmotor1:setCommand("stop")
		end
		-- ポートCのLモーターを停止
		if self._lmotor2 ~= nil then
			self._lmotor2:setCommand("stop")
		end
		return self._ReturnCode_t.RTC_OK
	end
</pre>


`onExecute`関数を以下のように編集してください。
タッチセンサの値をOutPortから送信、InPortから受信した速度指令からLモーターの回転速度を計算して駆動する処理を書きます。

<pre>
	function obj:onExecute(ec_id)
		-- 車輪の半径
		local wheelRadius = 0.028
		-- 車輪間の距離
		local wheelDistance = 0.108

		-- タッチセンサの値を格納
		self._d_touch.data = {self._touchsensor1:pressed(),
							  self._touchsensor2:pressed()}
		-- データにタイムスタンプを設定
		openrtm.OutPort.setTimestamp(self._d_touch)
		-- touchのOutPortからタッチセンサの値を送信
		obj._touchOut:write()

		-- velocityのInPortに入力がある場合
		if self._velocityIn:isNew() then
			-- データ読み込み
			local data = self._velocityIn:read()
			-- 直進速度vx、旋回角速度vaから左右の車輪の回転速度を計算
			local r = wheelRadius
			local d = wheelDistance/2.0
			local vx = data.data.vx
			local va = data.data.va
			local right_motor_speed = (vx + va*d)/r
			local left_motor_speed = (vx - va*d)/r

			-- モーター1回転当たりのカウントを取得
			local cpr1 = self._lmotor1:countPerRot()
			local cpr2 = self._lmotor2:countPerRot()
			
			-- 回転速度[rad]からモーターに指令するカウント数に変換
			local speed1 = right_motor_speed/(2*math.pi)*cpr1
			local speed2 = left_motor_speed/(2*math.pi)*cpr2


			-- モーターに回転速度を指令
			self._lmotor1:setSpeedSP(math.floor(speed1))
			self._lmotor1:setCommand("run-forever")

			self._lmotor2:setSpeedSP(math.floor(speed2))
			self._lmotor2:setCommand("run-forever")
		end

		return self._ReturnCode_t.RTC_OK
	end
</pre>


## 動作確認
### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](download.md)


### FloatSeqToVelocityコンポーネントの起動

FloatSeqToVelocityコンポーネントを入手して、`FloatSeqToVelocity.exe`を実行してください。

* [ダウンロード](download.md)

### EV3起動、接続

EV3のタッチセンサ、Lモーターを以下のように接続して、電源を投入してください。

|ポート|デバイス|
|---|---|
|ポート1|タッチセンサ(左)|
|ポート3|タッチセンサ(右)|
|ポートB|Lモーター(右)|
|ポートB|Lモーター(左)|

### RTC起動

EV3にTera Term等でリモートログインして`EV3Sample.lua`をEV3に転送してください。

転送後、以下のコマンドを実行してください。
RTCの起動には1分程かかります。


<pre>
$ lua EV3Sample.lua -o corba.endpoints:EV3のIPアドレス
</pre>


### RTSystem作成

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。
![ev3dev1](https://user-images.githubusercontent.com/6216077/47643247-3e406480-dbae-11e8-908c-180413a5e14d.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。
![ev3dev6](https://user-images.githubusercontent.com/6216077/47643249-3ed8fb00-dbae-11e8-9ce8-289fa1fb5721.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。
![ev3dev3](https://user-images.githubusercontent.com/6216077/47643245-3e406480-dbae-11e8-97f7-70b4b3d2c627.png)

`TkJoyStick0`の`pos`のOutPortを`FloatSeqToVelocity0`の`in`のInPortに、`FloatSeqToVelocity0`の`out`のOutPortを`EV3Sample0`の`velocity`のInPortにドラックアンドドロップしてください。 これで通信ができるようになります。
![ev3dev7](https://user-images.githubusercontent.com/6216077/47643248-3ed8fb00-dbae-11e8-9e85-a2deed17265d.png)

`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるためEV3の操作ができるようになります。
![ev3dev5](https://user-images.githubusercontent.com/6216077/47643251-3ed8fb00-dbae-11e8-8635-710cac8c6b94.png)

