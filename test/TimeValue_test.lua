local luaunit = require "luaunit"
local TimeValue = require "openrtm.TimeValue"


TestTimeValue = {}


function TestTimeValue:test_logger()
	local tm1 = TimeValue.new(10,5)
	local tm2 = TimeValue.new(20,10)
	local tm3 = tm1 + tm2
	luaunit.assertEquals(tm3:sec(), 30)
	luaunit.assertEquals(tm3:usec(), 15)
	tostring(tm1)
	tm1:set_time(1.5)
	luaunit.assertEquals(tm1:sec(), 1)
	luaunit.assertEquals(tm1:usec(), 500000)
	tm1:toDouble()
	luaunit.assertEquals(TimeValue.new(1,0):sign(),1)
	luaunit.assertEquals(TimeValue.new(0,0):sign(),0)
	luaunit.assertEquals(TimeValue.new(-1,0):sign(),-1)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
