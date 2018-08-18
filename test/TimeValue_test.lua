local luaunit = require "luaunit"
local TimeValue = require "openrtm.TimeValue"


TestTimeValue = {}


function TestTimeValue:test_logger()
	local tm1 = TimeValue.new(10,5)
	local tm2 = TimeValue.new(20,10)
	local tm3 = tm1 + tm2
	luaunit.assertEquals(tm3:sec(), 30)
	luaunit.assertEquals(tm3:usec(), 15)
	local tm5 = TimeValue.new(10,500000)
	local tm6 = TimeValue.new(20,800000)
	local tm7 = tm6 + tm5
	luaunit.assertEquals(tm7:sec(), 31)
	luaunit.assertEquals(tm7:usec(), 300000)

	local tm4 = tm2 - tm1
	luaunit.assertEquals(tm4:sec(), 10)
	luaunit.assertEquals(tm4:usec(), 5)
	local tm8 = tm5 - tm6
	luaunit.assertEquals(tm8:sec(), -10)
	luaunit.assertEquals(tm8:usec(), -300000)

	local tm9 = TimeValue.new(10,500000)
	local tm10 = TimeValue.new(20,300000)
	local tm11 = tm9 - tm10
	luaunit.assertEquals(tm11:sec(), -9)
	luaunit.assertEquals(tm11:usec(), -800000)


	local tm12 = TimeValue.new(10,500000)
	local tm13 = TimeValue.new(20,300000)
	local tm14 = tm13 - tm12
	luaunit.assertEquals(tm14:sec(), 9)
	luaunit.assertEquals(tm14:usec(), 800000)



	tostring(tm1)
	tm1:set_time(1.5)
	luaunit.assertEquals(tm1:sec(), 1)
	luaunit.assertEquals(tm1:usec(), 500000)
	tm1:toDouble()
	luaunit.assertEquals(TimeValue.new(1,0):sign(),1)
	luaunit.assertEquals(TimeValue.new(0,0):sign(),0)
	luaunit.assertEquals(TimeValue.new(-1,0):sign(),-1)
	luaunit.assertEquals(TimeValue.new(0,1):sign(),1)
	luaunit.assertEquals(TimeValue.new(0,-1):sign(),-1)


	local tm1 = TimeValue.new(10,5000000)
	local tm1 = TimeValue.new(10,-5000000)
	local tm1 = TimeValue.new(-10,5000000)
	local tm1 = TimeValue.new(-10,-5000000)

	local tm1 = TimeValue.new("10","-50000")
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
