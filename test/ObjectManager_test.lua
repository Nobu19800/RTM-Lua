local luaunit = require "luaunit"
local ObjectManager = require "openrtm.ObjectManager"
local Properties = require "openrtm.Properties"



local FactoryPredicate = function(argv)
	local obj = {}

	if argv.name then
		obj._vendor = ""
		obj._category = ""
		obj._impleid = argv.name
		obj._version = ""
	elseif argv.factory then
		obj._vendor = argv.factory:profile():getProperty("vendor")
		obj._category = argv.factory:profile():getProperty("category")
		obj._impleid = argv.factory:profile():getProperty("implementation_id")
		obj._version = argv.factory:profile():getProperty("version")
	end


	local call_func = function(self, factory)
		local _prop = Properties.new({prop=factory:profile()})
		if self._impleid ~= _prop:getProperty("implementation_id") then
			return false
		end

		return true
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

local FactoryMoc = {}
FactoryMoc.new = function(name)
	local obj = {}
	obj._prop = Properties.new()
	obj._prop:setProperty("implementation_id", name)
	function obj:profile()
		return self._prop
	end
	return obj
end


TestObjectManager = {}


function TestObjectManager:test_objmgr()
	local objmgr = ObjectManager.new(FactoryPredicate)
	luaunit.assertIsTrue(objmgr:registerObject(FactoryMoc.new("test1")))
	luaunit.assertIsFalse(objmgr:registerObject(FactoryMoc.new("test1")))
	luaunit.assertNotEquals(objmgr:unregisterObject("test1"),nil)
	luaunit.assertEquals(objmgr:unregisterObject("test1"),nil)

	luaunit.assertEquals(#objmgr:getObjects(), 0)

	objmgr:registerObject(FactoryMoc.new("test1"))
	


	luaunit.assertEquals(#objmgr:getObjects(), 1)
	

end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
