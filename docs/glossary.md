# 用語集

<!-- TOC -->

- [RTミドルウェア](#rtミドルウェア)
- [RTコンポーネント](#rtコンポーネント)
    - [データポート](#データポート)
        - [InPort](#inport)
        - [OutPort](#outport)
        - [データ型](#データ型)
            - [独自データ型](#独自データ型)
        - [インターフェース型](#インターフェース型)
            - [corba_cdr](#corba_cdr)
            - [data_service](#data_service)
            - [shared_memory](#shared_memory)
            - [direct](#direct)
        - [データフロー型](#データフロー型)
        - [サブスクリプション型](#サブスクリプション型)
            - [flush](#flush)
            - [new](#new)
            - [periodic](#periodic)
    - [サービスポート](#サービスポート)
    - [コンフィグレーションパラメータ](#コンフィグレーションパラメータ)
    - [ライフサイクル](#ライフサイクル)
        - [Inactivate](#inactivate)
        - [Activate](#activate)
        - [Error](#error)
- [実行コンテキスト](#実行コンテキスト)
    - [PeriodicExecutionContext](#periodicexecutioncontext)
    - [ExtTrigExecutionContext](#exttrigexecutioncontext)
    - [OpenHRPExecutionContext](#openhrpexecutioncontext)
    - [SimulatorExecutionContext](#simulatorexecutioncontext)
    - [RTPreemptEC](#rtpreemptec)
- [マネージャ](#マネージャ)
     - [マスターマネージャ](#マスターマネージャ)
     - [スレーブマネージャ](#スレーブマネージャ)
- [RTシステム](#rtシステム)
- [複合コンポーネント](#複合コンポーネント)
- [IDLファイル](#idlファイル)
- [SDOサービス](#sdoサービス)
    - [コンポーネントオブザーバ](#コンポーネントオブザーバ)
- [FSM4RTC](#fsm4rtc)
    - [CSP](#csp)
- [ロガー](#ロガー)
- [ナンバリングポリシー](#ナンバリングポリシー)
    - [process_unique](#process_unique)
    - [ns_unique](#ns_unique)
    - [node_unique](#node_unique)
- [CORBA](#corba)
    - [ORB](#orb)
    - [POA](#poa)
    - [CORBAの実装例](#corbaの実装例)
        - [omniORB](#omniorb)
        - [TAO](#tao)
        - [ORBexpress](#orbexpress)
        - [RtORB](#rtorb)
        - [IIOP.NET](#iiopnet)
        - [OpenORB](#openorb)
        - [OiL](#oil)
    - [オブジェクトリファレンス](#オブジェクトリファレンス)
    - [CDR](#cdr)
    - [IOR](#ior)
    - [GIOP](#giop)
    - [INS](#ins)
        - [corbaloc](#corbaloc)
        - [corbaname](#corbaname)
- [ネームサーバー](#ネームサーバー)
- [OpenRTM-aist](#openrtm-aist)
- [rtc.conf](#rtcconf)
- [Lua](#Lua)
    - [LuaJIT](#LuaJIT)
    - [LuaRocks](#LuaRocks)

<!-- /TOC -->

## RTミドルウェア
ソフトウェアモジュールを組み合わせてロボット技術を用いたシステム(RTシステム)を構築するための標準規格。OMG RTC。
詳細は[Wikipedia](https://ja.wikipedia.org/wiki/RT%E3%83%9F%E3%83%89%E3%83%AB%E3%82%A6%E3%82%A8%E3%82%A2)でも見てください。

規格の詳細は以下のページから見れます。

* [RTC](https://www.omg.org/spec/RTC/About-RTC/)
* [FSM4RTC](https://www.omg.org/spec/FSM4RTC/About-FSM4RTC/)

主に以下の機能が定義されています。

* RTコンポーネントの情報取得
* 実行コンテキストによるRTコンポーネントの状態管理
* ポートを接続するための機能
* SDOコンフィギュレーション、SDOサービスに関連する機能
* データを転送するためのインターフェース(FSM4RTC)
* RTCの状態通知機能(FSM4RTC)
* 有限状態機械のための仕組み(FSM4RTC)


RTCの情報取得の機能が規格で定義されており、どのような機能、ポートのRTCなのか分かりやすいのは特徴の一つです。


## RTコンポーネント
ロボット技術を用いたソフトウェアモジュールのことをRTコンポーネント( Robot Technology Component、RTC)といいます。
RTCにはコンポーネントの基本情報(コンポーネントプロファイル)、他のRTCとやり取りするためのポート(データポート、サービスポート)、コンフィギュレーションパラメータ、ライフサイクルという要素から成り立っています。

![rtc1](https://user-images.githubusercontent.com/6216077/48332599-d141ca00-e697-11e8-95ed-745b6e4c90bc.png)

OpenRTM-aist付属のIDLファイルに定義されたインターフェースは以下のようになっています。

![rtobject](https://user-images.githubusercontent.com/6216077/48303258-6d11ef80-e54b-11e8-9fda-7f1d83377983.png)




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


`on_initialize`、`on_finalize`はOpenRTM-aistでは内部からしか呼び出されない。

実行コンテキストが別のプロセス、別のマシン上のRTCを操作する機能を削る場合は、`ComponentAction`インターフェースのオペレーションはリモート呼び出しする必要がないためCORBAで実装する必要もありません。


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
  
  
  struct PortProfile
  {
    string name;
    PortInterfaceProfileList interfaces;
    PortService port_ref;
    ConnectorProfileList connector_profiles;
    RTObject owner;
    NVList properties;
  };
  

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


![portservice](https://user-images.githubusercontent.com/6216077/48302008-f15b7700-e539-11e8-9041-febfd5c16c54.png)


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

![dataport1](https://user-images.githubusercontent.com/6216077/48302104-48158080-e53b-11e8-8a90-c91399dafe5e.png)

![dataport2](https://user-images.githubusercontent.com/6216077/48302111-857a0e00-e53b-11e8-8d29-d7779354edae.png)



`InPortCdr`の`put`オペレーションは`OutPort`から`InPort`にデータを渡す`Push`型の通信の場合に使用します。
`OutPortCdr`の`put`オペレーションは`InPort`が`OutPort`からデータを取得する`Pull`型の通信の場合に使用します。


CORBA通信を行う場合には、CORBAオブジェクトリファレンス(InPortCdr、OutPortCdr)をクライアント側に渡す必要があります。

`connect`オペレーションはOutPort、InPortどちら側からも呼び出される可能性があります。

例えば、`connect`の引数で渡すコネクタプロファイルを以下のように設定します。

|名前|型|値|
|---|---|---|
|name|string|適当な名前|
|connector_id|UniqueIdentifier|空白|
|ports|PortServiceList|{InPortのオブジェクトリファレンス、OutPortのオブジェクトリファレンス}|
|properties|NVList|{"dataport.interface_type":"corba_cdr", "dataport.dataflow_type","push"}|


この場合に`InPort`側の`connect`を呼び出すと以下のような処理になります。
これは、コネクタプロファイルの`ports`にInPortのオブジェクトリファレンスを先に格納しているためです。

![connect5](https://user-images.githubusercontent.com/6216077/48295494-a3aa2480-e4cf-11e8-87c6-3d5c1edc21d5.png)

ここで、(1)と(2)ではコネクタプロファイルの内容が変わっています。

|名前|型|値|
|---|---|---|
|name|適当な名前|
|connector_id|string|空白|
|ports|UniqueIdentifier|{InPortのオブジェクトリファレンス、OutPortのオブジェクトリファレンス}|
|properties|PortServiceList|NVList|{"dataport.interface_type":"corba_cdr", "dataport.dataflow_type","push", "dataport.corba_cdr.inport_ior":InPortCdrのIOR文字列, "dataport.corba_cdr.inport_ref":InPortCdrのオブジェクトリファレンス}|

`Push`型のためInPort側に`InPortCdr`オブジェクトがあり、OutPort側で`InPortCdr`のオブジェクトリファレンスを取得して`put`関数をリモート呼び出しするということになります。

このため、`InPort`から`OutPort`の`notify_connect`を呼び出す時に`InPortCdr`のオブジェクトリファレンスが取得できるようになっている必要があります。


他に`OutPort`の`connect`を呼び出す場合、`ports`の順序で以下の処理順序があります。

![connect6](https://user-images.githubusercontent.com/6216077/48295493-a3aa2480-e4cf-11e8-8d62-1ed4506798e9.png)
![connect3](https://user-images.githubusercontent.com/6216077/48295495-a3aa2480-e4cf-11e8-98f3-5256a33dfa68.png)
![connect4](https://user-images.githubusercontent.com/6216077/48295496-a3aa2480-e4cf-11e8-995d-cee2a540446c.png)




##### data_service
`data_service`もCORBA通信のインターフェースですが、こちらは規格標準のインターフェースです。
`DataPort.idl`で定義されています。

![dataport3](https://user-images.githubusercontent.com/6216077/48302195-95462200-e53c-11e8-8c76-70c8d65b3c53.png)
![dataport4](https://user-images.githubusercontent.com/6216077/48302196-95462200-e53c-11e8-96c5-2069c55706b3.png)


動作としては`corba_cdr`と同じです。

##### shared_memory
`shared_memory`は共有メモリによるデータ転送を行うインターフェース型です。


##### direct
`direct`は同一プロセス内で変数渡しによりデータの転送を行うインターフェース型です。

#### データフロー型
データフロー型はデータを転送する際の流れを定義します。
`Push`型は`OutPort`から`InPort`にデータを送る方式で、`Pull`型は`InPort`から`OutPort`のデータを取る方式です。

以下はPush型の通信です。

![push](https://user-images.githubusercontent.com/6216077/48321007-7cd02780-e662-11e8-982f-1ad940ccd538.png)

以下はPull型の通信です。

![pull](https://user-images.githubusercontent.com/6216077/48321006-7cd02780-e662-11e8-9b4b-4ecb068ae3a2.png)

現在はPush型、Pull型の2種類ですが、例えばメッセージブローカーを介して通信する場合はPush型やPull型に当てはまらない通信になります。

![topic](https://user-images.githubusercontent.com/6216077/48321005-7cd02780-e662-11e8-818a-9e9086eeada5.png)

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

![rtse2](https://user-images.githubusercontent.com/6216077/48301754-341b5000-e536-11e8-8247-74a12582acab.png)

サービスポートには関数の処理を実装した`プロバイダ`と、関数をリモート呼び出しする側の`コンシューマ`のインターフェースを保持しています。

`connect`を呼び出すときのコネクタプロファイルを以下のように設定します。


|名前|型|値|
|---|---|---|
|name|適当な名前|
|connector_id|string|空白|
|ports|PortServiceList|{ServicePort1のオブジェクトリファレンス、ServicePort2のオブジェクトリファレンス}|
|properties|NVList|{}|



そして`ServicePort1`の`connect`を呼び出すと、以下の順序で接続処理を行います。


![connect7](https://user-images.githubusercontent.com/6216077/48301010-f57f9880-e529-11e8-9a4d-b0da0cae0543.png)

`ServicePort1`がプロバイダインターフェースを保持している場合、(2)以降は以下のようにコネクタプロファイルにオブジェクトリファレンスが設定されます。

|名前|型|値|
|---|---|---|
|name|適当な名前|
|connector_id|string|空白|
|ports|PortServiceList|{ServicePort1のオブジェクトリファレンス、ServicePort2のオブジェクトリファレンス}|
|properties|NVList|{"MyServiceProvider0.port.MyService.provided.MyService.myservice0":"IOR文字列", "port.MyService.myservice0":"IOR文字列"}|

`RTCのインスタンス名.port.型名.provided.インターフェースのインスタンス名`、もしくは`port.型名.インターフェースのインスタンス名`にオブジェクトのIOR文字列が格納されています。
型名にはIDLファイルで定義したインターフェース名が格納されるため、型名が一致しないとポートの接続はできません。
サービスポートは複数のインターフェースを持つことが可能ですが、インターフェース名が一致したプロバイダとコンシューマインターフェースを関連付けます。

`ports`の順番を入れ替えると以下のような処理となります。

![connect8](https://user-images.githubusercontent.com/6216077/48301011-f57f9880-e529-11e8-8aa1-39e4fd87a234.png)

### コンフィグレーションパラメータ
コンフィギュレーションパラメータはRTC実行中に内部パラメータを外部から変更可能な機能です。

![rtse1](https://user-images.githubusercontent.com/6216077/48301442-a5a4cf80-e531-11e8-80e3-a776f2cdda5d.png)

データポートかサービスポートかコンフィギュレーションパラメータのどれを使うかは場合によって違います。

データポートを使っても内部の処理を工夫すればパラメータを変更する事はできますが、1回変更すればいいところにデータポートを使うのは適切ではありません。

パラメータの変更にサービスポートを使うのは一つの方法です。
ただ、それも場合によります。他のRTCからパラメータを変更する必要があるときにはサービスポートを使うのが有効です。

例えば、RTCがファイルをロードする必要がある場合に、そのファイルパスを設定したいとします。
確かにサービスポートでも設定できるのですが、設定するためのRTCが別個必要になるため手軽ではありません。
他のRTCから変更する必要がない場合は、コンフィギュレーションパラメータで設定することをお勧めします。

コンフィギュレーションの設定には、`get_configuration`オペレーションで`Configuration`オブジェクトを取得後に設定します。

![configuration](https://user-images.githubusercontent.com/6216077/48313566-fb48ad00-e601-11e8-8313-53b8e400aad8.png)





### ライフサイクル
RTCの重要な要素としてライフサイクルがあります。
RTCには`Created`、`Inactive`、`Activate`、`Error`の4種類の状態があります。

![rtstatemachine](https://user-images.githubusercontent.com/6216077/48302715-7008e200-e543-11e8-801a-bee4de164c70.png)


ここで重要なのはRTCが個別に状態を持っているのではなく、**RTCが関連付けしている実行コンテキストごとに状態を持っている**という点です。

以下の例では、`実行コンテキストA`には`RTC1`を、`実行コンテキストB`には`RTC1`と`RTC2`を関連付けています。
この場合、`RTC1`は`実行コンテキストA`での状態と`実行コンテキストB`での状態があることになります。
`RTC1`は`実行コンテキストA`ではInactive状態、`実行コンテキストB`ではActive状態になっており、実行コンテキストごとに別々の状態になることがあります。

![activity](https://user-images.githubusercontent.com/6216077/48302262-e276c380-e53d-11e8-8737-d14cb5793534.png)

#### Inactivate
`Inactive`状態(非アクティブ状態、非活性状態)は、RTCが処理を実行していない状態です。
この状態では`on_execute`オペレーションも実行されず、またコンフィギュレーションパラメータの変更は(原則)反映されません。
サービスポートも機能が停止するのが動作としては正しいのですが、使いづらくなるだけなのでOpenRTM-aist 1.2以降ではInactive状態でもサービスポートは機能するようになっています。

#### Activate
`Active`状態(アクティブ状態、活性状態)は、RTCが処理を実行している状態です。
この状態では、実行コンテキストにより`on_execute`オペレーションが実行され、`on_state_update`オペレーションでコンフィギュレーションパラメータの更新が行われます。
RTCの`onExecute`関数にはロボットを制御するなどのメインとなる処理を実装します。

また`Active`状態遷移直後に`on_activated`、他の状態に遷移するときに`on_deactivated`を実行します。
RTCの`onActivated`関数にはサーボをオンにするなどの初期化処理、`onDeactivated`関数にはサーボをオフにするなどの後処理を実装します。

#### Error
`Error`状態(エラー状態、異常状態)は、RTCに問題が発生した事を検知して処理を停止した状態です。
この状態では、実行コンテキストにより`on_error`オペレーションが実行されます。
RTCの`onError`関数にはロボットを安全に停止するなどの、エラーに対応した処理を実装します。

## 実行コンテキスト
実行コンテキスト(Execution Context、EC)はRTCの状態を管理する機能です。
RTC単体では処理を実行することができず、実行コンテキストがRTCの操作を呼び出すことで処理を実行します。

RTCと実行コンテキストを分離することによって、実行コンテキストの変更のみで通常の周期実行、リアルタイム処理、シミュレータからのトリガ駆動を使い分けることができます。

実行コンテキストは`RTC.idl`、`OpenRTM.idl`で以下のようなインターフェースが定義されています。

![executioncontext](https://user-images.githubusercontent.com/6216077/48303135-ddb80c80-e549-11e8-96cb-8db6547030af.png)

`ExecutionContext`で定義されたオペレーションは以下の通りです。

|名前|意味|
|---|---|
|is_running|実行状態かを確認|
|start|実行コンテキストの実行を開始する|
|stop|実行コンテキストの実行を停止する|
|get_rate|実行周期を取得する|
|set_rate|実行周期を設定する|
|add_component|RTCを関連付ける|
|remove_component|RTCの関連付けを解除する|
|activate_component|RTCをアクティブ化する|
|deactivate_component|RTCを非アクティブ化する|
|reset_component|RTCをリセットする|
|get_component_state|RTCの状態を取得する|
|get_kind|実行コンテキストの種類を取得する|



RTSystemEditorで操作するためには実行コンテキストの情報を取得する`get_profile`オペレーションが必要なため、`ExecutionContextService`インターフェスの実装が必要になります。


|名前|意味|
|---|---|
|get_profile|実行コンテキストのプロファイルを取得|


`ExtTrigExecutionContextService`では以下のオペレーションが定義されています。
規格標準ではなく、`OpenRTM.idl`で定義されたOpenRTM-aist独自のインターフェースです。

|名前|意味|
|---|---|
|tick|RTCの処理を1回実行する|




実行コンテキストのプロファイルの定義は以下のようになっています。

<pre>
  enum ExecutionKind
  {
    PERIODIC,
    EVENT_DRIVEN,
    OTHER
  };
  
  
  struct ExecutionContextProfile
  {
    ExecutionKind kind;
    double rate;
    RTObject owner;
    RTCList participants;
    NVList properties;
  };
</pre>

イベント駆動の実行コンテキストには、実質的に`rate`の設定は意味がありません。

### PeriodicExecutionContext
`PeriodicExecutionContext`は周期実行を行う実行コンテキストです。

### ExtTrigExecutionContext
`ExtTrigExecutionContext`は外部からトリガ駆動で実行する実行コンテキストです。
`tick`のオペレーションの実装が必要になるため、`ExtTrigExecutionContextService`インターフェースで実装する必要があります。

`tick`を呼び出した時点では即座には実行されず、実行スレッドに指令して、RTCの処理は別スレッドで実行されます。
このため、`tick`の処理が戻ってきてもRTCの処理は終了していません。

### OpenHRPExecutionContext
`OpenHRPExecutionContext`は外部からトリガ駆動で実行する実行コンテキストです。
`ExtTrigExecutionContext`と違い、`OpenHRPExecutionContext`は`tick`実行時にRTCの処理を実行するため、RTCの処理終了まで`tick`の処理は戻ってきません。

### SimulatorExecutionContext
`SimulatorExecutionContext`は外部からトリガ駆動で実行する実行コンテキストです。
`OpenHRPExecutionContext`は`activate_component`等のRTCを状態を遷移する操作を実行しても`tick`でRTCの処理を実行しない限り状態は遷移しません。

### RTPreemptEC
`RTPreemptEC`は`PeriodicExecutionContext`と同じく周期実行の実行コンテキストですが、RT-Preemptパッチを適用したLinuxカーネルにより実時間処理を行うための実行コンテキストです。

## マネージャ
マネージャはRTCを管理する仕組みです。
1プロセスで1つのマネージャが起動し、モジュールのロード、RTCの生成、生存しているRTCの管理等を行います。

![rtse6](https://user-images.githubusercontent.com/6216077/48309973-4776fb80-e5c8-11e8-990a-887a4416724f.png)

インターフェースは`Manager.idl`で定義されています。RTM標準の規格ではなく、OpenRTM-aist固有のインターフェースです。

![manager](https://user-images.githubusercontent.com/6216077/48308249-8d6d9880-e5a3-11e8-9039-b263d00aa815.png)

### マスターマネージャ
マネージャは`マスターマネージャ`と`スレーブマネージャ`に分類されます。
マスターマネージャはスレーブマネージャを管理するマネージャです。
通常、マスターマネージャはRTCを生成しません。
またデフォルトでは`2810`のポート番号で起動するようになっており、RTSystemEditor等のツールからはそのポート番号にアクセスします。

![rtse5](https://user-images.githubusercontent.com/6216077/48309958-d6cfdf00-e5c7-11e8-815d-421614a5198f.png)

### スレーブマネージャ
スレーブマネージャはマスターマネージャにぶら下がっているマネージャです。
デフォルトで起動するマネージャはスレーブマネージャであり、RTCを生成することができます。
通常、スレーブマネージャはRTSystemEditor等のツールから直接操作することができず、マスターマネージャを介して操作することになります。
動的なRTCの生成、生成可能なモジュール名の取得などができます。


## RTシステム
単一、もしくは複数のRTCのポートの接続などを行い、RT(ロボットテクノロジー)を活用した処理を実行するためのシステムのことを`RTシステム`と言います。

![rtse4](https://user-images.githubusercontent.com/6216077/48308397-10dcb900-e5a7-11e8-8e42-795d72834365.png)


## 複合コンポーネント
複合コンポーネントは複数のRTCを1つに複合する仕組みの事です。

例えば、以下の例の場合`RTC1`と`RTC2`、`RTC2`と`RTC3`のポートは外に見せる必要がないということで隠蔽してあります。
こうすることで、複雑なRTシステムが見た目上は単純になるため、システムの概要を理解しやすくなります。

![rtse3](https://user-images.githubusercontent.com/6216077/48308343-cad32580-e5a5-11e8-8ce0-69cd86029276.png)

また、`実行の同期`、`状態の同期`を行う場合があります。

`実行の同期`を行う場合には、子コンポーネントを1つの実行コンテキストに関連付けて同期実行を行うようになっています。

`状態の同期`はOpenRTM-aistでは実装されていません。

## IDLファイル
`IDL`(Interface Description Language、インターフェース記述言語)は、ソフトウェアモジュールの間のやり取りを行うためのインターフェースを記述する言語です。


## SDOサービス
SDOサービスは後述のコンポーネントオブザーバー等、RTCに機能を追加するための仕組みです。
SDOサービスは片方にコンシューマ、片方にプロバイダとなる機能を実装する必要があります。

SDOサービスを追加するためには、`Configuration`インターフェースの`add_service_profile`オペレーションを使う必要があります。

`add_service_profile`で渡すサービスプロファイルには、例えば以下のような情報を渡します。


|名前|型|値|
|---|---|---|
|id|string|適当な名前|
|interface_type|string|空白|
|properties|NVList|{}|
|service|SDOService|SDOサービスのオブジェクトリファレンス|


オブジェクトリファレンスは上記のservice変数に格納する必要があるため、`SDOService`インターフェースを継承して開発する必要があります。


`add_service_profile`でSDOサービス登録後、RTCからオペレーションを呼び出します。

![sdoservice](https://user-images.githubusercontent.com/6216077/48308635-ab8bc680-e5ac-11e8-9eb4-530a52d84726.png)



### コンポーネントオブザーバ
コンポーネントオブザーバーはRTCからRTSystemEditor等のツールに状態変化、ハートビートなどを通知する機能です。
`RTC::ComponentObserver`はFSM4RTC規格標準のインターフェースであり、`OpenRTM::ComponentObserver`はOpenRTM-aist独自のインターフェースです。

![componentobserver](https://user-images.githubusercontent.com/6216077/48308716-37eab900-e5ae-11e8-839e-20c035e40957.png)

`status_kind`に通知内容の種別を設定します。
`RTC::StatusKind`には以下の値が列挙されています。

|名前|意味|
|---|---|
|COMPONENT_PROFILE|コンポーネントプロファイルの変更を通知|
|RTC_STATUS|RTCの状態変化を通知|
|EC_STATUS|ECの状態変化を通知|
|PORT_PROFILE|ポートプロファイルの変更を通知|
|CONFIGURATION|コンフィギュレーションの変更を通知|
|RTC_HEARTBEAT|定期的にRTCの生存確認を通知|
|EC_HEARTBEAT|定期的にECの生存確認を通知|
|FSM_PROFILE|FSMプロファイルの変更を通義|
|FSM_STATUS|FSMステータスの変更を通知|
|FSM_STRUCTURE|FSMストラクチャの変更を通知|
|USER_DEFINED|上記以外|

## FSM4RTC
FSM4RTC(Finite State Machine for RTC)は、有限状態機械の仕組みをRTCの導入するための規格です。

OMG RTCの規格では、RTCにはInactive状態、Active状態、Error状態の3種類の状態がありましたが、例えば以下のようにイベントでロボットを制御する場合などは複雑な状態変化を設定できるようにする必要があります。

![humanoid](https://user-images.githubusercontent.com/6216077/48308977-ee509d00-e5b2-11e8-99ce-1f9f7949ed1e.png)

現状のOpenRTM-aistでこのような仕組みを実装するためには、独自にStateパターンやswitch文によりステートマシンを実装し、データポートやサービスポートの入力で状態を変化させるという仕組みが必要になるため、実装が簡単ではありません。
FSM4RTCの仕組みを導入することで、FSMの実装が容易になります。

### CSP
CSP(Communicating Sequential Processes)は、並列に動作するシステムを記述して検証するための形式手法の一つです。
CSPで記述した並列システムは、`FDR4`等のツールでデッドロックが発生しないかなどの問題を検証することができます。

FSM4RTCで実装したRTシステムをCSPで検証するという試みが行われています。

## ロガー
RTC実行中のログをファイル、もしくは標準出力する機能です。特に規格では定義されていません。
OpenRTM-aistにはFluent Bitでログを収集する機能もあります。

## ナンバリングポリシー
例えば、OpenRTM-aistで`Sample`という名前のRTCを起動した場合、インスタンス名は`Sample0`となります。
同一プロセスで`Sample`を複数起動した場合、`Sample0`、`Sample1`、`Sample2`と番号が増えていく仕組みになっています。

ただしこれは同一プロセス内の話で、別プロセスで`Sample0`が起動している場合にもカウントを増やしてほしい場合は、デフォルト以外の設定が必要になります。

### process_unique
デフォルトの設定。上述の通りプロセス内でカウントする。

### ns_unique
ネームサーバーに登録されたRTC名が被らないように番号付けする。
`rtc.conf`に以下のように記述することで利用できる。

<pre>
manager.components.naming_policy:ns_unique
</pre>

### node_unique
同一ノード内でRTC名が被らないように番号付けする。
マスターマネージャに登録されたスレーブマネージャで起動している全てのRTCを調べて番号付けをする。

<pre>
naming.type:corba,manager
manager.components.naming_policy:node_unique
</pre>

## CORBA
CORBA(Common Object Request Broker Architecture)は分散環境で透過的にソフトウェアモジュールの相互利用を行うための標準規格です。
IDLファイルで定義されたインターフェースでプログラミング言語を問わずに関数のリモート呼び出しができます。

### ORB
ORB(Object Request Broker)はネットワークを介してプログラムの呼び出しを行うためのミドルウェアのことです。
CORBAもORBの一つです。

### POA
POA(Portable Object Adapter)はオブジェクトリファレンスとサービスの実体を関連付けて、リモート呼び出しに対して適切なサービスを呼び出すための仕組みです。

### CORBAの実装例
#### omniORB
OpenRTM-aistが利用しているCORBAの実装です。
C++、Pythonの実装があります。

#### TAO
フリーCORBA御三家の一つ。残りはORBacusとMICO。C++による実装。
UDPの通信、Real-Time CORBA等の機能が充実している。
OpenRTM-aistがサポートしている実装の一つ。

#### ORBexpress
商用CORBAの1つ。軽量であり、様々な独自プロトコルを追加できる。
OpenRTM-aistがサポートしている実装の一つ。

#### RtORB
RtORBはC言語で実装されているCORBA実装。
OpenRTM-aistで使用していないAPIが省かれているため非常に軽量。

#### IIOP.NET
.NET系のプログラミング言語で使用可能なCORBA実装。
OpenRTM.NETが使用している。

#### OpenORB
Javaで実装されたCORBA実装。
OpenRTM-aist Java版が使用している。
Java SE11からはCORBAのサポートがなくなる。

#### OiL
Luaで実装されたCORBA実装。
OpenRTM Luaが使用している。

### オブジェクトリファレンス
クライアント側で使用するオブジェクトの参照。
オブジェクトリファレンスによりリモートにCORBAオブジェクトの実体側の操作を呼び出せる。

![corba1](https://user-images.githubusercontent.com/6216077/48311887-c3ce0680-e5e9-11e8-86b5-8d64d11d8e22.png)


### CDR
CDR(Common Data Representation)は、CORBAで使用されているデータの表現方法の1つです。
サーバー、クライアントで通信する場合にデータはCDR形式のバイト列に変換(マーシャリング、符号化)し送信、受信側でバイト列を元のデータに戻す(アンマーシャリング、復号化)することでデータの受け渡しを行います。


### IOR
IOR(Interoperable Object Reference)はCORBAオブジェクトの情報を文字列で表現する形式です。
`IOR:`から始まる文字列となっており、ホスト名、ポート番号等の情報が含まれています。

### GIOP
GIOP(General Inter-ORB Protocol)はORBが通信するための通信プロトコル。
GIOPという文字(4byte)、バージョン(2byte)、メッセージフラグ(1byte)、メッセージ型(1byte)、メッセージ本体のサイズ(4byte)の合計12byteのヘッダーの後ろにメッセージ本体を格納する。
TCP/IP上のGIOPの実装を`IIOP`、UDP上のGIOPの実装を`DIOP`、共有メモリ上のGIOPの実装を`SHMIOP`、UNIXドメインソケット上のGIOPの実装を`UIOP`、IIOPでSSLによる暗号化を行う`SSLIOP`というプロトコルがあります。

### INS
INS(Interoperable Naming Service)はCORBAオブジェクトを名前解決する機能。
`coabeloc`、`corbaname`形式が利用できる。

#### corbaloc
`corbaloc`は指定アドレス、ポート番号で特定の名前に関連付けたCORBAオブジェクトの参照を取得する方式。

<pre>
corbaloc:iiop:localhost:2810/manager
</pre>

名前解決するCORBAオブジェクトは以下のように名前を関連付けておく必要がある。

<pre>
local manager = orb:newservant(mgr, id, "IDL:RTM/Manager:1.0")
</pre>

`corbaloc`で名前解決してオブジェクトリファレンスを取得するには以下のようなコードを記述する。

<pre>
local oil = require "oil"


oil.main(function()
    local orb = oil.init{ flavor = "cooperative;corba;intercepted;typed;base;"}


    orb:loadidlfile("idl/CosNaming.idl")
    orb:loadidlfile("idl/RTC.idl")
    orb:loadidlfile("idl/OpenRTM.idl")
    orb:loadidlfile("idl/Manager.idl")
    
     -- OiL 0.4
    local manager = orb:newproxy("corbaloc:iiop:localhost:2810/manager","IDL:RTM/Manager:1.0")
    -- OiL 0.5, 0,6
    --local manager = orb:newproxy("corbaloc:iiop:localhost:2810/manager",nil,"IDL:RTM/Manager:1.0")

    local profiles = manager:get_component_profiles()
    for k,profile in ipairs(profiles) do
        print(profile.instance_name)
    end
    
    oil.newthread(orb.run, orb)
end)
</pre>

#### corbaname
`corbaname`はネームサーバーからオブジェクトリファレンスを名前解決して取得する方法です。

<pre>
corbaname:iiop:localhost:2809#ConsoleIn0.rtc\
</pre>

omniORBpyでは以下のようなコードを記述します。

<pre>
import sys
from omniORB import CORBA
import RTC

orb = CORBA.ORB_init(sys.argv, CORBA.ORB_ID)
obj = orb.string_to_object("corbaname:iiop:localhost:2809#ConsoleIn0.rtc")
rtc = obj._narrow(RTC.RTObject)

print(rtc.get_component_profile())
</pre>


OiLでは`corbaname`はサポートしていません。

## ネームサーバー
ネームサーバー(もしくはネーミングサービス)はCORBAオブジェクトの参照を名前で登録して検索しやすくする仕組みです。

![nameserver](https://user-images.githubusercontent.com/6216077/48312823-b3bd2380-e5f7-11e8-95dc-37f99738485e.png)


## OpenRTM-aist
`OpenRTM-aist`は産業技術総合研究所が開発しているRTミドルウェアの実装です。
C++版、Python版、Java版にRTSystemEditorやRTCBuilder等のツールが含まれています。

## rtc.conf
`rtc.conf`はマネージャを起動する際に読み込む設定ファイルです。
例えば、rtc.confに以下のように記述することでログレベルの設定ができます。

<pre>
`logger.log_level:Debug`
</pre>

何も指定しなければ実行したフォルダのrtc.confを読み込みますが、以下のように`-f`のコマンドラインオプションで設定ファイルの指定ができます。

<pre>
lua Sample.lua -f conf/rtc_test.conf
</pre>

また、このような設定は必ずしも`rtc.conf`に記述する必要はなく、`-o`のコマンドラインオプションで設定できます。
`rtc.conf`と`-o`のコマンドラインオプションで同じ項目を設定している場合はコマンドラインオプションが優先されます。

<pre>
lua Sample.lua -o logger.log_level:Debug
</pre>

## Lua
リオデジャネイロ・カトリカ大学が開発しているスクリプト言語。
軽量、高い移植性、スクリプト言語としては高速であることが特徴。

* [he Programming Language Lua](https://www.lua.org/)

### LuaJIT
LuaのJITコンパイラ。Javaにも匹敵する非常に高速な処理が可能。

* [The LuaJIT Project](http://luajit.org/)

### LuaRocks
Luaのパッケージ管理システムの1つ。
以下のサイトで運営されている。
2018年11月現在2400個のモジュールが登録されている。

* [LuaRocks - The Lua package manager](https://luarocks.org/)

