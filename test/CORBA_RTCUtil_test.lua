local oil = require "oil"
local luaunit = require "luaunit"
local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"
local Properties = require "openrtm.Properties"
local RTObject = require "openrtm.RTObject"
local Factory = require "openrtm.Factory"
local OutPort = require "openrtm.OutPort"
local InPort = require "openrtm.InPort"


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
	local comp = manager:createComponent("TestComp")
end


TestCORBA_RTCUtil = {}
function TestCORBA_RTCUtil:test_component()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:setModuleInitProc(MyModuleInit)
	mgr:activateManager()
	mgr:runManager(true)
	local ReturnCode_t  = mgr._ReturnCode_t
	local LifeCycleState = mgr:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue

	local comp0 = mgr:getComponent("TestComp0")
	local prop0 = CORBA_RTCUtil.get_component_profile(comp0)
	local type_name0 = prop0:getProperty("type_name")
	luaunit.assertEquals( type_name0, "TestComp")
	luaunit.assertIsTrue(CORBA_RTCUtil.is_existing(comp0))
	local ec0 = CORBA_RTCUtil.get_actual_ec(comp0, 0)
	luaunit.assertEquals(CORBA_RTCUtil.get_ec_id(comp0, ec0),0)
	luaunit.assertEquals(CORBA_RTCUtil.activate(comp0, 0), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(CORBA_RTCUtil.deactivate(comp0, 0), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(CORBA_RTCUtil.reset(comp0, 0), ReturnCode_t.PRECONDITION_NOT_MET)
	local ret, state = CORBA_RTCUtil.get_state(comp0,0)
	luaunit.assertEquals(state, LifeCycleState.INACTIVE_STATE)
	luaunit.assertIsTrue(CORBA_RTCUtil.is_in_inactive(comp0))
	luaunit.assertIsFalse(CORBA_RTCUtil.is_in_active(comp0))
	luaunit.assertIsFalse(CORBA_RTCUtil.is_in_error(comp0))
	luaunit.assertEquals(CORBA_RTCUtil.set_default_rate(comp0,100), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(CORBA_RTCUtil.get_default_rate(comp0), 100)
	luaunit.assertEquals(CORBA_RTCUtil.set_current_rate(comp0, 0, 10), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(CORBA_RTCUtil.get_current_rate(comp0, 0), 10)
	
	local comp1 = mgr:getComponent("TestComp1")
	local ec1 = CORBA_RTCUtil.get_actual_ec(comp1, 0)
	luaunit.assertEquals(CORBA_RTCUtil.add_rtc_to_default_ec(comp0,comp1), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(#CORBA_RTCUtil.get_participants_rtc(comp0),1)
	luaunit.assertEquals(CORBA_RTCUtil.remove_rtc_to_default_ec(comp0,comp1), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(#CORBA_RTCUtil.get_participants_rtc(comp0),0)

	mgr:createShutdownThread(0.01)
	--luaunit.assertEquals( BufferStatus.toString(BufferStatus.PRECONDITION_NOT_MET), 'PRECONDITION_NOT_MET' )
end


function TestCORBA_RTCUtil:test_port()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:setModuleInitProc(MyModuleInit)
	mgr:activateManager()
	mgr:runManager(true)
	local ReturnCode_t  = mgr._ReturnCode_t
	local LifeCycleState = mgr:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue

	local comp0 = mgr:getComponent("TestComp0")

	local d_out = {tm={sec=0,nsec=0},data=0}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")
	comp0:addOutPort("out",outOut)
	
	--print(CORBA_RTCUtil.get_port_names(comp0)[1])
	luaunit.assertEquals(CORBA_RTCUtil.get_port_names(comp0)[1],"TestComp0.out")
	luaunit.assertEquals(CORBA_RTCUtil.get_outport_names(comp0)[1],"TestComp0.out")
	
	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")
	comp0:addInPort("in",inIn)
	
	luaunit.assertEquals(CORBA_RTCUtil.get_inport_names(comp0)[1],"TestComp0.in")
	luaunit.assertEquals(#CORBA_RTCUtil.get_svcport_names(comp0),0)

	luaunit.assertNotEquals(CORBA_RTCUtil.get_port_by_name(comp0, "TestComp0.out"), oil.corba.idl.null)
	
	local ret = CORBA_RTCUtil.connect("testcon",Properties.new(),outOut,inIn)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	luaunit.assertIsTrue(CORBA_RTCUtil.already_connected(outOut,inIn))


	luaunit.assertEquals(CORBA_RTCUtil.get_connector_names_by_portref(outOut)[1], "testcon") 
	luaunit.assertEquals(CORBA_RTCUtil.get_connector_names(comp0, "TestComp0.out")[1], "testcon") 

	luaunit.assertEquals(#CORBA_RTCUtil.get_connector_ids_by_portref(outOut), 1) 
	luaunit.assertEquals(#CORBA_RTCUtil.get_connector_ids(comp0, "TestComp0.out"), 1) 

	luaunit.assertEquals(CORBA_RTCUtil.disconnect_by_portref_connector_name(outOut, "testcon"), ReturnCode_t.RTC_OK)
	luaunit.assertIsFalse(CORBA_RTCUtil.already_connected(outOut,inIn))

	luaunit.assertEquals(CORBA_RTCUtil.connect_multi("testcon",Properties.new(),outOut,{inIn}), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(CORBA_RTCUtil.disconnect_all_by_ref(outOut), ReturnCode_t.RTC_OK)

	
	luaunit.assertEquals(CORBA_RTCUtil.connect_by_name("testcon",Properties.new(),comp0,"TestComp0.out",comp0,"TestComp0.in"), ReturnCode_t.RTC_OK)
	luaunit.assertEquals(CORBA_RTCUtil.disconnect_all_by_ref(outOut), ReturnCode_t.RTC_OK)




	mgr:createShutdownThread(0.01)
end


function TestCORBA_RTCUtil:test_config()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:setModuleInitProc(MyModuleInit)
	mgr:activateManager()
	mgr:runManager(true)
	local ReturnCode_t  = mgr._ReturnCode_t
	local LifeCycleState = mgr:instance():getORB().types:lookup("::RTC::LifeCycleState").labelvalue

	local comp0 = mgr:getComponent("TestComp0")
	
	

	local prop = CORBA_RTCUtil.get_configuration(comp0,"default")
	luaunit.assertEquals(prop:getProperty("test_param0"), "0")
	

	CORBA_RTCUtil.set_configuration(comp0, "default", "test_param0", "1")
	local param = CORBA_RTCUtil.get_parameter_by_key(comp0, "default", "test_param0")
	luaunit.assertEquals(param, "1")
	luaunit.assertEquals(CORBA_RTCUtil.get_active_configuration_name(comp0), "default")
	

	CORBA_RTCUtil.set_active_configuration(comp0, "test_param0", "2")
	local prop = CORBA_RTCUtil.get_active_configuration(comp0)
	luaunit.assertEquals(prop:getProperty("test_param0"), "2")

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
