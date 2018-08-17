local luaunit = require "luaunit"
local ConnectorListener = require "openrtm.ConnectorListener"


TestConnectorListener = {}



local ConnectorDataListener_ = {}
ConnectorDataListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ConnectorListener.ConnectorDataListener.new()})
	function obj:call(info, data)
	end
	return obj
end


local ConnectorListener_ = {}
ConnectorListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ConnectorListener.ConnectorListener.new()})
	function obj:call(info)
	end
	return obj
end


function TestConnectorListener:test_listener()
	local listeners = ConnectorListener.ConnectorListeners.new()
	local listener1 = ConnectorDataListener_.new()
	listeners.connectorData_[ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE]:addListener(listener1)

	local listener2 = ConnectorListener_.new()
	listeners.connector_[ConnectorListener.ConnectorListenerType.ON_BUFFER_EMPTY]:addListener(listener2)

	listeners.connectorData_[ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE]:notify({})
	listeners.connector_[ConnectorListener.ConnectorListenerType.ON_BUFFER_EMPTY]:notify({},"")


	listeners.connectorData_[ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE]:removeListener(listener1)
	listeners.connector_[ConnectorListener.ConnectorListenerType.ON_BUFFER_EMPTY]:removeListener(listener2)


end

function TestConnectorListener:test_string()
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE)
	luaunit.assertEquals(str, "ON_BUFFER_WRITE")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_FULL)
	luaunit.assertEquals(str, "ON_BUFFER_FULL")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT)
	luaunit.assertEquals(str, "ON_BUFFER_WRITE_TIMEOUT")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_OVERWRITE)
	luaunit.assertEquals(str, "ON_BUFFER_OVERWRITE")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_READ)
	luaunit.assertEquals(str, "ON_BUFFER_READ")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_SEND)
	luaunit.assertEquals(str, "ON_SEND")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_RECEIVED)
	luaunit.assertEquals(str, "ON_RECEIVED")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_FULL)
	luaunit.assertEquals(str, "ON_RECEIVER_FULL")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT)
	luaunit.assertEquals(str, "ON_RECEIVER_TIMEOUT")
	local str = ConnectorListener.ConnectorDataListener.toString(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_ERROR)
	luaunit.assertEquals(str, "ON_RECEIVER_ERROR")


	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_BUFFER_EMPTY)
	luaunit.assertEquals(str, "ON_BUFFER_EMPTY")
	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_BUFFER_READ_TIMEOUT)
	luaunit.assertEquals(str, "ON_BUFFER_READ_TIMEOUT")
	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_SENDER_EMPTY)
	luaunit.assertEquals(str, "ON_SENDER_EMPTY")
	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_SENDER_TIMEOUT)
	luaunit.assertEquals(str, "ON_SENDER_TIMEOUT")
	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_SENDER_ERROR)
	luaunit.assertEquals(str, "ON_SENDER_ERROR")
	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_CONNECT)
	luaunit.assertEquals(str, "ON_CONNECT")
	local str = ConnectorListener.ConnectorListener.toString(ConnectorListener.ConnectorListenerType.ON_DISCONNECT)
	luaunit.assertEquals(str, "ON_DISCONNECT")


end

local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
