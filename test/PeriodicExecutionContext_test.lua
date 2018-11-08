local luaunit = require "luaunit"
local PeriodicExecutionContext = require "openrtm.PeriodicExecutionContext"
local Properties = require "openrtm.Properties"
local oil = require "oil"





TestPeriodicExecutionContext = {}


function TestPeriodicExecutionContext:test_ec()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	

	local ec = PeriodicExecutionContext.new()
	ec:init(Properties.new())

	luaunit.assertIsFalse(ec:threadRunning())
	
	

	oil.main(function()
		ec:onStarted()
		oil.tasks:suspend(1)
		ec:onStopped()
	end)

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
