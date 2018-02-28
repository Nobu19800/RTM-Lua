---------------------------------
--! @file ConnectorListener.lua
--! @brief コネクタコールバック定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ConnectorListener= {}
--_G["openrtm.ConnectorListener"] = ConnectorListener


ConnectorListener.ConnectorListeners = {}

ConnectorListener.ConnectorListeners.new = function()
	local obj = {}
	return obj
end


return ConnectorListener
