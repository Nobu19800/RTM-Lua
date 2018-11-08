local luaunit = require "luaunit"

local NamingServiceNumberingPolicy = require "openrtm.NamingServiceNumberingPolicy"
local RTCUtil = require "openrtm.RTCUtil"
local oil = require "oil"

local Properties = require "openrtm.Properties"

local RTObject = require "openrtm.RTObject"
local Factory = require "openrtm.Factory"

local OutPort = require "openrtm.OutPort"
local InPort = require "openrtm.InPort"

local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"




local testcomp_spec = {
	["implementation_id"]="TestComp",
	["type_name"]="TestComp",
	["description"]="TestComp",
	["version"]="1.0",
	["vendor"]="Sample",
	["category"]="example",
	["activity_type"]="DataFlowComponent",
	["max_instance"]="10",
	["language"]="Lua",
	["lang_type"]="script",
	["conf.default.test_param0"]="0"
}


local MyModuleInit = function(manager)
	local prof = Properties.new({defaults_map=testcomp_spec})
	manager:registerFactory(prof, RTObject.new, Factory.Delete)
	local comp = manager:createComponent("TestComp")
end


local ObjMock = {}
ObjMock.new = function()
	local obj = {}
	function obj:getTypeName()
		return "TestComp"
	end
	return obj
end

TestNamingServiceNumberingPolicy = {}
function TestNamingServiceNumberingPolicy:test_naming()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)
	
	local policy = NamingServiceNumberingPolicy.new()

	local ret = false
	oil.main(function()
		ret = policy:find("TestComp0")
	end)

	luaunit.assertIsTrue(ret)

	local ret = ""
	oil.main(function()
		ret = policy:onCreate(ObjMock.new())
	end)

	luaunit.assertEquals(ret, "1")



	mgr:createShutdownThread(0.01)
end



function TestNamingServiceNumberingPolicy:test_other()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t

	local comp0 = mgr:getComponent("TestComp0")


	local d_out = {tm={sec=0,nsec=0},data=0}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")
	comp0:addOutPort("out",outOut)


	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")
	comp0:addInPort("in",inIn)

	local ret = -1
	CORBA_RTCUtil.connect("testcon",Properties.new(),outOut,inIn)

	oil.main(function()
		ret = CORBA_RTCUtil.disconnect_by_portname_connector_name("rtcname://localhost/TestComp0.out","testcon")
	end)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)

	local ret = -1
	oil.main(function()
		ret = CORBA_RTCUtil.disconnect_by_portname_connector_name("rtcname://localhost/dummy.out","testcon")
	end)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)

	oil.main(function()
		ret = CORBA_RTCUtil.get_port_by_url("rtcname://localhost/TestComp0.out")
	end)
	luaunit.assertNotEquals(ret,oil.corba.idl.null)

	oil.main(function()
		ret = CORBA_RTCUtil.get_port_by_url("rtcname://localhost/dummy.out")
	end)
	luaunit.assertEquals(ret,oil.corba.idl.null)



	CORBA_RTCUtil.connect("testcon",Properties.new(),outOut,inIn)
	local ids = CORBA_RTCUtil.get_connector_ids(comp0, "TestComp0.out")
	oil.main(function()
		ret = CORBA_RTCUtil.disconnect_by_portname_connector_id("rtcname://localhost/TestComp0.out",ids[1])
	end)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	oil.main(function()
		ret = CORBA_RTCUtil.disconnect_by_portname_connector_id("rtcname://localhost/dummy.out",ids[1])
	end)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)

	oil.main(function()
		ret = CORBA_RTCUtil.disconnect_all_by_name("rtcname://localhost/TestComp0.out")
	end)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	oil.main(function()
		ret = CORBA_RTCUtil.disconnect_all_by_name("rtcname://localhost/dummy.out")
	end)
	luaunit.assertEquals(ret, ReturnCode_t.BAD_PARAMETER)




	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
