local luaunit = require "luaunit"
local GlobalFactory = require "openrtm.GlobalFactory"
local Factory = GlobalFactory.Factory

TestGlobalFactory = {}



local ObjectMOC = {}
ObjectMOC.new = function()
	local obj = {}
	return obj
end





function TestGlobalFactory:test_factory()

	local creator = function()
		return ObjectMOC.new()
	end
	local destructor = function(obj)
	end

	
	local factory = Factory.new()
	luaunit.assertEquals(factory:addFactory("test1",creator,destructor), GlobalFactory.Factory.FACTORY_OK)
	luaunit.assertEquals(factory:addFactory("test1",creator,destructor), GlobalFactory.Factory.ALREADY_EXISTS)

	luaunit.assertIsTrue(factory:hasFactory("test1"))
	luaunit.assertIsFalse(factory:hasFactory("test2"))

	luaunit.assertEquals(factory:getIdentifiers()[1], "test1")
	


	local obj1 = factory:createObject("test1")
	luaunit.assertNotEquals(obj1, nil)
	luaunit.assertEquals(factory:createObject("test2"), nil)

	luaunit.assertEquals(#factory:createdObjects(), 1)

	luaunit.assertIsTrue(factory:isProducerOf(obj1))

	local id,ret = factory:objectToIdentifier(obj1)
	luaunit.assertEquals(id, "test1")
	luaunit.assertEquals(ret, GlobalFactory.Factory.FACTORY_OK)

	luaunit.assertNotEquals(factory:objectToCreator(obj1),nil)
	luaunit.assertNotEquals(factory:objectToDestructor(obj1),nil)


	luaunit.assertEquals(factory:deleteObject(obj1), GlobalFactory.Factory.FACTORY_OK)
	luaunit.assertEquals(factory:deleteObject(obj1), GlobalFactory.Factory.NOT_FOUND)
	
	luaunit.assertIsFalse(factory:isProducerOf(obj1))
	local id,ret = factory:objectToIdentifier(obj1)
	luaunit.assertEquals(id, -1)
	luaunit.assertEquals(ret, GlobalFactory.Factory.NOT_FOUND)

	luaunit.assertEquals(factory:objectToCreator(obj1),nil)
	luaunit.assertEquals(factory:objectToDestructor(obj1),nil)


	
	luaunit.assertEquals(factory:removeFactory("test1"), GlobalFactory.Factory.FACTORY_OK)
	luaunit.assertEquals(factory:removeFactory("test1"), GlobalFactory.Factory.NOT_FOUND)
	
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
