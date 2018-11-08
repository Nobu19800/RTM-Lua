local luaunit = require "luaunit"
local OutPortPushConnector = require "openrtm.OutPortPushConnector"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo
local DataPortStatus = require "openrtm.DataPortStatus"
local BufferStatus = require "openrtm.BufferStatus"
local DataPortStatus = require "openrtm.DataPortStatus"



TestOutPortPushConnector = {}



local ConsumerMock = {}
ConsumerMock.new = function()
	local obj = {}
	function obj:init(prop)
	end
	function obj:put(data)
		return DataPortStatus.PORT_OK
	end


	return obj
end

local BufferMock = {}
BufferMock.new = function()
	local obj = {}
	function obj:init(prop)
	end


	return obj
end



function TestOutPortPushConnector:test_connector()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local consumer = ConsumerMock.new()
	local buffer = BufferMock.new()
	local listener = ConnectorListener.ConnectorListeners.new()
	local info = ConnectorInfo.new(
		"name",
		"id",
		{},
		Properties.new()
	)

	local connector = OutPortPushConnector.new(info, consumer, listener, buffer)

	

	local d_out = {tm={sec=0,nsec=0},data=0}
	local data = {_data=d_out, _type="::RTC::TimedLong"}
	luaunit.assertEquals(connector:write(data), DataPortStatus.PORT_OK)
	
	--luaunit.assertIsFalse(inIn:isNew())
	--luaunit.assertIsTrue(inIn:isEmpty())
	
	
	mgr:createShutdownThread(0.01)

end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
