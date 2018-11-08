local luaunit = require "luaunit"
local InPortPullConnector = require "openrtm.InPortPullConnector"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo
local DataPortStatus = require "openrtm.DataPortStatus"


TestInPortPullConnector = {}



local CosumerMock = {}
CosumerMock.new = function()
	local obj = {}
	function obj:init(prop)
	end
	function obj:setBuffer(buffer)
	end
	function obj:setListener(info, listeners)
	end
	function obj:get(data)
		local mgr = require "openrtm.Manager"
		local d_out = {tm={sec=0,nsec=0},data=0}
		data._data = mgr:instance():cdrMarshal(d_out, "::RTC::TimedLong")
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



function TestInPortPullConnector:test_connector()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local consumer = CosumerMock.new()
	local buffer = BufferMock.new()
	local listener = ConnectorListener.ConnectorListeners.new()
	local info = ConnectorInfo.new(
		"name",
		"id",
		{},
		Properties.new()
	)

	local connector = InPortPullConnector.new(info, consumer, listener, buffer)

	connector:setDataType("::RTC::TimedLong")

	local data = {_data=0}
	luaunit.assertEquals(connector:read(data), DataPortStatus.PORT_OK)
	luaunit.assertEquals(data._data.data, 0)
	--luaunit.assertIsFalse(inIn:isNew())
	--luaunit.assertIsTrue(inIn:isEmpty())
	connector:createBuffer(info)
	
	mgr:createShutdownThread(0.01)

end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
