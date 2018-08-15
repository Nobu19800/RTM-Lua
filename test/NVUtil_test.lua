local luaunit = require "luaunit"
local NVUtil = require "openrtm.NVUtil"
local Properties = require "openrtm.Properties"


TestNVUtil = {}


function TestNVUtil:test_nv()
	local nv = NVUtil.newNV("name","value")
	luaunit.assertEquals(nv.name, "name")
	luaunit.assertEquals(nv.value, "value")

	local prop = Properties.new()
	prop:setProperty("testname1","testvalue1")
	local nvs = {}
	
	NVUtil.copyFromProperties(nvs, prop)
	local index = NVUtil.find_index(nvs, "testname1")
	luaunit.assertEquals(index, 1)

	NVUtil.appendStringValue(nvs, "testname3", "testvalue3")
	local ret = NVUtil.isStringValue(nvs, "testname3", "testvalue3")
	luaunit.assertIsTrue(ret)



	local prop2 = Properties.new()
	local nvs2 = {NVUtil.newNV("testname2","testvalue2")}
	NVUtil.copyToProperties(prop2, nvs2)
	luaunit.assertEquals(prop2:getProperty("testname2"), "testvalue2")

	

	NVUtil.append(nvs, nvs2)
	local value = NVUtil.find(nvs, "testname2")
	luaunit.assertEquals(value, "testvalue2")


	NVUtil.dump_to_stream(nvs)
	local value = NVUtil.toString(nvs, "testname2")
	luaunit.assertEquals(value, "testvalue2")
	local ret = NVUtil.isString(nvs, "testname2")
	luaunit.assertIsTrue(ret)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
