local luaunit = require "luaunit"
local PortConnectListener = require "openrtm.PortConnectListener"


TestPortConnectListener = {}



local PortConnectListener_ = {}
PortConnectListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=PortConnectListener.PortConnectListener.new()})
	function obj:call(info, data)
	end
	return obj
end


local PortConnectRetListener_ = {}
PortConnectRetListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=PortConnectListener.PortConnectRetListener.new()})
	function obj:call(portname, profile, ret)
	end
	return obj
end


function TestPortConnectListener:test_listener()
	local listeners = PortConnectListener.PortConnectListeners.new()
	local listener1 = PortConnectListener_.new()
	listeners.portconnect_[PortConnectListener.PortConnectListenerType.ON_NOTIFY_CONNECT]:addListener(listener1)

	local listener2 = PortConnectRetListener_.new()
	listeners.portconnret_[PortConnectListener.PortConnectRetListenerType.ON_PUBLISH_INTERFACES]:addListener(listener2)

	listeners.portconnect_[PortConnectListener.PortConnectListenerType.ON_NOTIFY_CONNECT]:notify({},{})
	listeners.portconnret_[PortConnectListener.PortConnectRetListenerType.ON_PUBLISH_INTERFACES]:notify({},{},{})


	listeners.portconnect_[PortConnectListener.PortConnectListenerType.ON_NOTIFY_CONNECT]:removeListener(listener1)
	listeners.portconnret_[PortConnectListener.PortConnectRetListenerType.ON_PUBLISH_INTERFACES]:removeListener(listener1)


end

function TestPortConnectListener:test_string()
	local str = PortConnectListener.PortConnectListener.toString(PortConnectListener.PortConnectListenerType.ON_NOTIFY_CONNECT)
	luaunit.assertEquals(str, "ON_NOTIFY_CONNECT")
	local str = PortConnectListener.PortConnectListener.toString(PortConnectListener.PortConnectListenerType.ON_NOTIFY_DISCONNECT)
	luaunit.assertEquals(str, "ON_NOTIFY_DISCONNECT")
	local str = PortConnectListener.PortConnectListener.toString(PortConnectListener.PortConnectListenerType.ON_UNSUBSCRIBE_INTERFACES)
	luaunit.assertEquals(str, "ON_UNSUBSCRIBE_INTERFACES")


	local str = PortConnectListener.PortConnectRetListener.toString(PortConnectListener.PortConnectRetListenerType.ON_PUBLISH_INTERFACES)
	luaunit.assertEquals(str, "ON_PUBLISH_INTERFACES")
	local str = PortConnectListener.PortConnectRetListener.toString(PortConnectListener.PortConnectRetListenerType.ON_CONNECT_NEXTPORT)
	luaunit.assertEquals(str, "ON_CONNECT_NEXTPORT")
	local str = PortConnectListener.PortConnectRetListener.toString(PortConnectListener.PortConnectRetListenerType.ON_SUBSCRIBE_INTERFACES)
	luaunit.assertEquals(str, "ON_SUBSCRIBE_INTERFACES")
	local str = PortConnectListener.PortConnectRetListener.toString(PortConnectListener.PortConnectRetListenerType.ON_CONNECTED)
	luaunit.assertEquals(str, "ON_CONNECTED")
	local str = PortConnectListener.PortConnectRetListener.toString(PortConnectListener.PortConnectRetListenerType.ON_DISCONNECT_NEXT)
	luaunit.assertEquals(str, "ON_DISCONNECT_NEXT")
	local str = PortConnectListener.PortConnectRetListener.toString(PortConnectListener.PortConnectRetListenerType.ON_DISCONNECTED)
	luaunit.assertEquals(str, "ON_DISCONNECTED")


	
end

local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
