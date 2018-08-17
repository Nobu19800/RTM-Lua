local luaunit = require "luaunit"
local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local Properties = require "openrtm.Properties"
local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"
local ConnectorListener = require "openrtm.ConnectorListener"
local PortCallBack = require "openrtm.PortCallBack"




TestOutPort = {}




local DataListener = {}
DataListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=ConnectorListener.ConnectorDataListener.new()})
	obj._name = name
	function obj:call(info, cdrdata)
		return ConnectorListener.ConnectorListenerStatus.NO_CHANGE
	end
	return obj
end


local ConnListener = {}
ConnListener.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=ConnectorListener.ConnectorListener.new()})
	obj._name = name
	function obj:call(info)
		return ConnectorListener.ConnectorListenerStatus.NO_CHANGE
	end
	return obj
end



local OnWrite = {}
OnWrite.new = function()
	local obj = {}
	setmetatable(obj, {__index=PortCallBack.OnWrite.new()})
	obj._count = 0
	function obj:call(value)
		self._count = self._count + 1
	end
	return obj
end


local OnWriteConvert = {}
OnWriteConvert.new = function()
	local obj = {}
	setmetatable(obj, {__index=PortCallBack.OnWriteConvert.new()})
	obj._count = 0
	function obj:call(value)
		self._count = self._count + 1
		return value
	end
	return obj
end




function TestOutPort:test_outport()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t


	local d_out = {tm={sec=0,nsec=0},data=0}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")
	local prop = Properties.new()
	outOut:init(prop)

	outOut:addConnectorListener(ConnectorListener.ConnectorListenerType.ON_CONNECT,
		ConnListener.new("ON_CONNECT"))
	outOut:addConnectorListener(ConnectorListener.ConnectorListenerType.ON_DISCONNECT,
		ConnListener.new("ON_DISCONNECT"))


	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE,
		DataListener.new("ON_BUFFER_WRITE"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_FULL,
		DataListener.new("ON_BUFFER_FULL"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT,
		DataListener.new("ON_BUFFER_WRITE_TIMEOUT"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_OVERWRITE,
		DataListener.new("ON_BUFFER_OVERWRITE"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_READ,
		DataListener.new("ON_BUFFER_READ"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_SEND,
		DataListener.new("ON_SEND"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVED,
		DataListener.new("ON_RECEIVED"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_FULL,
		DataListener.new("ON_RECEIVER_FULL"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT,
		DataListener.new("ON_RECEIVER_TIMEOUT"))
	outOut:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_ERROR,
		DataListener.new("ON_RECEIVER_ERROR"))





	luaunit.assertEquals(outOut:name(), "out")
	OutPort.setTimestamp(d_out)

	

	local on_write = OnWrite.new()
	local on_write_conv = OnWriteConvert.new()
	outOut:setOnWrite(on_write)
	outOut:setOnWriteConvert(on_write_conv)


	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")
	inIn:init(prop)

	
	local ret = CORBA_RTCUtil.connect("testcon",Properties.new(),outOut,inIn)
	

	local conprofs = outOut:get_connector_profiles()
	luaunit.assertEquals(#conprofs, 1)
	local con = outOut:getConnectorById(conprofs[1].connector_id)
	luaunit.assertNotEquals(con, nil)


	outOut:write()
	
	
	luaunit.assertEquals(on_write._count, 1)
	luaunit.assertEquals(on_write_conv._count, 1)

	
	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
