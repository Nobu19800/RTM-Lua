---------------------------------
--! @file ConfigurationListener.lua
--! @brief コンフィギュレーションコールバック定義クラス
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ConfigurationListener= {}
_G["openrtm.ConfigurationListener"] = ConfigurationListener

ConfigurationListener.ConfigurationListeners = {}
ConfigurationListener.ConfigurationListeners.new = function()
	local obj = {}
	return obj
end


return ConfigurationListener
