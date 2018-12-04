# RTC作成手順
以下の手順はOpenRTM-aist 1.2以降のOpenRTPでしか実行できません。
OpenRTM-aist 1.2がリリースされていない場合は、[こちら](index.md#rtc作成方法)の手順を参考にしてください。

## 概要
このページでは、インポートの入力データを定数倍してアウトポートから出力するRTCの作成手順を説明します。

![rtm_lua13](https://user-images.githubusercontent.com/6216077/37755473-f12b74c8-2de8-11e8-93c1-076cc157dddc.png)

## ひな型の作成
### RTC Builderの起動

OpenRTP起動後に、ワークスペースの指定を行います。

ここで指定したディレクトリにプロジェクトが生成されるため、指定したディレクトリは覚えておいてください。
![openrtp_lua1-1](https://user-images.githubusercontent.com/6216077/37707312-152fd43e-2d46-11e8-8150-8d1be7bc99bd.png)

Welcomeページが開きますが、×を押して消してください。
![openrtp_lua2-1](https://user-images.githubusercontent.com/6216077/37707316-17978546-2d46-11e8-8b65-90189970459a.png)

右上のパースペクティブを開くボタンを押してください。
![openrtp_lua3-1](https://user-images.githubusercontent.com/6216077/37707321-1996b718-2d46-11e8-99a9-7396937bf1a5.png)

一覧から`RTC Builder`をダブルクリックするとRTC Builderが起動します。
![openrtp_lua4-1](https://user-images.githubusercontent.com/6216077/37707324-1bfc0b20-2d46-11e8-949b-0a07d3353dae.png)

### コード生成

#### プロジェクト作成
プロジェクトを作成します。
左上の`Open New RtcBuilder Editor`ボタンを押してください。
![openrtp_lua5-1](https://user-images.githubusercontent.com/6216077/37707327-1e30d48e-2d46-11e8-9a71-a936c22ca712.png)

プロジェクト名は適当な名前に設定してください。
ここでは`test_lua`と設定します。
![openrtp_lua6-1](https://user-images.githubusercontent.com/6216077/37707331-21bf3456-2d46-11e8-9349-f6719d8c451b.png)

#### 基本情報の設定
RTCの情報を入力します。
`基本`タブを開いている場合は、モジュール名、バージョン、カテゴリ名等の基本情報を入力することができます。
ここでは`モジュール名`に`test_lua`と設定します。

![openrtp_lua7-1](https://user-images.githubusercontent.com/6216077/37707334-23ad57de-2d46-11e8-8231-d3cdbe4693e7.png)

#### アクティビティの設定
アクティビティの設定を行います。

まずRTCの基本的な動作として**状態遷移**があります。
RTCは生成状態、**非アクティブ状態**、**アクティブ状態**、**エラー状態**の4種類が存在します。
このうち生成状態については、即座に非アクティブ状態に遷移するため特に気にする必要はありません。


![rtse_lua](https://user-images.githubusercontent.com/6216077/37748753-63a05c6a-2dc8-11e8-9e96-272dfb84f60b.png)

非アクティブ状態は処理の開始を待っている状態であり、アクティブ状態は処理を実行している状態です。
例えばロボットを制御するなどの処理はアクティブ状態時に実行するため、処理を開始するためにはアクティブ状態にする必要があります。



アクティビティには以下の種類があり、RTCの状態遷移により実行されます。
以下のアクティビティコールバック関数に、ロボットを制御するなどの処理を記述します。

|アクティビティ名|処理|
|---|---|
|onInitialize|初期化処理|
|**onActivated**|アクティブ化されるとき1度だけ呼ばれる|
|**onExecute**|アクティブ状態時に周期的に呼ばれる|
|**onDeactivated**|非アクティブ化されるとき1度だけ呼ばれる|
|onAborting|ERROR状態に入る前に1度だけ呼ばれる|
|onReset|resetされる時に1度だけ呼ばれる|
|onError|ERROR状態のときに周期的に呼ばれる|
|onFinalize|終了時に1度だけ呼ばれる|
|onStateUpdate|onExecuteの後毎回呼ばれる|
|onRateChanged|ExecutionContextのrateが変更されたとき1度だけ呼ばれる|
|onStartup|ExecutionContextが実行を開始するとき1度だけ呼ばれる|
|onShutdown|ExecutionContextが実行を停止するとき1度だけ呼ばれる|


`アクティビティ`タブを開いてください。
今回はonExecuteコールバックのみを有効にします。
onExecuteをクリック後、下のON・OFFボタンをONに設定してください。

![openrtp_lua8-1](https://user-images.githubusercontent.com/6216077/37707337-2661bfa6-2d46-11e8-9489-3c203ca61601.png)


#### データポートの設定
データポートの設定を行います。
データポートは連続的なデータをやり取りするためのポートです。
データの出力ポートが**OutPort**、入力ポートが**InPort**です。

![rtse_lua2](https://user-images.githubusercontent.com/6216077/37749380-05806f3c-2dcb-11e8-87d0-c1a9f3baa13f.png)

今回はTimedLong型のデータをやり取りするInPort、OutPortを追加します。
`データポート`タブを開いてください。
以下の`Addボタン`を押すとポートを追加できます。

![openrtp_lua10-1](https://user-images.githubusercontent.com/6216077/37707345-29a9997c-2d46-11e8-806c-8f35e1a962be.png)


ポート名を変更するには、名前をクリックしてください。

##### InPortの設定

以下のInPortを設定してください。

|||
|---|---|
|ポート名|in|
|データ型|RTC::TimedLong|

##### OutPortの設定

以下のOutPortを設定してください。

|||
|---|---|
|ポート名|out|
|データ型|RTC::TimedLong|


TimedLong型はタイムスタンプ付きのLong型データを格納できます。

#### コンフィギュレーションパラメータの設定
コンフィギュレーションパラメータの設定を行います。

コンフィギュレーションパラメータはRT System Editor等のツール、あるいはRTC起動時に値を変更可能なパラメータです。
データポートは連続的に値を入出力する場合に使いますが、コンフィギュレーションパラメータは制御のゲインなど変更の頻度の低いパラメータの使用するようにすると汎用性が高くなりやすいです。


コンフィギュレーションタブを開いてください。

Addボタンを押すとパラメータを追加できます。

![rtm_lua12](https://user-images.githubusercontent.com/6216077/37755186-bdccca6a-2de7-11e8-83cb-5e6695b52b50.png)

以下のパラメータを設定してください。

|||
|---|---|
|名称|K|
|データ型|long|
|デフォルト値|10|
|制約条件|0<x<100|
|Widget|spin|



#### 言語の設定
`言語・環境`タブを開いて言語にLuaを選択してください。
![openrtp_lua11-1](https://user-images.githubusercontent.com/6216077/37707348-2d0a0296-2d46-11e8-9570-41eda10ec03c.png)

#### コード生成
最後に`基本`タブに戻ってコード生成ボタンを押すとコードを生成します。

![openrtp_lua12-1](https://user-images.githubusercontent.com/6216077/37707350-2fdf5a0c-2d46-11e8-945b-b017526added.png)


この時、コードはワークスペースに設定したフォルダ内(`workspace\test_lua\`)に生成されます。

## ソースコード編集
Luaソースコードを編集して処理を記述します。
test_lua.luaをSciTE等のエディタで開いてください。

![openrtp_lua13-1](https://user-images.githubusercontent.com/6216077/37707356-348067a4-2d46-11e8-8f13-fbb217106fb7.png)


test_lua.luaのnew関数内に以下の変数が定義されています。

|変数名|意味|
|---|---|
|obj._d_out|OutPort出力データを格納する変数|
|obj._d_in|InPort入力データを格納する変数|
|obj._outOut|OutPortオブジェクト|
|obj._inIn|InPortオブジェクト|

![openrtp_lua14-1](https://user-images.githubusercontent.com/6216077/37707362-37cb57fc-2d46-11e8-9858-63dcc20db600.png)

これらの変数はデータの入出力を行う際に使用するため覚えておいてください。

`onExecute`関数に処理を記述します。
`onExecute`関数はアクティブ状態の時に周期的に実行される関数です。

![openrtp_lua15-1](https://user-images.githubusercontent.com/6216077/37707369-3a97d780-2d46-11e8-90de-d8fe7062cd4b.png)

onExecute関数を以下のように編集してください。

```Lua
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			self._d_out.data = data.data * self._K._value
			self._outOut:write()
		end

		return self._ReturnCode_t.RTC_OK
	end
```

## 動作確認
### RT System Editor起動
RT System Editorを起動します。
パースペクティブを開くウィンドウから`RT System Editor`をダブルクリックするとRT System Editorが起動します。
![openrtp_lua16-1](https://user-images.githubusercontent.com/6216077/37707376-3db70184-2d46-11e8-837a-9bd5c08a91dc.png)

### ネームサービス起動
まずはネームサービスを起動してください。
ネームサービスは名前でオブジェクトを管理するためのサービスであり、RTCを名前でネームサービスに登録することができます。
ネームサービス起動ボタンで起動できます。
ネームサービスが起動したら、ネームサービスビューに`localhost`と表示されます。

![openrtp_lua18-1](https://user-images.githubusercontent.com/6216077/37707382-42d8f60e-2d46-11e8-853e-10969208041c.png)


### System Diagram表示
System Diagramを表示してください。
System Diagram上でRTSystemを作成します。

![rtm_lua10](https://user-images.githubusercontent.com/6216077/37753420-282a1640-2de0-11e8-9b88-6ca17f51a42b.png)


### RTC起動
#### test_luaの起動
先ほど作成したテスト用コンポーネントtest_lua.luaをダブルクリックして起動します。

#### サンプルコンポーネントの起動
サンプルコンポーネントの`ConsoleIn`、`ConsoleOut`を起動します。
以下からOpenRTM Lua版のファイル一式を入手して、**ConsoleIn.bat**、**ConsoleOut.bat**をダブルクリックすると起動します。

* [ダウンロード](download.md)

既にダウンロード済みの場合は、そちらで起動しても問題ありません。

RTCが正常に起動した場合は、RT System EditorのネームサービスビューにRTCが表示されます。

![openrtmlua600](https://user-images.githubusercontent.com/6216077/38162731-cf32856a-3521-11e8-9977-cbd56670e7a6.png)


#### ポート接続、アクティブ化

RT System Editorの`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![openrtmlua630](https://user-images.githubusercontent.com/6216077/38162747-0e8797dc-3522-11e8-903b-c5a49044b3a7.png)

システムダイアグラム上にRTCをドラックアンドドロップしてください。

![openrtmlua610](https://user-images.githubusercontent.com/6216077/38162737-efa4725e-3521-11e8-8da2-b32be9d7d686.png)

InPortをOutPortにドラックアンドドロップしてコネクタを接続してください。

![openrtmlua620](https://user-images.githubusercontent.com/6216077/38162767-53adf69e-3522-11e8-9f22-d142299788f3.png)

`All Activate`ボタンを押すとRTCがアクティブ化して動作を開始します。
RTCが緑色に変化しない場合がありますが、動作に問題はありません。

![openrtmlua640](https://user-images.githubusercontent.com/6216077/38162778-78fde1ca-3522-11e8-949a-d48cc5335dd1.png)

ConsoleIn.luaを実行した時に起動したウィンドウに数値を入力すると、ConsoleOut側で10倍した数値が表示されます。

`test_lua0`のコンフィギュレーションパラメータ`K`を操作すると、ConsoleIn側で入力した数値が同じでもConsoleOut側で表示される数値が変化します。

システムダイアグラム上の`test_lua0`をクリックして、コンフィグレーションビューの編集ボタンを押してください。

![openrtmlua650](https://user-images.githubusercontent.com/6216077/38162822-3540184e-3523-11e8-9412-57c514af3120.png)

編集ボタンで表示されたウインドウでコンフィギュレーションパラメータの操作ができます。
今回はWidgetをspinに設定したため、スピンボックスで設定できます。

![openrtmlua660](https://user-images.githubusercontent.com/6216077/38162843-9de72f68-3523-11e8-88ab-2b697e52a406.png)
