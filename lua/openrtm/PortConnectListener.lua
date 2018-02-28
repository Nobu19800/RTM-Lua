---------------------------------
--! @file PortConnectListener.lua
--! @brief コネクタ関連のコールバック定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local PortConnectListener= {}
--_G["openrtm.PortConnectListener"] = PortConnectListener

PortConnectListener.PortConnectListenerType = {
												ON_NOTIFY_CONNECT = 1,
												ON_NOTIFY_DISCONNECT = 2,
												ON_UNSUBSCRIBE_INTERFACES = 3,
												PORT_CONNECT_LISTENER_NUM = 4
												}

PortConnectListener.PortConnectRetListenerType = {
												ON_PUBLISH_INTERFACES = 1,
												ON_CONNECT_NEXTPORT = 2,
												ON_SUBSCRIBE_INTERFACES = 3,
												ON_CONNECTED = 4,
												ON_DISCONNECT_NEXT = 5,
												ON_DISCONNECTED = 6,
												PORT_CONNECT_RET_LISTENER_NUM = 7
												}


PortConnectListener.PortConnectListeners = {}

PortConnectListener.PortConnectListeners.new = function()
	local obj = {}
	return obj
end


return PortConnectListener
