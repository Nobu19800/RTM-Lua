local luaunit = require "luaunit"
local ListenerHolder = require "openrtm.ListenerHolder"



TestListenerHolder = {}


local listenerMock = {}
listenerMock.new = function()
	local obj = {}
	obj._value = 0
	function obj:test_func(v)
		self._value = v
	end
	return obj
end

function TestListenerHolder:test_holder()
	local holder = ListenerHolder.new()
	local listener = listenerMock.new()
	holder:addListener(listener, true)
	holder:notify("test_func",10)
	luaunit.assertEquals(listener._value, 10)
	holder:removeListener(listener)
	holder:notify("test_func",100)
	luaunit.assertNotEquals(listener._value, 100)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
