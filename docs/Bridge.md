# ブリッジRTCの使用方法

このページではOpenRTM-aist従来の`corba_cdr型`とFSM4RTC標準の`data_service`型インターフェースを接続するブリッジの使用方法について説明します。
Windowsの場合は実行ファイルを用意してありますが、他の環境の場合はOpenRTM-aist Python版の2.0.0が必要になります。

Windowsの場合は以下のファイルをダウンロードして適当な場所に展開してください。

* [Bridge.zip](https://github.com/Nobu19800/RTCBridge/releases/download/v.0.1.0/Bridge.zip)

他の環境の場合は、Pythonのコードを入手して実行します。

* [RTCBridge](https://github.com/Nobu19800/RTCBridge)

使用するデータポートの数を設定します。
`Bridge.conf`をテキストエディタで開いて、`conf.default.port_num`の数を変更してください。

<pre>
conf.default.port_num: 5
</pre>



設定後、`Bridge.exe`(もしくはBridge.py)を実行するとRTCが起動するため、ブリッジ接続したいポートをBridgeコンポーネントのポートに接続してください。

![bridge0](https://user-images.githubusercontent.com/6216077/49053785-e6406080-f234-11e8-9997-4ff44619aed4.png)

同じ番号のInPort、OutPortで変換を行います。`in0`のInPortは、`out0`のOutPortに対応しています。
