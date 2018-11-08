local luaunit = require "luaunit"
local PublisherFlush = require "openrtm.PublisherFlush"
local Properties = require "openrtm.Properties"
local DataPortStatus = require "openrtm.DataPortStatus"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorListeners = ConnectorListener.ConnectorListeners
local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo



TestPublisherFlush = {}


local ConsumerMock = {}
ConsumerMock.new = function()
	local obj = {}
	function obj:put(data)
		return DataPortStatus.PORT_OK
	end
	return obj
end

local BufferMock = {}
BufferMock.new = function()
	local obj = {}
	return obj
end

function TestPublisherFlush:test_publisher()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)


	local publisher = PublisherFlush.new()
	local prop = Properties.new()
	publisher:init(prop)
	local consumer = ConsumerMock.new()
	luaunit.assertEquals(publisher:setConsumer(consumer), DataPortStatus.PORT_OK)
	
	local buffer = BufferMock.new()
	luaunit.assertEquals(publisher:setBuffer(buffer), DataPortStatus.PORT_OK)
	

	local info = ConnectorInfo.new(
		"name",
		"id",
		{},
		Properties.new()
	)

	local listeners = ConnectorListeners.new()
	
	luaunit.assertEquals(publisher:setListener(info, listeners), DataPortStatus.PORT_OK)


	luaunit.assertEquals(publisher:activate(), DataPortStatus.PORT_OK)
	luaunit.assertEquals(publisher:activate(), DataPortStatus.PRECONDITION_NOT_MET)

	luaunit.assertIsTrue(publisher:isActive())

	luaunit.assertEquals(publisher:write("abc",0,0), DataPortStatus.PORT_OK)

	luaunit.assertEquals(publisher:deactivate(), DataPortStatus.PORT_OK)
	luaunit.assertEquals(publisher:deactivate(), DataPortStatus.PRECONDITION_NOT_MET)

	luaunit.assertIsFalse(publisher:isActive())

	mgr:createShutdownThread(0.01)
end




local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
