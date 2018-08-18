local luaunit = require "luaunit"
local InPortDSProvider = require "openrtm.InPortDSProvider"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local oil = require "oil"
local RTCUtil = require "openrtm.RTCUtil"
local BufferStatus = require "openrtm.BufferStatus"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo

TestInPortDSProvider = {}



local BufferMoc = {}
BufferMoc.new = function()
	local obj = {}
	return obj
end

local ConnectorMoc = {}
ConnectorMoc.new = function()
	local obj = {}
	obj._count = 0
	function obj:write(data)
		self._count = self._count + 1
		return BufferStatus.BUFFER_OK
	end
	return obj
end




function TestInPortDSProvider:test_provider()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)
	local PortStatus = mgr:instance():getORB().types:lookup("::RTC::PortStatus").labelvalue
	local orb = mgr:getORB()
	local PortStatus = orb.types:lookup("::RTC::PortStatus").labelvalue
	

	local provider = InPortDSProvider.new()
	provider:init(Properties.new())
	local buffer = BufferMoc.new()
	provider:setBuffer(buffer)
	local connector = ConnectorMoc.new()
	provider:setConnector(connector)
	local listener = ConnectorListener.ConnectorListeners.new()
	local info = ConnectorInfo.new(
		"name",
		"id",
		{},
		Properties.new()
	)
	provider:setListener(info, listener)

	
		
	luaunit.assertEquals(provider:push(""), PortStatus.PORT_OK)
	luaunit.assertEquals(connector._count, 1)


	luaunit.assertEquals(provider:convertReturn(BufferStatus.BUFFER_OK,""),PortStatus.PORT_OK)
	luaunit.assertEquals(provider:convertReturn(BufferStatus.BUFFER_FULL,""),PortStatus.BUFFER_FULL)
	luaunit.assertEquals(provider:convertReturn(BufferStatus.BUFFER_EMPTY,""),PortStatus.BUFFER_EMPTY)
	luaunit.assertEquals(provider:convertReturn(BufferStatus.PRECONDITION_NOT_MET,""),PortStatus.PORT_ERROR)
	luaunit.assertEquals(provider:convertReturn(BufferStatus.TIMEOUT,""),PortStatus.BUFFER_TIMEOUT)
	luaunit.assertEquals(provider:convertReturn(BufferStatus.NOT_SUPPORTED,""),PortStatus.UNKNOWN_ERROR)

	luaunit.assertNotEquals(provider:getObjRef(),nil)


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
