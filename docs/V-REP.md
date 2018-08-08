# V‐REP上で動作するRTCの作成方法
このページでは物理シミュレータV-REP上で動作する上で動作するRTCを作成して、以下のようにPython版サンプルコンポーネントのジョイスティックコンポーネントと接続して車体を操作するシステムの作成を行います。

* https://www.youtube.com/watch?v=EaQ2oOxfhSY


## V-REPのインストール
以下からV-REPのインストーラーを入手してインストールしてください。

* http://www.coppeliarobotics.com/downloads.html

## V-REPにOpenRTM Lua版をインストール
V-REPをインストールしたフォルダ(`C:\Program Files\V-REP3`)にOpenRTM Lua版の各ファイルをコピーします。

以下から64bit用のOpenRTM Lua版ファイル一式(OpenRTM Lua x.y.z 64bit)をダウンロードしてください。

* [ダウンロード](ダウンロード)

OpenRTM Lua版からV-REPにファイルをコピーします。

`openrtm-lua-x.y.z(x64)\lua\`以下のファイルを全て`C:\Program Files\V-REP3\V-REP_PRO_EDU\lua\`以下にコピーしてください。

![openrtmlua340](https://user-images.githubusercontent.com/6216077/37710309-97ec79f4-2d50-11e8-9f3c-3efd55eac308.png)


次に`openrtm-lua-x.y.z(x64)\clibs\`以下のファイルを全て`C:\Program Files\V-REP3\V-REP_PRO_EDU\`以下にコピーしてください。


![openrtmlua360](https://user-images.githubusercontent.com/6216077/37710315-9af9581a-2d50-11e8-803d-560ab910f990.png)



## RTC作成
RTC BuilderによるRTCの基本的な作成手順は以下のページを参考にしてください。

* [RTC作成手順](RTC作成手順)

上のページの作成手順に従って、以下の仕様のRTCを作成してください。



### 基本プロファイル
|||
|---|---|
|モジュール名|VRepSample|


### アクティビティ

`onExecute`を有効にしてください。

### インポート
|||
|---|---|
|ポート名|in|
|データ型|RTC::TimedFloatSeq|


### VRepSample.luaの編集

ソースコードの先頭付近に以下の行を追加して、シミュレーションのスレッドと自動的に切り替える機能をオフにしてください。
機能をオフにした場合、`simSwitchThread`関数によりシミュレーションを進める必要があります。

<pre>
simSetThreadAutomaticSwitch(false)
</pre>

`onExecute`関数を以下のように編集してください。

<pre>
	function obj:onExecute(ec_id)
            simSwitchThread()
            if self._inIn:isNew() then
                local data = self._inIn:read()
                local joint_front_left_wheel=simGetObjectHandle('joint_front_left_wheel')
                local joint_front_right_wheel=simGetObjectHandle('joint_front_right_wheel')
                local joint_back_right_wheel=simGetObjectHandle('joint_back_right_wheel')
                local joint_back_left_wheel=simGetObjectHandle('joint_back_left_wheel')

                simSetJointTargetVelocity(joint_front_left_wheel, data.data[2]/50+data.data[1]/50)
                simSetJointTargetVelocity(joint_front_right_wheel, -data.data[2]/50+data.data[1]/50)
                simSetJointTargetVelocity(joint_back_right_wheel, -data.data[2]/50+data.data[1]/50)
                simSetJointTargetVelocity(joint_back_left_wheel, data.data[2]/50+data.data[1]/50)
            end
            return self._ReturnCode_t.RTC_OK
	end
</pre>

`simSwitchThread`関数によりシミュレーションを1ステップ進めています。

InPortで読み込んだデータを車輪の速度に入力しています。


V-REPの関数については以下のページが参考になります。

* [Virtual Robot Experimentation Platform
USER MANUAL](http://www.coppeliarobotics.com/helpFiles/en/apiOverview.htm)

## 動作確認
### ネームサーバー起動
事前にネームサーバーの起動が必要です。

* [OpenRTM-aistを10分で始めよう！](https://www.openrtm.org/openrtm/ja/node/6026#toc3)

※OpenRTM-aist 1.2以降ではRT System Editorにネームサーバー起動ボタンがあるため、手順が簡単になっています。

### TkJoyStickコンポーネントの起動

TkJoyStickコンポーネントを入手して、`TkJoyStickComp.exe`を実行してください。

* [ダウンロード](ダウンロード)

### ロボット配置
`robots`->`mobile`->`Robotnik_Summit_XL140701.ttm`をドラックアンドドロップして配置します。
![openrtmlua380](https://user-images.githubusercontent.com/6216077/37711260-7f81a71a-2d53-11e8-8af2-60da43c26fe0.png)
`new scene(scene1)`のツリーから`Robotnik_Summit_XL`の名前の右にあるアイコンをクリックするとLuaスクリプトの編集ウインドウが起動します。
![openrtmlua390](https://user-images.githubusercontent.com/6216077/37711268-858b96ac-2d53-11e8-86e6-6f98ca931ed9.png)
その上に先ほど作成した`VRepSample.lua`のソースコードを全て上書きしてください。
![openrtmlua420](https://user-images.githubusercontent.com/6216077/37711275-8b10246c-2d53-11e8-940d-0753acb63c8c.png)
### RTC起動

V-REP上で以下のボタンを押すとシミュレーションが開始してRTCが起動します。
![openrtmlua430](https://user-images.githubusercontent.com/6216077/37711279-8f7d9eee-2d53-11e8-99f3-49e041036896.png)

### RTSystem作成

まずRTCの起動に成功している場合は、以下のようにネームサービスビューにRTCが表示されます。

![openrtmlua550](https://user-images.githubusercontent.com/6216077/38161053-f6efeed6-3502-11e8-8b12-57f12b3ea6fb.png)

`Open New System Editor`ボタンを押してシステムダイアグラムを表示してください。

![openrtmlua560](https://user-images.githubusercontent.com/6216077/38161073-1fc67a14-3503-11e8-9060-9c843854d4bc.png)

ネームサービスビューからシステムダイアグラムにRTCをドラックアンドドロップしてください。

![openrtmlua570](https://user-images.githubusercontent.com/6216077/38161105-70eb8f10-3503-11e8-9b5d-c4435d4b4bba.png)


`TkJoyStick0`の`pos`のOutPortを、VRepSample0のinのInPortにドラックアンドドロップしてください。 これで通信ができるようになります。

![openrtmlua580](https://user-images.githubusercontent.com/6216077/38161120-cd5672ec-3503-11e8-8a8d-065fa7c2e5ab.png)

`All Activate`ボタンを押すと`TkJoyStick0`からデータが送信されるため操作ができるようになります。

![openrtmlua590](https://user-images.githubusercontent.com/6216077/38161127-e8b34b6e-3503-11e8-8a9a-4e96c2a41ba4.png)


### コネクタ接続、RTCのアクティブ化の自動化

VRepSample.luaのmanager:init関数の引数を以下のように変更してください。

<pre>
manager:init({"-o", "manager.components.preconnect:VRepSample0.in?port=rtcname://localhost/TkJoyStick0.pos", "-o", "manager.components.preactivation:VRepSample0,rtcname://localhost/TkJoyStick0"})
</pre>

`-o`オプションでパラメータの設定ができます。

* `"-o", "manager.components.preconnect:VRepSample0.in?port=rtcname://localhost/TkJoyStick0.pos"`

起動時に接続するポートを指定します。 この場合は`VRepSample0`というRTCの`in`というデータポートを、`TkJoyStick0`というRTCの`pos`というポートに接続します。

ただし、`TkJoyStick0`は別プロセスで起動しているため、`rtcname形式`による指定が必要になります。 `rtcname形式`はネームサーバーからRTCを取得する方法です。`rtcname://アドレス/RTC名.ポート名`で指定します。

* `"-o","manager.components.preactivation:VRepSample0,rtcname://localhost/TkJoyStick0"`


起動時にアクティブ化するRTCを指定します。
