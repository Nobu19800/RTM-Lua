# 独自データ型の作成手順
## IDLファイルの作成

まずはIDLファイル(今回はtest.idl)を作成します。
OpenRTM-aist 1.2からは必ずデータ型にタイムスタンプが必要になっています。 BasicDataType.idlをインクルードして、データ型にタイムスタンプ(RTC::Time tm;)を追加してください。

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

## RTC Builderを使用する場合(OpenRTM-aist 1.2以降)

RTC Builderのデータポート設定画面でIDLファイルの横のBrowse…ボタンを押してIDLファイルを選択します。

![rtcb1](https://user-images.githubusercontent.com/6216077/48300587-c9f9af80-e523-11e8-9e7a-ed7b8f182a24.png)

するとデータ型一覧に独自データ型が追加されるため、`SampleDataType`を追加してください。

![rtcb2](https://user-images.githubusercontent.com/6216077/48300588-c9f9af80-e523-11e8-9967-cfd8bb88ca2c.png)

この後の手順は通常のRTCと同じです。


## ソースコードを編集する場合

まずは`test.idl`、`BasicDataType.idl`を適当なフォルダに配置します。

<pre>
--
 |-- Sample.lua(RTCのソースコード)
 |-- idl
      |--test.idl
      |--BasicDataType.idl
</pre>

`Sample.lua`でIDLファイルの読み込み、データポートの初期化を行います。

<pre>
local Sample = {}
Sample.new = function(manager)
	local obj = {}
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
  -- 以下が追加するコード
	manager:loadIdLFile("idl/test.idl")
	obj._d_in = openrtm.RTCUtil.instantiateDataType("::Sample::SampleDataType")
	obj._inIn = openrtm.InPort.new("in", obj._d_in, "::Sample::SampleDataType")
</pre>


この後は通常のデータポートの利用方法と同じです。


<pre>
	function obj:onExecute(ec_id)
		if self._inIn:isNew() then
			local data = self._inIn:read()
			print(data.data1)
			print(data.data2)
		end
		return self._ReturnCode_t.RTC_OK
	end
</pre>

