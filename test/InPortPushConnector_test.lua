local luaunit = require "luaunit"
local InPortPushConnector = require "openrtm.InPortPushConnector"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo
local DataPortStatus = require "openrtm.DataPortStatus"
local BufferStatus = require "openrtm.BufferStatus"



TestInPortPushConnector = {}



local ProviderMock = {}
ProviderMock.new = function()
	local obj = {}
	function obj:init(prop)
	end
	function obj:setBuffer(buffer)
	end
	function obj:setListener(info, listeners)
	end

	return obj
end

local BufferMock = {}
BufferMock.new = function()
	local obj = {}
	function obj:init(prop)
	end
	function obj:read(data)
		local mgr = require "openrtm.Manager"
		local d_out = {tm={sec=0,nsec=0},data=0}
		data._data = mgr:instance():cdrMarshal(d_out, "::RTC::TimedLong")

		return BufferStatus.BUFFER_OK
	end
	function obj:write(data)
		return BufferStatus.BUFFER_OK
	end
	return obj
end



function TestInPortPushConnector:test_connector()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local provider = ProviderMock.new()
	local buffer = BufferMock.new()
	local listener = ConnectorListener.ConnectorListeners.new()
	local info = ConnectorInfo.new(
		"name",
		"id",
		{},
		Properties.new()
	)

	local connector = InPortPushConnector.new(info, provider, listener, buffer)

	connector:setDataType("::RTC::TimedLong")

	local data = {_data=0}
	luaunit.assertEquals(connector:read(data), DataPortStatus.PORT_OK)
	luaunit.assertEquals(data._data.data, 0)
	--luaunit.assertIsFalse(inIn:isNew())
	--luaunit.assertIsTrue(inIn:isEmpty())
	
	
	mgr:createShutdownThread(0.01)

end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
