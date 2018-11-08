local luaunit = require "luaunit"
local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local Properties = require "openrtm.Properties"
local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"
local ConnectorListener = require "openrtm.ConnectorListener"
local PortCallBack = require "openrtm.PortCallBack"



TestInPort = {}




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




local OnRead = {}
OnRead.new = function()
	local obj = {}
	setmetatable(obj, {__index=PortCallBack.OnRead.new()})
	obj._count = 0
	function obj:call()
		self._count = self._count + 1
	end
	return obj
end


local OnReadConvert = {}
OnReadConvert.new = function()
	local obj = {}
	setmetatable(obj, {__index=PortCallBack.OnReadConvert.new()})
	obj._count = 0
	function obj:call(value)
		self._count = self._count + 1
		return value
	end
	return obj
end



function TestInPort:test_inport()

	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t


	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")
	local prop = Properties.new()
	inIn:init(prop)

	inIn:addConnectorListener(ConnectorListener.ConnectorListenerType.ON_CONNECT,
		ConnListener.new("ON_CONNECT"))
	inIn:addConnectorListener(ConnectorListener.ConnectorListenerType.ON_DISCONNECT,
		ConnListener.new("ON_DISCONNECT"))

	local lintener = ConnListener.new("ON_CONNECT2")
	inIn:addConnectorListener(ConnectorListener.ConnectorListenerType.ON_CONNECT, lintener)
	inIn:removeConnectorListener(ConnectorListener.ConnectorListenerType.ON_CONNECT, lintener)



	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE,
		DataListener.new("ON_BUFFER_WRITE"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_FULL,
		DataListener.new("ON_BUFFER_FULL"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE_TIMEOUT,
		DataListener.new("ON_BUFFER_WRITE_TIMEOUT"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_OVERWRITE,
		DataListener.new("ON_BUFFER_OVERWRITE"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_READ,
		DataListener.new("ON_BUFFER_READ"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_SEND,
		DataListener.new("ON_SEND"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVED,
		DataListener.new("ON_RECEIVED"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_FULL,
		DataListener.new("ON_RECEIVER_FULL"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_TIMEOUT,
		DataListener.new("ON_RECEIVER_TIMEOUT"))
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_RECEIVER_ERROR,
		DataListener.new("ON_RECEIVER_ERROR"))


	local lintener = DataListener.new("ON_BUFFER_WRITE2")
	inIn:addConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE,lintener)
	inIn:removeConnectorDataListener(ConnectorListener.ConnectorDataListenerType.ON_BUFFER_WRITE,lintener)
	



	luaunit.assertEquals(inIn:name(), "in")
	luaunit.assertIsFalse(inIn:isNew())
	luaunit.assertIsTrue(inIn:isEmpty())
	
	local on_read = OnRead.new()
	inIn:setOnRead(on_read)
	local on_read_conv = OnReadConvert.new()
	inIn:setOnReadConvert(on_read_conv)


	local d_out = {tm={sec=0,nsec=0},data=0}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")
	outOut:init(prop)

	local prop = Properties.new()
	prop:setProperty("dataport.inport.buffer.write.full_policy","do_nothing")
	prop:setProperty("dataport.inport.buffer.read.empty_policy","do_nothing")
	local ret = CORBA_RTCUtil.connect("testcon",prop,outOut,inIn)

	local conprofs = inIn:get_connector_profiles()
	luaunit.assertEquals(#conprofs, 1)
	local con = inIn:getConnectorById(conprofs[1].connector_id)
	luaunit.assertNotEquals(con, nil)


	outOut:write()
	luaunit.assertIsTrue(inIn:isNew())
	luaunit.assertIsFalse(inIn:isEmpty())

	inIn:read()
	
	
	luaunit.assertEquals(on_read._count, 1)
	luaunit.assertEquals(on_read_conv._count, 1)

	inIn:setOnReadConvert(nil)
	outOut:write()
	inIn:read()


	CORBA_RTCUtil.disconnect_all_by_ref(outOut)
	inIn:read()
	local prop = Properties.new()
	prop:setProperty("dataport.dataflow_type","pull")
	local ret = CORBA_RTCUtil.connect("testcon",prop,outOut,inIn)
	outOut:write()
	luaunit.assertIsFalse(inIn:isNew())

	inIn:read()
	

	inIn:update()
	
	mgr:createShutdownThread(0.01)
end



function TestInPort:test_direct()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t


	local d_out = {tm={sec=0,nsec=0},data=10}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")
	local prop = Properties.new()
	outOut:init(prop)
	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")
	inIn:init(prop)


	local prop = Properties.new()
	prop:setProperty("dataport.dataflow_type","pull")
	prop:setProperty("dataport.interface_type","direct")
	local ret = CORBA_RTCUtil.connect("testcon",prop,outOut,inIn)
	luaunit.assertIsTrue(outOut:write())
	local data = inIn:read()
	luaunit.assertEquals(data.data, 10)

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
