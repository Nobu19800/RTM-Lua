--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ManagerActionListener= {}
_G["openrtm.ManagerActionListener"] = ManagerActionListener

ManagerActionListener.ManagerActionListeners = {}

ManagerActionListener.ManagerActionListeners.new = function()
	local obj = {}

	return obj
end


return ManagerActionListener
