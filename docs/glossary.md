# 用語集

## RTミドルウェア
ソフトウェアモジュールを組み合わせてロボット技術を用いたシステム(RTシステム)を構築するための標準規格。
詳細は[Wikipedia](https://ja.wikipedia.org/wiki/RT%E3%83%9F%E3%83%89%E3%83%AB%E3%82%A6%E3%82%A8%E3%82%A2)でも見てください。
## RTコンポーネント
ロボット技術を用いたソフトウェアモジュールのことをRTコンポーネント(RTC)といいます。
RTCにはコンポーネントの基本情報(コンポーネントプロファイル)、他のRTCとやり取りするためのポート(データポート、サービスポート)、コンフィギュレーションパラメータ、ライフサイクルという要素から成り立っています。

OpenRTM-aist付属のIDLファイルに定義されたインターフェースは以下のようになっています。

![rtobject](https://user-images.githubusercontent.com/6216077/48066667-8fd19a80-e211-11e8-9357-0c2964a1cb04.png)

RTミドルウェアの規格はプラットフォーム独立モデルで定義されているため、上記のインターフェースが定義できればCORBA以外のRPCができる通信ライブラリでも実装できます。ただし既存のOpenRTM-aist等とは通信できなくなります。

RT System EditorからRTCを操作するためには、最低でもコンポーネントプロファイルを取得する`get_component_profile`、ポート一覧を取得する`get_ports`、RTCを終了させる`exit`が必要になるため、最低でも`RTC::RTObject`の実装が必要になります。

`RTC::RTObject`の実装のためには`RTC::ComponentAction`、`RTC::LightweightRTObject`、`SDOPackage::SDOSystemElement`、`SDOPackage::SDO`の実装が必要になります。

`RTC::ComponentAction`インターフェースで定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|on_initialize|初期化時のコールバック関数|
|on_finalize|終了時のコールバック関数|
|**on_startup**|実行コンテキスト開始時のコールバック関数|
|**on_shutdown**|実行コンテキスト停止時のコールバック関数|
|**on_activated**|アクティブ状態遷移時のコールバック関数|
|**on_deactivated**|非アクティブ状態遷移時のコールバック関数|
|**on_aborting**|エラー状態遷移時のコールバック関数|
|**on_error**|エラー状態時のコールバック関数、周期実行の場合には周期的に呼び出される|
|**on_reset**|リセット実行時のコールバック関数|

上記の太字のオペレーションは実行コンテキストから呼び出されます。

![on_activated](https://user-images.githubusercontent.com/6216077/48067694-39b22680-e214-11e8-9442-fc8df7717f56.png)


`on_initialize`、`on_finalize`はOpenRTM-aistでは内部からしか呼び出されるようになっていない。

機能として実行コンテキストが別のプロセス、マシン上のRTCを操作する機能を削る場合は、`ComponentAction`インターフェースのオペレーションはリモート呼び出しする必要がないためCORBAで実装する必要もありません。


`RTC::LightweightRTObject`インターフェースで定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|initialize|初期化時に呼び出す|
|finalize|終了時に呼び出す|
|is_alive|指定実行コンテキストで生存しているか確認|
|exit|終了処理実行|
|attach_context|実行コンテキストを関連付ける|
|detach_context|実行コンテキストの関連付け解除|
|get_context|指定IDの実行コンテキストを取得|
|get_owned_contexts|自身がオーナーの実行コンテキストを取得|
|get_participating_contexts|自身以外がオーナーの実行コンテキストを取得|
|get_context_handle|指定実行コンテキストのIDを取得|


`initialize`、`finalize`はOpenRTM-aistでは内部からしか呼び出されない。
外部の実行コンテキストと関連付ける必要がない場合は`exit`以外のオペレーションはCORBAで実装する必要はありません。


`RTC::DataFlowComponentAction`インターフェースで定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|on_execute|アクティブ状態時のコールバック関数、周期実行の場合には周期的に呼び出される|
|on_state_update|状態更新時のコールバック関数、アクティブ状態、エラー状態の時に周期実行の場合には周期的に呼び出される|
|on_rate_changed|実行周期変更時のコールバック関数|

この中で重要なのは`on_execute`オペレーション。
内部の実行コンテキストとしか関連付けしない場合はCORBAで実装する必要はない。


`SDOPackage::SDOSystemElement`インターフェースで定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|get_owned_organizations|自身が保持している構成要素の取得|

`get_owned_organizations`は自身が複合コンポーネントの場合に、複合コンポーネントを構成している子コンポーネントを取得できます。
よって、複合コンポーネントを実装しない場合は`get_owned_organizations`オペレーションを実装する必要もありません。


`SDOPackage::SDO`インターフェースで定義されたオペレーションは以下の通りです。


|名前|意味|
|---|---|
|get_sdo_id|実質的に機能していない|
|get_sdo_type|実質的に機能していない|
|get_device_profile|実質的に機能していない|
|get_service_profiles|実質的に機能していない|
|get_service_profile|実質的に機能していない|
|get_sdo_service|実質的に機能していない|
|get_configuration|コンフィギュレーション取得|
|get_monitoring|実質的に機能していない|
|get_organizations|構成要素の取得|
|get_status_list|実質的に機能していない|
|get_status|実質的に機能していない|


実質的に機能しているのは`get_configuration`、`get_organizations`のみ。
使わないオペレーションが大量に定義されているため、ビルド後のバイナリのサイズが大きくなる原因の1つになっている。

`get_configuration`で取得したSDOコンフィギュレーションはコンポーネントオブザーバー等のサービスの設定、コンフィギュレーションパラメータの設定を行う機能を提供します。
`get_organizations`は複合コンポーネントの親コンポーネントを取得します。

上記の機能が必要ない場合は実装の必要はありません。


`RTC::RTObject`インターフェースで定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|get_component_profile|コンポーネントプロファイルの取得|
|get_ports|ポートの一覧取得|

これらのオペレーションをCORBAで実装すればRTSystemEditorから情報取得ができるようになります。

コンポーネントプロファイルは以下のような構造になっています。

<pre>  
  struct ComponentProfile
  {
    string instance_name;
    string type_name;
    string description;
    string version;
    string vendor;
    string category;
    PortProfileList port_profiles;
    RTObject parent;
    NVList properties;
  };
</pre>

RTSystemEditorでは`port_profiles`に格納したポートプロファイル一覧を取得後、`PortProfile`からポートの種類、接続したコネクタ一覧の情報を取得しています。

<pre>
  struct ConnectorProfile
  {
    string name;
    UniqueIdentifier connector_id;
    PortServiceList ports;
    NVList properties;
  };
  
  typedef sequence<ConnectorProfile> ConnectorProfileList;
  
  enum PortInterfacePolarity
  {
    PROVIDED,
    REQUIRED
  };
  
  struct PortInterfaceProfile
  {
    string instance_name;
    string type_name;
    PortInterfacePolarity polarity;
  };
  
  typedef sequence<PortInterfaceProfile> PortInterfaceProfileList;
  
  struct PortProfile
  {
    string name;
    PortInterfaceProfileList interfaces;
    PortService port_ref;
    ConnectorProfileList connector_profiles;
    RTObject owner;
    NVList properties;
  };
  
  typedef sequence<PortProfile> PortProfileList;
</pre>


`PortProfile`の`properties`には以下の情報を格納します。

|パラメータ名|意味|
|---|---|
|port.port_type|ポートの種類(DataOutPort、DataInPort、CorbaPort)|
|dataport.data_type|データ型|

サービスポートの場合は、`interfaces`にインターフェースの情報を格納します。


### データポート
データポートはデータを連続的に転送するためのポートです。
インターフェースとしてはデータポート、サービスポートに違いはなく、以下の`PortService`インターフェースで定義されています。


![portservice](https://user-images.githubusercontent.com/6216077/48066666-8f390400-e211-11e8-9df5-2e97a0be3db5.png)


|名前|意味|
|---|---|
|get_port_profile|ポートプロファイル取得|
|get_connector_profiles|コネクタプロファイル一覧取得|
|get_connector_profile|指定IDのコネクタプロファイルを取得|
|connect|コネクタ接続|
|disconnect|コネクタ切断|
|disconnect_all|全てのコネクタ切断|
|notify_connect|コネクタ接続を通知|
|notify_disconnect|コネクタ切断を通知|

RTSystemEditorで操作する際は上記のオペレーションはすべて実装が必須です。
`PortService`ではデータを転送するインターフェースは定義されておらず、`notify_connect`内でコネクションを確立するための処理を行います。

RTSystemEditorからは`connect`オペレーションを呼び出します。
その後は`PortService`の間で`notify_connect`を呼び出します。
ただし、`notify_connect`がどの順序で呼び出されるかは、`connect`の引数で渡したコネクタプロファイルに格納したポートの順番に依存します。

![connect1](https://user-images.githubusercontent.com/6216077/48067382-80535100-e213-11e8-8126-14327d51291e.png)
![connect2](https://user-images.githubusercontent.com/6216077/48067383-80535100-e213-11e8-8b16-9e45a2dd4ef6.png)


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
