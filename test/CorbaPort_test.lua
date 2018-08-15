local luaunit = require "luaunit"

local CorbaPort = require "openrtm.CorbaPort"
local RTCUtil = require "openrtm.RTCUtil"
local Properties = require "openrtm.Properties"
local oil = require "oil"




TestCorbaNaming = {}
function TestCorbaNaming:test_naming()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)
	

	local myServicePort = CorbaPort.new("MyService")
	myServicePort:init(Properties.new())



	


	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
