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

RTSystemEditorで情報を取得するためにはコンポーネントプロファイルを取得する機能を実装すれば充分であり、見た目上は既存のRTミドルウェアと変わらない動きをします。


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
`PortService`ではデータを転送するインターフェースは`data_service`インターフェースのみが規格で定義されており、他にユーザーが独自に作成したインターフェース等も拡張可能です。

`notify_connect`内でコネクションを確立するための処理を行います。

RTSystemEditorからは`connect`オペレーションを呼び出します。
その後は`PortService`の間で`notify_connect`を呼び出します。
ただし、`notify_connect`がどの順序で呼び出されるかは、`connect`の引数で渡したコネクタプロファイルに格納したポートの順番に依存します。

![connect1](https://user-images.githubusercontent.com/6216077/48294687-28de0b00-e4c9-11e8-9fc9-c4886c6c1643.png)
![connect2](https://user-images.githubusercontent.com/6216077/48294690-2c719200-e4c9-11e8-81ea-df6decbbadc9.png)

`notify_connect`内でどのような処理をするかは規格では定義されていません。
とりあえず、`notify_connect`処理後に`get_connector_profiles`で取得できるコネクタプロファイルが追加されていたら、RT System Editorからはポートが接続されているように見えます。



#### InPort
`InPort`は`OutPort`からデータを受信するポートです。
前述の通り、InPort、OutPortにインターフェースの違いはなく、`get_port_profile`で取得できるポートプロファイルの内容が違うだけです。

#### OutPort
`OutPort`は`InPort`にデータを送信するポートです。
`InPort`をデータが受信するポート、`OutPort`をデータを送信するポートにするためには、`notify_connect`内でコネクションを確立する処理をする必要があります。例えば、ソケット通信をする場合は`notify_connect`内でソケットの作成、接続を行い、`InPort`側ではrecv関数で待ち受け、`OutPort`側ではsend関数でデータ送信という事をします。

#### データ型
データ型には転送するデータの内容のことです。
データ型はOMG IDL構文で定義されています。
OpenRTM-aistには`BasicDataType.idl`、`ExtendedDataTypes.idl`、`InterfaceDataTypes.idl`のIDLファイルが付属しており、多数のデータ型が定義されています。
`BasicDataType.idl`には単純なDouble型のデータの送信、配列のデータの送信など基本的なデータ型が定義されています。
`ExtendedDataTypes.idl`には移動ロボットの速度指令など、拡張データ型が定義されています。
`InterfaceDataTypes.idl`にはカメラ画像のデータなど、複雑なデータ型が定義されています。

詳細は以下のページを参考にしてください。

* [データ型マニュアル](https://nobu19800.github.io/DataTypeManual/docs/)

##### 独自データ型
データ型にはOpenRTM-aist標準のデータ型以外に、独自IDLファイルによる独自データ型が定義できます。
以下はOpenRTM-aist 1.2での独自データ型作成手順です。


まずはIDLファイル(今回はtest.idl)を作成します。

OpenRTM-aist 1.2からは必ずデータ型にタイムスタンプが必要になったため、独自データ型作成の難易度が大幅に上がっています。
`BasicDataType.idl`をインクルードして、データ型にタイムスタンプ(`RTC::Time tm;`)を追加してください。

<pre>
#include "BasicDataType.idl"

module Sample {
    struct SampleDataType
    {
        RTC::Time tm;
        double data1;
        short data2;
    };
};
</pre>

次にRTC Builderのデータポート設定画面でIDLファイルの横のBrowse...ボタンを押してIDLファイルを選択します。

![rtcb1](https://user-images.githubusercontent.com/6216077/48300587-c9f9af80-e523-11e8-9e7a-ed7b8f182a24.png)

するとデータ型一覧に独自データ型が追加されます。

![rtcb2](https://user-images.githubusercontent.com/6216077/48300588-c9f9af80-e523-11e8-9967-cfd8bb88ca2c.png)


#### インターフェース型
インターフェース型はデータを転送する方法を定義しています。
OpenRTM-aist 2.0では`corba_cdr`、`data_service`、`shared_memory`、`direct`の4種類のインターフェース型が利用できます。
OpenRTM-aistのRTCと通信するためには、`notify_connect`の中でこれらのインターフェースのコネクションを確立するための処理をする必要があります。

##### corba_cdr
`corba_cdr`はCORBA通信でデータを転送するインターフェース型です。
`DataPort_OpenRTM.idl`ファイルで`InPortCdr`インターフェースと`OutPortCdr`インターフェースが定義されています。

<pre>
  interface InPortCdr
  {
    PortStatus put(in CdrData data);
  };
ports|{InPortOutPort}|
|
  interface OutPortCdr
  {
    PortStatus get(out CdrData data);
  };
</pre>

`InPortCdr`の`put`オペレーションは`OutPort`から`InPort`にデータを渡す`Push`型の通信の場合に使用します。
`OutPortCdr`の`put`オペレーションは`InPort`が`OutPort`からデータを取得する`Pull`型の通信の場合に使用します。


CORBA通信を行う場合には、CORBAオブジェクトリファレンス(InPortCdr、OutPortCdr)をクライアント側に渡す必要があります。

`connect`オペレーションはOutPort、InPortどちら側からも呼び出される可能性があります。

例えば、`connect`の引数で渡すコネクタプロファイルを以下のように設定します。

|名前|値|
|---|---|
|name|適当な名前|
|connector_id|空白|
|ports|{InPortのオブジェクトリファレンス、OutPortのオブジェクトリファレンス}|
|properties|{"dataport.interface_type":"corba_cdr", "dataport.dataflow_type","push"}|


この場合に`InPort`側の`connect`を呼び出すと以下のような処理になります。
これは、コネクタプロファイルの`ports`にInPortのオブジェクトリファレンスを先に格納しているためです。

![connect5](https://user-images.githubusercontent.com/6216077/48295494-a3aa2480-e4cf-11e8-87c6-3d5c1edc21d5.png)

ここで、(1)と(2)ではコネクタプロファイルの内容が変わっています。

|名前|値|
|---|---|
|name|適当な名前|
|connector_id|空白|
|ports|{InPortのオブジェクトリファレンス、OutPortのオブジェクトリファレンス}|
|properties|{"dataport.interface_type":"corba_cdr", "dataport.dataflow_type","push", "dataport.corba_cdr.inport_ior":InPortCdrのIOR文字列, "dataport.corba_cdr.inport_ref":InPortCdrのオブジェクトリファレンス}|

`Push`型のためInPort側に`InPortCdr`オブジェクトがあり、OutPort側で`InPortCdr`のオブジェクトリファレンスを取得して`put`関数をリモート呼び出しするということになります。

このため、`InPort`から`OutPort`の`notify_connect`を呼び出す時に`InPortCdr`のオブジェクトリファレンスが取得できるようになっている必要があります。


他に`OutPort`の`connect`を呼び出す場合、`ports`の順序で以下の処理順序があります。

![connect6](https://user-images.githubusercontent.com/6216077/48295493-a3aa2480-e4cf-11e8-8d62-1ed4506798e9.png)
![connect3](https://user-images.githubusercontent.com/6216077/48295495-a3aa2480-e4cf-11e8-98f3-5256a33dfa68.png)
![connect4](https://user-images.githubusercontent.com/6216077/48295496-a3aa2480-e4cf-11e8-995d-cee2a540446c.png)




##### data_service
`data_service`もCORBA通信のインターフェースですが、こちらは規格標準のインターフェースです。
`DataPort.idl`で定義されています。

<pre>
    interface DataPushService
    {
        PortStatus push(in OctetSeq data);
    };

    interface DataPullService
    {
        PortStatus pull(out OctetSeq data);
    };
</pre>

動作としては`corba_cdr`と同じです。

##### shared_memory
`shared_memory`は共有メモリによるデータ転送を行うインターフェース型です。


##### direct
`direct`は同一プロセス内で変数渡しによりデータの転送を行うインターフェース型です。

#### データフロー型
データフロー型はデータを転送する際の流れを定義します。
`Push`型は`OutPort`から`InPort`にデータを送る方式で、`Pull`型は`InPort`から`OutPort`のデータを取る方式です。

現在はPush型、Pull型の2種類ですが、例えばメッセージブローカーを介して通信する場合はPush型やPull型に当てはまらない通信になります。

現状、OpenRTM-aistではデータフロー型については拡張できるようになっていません。

#### サブスクリプション型
データフロー型がPush型の場合のみ、データの送信タイミングを`flush`、`new`、`perriodic`から選択できます。
##### flush
OutPortの`write`関数を呼び出した時点で即座にデータを送信する方式です。
##### new
OutPortの`write`関数を呼び出した時点ではリングバッファに格納しておいて、別スレッドでデータを送信する方式です。
`write`関数を呼び出すとデータ送信処理を1回実行するようにデータ送信スレッドに指令します。
既にデータ送信処理中に指令を送ってもさらに1回実行することはないため、データ送信処理中に`write`関数を呼び出すと、データが送信されない場合があります。
##### periodic
OutPortの`write`関数を呼び出した時点ではリングバッファに格納しておいて、別スレッドでデータを送信する方式です。
`new`型と違う点はデータ送信スレッドがデータ送信処理を周期的に実行している点です。
`new`型のようにデータの欠損が発生することはありませんが、データがすぐに送信されない場合があります。



### サービスポート
サービスポートはコマンドレベルの操作を提供する機能であり、単純なデータの転送だけではなく、特定の処理の呼び出し、処理結果の取得ということができます。
データポートを使うべきか、サービスポートを使うべきかは場合によりますが、例えば以下のような場合に使われる事があります。

* 1回しか呼び出さない処理(例：サーボの初期化)
* 特定のタイミングでデータを取得したい場合(例：ロボットのパラメータの取得)
* 特定のタイミングで処理をしたい(例：GUI上のボタンを押したタイミングで移動ロボットを特定の場所に移動させる)

データポート、サービスポートにインターフェースの違いはなく、`get_port_profile`で取得できるポートプロファイルの内容が違うだけです。

サービスポートの操作を呼び出す方法については特に規格では定義されておらず、OpenRTM-aistではCORBAによるリモート関数呼び出しで処理しています。

サービスポートには関数の処理を実装した`プロバイダ`と、関数をリモート呼び出しする側の`コンシューマ`のインターフェースを保持しています。

`connect`を呼び出すときのコネクタプロファイルを以下のように設定します。


|名前|値|
|---|---|
|name|適当な名前|
|connector_id|空白|
|ports|{ServicePort1のオブジェクトリファレンス、ServicePort2のオブジェクトリファレンス}|
|properties|{}|



そして`ServicePort1`の`connect`を呼び出すと、以下の順序で接続処理を行います。


![connect7](https://user-images.githubusercontent.com/6216077/48301010-f57f9880-e529-11e8-9a4d-b0da0cae0543.png)

`ServicePort1`がプロバイダインターフェースを保持している場合、(2)以降は以下のようにコネクタプロファイルにオブジェクトリファレンスが設定されます。

|名前|値|
|---|---|
|name|適当な名前|
|connector_id|空白|
|ports|{ServicePort1のオブジェクトリファレンス、ServicePort2のオブジェクトリファレンス}|
|properties|{"MyServiceProvider0.port.MyService.provided.MyService.myservice0":"IOR文字列", "port.MyService.myservice0":"IOR文字列"}|

`RTCのインスタンス名.port.型名.provided.インターフェースのインスタンス名`、もしくは`port.型名.インターフェースのインスタンス名`にオブジェクトのIOR文字列が格納されています。
型名にはIDLファイルで定義したインターフェース名が格納されるため、型名が一致しないとポートの接続はできません。
サービスポートは複数のインターフェースを持つことが可能ですが、インターフェース名が一致したプロバイダとコンシューマインターフェースを関連付けます。

`ports`の順番を入れ替えると以下のような処理となります。

![connect8](https://user-images.githubusercontent.com/6216077/48301011-f57f9880-e529-11e8-8aa1-39e4fd87a234.png)

### コンフィグレーションパラメータ
コンフィギュレーションパラメータは

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
### オブジェクトリファレンス
#### CDR
#### IOR
#### corbaloc
#### corbaname
## ネームサーバー
## OpenRTM-aist
## rtc.conf
