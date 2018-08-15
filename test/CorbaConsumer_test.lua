local luaunit = require "luaunit"

local CorbaConsumer = require "openrtm.CorbaConsumer"






TestCorbaConsumer = {}
function TestCorbaConsumer:test_func()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)
	

	local orb = mgr:getORB()
	orb:loadidl [[
		interface Hello {
			string echo(in string name);
		};
	]]

	local hello = {}
	function hello:echo(name)
		return "abc"
	end

	local svr = orb:newservant(hello, nil, "Hello")
	local ior = orb:tostring(svr)

	local cc = CorbaConsumer.new("Hello")
	luaunit.assertIsTrue(cc:setIOR(ior))

	luaunit.assertEquals(cc:_ptr():echo("abc"), "abc")

	cc:releaseObject()
	orb:deactivate(svr)
	


	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
