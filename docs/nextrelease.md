# 次期リリースでの追加、修正項目




## 0.5.0(未定、状況次第ではリリース前に開発中止の可能性もあり)


* トピック通信機能

[luamqtt](https://luarocks.org/modules/xhaskx/luamqtt)、もしくは[mqtt_lua](https://github.com/geekscape/mqtt_lua)を使用したトピック通信機能を実装する。
会津大が開発している既存のMQTTによる通信インターフェースの仕様に合わせたものを作る。

* LuDOへの対応

* Lua-5.3、Lua-5.4への対応

* 簡易にRTCを作成できるライブラリ

PyRTSeamのようなツール

* コマンドラインツール

rtshellのようなツール

* ネームサーバー




## 実装する予定のない機能
* New、PeriodicのPublisher

Luaにはマルチスレッドがないため、実装しても意味がありません。
* FSM4RTC

相当な労力を要するため、実装予定はありません。
* 共有メモリ通信
* CORBA_IORUtilの実装
* CPUAffinity設定
* ComponentObserverの実装
* FluentBitのロガー機能
* ExtTrigExecutionContextの実装
* コネクタのタイムスタンプ機能
* トピックベースのポート接続機能

現在のところ実装予定なし。
