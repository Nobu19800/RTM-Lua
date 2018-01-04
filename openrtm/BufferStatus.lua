--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

BufferStatus = {}
local BufferStatus = {}
_G["openrtm.BufferStatus"] = BufferStatus


BufferStatus = {
				BUFFER_OK = 0,
				BUFFER_ERROR = 1,
				BUFFER_FULL = 2,
				BUFFER_EMPTY = 3,
				NOT_SUPPORTED = 4,
				TIMEOUT = 5,
				PRECONDITION_NOT_MET = 6
				}

BufferStatus.toString = function(status)
	str = {"BUFFER_OK",
           "BUFFER_ERROR",
           "BUFFER_FULL",
           "BUFFER_EMPTY",
           "NOT_SUPPORTED",
           "TIMEOUT",
           "PRECONDITION_NOT_MET"}
	return str[status+1]
end

return BufferStatus
