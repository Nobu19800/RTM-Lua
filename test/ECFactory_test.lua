local luaunit = require "luaunit"
local ECFactory = require "openrtm.ECFactory"
local ECFactoryLua = ECFactory.ECFactoryLua



TestECFactory = {}


function TestECFactory:test_toString()
	local factory = ECFactoryLua.new("test1",function()return "test2"end,function(ec)end)

	luaunit.assertEquals( factory:name(), 'test1' )
	luaunit.assertEquals( factory:create(), 'test2' )
	factory:destroy(nil)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
