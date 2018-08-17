local luaunit = require "luaunit"
local NVUtil = require "openrtm.NVUtil"
local Properties = require "openrtm.Properties"


TestNVUtil = {}


function TestNVUtil:test_code()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t

	luaunit.assertEquals(NVUtil.getReturnCode("RTC_OK"), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(NVUtil.getReturnCode("RTC_ERROR"), ReturnCode_t.RTC_ERROR)
	luaunit.assertEquals(NVUtil.getReturnCode("BAD_PARAMETER"), ReturnCode_t.BAD_PARAMETER)
	luaunit.assertEquals(NVUtil.getReturnCode("UNSUPPORTED"), ReturnCode_t.UNSUPPORTED)
	luaunit.assertEquals(NVUtil.getReturnCode("OUT_OF_RESOURCES"), ReturnCode_t.OUT_OF_RESOURCES)
	luaunit.assertEquals(NVUtil.getReturnCode("PRECONDITION_NOT_MET"), ReturnCode_t.PRECONDITION_NOT_MET)

	luaunit.assertEquals(NVUtil.getReturnCode(ReturnCode_t.RTC_OK), ReturnCode_t.RTC_OK)

	local PortStatus = mgr:getORB().types:lookup("::RTC::PortStatus").labelvalue
	luaunit.assertEquals(NVUtil.getPortStatus_RTC("PORT_OK"), PortStatus.PORT_OK)
	luaunit.assertEquals(NVUtil.getPortStatus_RTC("PORT_ERROR"), PortStatus.PORT_ERROR)
	luaunit.assertEquals(NVUtil.getPortStatus_RTC("BUFFER_FULL"), PortStatus.BUFFER_FULL)
	luaunit.assertEquals(NVUtil.getPortStatus_RTC("BUFFER_EMPTY"), PortStatus.BUFFER_EMPTY)
	luaunit.assertEquals(NVUtil.getPortStatus_RTC("BUFFER_TIMEOUT"), PortStatus.BUFFER_TIMEOUT)
	luaunit.assertEquals(NVUtil.getPortStatus_RTC("UNKNOWN_ERROR"), PortStatus.UNKNOWN_ERROR)

	luaunit.assertEquals(NVUtil.getPortStatus_RTC(PortStatus.UNKNOWN_ERROR), PortStatus.UNKNOWN_ERROR)
	

	local LifeCycleState = mgr:getORB().types:lookup("::RTC::LifeCycleState").labelvalue
	luaunit.assertEquals(NVUtil.getLifeCycleState ("CREATED_STATE"), LifeCycleState.CREATED_STATE)
	luaunit.assertEquals(NVUtil.getLifeCycleState ("INACTIVE_STATE"), LifeCycleState.INACTIVE_STATE)
	luaunit.assertEquals(NVUtil.getLifeCycleState ("ACTIVE_STATE"), LifeCycleState.ACTIVE_STATE)
	luaunit.assertEquals(NVUtil.getLifeCycleState ("ERROR_STATE"), LifeCycleState.ERROR_STATE)
	
	luaunit.assertEquals(NVUtil.getLifeCycleState (LifeCycleState.CREATED_STATE), LifeCycleState.CREATED_STATE)



	mgr:createShutdownThread(0.01)
end

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
	local ret = NVUtil.isStringValue(nvs, "testname3", "dummy")
	luaunit.assertIsFalse(ret)



	local prop2 = Properties.new()
	local nvs2 = {NVUtil.newNV("testname2","testvalue2")}
	NVUtil.copyToProperties(prop2, nvs2)
	luaunit.assertEquals(prop2:getProperty("testname2"), "testvalue2")

	luaunit.assertNotEquals(NVUtil.any_from_any({}),nil)

	NVUtil.append(nvs, nvs2)
	local value = NVUtil.find(nvs, "testname2")
	luaunit.assertEquals(value, "testvalue2")
	local value = NVUtil.find(nvs, "dummy")
	luaunit.assertEquals(value, nil)

	


	NVUtil.dump_to_stream(nvs)
	local value = NVUtil.toString(nvs, "testname2")
	luaunit.assertEquals(value, "testvalue2")
	NVUtil.toString(nvs)

	local ret = NVUtil.isString(nvs, "testname2")
	luaunit.assertIsTrue(ret)

	local nvs = {NVUtil.newNV("name",1)}
	local ret = NVUtil.isString(nvs, "testname2")
	luaunit.assertIsFalse(ret)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
