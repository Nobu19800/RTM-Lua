local luaunit = require "luaunit"
local Factory = require "openrtm.Factory"
local Properties = require "openrtm.Properties"
local FactoryLua = Factory.FactoryLua

TestFactory = {}



local RTObjectMOC = {}
RTObjectMOC.new = function(name)
	local obj = {}
	obj._typename = name
	function obj:setProperties(prop)
	end
	function obj:setInstanceName(name)
	end
	function obj:getTypeName()
		return self._typename
	end
	
	return obj
end


local ManagerMOC = {}
ManagerMOC.new = function()
	local obj = {}
	return obj
end


local PolicyMOC = {}
PolicyMOC.new = function()
	local obj = {}
	obj.count = 0
	function obj:onCreate(rtobj)
		obj.count = obj.count+1
		return obj.count
	end
	function obj:onDelete(rtobj)
		obj.count = obj.count-1
	end
	return obj
end


function TestFactory:test_init()

	local prof = Properties.new()
	local mgr = ManagerMOC.new()
	local new_func = function(mgr)
		return RTObjectMOC.new("test")
	end
	local delete_func = function(comp)
	end
	local factory = FactoryLua.new(prof, new_func, delete_func, PolicyMOC.new())
	factory:init()
	luaunit.assertNotEquals(factory:create(mgr),nil)
	factory:destroy(mgr)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
