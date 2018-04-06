---------------------------------
--! @file openrtm_ms.moon
--! @brief MoonScript用のライブラリ
---------------------------------



openrtm = require "openrtm"


openrtm_ms = {}

for k,v in pairs openrtm
	openrtm_ms[k] = v

openrtm_ms.setTimestamp = openrtm.OutPort.setTimestamp


-- @class RTObject
-- RTC基底オブジェクト
class openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		tmp = {}
		for k,v in pairs self.__index
			tmp[k] = v
		obj = openrtm.RTObject.new(manager)
		setmetatable(self, {__index:obj})
		for k,v in pairs tmp
			self[k] = v





-- @class InPort
-- InPort
class openrtm_ms.InPort
	-- コンストラクタ
	-- @param name ポート名
	-- @param value データ変数
	-- @param data_type データ型
	-- @param buffer バッファ
	-- @param read_block 読み込み時ブロックの設定
	-- @param write_block 書き込み時時ブロックの設定
	-- @param read_timeout 読み込み時のタイムアウト
	-- @param write_timeout 書き込み時のタイムアウト
	new: (name, value, data_type, buffer, read_block, write_block, read_timeout, write_timeout) =>
		obj = openrtm.InPort.new(name, value, data_type, buffer, read_block, write_block, read_timeout, write_timeout)
		setmetatable(self, {__index:obj})


-- @class OutPort
-- アウトポート
class openrtm_ms.OutPort
	-- コンストラクタ
	-- @param name ポート名
	-- @param value データ変数
	-- @param data_type データ型
	-- @param buffer バッファ
	new: (name, value, data_type, buffer) =>
		obj = openrtm.OutPort.new(name, value, data_type, buffer)
		setmetatable(self, {__index:obj})







-- @class CorbaPort
-- CORBAポート
class openrtm_ms.CorbaPort
	-- コンストラクタ
	-- @param name ポート名
	new: (name) =>
		obj = openrtm.CorbaPort.new(name)
		setmetatable(self, {__index:obj})

			
			
-- @class Properties
-- プロパティ
class openrtm_ms.Properties
	-- コンストラクタ
	-- @param argv argv.prop：コピー元のプロパティ、argv.key・argv.value：キーと値、argv.defaults_map：テーブル
	new: (argv) =>
		obj = openrtm.Properties.new(argv)
		setmetatable(self, {__index:obj})
			
			
-- @class CorbaConsumer
-- CORBAコンシューマオブジェクト初期化関数
class openrtm_ms.CorbaConsumer
	-- コンストラクタ
	-- @param consumer CORBAコンシューマオブジェクト
	new: (consumer) =>
		obj = openrtm.CorbaConsumer.new(consumer)
		setmetatable(self, {__index:obj})


return openrtm_ms
