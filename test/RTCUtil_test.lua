local luaunit = require "luaunit"
local RTCUtil = require "openrtm.RTCUtil"
local oil = require "oil"



TestRTCUtil = {}


function TestRTCUtil:test_util()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t

	local orb = mgr:getORB()

	orb:loadidl [[
		interface Hello {
			string echo(in string name);
		};
	]]

	local hello = {}
	function hello:echo(name)
		return "abc"
	end

	local svr = orb:newservant(hello, nil, "Hello")
	local ior = orb:tostring(svr)

	local objref = RTCUtil.newproxy(orb, ior, "Hello")
	luaunit.assertNotEquals(objref, nil)

	local ref = RTCUtil.getReference(orb, svr, "hello")
	luaunit.assertNotEquals(ref, nil)

	local data = RTCUtil.instantiateDataType("::RTC::TimedLong")
	luaunit.assertEquals(data.data, 0)
	local data = RTCUtil.instantiateDataType("::RTC::TimedShort")
	luaunit.assertEquals(data.data, 0)
	local data = RTCUtil.instantiateDataType("::RTC::TimedFloat")
	luaunit.assertEquals(data.data, 0)
	local data = RTCUtil.instantiateDataType("::RTC::TimedDouble")
	luaunit.assertEquals(data.data, 0)
	local data = RTCUtil.instantiateDataType("::RTC::TimedString")
	luaunit.assertEquals(data.data, "")
	local data = RTCUtil.instantiateDataType("::RTC::TimedULong")
	luaunit.assertEquals(data.data, 0)
	local data = RTCUtil.instantiateDataType("::RTC::TimedUShort")
	luaunit.assertEquals(data.data, 0)
	
	local data = RTCUtil.instantiateDataType("::RTC::TimedBoolean")
	luaunit.assertEquals(data.data, true)
	local data = RTCUtil.instantiateDataType("::RTC::TimedOctet")
	luaunit.assertEquals(data.data, 0x00)
	local data = RTCUtil.instantiateDataType("::RTC::TimedLongSeq")
	luaunit.assertEquals(#data.data, 0)


	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
