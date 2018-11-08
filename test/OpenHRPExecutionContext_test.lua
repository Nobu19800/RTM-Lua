local luaunit = require "luaunit"
local OpenHRPExecutionContext = require "openrtm.OpenHRPExecutionContext"
local Properties = require "openrtm.Properties"
local oil = require "oil"





TestOpenHRPExecutionContext = {}


function TestOpenHRPExecutionContext:test_ec()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)

	local ec = OpenHRPExecutionContext.new()
	ec:init(Properties.new())
	ec:start()

	oil.main(function()
		for i = 1,1002 do
			ec:tick()
		end
	end)

	ec:stop()
	
	ec:tick()


	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
