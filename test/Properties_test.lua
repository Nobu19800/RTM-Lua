local luaunit = require "luaunit"
local Properties = require "openrtm.Properties"


TestProperties = {}



local dummy_output = {}
dummy_output.new = function()
	local obj = {}
	obj.write = function(str, ...)

	end
	return obj
end

local dummy_instream = {}
dummy_instream.new = function(value)
	local obj = {}
	obj._value = value
	obj._count = 0
	function obj:lines()
		return function()
			self._count = self._count+1
			return self._value[self._count]
		end
	end
	return obj
end


function TestProperties:test_prop()
	local prop1 = Properties.new()
	prop1:setProperty("param1","value1")
	luaunit.assertEquals(prop1:getProperty("param1"),"value1")
	local prop2 = Properties.new{prop=prop1}
	luaunit.assertEquals(prop2:getProperty("param1"),"value1")
	local prop3 = Properties.new{key="param2",value="value2"}
	luaunit.assertEquals(prop3:getName(),"param2")
	luaunit.assertEquals(prop3:getValue(),"value2")
	local prop4 = Properties.new{key="param3"}
	local prop5 = Properties.new{defaults_map={["param4"]="value4"}}
	luaunit.assertEquals(prop5:getProperty("param4"),"value4")

	local value = prop5:getProperty("param4", "default4")
	luaunit.assertEquals(value,"value4")
	local value = prop5:getProperty("dummy", "default4")
	luaunit.assertEquals(value,"default4")
	prop5:setDefault("param5", "default5")
	local value = prop5:getProperty("param5")
	luaunit.assertEquals(value,"default5")
	

	luaunit.assertEquals(prop5:getDefault("param5"),"default5")

	prop5:setDefaults({["param6"]="default6"})
	luaunit.assertEquals(prop5:getDefault("param6"),"default6")

	local output = dummy_output.new()
	prop5:list(output)

	local prop6 = Properties.new()
	--[[
	prop6:loadStream(
			dummy_instream.new(
			{
				"param7:value7",
				"#param8:value8",
				" param9=value9",
				" #param10=value10",
				"!param11:value11",
			}
		)
	)
	--]]
	prop6:loadStream({
		"param7:value7",
		"#param8:value8",
		" param9=value9",
		" #param10=value10",
		"!param11:value11",
		"param12.param13:value13"
	})
	luaunit.assertEquals(prop6:getProperty("param7"),"value7")
	luaunit.assertNotEquals(prop6:getProperty("param8"),"value8")
	luaunit.assertEquals(prop6:getProperty("param9"),"value9")
	luaunit.assertNotEquals(prop6:getProperty("param10"),"value10")
	luaunit.assertNotEquals(prop6:getProperty("param11"),"value11")


	luaunit.assertEquals(#prop6:propertyNames(), 3)
	luaunit.assertEquals(prop6:size(), 3)
	luaunit.assertNotEquals(prop6:findNode("param12"), nil)
	luaunit.assertNotEquals(prop6:getNode("param14"), nil)
	luaunit.assertEquals(prop6:size(), 4)
	luaunit.assertIsTrue(prop6:createNode("param15"))
	luaunit.assertEquals(prop6:size(), 5)
	luaunit.assertIsFalse(prop6:createNode("param15"))
	luaunit.assertNotEquals(prop6:removeNode("param15"), nil)
	luaunit.assertEquals(prop6:removeNode("param15"), nil)
	luaunit.assertNotEquals(prop6:hasKey("param12"),nil)
	prop6:clear()
	luaunit.assertEquals(prop6:hasKey("param12"),nil)
	prop5:mergeProperties(prop1)
	luaunit.assertEquals(prop5:getProperty("param4"),"value4")
	luaunit.assertEquals(prop5:getProperty("param1"),"value1")

	
	local key,value = prop5:splitKeyValue("name1:value1")
	luaunit.assertEquals(key,"name1")
	luaunit.assertEquals(value,"value1")
	local key,value = prop5:splitKeyValue("name2=value2")
	luaunit.assertEquals(key,"name2")
	luaunit.assertEquals(value,"value2")
	luaunit.assertNotEquals(prop5:getLeaf(),nil)

	local prop7 = Properties.new()
	prop7:load(
			dummy_instream.new(
			{
				"param7:value7",
				"#param8:value8",
				" param9=value9",
				" #param10=value10",
				"!param11:value11",
			}
		)
	)
	
	

	luaunit.assertEquals(prop7:getProperty("param7"),"value7")
	luaunit.assertNotEquals(prop7:getProperty("param8"),"value8")
	luaunit.assertEquals(prop7:getProperty("param9"),"value9")
	luaunit.assertNotEquals(prop7:getProperty("param10"),"value10")
	luaunit.assertNotEquals(prop7:getProperty("param11"),"value11")


end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
