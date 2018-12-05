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
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
        self._d_out = openrtm_lns.RTCUtil.instantiateDataType("::RTC::TimedLong");
        self._outOut = unwrap openrtm_lns.OutPort.new("out",self._d_out,"::RTC::TimedLong");
    }
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        self.addOutPort("out",self._outOut);
        return openrtm_lns.ReturnCode_t.RTC_OK;
    }
```

データの出力を行う場合は、`self._d_out`に送信データを格納後、`self._outOut`のwrite関数を実行します。

```
        self._d_out.data = 1;
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
    pub fn __init( manager: openrtm_lns.Manager ) {
        super( manager );
        self._d_in = openrtm_lns.RTCUtil.instantiateDataType("::RTC::TimedLong");
        self._inIn = unwrap openrtm_lns.InPort.new("in",self._d_in,"::RTC::TimedLong");
    }
    pub override fn onInitialize() mut : openrtm_lns.ReturnCode_t {
        self.addInPort("in",self._inIn);
        return openrtm_lns.ReturnCode_t.RTC_OK;
    }
```


