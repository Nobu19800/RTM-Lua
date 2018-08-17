local luaunit = require "luaunit"
local OutPortDSProvider = require "openrtm.OutPortDSProvider"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"
local oil = require "oil"
local RTCUtil = require "openrtm.RTCUtil"
local BufferStatus = require "openrtm.BufferStatus"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo

TestOutPortDSProvider = {}



local BufferMoc = {}
BufferMoc.new = function()
	local obj = {}
	function obj:empty()
		return false
	end
	function obj:read(cdr)
		local mgr = require "openrtm.Manager"
		local d_out = {tm={sec=0,nsec=0},data=0}
		local data = mgr:instance():cdrMarshal(d_out, "::RTC::TimedLong")

		cdr._data = data
		return BufferStatus.BUFFER_OK
	end
	return obj
end

local ConnectorMoc = {}
ConnectorMoc.new = function()
	local obj = {}
	obj._count = 0

	return obj
end




function TestOutPortDSProvider:test_provider()

	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)
	local PortStatus = mgr:instance():getORB().types:lookup("::RTC::PortStatus").labelvalue
	local orb = mgr:getORB()

	local provider = OutPortDSProvider.new()
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

	
	local ret,data = provider:pull("")
	luaunit.assertEquals(ret, PortStatus.PORT_OK)
	


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
