---------------------------------
--! @file openrtm_ms.moon
--! @brief MoonScript用のライブラリ
---------------------------------



openrtm = require "openrtm"


openrtm_ms = {}


-- @class RTObject
-- RTC基底オブジェクト
class openrtm_ms.RTObject
	-- コンストラクタ
	-- @param manager マネージャ
	new: (manager) =>
		obj = openrtm.RTObject.new(manager)
		for k,v in pairs obj
			if self[k] == nil
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
		for k,v in pairs obj
			if self[k] == nil
				self[k] = v


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
		for k,v in pairs obj
			if self[k] == nil
				self[k] = v






-- @class CorbaPort
-- CORBAポート
class openrtm_ms.CorbaPort
	-- コンストラクタ
	-- @param name ポート名
	new: (name) =>
		obj = openrtm.CorbaPort.new(name)
		for k,v in pairs obj
			if self[k] == nil
				self[k] = v

			
			
-- @class Properties
-- プロパティ
class openrtm_ms.Properties
	-- コンストラクタ
	-- @param argv argv.prop：コピー元のプロパティ、argv.key・argv.value：キーと値、argv.defaults_map：テーブル
	new: (argv) =>
		obj = openrtm.Properties.new(argv)
		for k,v in pairs obj
			if self[k] == nil
				self[k] = v
			
			
-- @class CorbaConsumer
-- CORBAコンシューマオブジェクト初期化関数
class openrtm_ms.CorbaConsumer
	-- コンストラクタ
	-- @param consumer CORBAコンシューマオブジェクト
	new: (consumer) =>
		obj = openrtm.CorbaConsumer.new(consumer)
		for k,v in pairs obj
			if self[k] == nil
				self[k] = v


return openrtm_ms
