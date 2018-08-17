local luaunit = require "luaunit"
local OpenHRPExecutionContext = require "openrtm.OpenHRPExecutionContext"
local Properties = require "openrtm.Properties"






TestOpenHRPExecutionContext = {}


function TestOpenHRPExecutionContext:test_ec()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ec = OpenHRPExecutionContext.new()
	ec:init(Properties.new())
	ec:start()

	ec:tick()

	ec:stop()
	
	ec:tick()


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
