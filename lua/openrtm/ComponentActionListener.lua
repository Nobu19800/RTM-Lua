---------------------------------
--! @file ComponentActionListener.lua
--! @brief コンポーネントコールバック定義クラス
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ComponentActionListener= {}
--_G["openrtm.ComponentActionListener"] = ComponentActionListener


ComponentActionListener.ComponentActionListeners = {}

ComponentActionListener.ComponentActionListeners.new = function()
	local obj = {}
	return obj
end


return ComponentActionListener
