---------------------------------
--! @file DataPortStatus.lua
--! @brief データポートステータス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local DataPortStatus= {}
_G["openrtm.DataPortStatus"] = DataPortStatus

DataPortStatus = {PORT_OK            = 0,
				PORT_ERROR           = 1,
				BUFFER_ERROR         = 2,
				BUFFER_FULL          = 3,
				BUFFER_EMPTY         = 4,
				BUFFER_TIMEOUT       = 5,
				SEND_FULL            = 6,
				SEND_TIMEOUT         = 7,
				RECV_EMPTY           = 8,
				RECV_TIMEOUT         = 9,
				INVALID_ARGS         = 10,
				PRECONDITION_NOT_MET = 11,
				CONNECTION_LOST      = 12,
				UNKNOWN_ERROR        = 13}

-- データポートステータスを文字列に変換
-- @param status データポートステータス
-- @return 文字列
DataPortStatus.toString = function(status)
	str = {"PORT_OK",
           "PORT_ERROR",
           "BUFFER_ERROR",
           "BUFFER_FULL",
           "BUFFER_EMPTY",
           "BUFFER_TIMEOUT",
           "SEND_FULL",
           "SEND_TIMEOUT",
           "RECV_EMPTY",
           "RECV_TIMEOUT",
           "INVALID_ARGS",
           "PRECONDITION_NOT_MET",
           "CONNECTION_LOST",
           "UNKNOWN_ERROR"}
	return str[status+1]
end



return DataPortStatus
