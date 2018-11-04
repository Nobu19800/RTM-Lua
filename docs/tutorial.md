# 動作確認手順

OpenRTM-aistをインストールしていることを前提にしています。

## OpenRTPの起動
まずOpenRTPを起動してください。
OpenRTPはOpenRTM-aistに付属しているRTミドルウェアの開発ツールです。


デスクトップの`OpenRTP x86_64`をダブルクリックして起動します。

![tutorial1](https://user-images.githubusercontent.com/6216077/47963219-3845fa00-e06c-11e8-8fbb-8efce9b3c6e1.png)

## RT System Editorの起動
次にOpenRTP上でRT System Editorを起動します。
RT System EditorはRTCを組み合わせてRTシステムを構築するためのツールです。
RTCの状態の操作、コネクタの接続などができます。

`パースペクティブ`を開くボタンを押して表示したウィンドウから`RT System Editor`を選択して開くボタンを押します。

![tutorial2](https://user-images.githubusercontent.com/6216077/47963218-37ad6380-e06c-11e8-8af6-a157897b4c73.png)

![tutorial3](https://user-images.githubusercontent.com/6216077/47963217-37ad6380-e06c-11e8-90af-da7f3bd0956e.png)


## ネームサーバーの起動

ネームサーバーを起動します。
ネームサーバーはCORBAオブジェクトを名前で管理するためのサービスです。

ネームサービスビューの`ネームサービスを起動`ボタンから起動してください。

![tutorial4](https://user-images.githubusercontent.com/6216077/47963216-37ad6380-e06c-11e8-8263-6ec19fc99670.png)

ネームサーバーが起動すると以下のようにネームサービスビューにlocalhostと表示されます。

![tutorial5](https://user-images.githubusercontent.com/6216077/47963215-3714cd00-e06c-11e8-8e97-547e7aef1df1.png)

## RTCの起動
OpenRTM Luaの`samples`フォルダ内の以下のバッチファイルを実行するとサンプルのRTCが起動します。
`ConsoleIn`は標準入力した数値をOutPortから出力するサンプル、`ConsoleOut`はInPortに入力した数値を標準出力するサンプルコンポーネントです。
今回は`ConsoleIn`で標準入力した数値を`ConsoleOut`に送信して表示するシステムを構築します。

* `ConsoleIn.bat`
* `ConsoleOut.bat`

RTCが起動するとネームサービスビューに`ConsoleIn0`と`ConsoleOut0`が表示されます。

![tutorial6](https://user-images.githubusercontent.com/6216077/47963213-3714cd00-e06c-11e8-95a7-a18517af728b.png)

## RTシステムの構築
`Open New System Editor`ボタンを押してシステムダイアグラムを表示します。

![tutorial7](https://user-images.githubusercontent.com/6216077/47963212-3714cd00-e06c-11e8-96e7-a8728b858b8c.png)

システムダイアグラム上に`ConsoleIn0`と`ConsoleOut0`をドラックアンドドロップして並べます。
システムダイアグラム上の表示でRTCがどのようなポートを持っているのか、どのような状態なのかが一目でわかります。

![tutorial8](https://user-images.githubusercontent.com/6216077/47963225-38de9080-e06c-11e8-881d-563598b56aa5.png)

現在、`ConsoleIn0`と`ConsoleOut0`は通信できる状態ではないため、コネクタを生成して通信できるようにします。

`ConsoleIn0`の`out`から`ConsoleOut0`の`in`にドラックアンドドロップすることでコネクタを生成します。

![tutorial9](https://user-images.githubusercontent.com/6216077/47963224-38de9080-e06c-11e8-9ea7-46330b5d1bfb.png)

コネクタプロファイルの設定はそのままでOKボタンを押します。

![tutorial10](https://user-images.githubusercontent.com/6216077/47963223-38de9080-e06c-11e8-9e12-90f177ea7f7f.png)

接続に成功するとポートが線で接続されます。

![tutorial11](https://user-images.githubusercontent.com/6216077/47963222-3845fa00-e06c-11e8-8d3b-83f99ab3c320.png)

RTCには`Inactive`、`Active`、`Error`という状態があります。
`ConsoleIn0`がデータを出力する、`ConsoleOut0`が入力データを表示するという処理は`Active`状態に遷移しないと実行しません。
`Activate Systems`ボタンでRTCをアクティブ化します。

![tutorial12](https://user-images.githubusercontent.com/6216077/47963221-3845fa00-e06c-11e8-88ba-aacc93a888bf.png)

すると`ConsoleIn.bat`を実行したときに表示されたウィンドウに`Please input number:`と表示されるため、数値を入力してください。

入力した数値は`ConsoleOut.bat`のウィンドウで表示されます。

![tutorial13](https://user-images.githubusercontent.com/6216077/47963220-3845fa00-e06c-11e8-9113-eb065b47888a.png)
