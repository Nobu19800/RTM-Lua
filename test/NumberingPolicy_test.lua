local luaunit = require "luaunit"

local NumberingPolicy = require "openrtm.NumberingPolicy"
local ProcessUniquePolicy = NumberingPolicy.ProcessUniquePolicy
local RTCUtil = require "openrtm.RTCUtil"
local oil = require "oil"

local Properties = require "openrtm.Properties"



local ObjMock = {}
ObjMock.new = function()
	local obj = {}
	function obj:getTypeName()
		return "TestComp"
	end
	return obj
end

TestNumberingPolicy = {}
function TestNumberingPolicy:test_naming()

	
	local policy = ProcessUniquePolicy.new()

	local obj = ObjMock.new()
	local ret = policy:onCreate(obj)
	luaunit.assertEquals(ret, "0")


	local ret = policy:find(obj)
	luaunit.assertEquals(ret, 1)

	ret = policy:onCreate(ObjMock.new())
	luaunit.assertEquals(ret, "1")


	policy:onDelete(obj)
	local ret = policy:find(obj)
	luaunit.assertEquals(ret, -1)


end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
