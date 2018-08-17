local luaunit = require "luaunit"
local PortAdmin = require "openrtm.PortAdmin"
local Properties = require "openrtm.Properties"



local PortMock = {}
PortMock.new = function(name)
	local obj = {}
	obj._name = name
	function obj:getName()
		return self._name
	end
	function obj:get_port_profile()
		return {name=self._name}
	end
	function obj:getProfile()
		return {name=self._name}
	end
	
	function obj:getPortRef()
		return self
	end

	function obj:disconnect_all()
	end
	function obj:activate()
	end
	function obj:deactivate()
	end
	function obj:activateInterfaces()
	end
	function obj:deactivateInterfaces()
	end
	function obj:setPortRef(_obj)
	end

	return obj
end



TestPortAdmin = {}


function TestPortAdmin:test_port()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local orb = mgr:getORB()

	local portadmin = PortAdmin.new(orb)
	local port1 = PortMock.new("test1")
	luaunit.assertIsTrue(portadmin:addPort(port1))
	luaunit.assertIsFalse(portadmin:addPort(port1))
	
	luaunit.assertEquals(#portadmin:getPortServiceList(), 1)

	
	luaunit.assertIsTrue(portadmin:removePort(port1))
	luaunit.assertIsFalse(portadmin:removePort(port1))
	
	luaunit.assertIsTrue(portadmin:addPort(port1))
	luaunit.assertEquals(#portadmin:getPortProfileList(), 1)
	portadmin:activatePorts()
	portadmin:deactivatePorts()
	portadmin:finalizePorts()
	luaunit.assertEquals(#portadmin:getPortProfileList(), 0)




	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
