---------------------------------
--! @file openrtm_ms.moon
--! @brief MoonScript用のライブラリ
---------------------------------



openrtm = require "openrtm"


openrtm_ms = {}



-- RTC基底オブジェクト初期化
-- @param manager マネージャ
-- @return RTC
class openrtm_ms.RTObject
	new: (manager) =>
		tmp = {}
		for k,v in pairs self.__index
			tmp[k] = v
		openrtm.RTObject.new(manager, self)
		for k,v in pairs tmp
			self[k] = v






-- InPort初期化
-- @param name ポート名
-- @param value データ変数
-- @param data_type データ型
-- @param buffer バッファ
-- @param read_block 読み込み時ブロックの設定
-- @param write_block 書き込み時時ブロックの設定
-- @param read_timeout 読み込み時のタイムアウト
-- @param write_timeout 書き込み時のタイムアウト
-- @return InPort
class openrtm_ms.InPort
	new: (name, value, data_type, buffer, read_block, write_block, read_timeout, write_timeout) =>
		tmp = {}
		for k,v in pairs self.__index
			tmp[k] = v
		openrtm.InPort.new(name, value, data_type, buffer, read_block, write_block, read_timeout, write_timeout, self)
		for k,v in pairs tmp
			self[k] = v


-- アウトポート初期化
-- @param name ポート名
-- @param value データ変数
-- @param data_type データ型
-- @param buffer バッファ
-- アウトポート
class openrtm_ms.OutPort
	new: (name, value, data_type, buffer) =>
		tmp = {}
		for k,v in pairs self.__index
			tmp[k] = v
		openrtm.OutPort.new(name, value, data_type, buffer, self)
		for k,v in pairs tmp
			self[k] = v




-- CORBAポート初期化関数
-- @param name ポート名
-- @return CORBAポート
class openrtm_ms.CorbaPort
	new: (name) =>
		tmp = {}
		for k,v in pairs self.__index
			tmp[k] = v
		openrtm.RTObject.new(name, self)
		for k,v in pairs tmp
			self[k] = v


return openrtm_ms
