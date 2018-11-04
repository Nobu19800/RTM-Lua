# 用語集

## RTミドルウェア
ソフトウェアモジュールを組み合わせてロボット技術を用いたシステム(RTシステム)を構築するための標準規格。
詳細は[Wikipedia](https://ja.wikipedia.org/wiki/RT%E3%83%9F%E3%83%89%E3%83%AB%E3%82%A6%E3%82%A8%E3%82%A2)でも見てください。
## RTコンポーネント
ロボット技術を用いたソフトウェアモジュールのことをRTコンポーネント(RTC)といいます。
RTCにはコンポーネントの基本情報(コンポーネントプロファイル)、他のRTCとやり取りするためのポート(データポート、サービスポート)、コンフィギュレーションパラメータ、ライフサイクルという要素から成り立っています。

OpenRTM-aist付属のIDLファイルに定義されたインターフェースは以下のようになっています。

![class0](https://user-images.githubusercontent.com/6216077/47964352-19e7fa80-e07c-11e8-9423-fe18279b4538.png)

RTミドルウェアの規格はプラットフォーム独立モデルで定義されているため、上記のインターフェースが定義できればCORBA以外のRPCができる通信ライブラリでも実装できます。ただし既存のOpenRTM-aist等とは通信できなくなります。

RT System EditorからRTCを操作するためには、最低でもコンポーネントプロファイルを取得する`get_component_profile`、ポート一覧を取得する`get_ports`、RTCを終了させる`exit`が必要になるため、最低でも`RTC::RTObject`の実装が必要になります。

`RTC::RTObject`の実装のためには`RTC::ComponentAction`、`RTC::LightweightRTObject`、`SDOPackage::SDOSystemElement`、`SDOPackage::SDO`の実装が必要になります。

`ComponentAction`インターフェースで定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|on_initialize|初期化時に呼び出す|
|on_finalize|終了時に呼び出す|
|**on_startup**|実行コンテキスト開始時に呼び出す|
|**on_shutdown**|実行コンテキスト停止時に呼び出す|
|**on_activated**|アクティブ状態遷移時に呼び出す|
|**on_deactivated**|非アクティブ状態遷移時に呼び出す|
|**on_aborting**|エラー状態遷移時に呼び出す|
|**on_error**|エラー状態時に呼び出す|
|**on_reset**|リセット実行時に呼び出す|

上記の太字のオペレーションは実行コンテキストから呼び出されます。

![on_activated](https://user-images.githubusercontent.com/6216077/47964658-5b7aa480-e080-11e8-9bb9-a5828d747e80.png)

機能として実行コンテキストが別のプロセス、マシン上のRTCを操作する機能を削る場合は、`ComponentAction`インターフェースのオペレーションはリモート呼び出しする必要がないためCORBAで実装する必要もありません。




### データポート
#### InPort
#### OutPort
#### データ型
#### インターフェース型
##### corba_cdr
##### data_service
##### shared_memory
##### direct
#### データフロー型
##### Push型
##### Pull型
#### サブスクリプション型
##### flush
##### new
##### periodic
#### 独自データ型
### サービスポート
### コンフィグレーションパラメータ
### ライフサイクル
#### Inactivate
#### Activate
#### Error
## 実行コンテキスト
### PeriodicExecutionContext
### SimulatorExecutionContext
## マネージャ
## RTシステム
## 複合コンポーネント
## IDLファイル
## SDOサービス
### コンポーネントオブザーバ
## FSM4RTC
### CSP
## ロガー
## ナンバリングポリシー
## CORBA
### CORBAの実装例
#### omniORB
#### TAO
#### ORBexpress
#### OiL
## ネームサーバー
## OpenRTM-aist
## rtc.conf
