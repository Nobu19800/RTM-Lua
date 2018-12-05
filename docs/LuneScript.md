# LuneScriptの利用

## LuneScriptとは？

* [LuneScript](https://ifritjp.github.io/doc/lua/transcompiler.html)

MoonScriptと同じくLuaのトランスコンパイラです。新しい言語なので情報は少ないです。

ちなみに[Google翻訳でLuneScriptを翻訳すると淫語という意味になる](https://qiita.com/dwarfJP/items/98ffacbb32b1a4d5f63e#%E3%81%A1%E3%82%87%E3%81%A3)らしいです。
独特のネーミングセンスをしています。

Luaの言語仕様が小さい故の欠点を解消するために様々な機能が追加されています。

LuneScriptは以下のようにクラスや継承を利用できます。

```
class BaseClass
{
    let mut v1 :int;
    pub fn __init(v1:int) {
         self.v1 = v1;
    }
    pub fn print_func() mut {
         print(self.v1);
    }
}


class SubClass extend BaseClass
{
    let mut v2 :int;
    pub fn __init(v1:int, v2:int) {
         super(v1);
         self.v2 = v2;
    }
    pub override fn print_func() mut {
         super();
         self.v2 = self.v2+1;
         print(self.v2);
    }
}

//pub fn test_func(bc:&BaseClass) mut {
//    bc.print_func();
//}



let mut obj = new SubClass(1,2);
obj.print_func();
obj.print_func();
obj.print_func();
```


Luaとは以下のような違いがあります。

* C++やJava等のように{}でスコープを表す
* オブジェクト指向(class)、クラスの継承
* fnによる関数定義
* アクセス修飾子(Public(pub)、Private(pri)、Protected(pro))
* デフォルトで変数はimmutable
* 静的型付け
* 他にもいろいろ



MoonScriptはLuaに機能を追加、記述方法の変更をしたという感じでしたが、LuneScriptはそれに加えて制約が強い印象です。

## インストール
Lua 5.2が必要です。
### Windows
[ダウンロード][download.md]のページからLua 5.2用のOpenRTM Luaをダウンロードしてください。

[LuneScript](https://github.com/ifritJP/LuneScript)のソースコードをダウンロードして以下のように配置します。

<pre>
openrtm-lua-*.*.*-cc-***-lua5.2
   |- lune
        |- bin
	|   |- lnsc
	|
	|- lua
	    |- lune
	    |     |- base
	    |       |- (省略)
	    |- openrtm_lns.lns
	    |- openrtm_lns
	          |- (省略)
</pre>

`lnsc`というスクリプトファイル、`lune`というフォルダをLuneScriptからコピーしてください。

`lune`フォルダを配置したパスを環境変数`LUA_PATH`に設定します。

<pre>
set LUA_PATH=..\\..\\lua\\?.lua;..\\lua\\?.lua;.\\?.lua;
set LUA_CPATH=..\\..\\clibs\\?.dll;
</pre>

またカレントディレクトリ(`.\\?.lua`)をモジュール探索パスに設定しておく必要があります。

### Ubuntu

## RTCの作成
### サンプルを例に、RTC作成方法を説明します。

### モジュールロード
以下のようにモジュールのロードを行います。

```
import openrtm_lns;
```

### RTCの仕様を定義
以下のようにRTCの仕様を定義したテーブルを作成します。

```
let consolein_spec = {
	 "implementation_id":"ConsoleIn",
	 "type_name":"ConsoleIn",
	 "description":"Console input component",
	 "version":"1.0",
	 "vendor":"Nobuhiko Miyamoto",
	 "category":"example",
	 "activity_type":"DataFlowComponent",
	 "max_instance":"10",
	 "language":"LuneScript",
	 "lang_type":"script"};
```

### RTCのテーブル作成
RTCをクラスで定義します。

```
class ConsoleIn extend openrtm_lns.RTObjectBase {
    (省略)
    // コンストラクタ
    // @param manager マネージャ
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
        (省略)
    }
    // 初期化時のコールバック関数
    // @return リターンコード
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        (省略)
    }

    // アクティブ状態の時の実行関数
    // @param ec_id 実行コンテキストのID
    // @return リターンコード
    pub override fn onExecute(ec_id:int) mut : openrtm_lns.ReturnCode_t {
        (省略)
    }
}
```


### データポート
アウトポート、インポート、サービスポートをonInitialize関数で追加します。

#### アウトポート
```
class ConsoleIn extend openrtm_lns.RTObjectBase {
    let mut _d_out:Map<str,stem>;
    let mut _outOut:openrtm_lns.OutPort_lns;
    // コンストラクタ
    // @param manager マネージャ
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
        // データ格納変数
        self._d_out = openrtm_lns.RTCUtil.instantiateDataType("::RTC::TimedLong");
        // アウトポート生成
        self._outOut = unwrap openrtm_lns.OutPort.new("out",self._d_out,"::RTC::TimedLong");
    }
    // 初期化時のコールバック関数
    // @return リターンコード
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        self.addOutPort("out",self._outOut);
        return openrtm_lns.ReturnCode_t.RTC_OK;
    }
```

データの出力を行う場合は、`self._d_out`に送信データを格納後、`self._outOut`のwrite関数を実行します。

```
        // 出力データ格納
        self._d_out.data = 1;
        // データ書き込み
        self._outOut.write();
```

この時`self._d_out`がimmutableな変数の場合に値を代入できません。
その場合はwrite関数の引数として渡すこともできます。

```
        self._outOut.write({"tm":{"sec":0,"nsec":0},"data":1});
```

#### インポート
```
class ConsoleOut extend openrtm_lns.RTObjectBase {
   let mut _d_in:Map<str,stem>;
   let mut _inIn:openrtm_lns.InPort_lns;
    // コンストラクタ
    // @param manager マネージャ
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
        // データ格納変数
        self._d_in = openrtm_lns.RTCUtil.instantiateDataType("::RTC::TimedLong");
        // インポート生成
        self._inIn = unwrap openrtm_lns.InPort.new("in",self._d_in,"::RTC::TimedLong");
    }

    // 初期化時のコールバック関数
    // @return リターンコード
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        self.addInPort("in",self._inIn);
        return openrtm_lns.ReturnCode_t.RTC_OK;
    }
```

`openrtm_ms.RTCUtil.instantiateDataType`関数により、データを格納する変数を初期化できます。

`openrtm_lns.OutPort.new("out",self._d_out,"::RTC::TimedLong")`のように、データ型は文字列で指定する必要があります。

入力データを読み込む場合は、`self._inIn`の`read`関数を使用します。

```
        // バッファに新規データがあるかを確認
        if self._inIn.isNew() {
             // データ読み込み
             let data = self._inIn.read();
             print("Received: ", data);
             print("Received: ", data.data);
        }
```

### サービスポート
#### プロバイダ

プロバイダ側のサービスポートを生成するためには、まずプロバイダのクラスを定義します。

```
class MyServiceSVC_impl extend (openrtm_lns.CorbaProvider_lns) {
    (省略)
    pub fn __init( ) {
        (省略)
    }
    pub fn echo( msg:str ) mut :str {
        (省略)
    }
    pub fn get_echo_history( ) mut :&str[] {
        (省略)
    }
    pub fn set_value( value:real ) mut {
        (省略)
    }
    pub fn get_value( ) :real {
        (省略)
    }
    pub fn get_value_history( ) :&real[] {
        (省略)
    }
}
```

onInitialize関数内でポートの生成、登録を行います。

```
class MyServiceProvider extend openrtm_lns.RTObjectBase {
   let mut _myServicePort:openrtm_lns.CorbaPort_lns;
   let mut _myservice0:MyServiceSVC_impl;
    // コンストラクタ
    // @param manager マネージャ
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
	// サービスポート生成
        self._myServicePort = unwrap openrtm_lns.CorbaPort.new("MyService");
	// プロバイダオブジェクト生成
        self._myservice0 = new MyServiceSVC_impl();
    }

    // 初期化時のコールバック関数
    // @return リターンコード
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        // サービスポートにプロバイダオブジェクトを登録
        self._myServicePort.registerProvider("myservice0", "MyService", self._myservice0, "idl/MyService.idl", "IDL:SimpleService/MyService:1.0");
	// ポート追加
        self.addPort(self._myServicePort);
        return openrtm_lns.ReturnCode_t.RTC_OK;
    }


}
```

`self._myServicePort.registerProvider("myservice0", "MyService", self._myservice0, "../idl/MyService.idl", "IDL:SimpleService/MyService:1.0")`のように、IDLファイル名、インターフェース名を文字列で指定する必要があります。


#### コンシューマ
コンシューマ側のサービスポートを追加する手順は現在のところ簡単ではありません。

まず実装するサービスの引数、戻り値の型を定義する必要があります。IDLファイルで定義したものと合わせるようにしてください。

```
interface SimpleService {
   pub fn echo(msg:str):str;
   pub fn get_echo_history():str[];
   pub fn set_value(value:real):nil;
   pub fn get_value():real;
   pub fn get_value_history():real[];
}
```

次に上記のインターフェースで定義したオブジェクトを取得するためのインターフェースを定義する必要があります。

```
interface CorbaConsumer_SimpleService extend (openrtm_lns.CorbaConsumer_lns) {
   pub fn _ptr() : SimpleService;
}

module CorbaConsumer require 'openrtm.CorbaConsumer' {
   pub static fn new( interfaceType:str, consumer:stem! ): CorbaConsumer_SimpleService;
}
```



コンシューマ側のサービスポートを追加するには、以下のようにonInitialize関数内でポートの生成、追加を行います。 `self._myServicePort.registerConsumer("myservice0", "MyService", self._myservice0, "../idl/MyService.idl")`のようにIDLファイル名を文字列で指定する必要があります。

`_myservice0`は先ほど定義した`CorbaConsumer_SimpleService`インターフェースの型に設定する必要があります。

```
class MyServiceConsumer extend openrtm_lns.RTObjectBase {
   let mut _myServicePort:openrtm_lns.CorbaPort_lns;
   let mut _myservice0:CorbaConsumer_SimpleService;
    // コンストラクタ
    // @param manager マネージャ
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
        // サービスポート生成
        self._myServicePort = unwrap openrtm_lns.CorbaPort.new("MyService");
        // コンシューマオブジェクト生成
        self._myservice0 = unwrap CorbaConsumer.new("IDL:SimpleService/MyService:1.0");
    }
    // 初期化時のコールバック関数
    // @return リターンコード
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        // サービスポートにコンシューマオブジェクトを登録
        self._myServicePort.registerConsumer("myservice0", "MyService", self._myservice0, "idl/MyService.idl");
        // ポート追加
        self.addPort(self._myServicePort);
        return openrtm_lns.ReturnCode_t.RTC_OK;
    }
```

オペレーションを呼び出す場合は、CorbaConsumerの`_ptr`関数でオブジェクトリファレンスを取得して関数を呼び出します。

```
let service:SimpleService = unwrap self._myservice0._ptr();
print(service.echo("test"));
```
