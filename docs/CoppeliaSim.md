# CoppeliaSim上で動作するRTCの作成方法
このページでは物理シミュレータCoppeliaSim上で動作する上で動作するRTCを作成して、以下のようにPython版サンプルコンポーネントのジョイスティックコンポーネントと接続して車体を操作するシステムの作成を行います。
CoppeliaSim 4.3で動作確認しています。

* [動画](https://www.youtube.com/watch?v=EaQ2oOxfhSY)


## CoppeliaSimのインストール
以下からCoppeliaSimのインストーラーを入手してインストールしてください。

* [Robot simulator CoppeliaSim: create, compose, simulate, any robot - Coppelia Robotics](https://coppeliarobotics.com/downloads)

## CoppeliaSimにOpenRTM Lua版をインストール
CoppeliaSimをインストールしたフォルダ(`C:\Program Files\CoppeliaSim`、もしくは任意ディレクトリの`CoppeliaSim_Edu_V4_3_0_Ubuntu18_04`)にOpenRTM Lua版の各ファイルをコピーします。

以下から64bit用のOpenRTM Lua版ファイル一式(OpenRTM Lua x.y.z *** Lua5.3 64bit バージョン名削除(CoppeliaSim向け))をダウンロードしてください。

* [ダウンロード](download.md)

OpenRTM Lua版からCoppeliaSimにファイルをコピーします。

`openrtm-lua-x.y.z-cc-x64-lua5.3-versionomit\lua`フォルダを`C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\`以下にコピーして上書きしてください。
Ubuntuの場合は任意ディレクトリの`CoppeliaSim_Edu_V4_3_0_Ubuntu18_04`以下にコピーします。

![imagecopy1](https://user-images.githubusercontent.com/6216077/159617150-7f146c4d-5237-430c-b080-551de01d61e9.png)


`openrtm-lua-x.y.z-cc-x64-lua5.3-versionomit\lua\idl`フォルダを(`C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu`、もしくは`CoppeliaSim_Edu_V4_3_0_Ubuntu18_04`)にコピーします。

![imagecopy2](https://user-images.githubusercontent.com/6216077/159617239-ad974670-253e-4d12-8db3-7e4c343e086a.png)



以下、WindowsとUbuntuでコピーするファイルが違います。Ubuntuで使いたいという人は注意してください。

### Windowsの場合

`openrtm-lua-x.y.z-cc-x64-lua5.3-versionomit\clibs\`以下のファイルを全て`C:\Program Files\CoppeliaSim3\CoppeliaSim_PRO_EDU\luar\`以下にコピーしてください。


![imagecopy3](https://user-images.githubusercontent.com/6216077/159617327-ae718b96-19f5-4740-b1bd-d9e0f55a9eab.png)

### Ubuntuの場合

以下から`luamodule_ubuntu_lua53`を入手してください。

* [ダウンロード](download.md)

中身のファイルを全て`CoppeliaSim_Edu_V4_3_0_Ubuntu18_04/`以下にコピーしてください。

![vrep200](https://user-images.githubusercontent.com/6216077/44310099-d5997680-a40b-11e8-9ccd-8d271ece7ccf.png)


## RTC作成
RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC.md)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。



### 基本プロファイル

|||
|---|---|
|モジュール名|CoppeliaSimSample|


### アクティビティ

`onExecute`を有効にしてください。

### インポート

|||
|---|---|
|ポート名|in|
|データ型|RTC::TimedFloatSeq|


### CoppeliaSimSample.luaの編集

ソースコードの先頭付近に以下の行を追加して、シミュレーションのスレッドと自動的に切り替える機能をオフにしてください。

```Lua
sim.setThreadAutomaticSwitch(false)
```

`onExecute`関数を以下のように編集してください。

```Lua
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			local joint_front_left_wheel=sim.getObjectHandle('joint_front_left_wheel')
			local joint_front_right_wheel=sim.getObjectHandle('joint_front_right_wheel')
			local joint_back_right_wheel=sim.getObjectHandle('joint_back_right_wheel')
			local joint_back_left_wheel=sim.getObjectHandle('joint_back_left_wheel')

			sim.setJointTargetVelocity(joint_front_left_wheel, data.data[2]/50+data.data[1]/50)
			sim.setJointTargetVelocity(joint_front_right_wheel, -data.data[2]/50+data.data[1]/50)
			sim.setJointTargetVelocity(joint_back_right_wheel, -data.data[2]/50+data.data[1]/50)
			sim.setJointTargetVelocity(joint_back_left_wheel, data.data[2]/50+data.data[1]/50)
		end
		return self._ReturnCode_t.RTC_OK
	end
```

InPortで読み込んだデータを車輪の速度に入力しています。


CoppeliaSimの関数については以下のページが参考になります。

* [regular API reference](https://www.coppeliarobotics.com/helpFiles/en/apiFunctions.htm)

Managerの起動やRTCの生成処理を初期化処理の`sysCall_init`関数で呼ぶ必要があります。
またデフォルトではRTCは周期実行コンテキストを使用しますが、トリガ駆動実行コンテキスト(`OpenHRPExecutionContext`)に変更します。


```Lua
if openrtm.Manager.is_main() then
	function sysCall_init()
		local manager = openrtm.Manager
		manager:init({"-o","exec_cxt.periodic.type:OpenHRPExecutionContext"})
		manager:setModuleInitProc(MyModuleInit)
		manager:activateManager()
		manager:runManager(true)
	end
```

Manager、RTCの更新処理を`sysCall_actuation`、`sysCall_sensing`関数に記述します。
これでシミュレーション更新時にManagerの更新、RTCのコールバック関数呼び出し処理が実行されます。

```Lua
function sysCall_actuation()
    local openrtm = require "openrtm"
    local mgr = openrtm.Manager
    mgr:step()

    local comp = mgr:getComponent("CoppeliaSimSample0")
    local ec = comp:get_owned_contexts()[1]
    ec:tick()
end
```

Managerの終了処理を`sysCall_cleanup`関数に記述することで、シミュレーション終了時にManager、RTCが終了します。

```Lua
function sysCall_cleanup()
    local openrtm = require "openrtm"
    local mgr = openrtm.Manager
    mgr:shutdown()
end
```


## 動作確認
### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](download.md)

### ロボット配置
`robots`->`mobile`->`Robotnik_Summit_XL140701.ttm`をドラックアンドドロップして配置します。
![openrtmlua380](https://user-images.githubusercontent.com/6216077/37711260-7f81a71a-2d53-11e8-8af2-60da43c26fe0.png)
`new scene(scene1)`のツリーから`Robotnik_Summit_XL`の名前の右にあるアイコンをクリックするとLuaスクリプトの編集ウインドウが起動します。
![openrtmlua390](https://user-images.githubusercontent.com/6216077/37711268-858b96ac-2d53-11e8-86e6-6f98ca931ed9.png)
その上に先ほど作成した`CoppeliaSimSample.lua`のソースコードを全て上書きしてください。
![imagesourcecode](https://user-images.githubusercontent.com/6216077/159617516-d100a335-6f04-44c1-96d1-5435310cd3c7.png)
### RTC起動

CoppeliaSim上で以下のボタンを押すとシミュレーションが開始してRTCが起動します。
![openrtmlua430](https://user-images.githubusercontent.com/6216077/37711279-8f7d9eee-2d53-11e8-99f3-49e041036896.png)

### RTSystem作成

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。

![system0](https://user-images.githubusercontent.com/6216077/159617836-40c13ce0-4b16-43a9-8783-cce2dc9e799b.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![system1](https://user-images.githubusercontent.com/6216077/159617650-58fd739e-551b-4409-bdbc-294c9a601419.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。

![sysrem3](https://user-images.githubusercontent.com/6216077/159617720-a89bb964-6893-4a3d-b2ea-8e2f7938ade2.png)


`TkJoyStick0`の`pos`のOutPortを、`CoppeliaSimSample0`inのInPortにドラックアンドドロップしてください。 これで通信ができるようになります。

![system4](https://user-images.githubusercontent.com/6216077/159617914-f3129269-8dd2-438d-ba54-1261e14488e6.png)

ここで`TkJoyStick0`の実行周期を10Hz定します。デフォルトでは1000Hzですが、CoppeliaSimSample0側のデータ受信の頻度が多いとシミュレーションが遅くなるため調整します。
システムダイアグラム上の`TkJoyStick0`をクリックして選択後に、Execution Context Viewタブを表示します。
その後、`rate`を`10`に変更後、`適用`ボタンを押します。

![system5](https://user-images.githubusercontent.com/6216077/159617959-943f6bf9-1949-457e-8af2-7d689a311cdf.png)

`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるため操作ができるようになります。

![system6](https://user-images.githubusercontent.com/6216077/159618029-466616a9-7eef-4f93-98c4-3cd8a14eee5d.png)


### コネクタ接続、RTCのアクティブ化の自動化

CoppeliaSimSample.luaのmanager:init関数の引数を以下のように変更してください。

```Lua
manager:init({"-o","exec_cxt.periodic.type:OpenHRPExecutionContext",
	"-o", "manager.components.preconnect:CoppeliaSimSample0.in?port=rtcname://localhost/TkJoyStick0.pos",
	"-o", "manager.components.preactivation:CoppeliaSimSample0,rtcname://localhost/TkJoyStick0",})
```

`-o`オプションでパラメータの設定ができます。

* `"-o", "manager.components.preconnect:CoppeliaSimSample0.in?port=rtcname://localhost/TkJoyStick0.pos"`

起動時に接続するポートを指定します。 この場合は`CoppeliaSimSample0`というRTCの`in`というデータポートを、`TkJoyStick0`というRTCの`pos`というポートに接続します。

ただし、`TkJoyStick0`は別プロセスで起動しているため、`rtcname形式`による指定が必要になります。 `rtcname形式`はネームサーバーからRTCを取得する方法です。`rtcname://アドレス/RTC名.ポート名`で指定します。

* `"-o","manager.components.preactivation:CoppeliaSimSample0,rtcname://localhost/TkJoyStick0"`

また、以下のコードを追加することでTkJoyStick0の実行周期を変更できます。

```Lua
local naming = manager:getNaming()
local comps = naming:string_to_component("rtcname://localhost/TkJoyStick0")
local ec = comps[1]:get_owned_contexts()[1]
ec:set_rate(10)
```


起動時にアクティブ化するRTCを指定します。

### rtc.confのパス
`coppeliaSim.exe`と同じフォルダのrtc.confを読み込みます。
