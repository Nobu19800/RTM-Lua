local luaunit = require "luaunit"
local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local Properties = require "openrtm.Properties"
local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"
local ConnectorListener = require "openrtm.ConnectorListener"




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




function TestInPort:test_inport()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
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





	luaunit.assertEquals(inIn:name(), "in")
	luaunit.assertIsFalse(inIn:isNew())
	luaunit.assertIsTrue(inIn:isEmpty())
	
	local ret_onread = 0
	local ret_onreadconv = 0
	inIn:setOnRead(function()
		ret_onread = ret_onread+1
	end)
	inIn:setOnReadConvert(function(value)
		ret_onreadconv = ret_onreadconv+1
		return value 
	end)


	local d_out = {tm={sec=0,nsec=0},data=0}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")
	outOut:init(prop)

	
	local ret = CORBA_RTCUtil.connect("testcon",Properties.new(),outOut,inIn)

	local conprofs = inIn:get_connector_profiles()
	luaunit.assertEquals(#conprofs, 1)
	local con = inIn:getConnectorById(conprofs[1].connector_id)
	luaunit.assertNotEquals(con, nil)


	outOut:write()
	luaunit.assertIsTrue(inIn:isNew())

	inIn:read()
	
	
	luaunit.assertEquals(ret_onread, 1)
	luaunit.assertEquals(ret_onreadconv, 1)

	inIn:update()
	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
