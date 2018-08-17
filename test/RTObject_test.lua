local luaunit = require "luaunit"
local RTObject = require "openrtm.RTObject"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local OpenHRPExecutionContext = require "openrtm.OpenHRPExecutionContext"
local ComponentActionListener = require "openrtm.ComponentActionListener"
local InPort = require "openrtm.InPort"
local OutPort = require "openrtm.OutPort"
local NVUtil = require "openrtm.NVUtil"

TestRTObject = {}


function TestRTObject:test_rtobj()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})--,"-o","logger.file_name: stdout"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t

	local orb = mgr:getORB()

	local rtobj = RTObject.new(mgr)
	local prop = Properties.new()
	prop:setProperty("exec_cxt.periodic.type","SimulatorExecutionContext")
	rtobj:setProperties(prop)
	local ret = ReturnCode_t.BAD_PARAMETER
	
	rtobj:createRef()
	oil.main(function()
		ret = rtobj:initialize()
	end)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	
	local prop = Properties.new()
	prop:setProperty("param1","value1")
	rtobj:setProperties(prop)

	luaunit.assertEquals(rtobj:getProperties():getProperty("param1"), "value1")
	
	rtobj:setInstanceName("instance_name1")
	luaunit.assertEquals(rtobj:getInstanceName(), "instance_name1")


	local prop = Properties.new()
	prop:setProperty("instance_name","instance_name2")
	prop:setProperty("type_name","type_name2")
	prop:setProperty("description","description2")
	prop:setProperty("version","version2")
	prop:setProperty("vendor","vendor2")
	prop:setProperty("category","category2")
	rtobj:setProperties(prop)

	luaunit.assertEquals(rtobj:getTypeName(), "type_name2")
	luaunit.assertEquals(rtobj:getCategory(), "category2")
	luaunit.assertEquals(rtobj:getCategory(), "category2")

	local ec = OpenHRPExecutionContext.new()
	ec:init(Properties.new())

	luaunit.assertEquals(rtobj:bindContext(ec),1)

	
	local prelistener1 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_INITIALIZE, function(ec_id)end)
	local prelistener2 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_FINALIZE, function(ec_id)end)
	local prelistener3 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_STARTUP, function(ec_id)end)
	local prelistener4 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_SHUTDOWN, function(ec_id)end)
	local prelistener5 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_ACTIVATED, function(ec_id)end)
	local prelistener6 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_DEACTIVATED, function(ec_id)end)
	local prelistener7 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_ABORTING, function(ec_id)end)
	local prelistener8 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_ERROR, function(ec_id)end)
	local prelistener9 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_RESET, function(ec_id)end)
	local prelistener10 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_EXECUTE, function(ec_id)end)
	local prelistener11 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_STATE_UPDATE, function(ec_id)end)
	local prelistener12 = rtobj:addPreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_RATE_CHANGED, function(ec_id)end)



	local postlistener1 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_INITIALIZE, function(ec_id, ret)end)
	local postlistener2 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_FINALIZE, function(ec_id, ret)end)
	local postlistener3 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_STARTUP, function(ec_id, ret)end)
	local postlistener4 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_SHUTDOWN, function(ec_id, ret)end)
	local postlistener5 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_ACTIVATED, function(ec_id, ret)end)
	local postlistener6 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_DEACTIVATED, function(ec_id, ret)end)
	local postlistener7 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_ABORTING, function(ec_id, ret)end)
	local postlistener8 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_ERROR, function(ec_id, ret)end)
	local postlistener9 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_RESET, function(ec_id, ret)end)
	local postlistener10 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_EXECUTE, function(ec_id, ret)end)
	local postlistener11 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_STATE_UPDATE, function(ec_id, ret)end)
	local postlistener12 = rtobj:addPostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_RATE_CHANGED, function(ec_id, ret)end)

	local portlistener1 = rtobj:addPortActionListener(ComponentActionListener.PortActionListenerType.ADD_PORT, function(ec_id)end)
	local portlistener2 = rtobj:addPortActionListener(ComponentActionListener.PortActionListenerType.REMOVE_PORT, function(ec_id)end)
	
	local eclistener1 = rtobj:addExecutionContextActionListener(ComponentActionListener.ExecutionContextActionListenerType.EC_ATTACHED, function(pprofile)end)
	local eclistener2 = rtobj:addExecutionContextActionListener(ComponentActionListener.ExecutionContextActionListenerType.EC_DETACHED, function(pprofile)end)
	

	luaunit.assertEquals(rtobj:on_startup(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_shutdown(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_activated(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_deactivated(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_aborting(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_error(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_reset(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_execute(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_state_update(0),ReturnCode_t.RTC_OK)
	luaunit.assertEquals(rtobj:on_rate_changed(0),ReturnCode_t.RTC_OK)


	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_INITIALIZE, prelistener1)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_FINALIZE, prelistener2)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_STARTUP, prelistener3)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_SHUTDOWN, prelistener4)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_ACTIVATED, prelistener5)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_DEACTIVATED, prelistener6)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_ABORTING, prelistener7)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_ERROR, prelistener8)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_RESET, prelistener9)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_EXECUTE, prelistener10)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_STATE_UPDATE, prelistener11)
	rtobj:removePreComponentActionListener(ComponentActionListener.PreComponentActionListenerType.PRE_ON_RATE_CHANGED, prelistener12)

	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_INITIALIZE, postlistener1)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_FINALIZE, postlistener2)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_STARTUP, postlistener3)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_SHUTDOWN, postlistener4)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_ACTIVATED, postlistener5)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_DEACTIVATED, postlistener6)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_ABORTING, postlistener7)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_ERROR, postlistener8)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_RESET, postlistener9)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_EXECUTE, postlistener10)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_STATE_UPDATE, postlistener11)
	rtobj:removePostComponentActionListener(ComponentActionListener.PostComponentActionListenerType.POST_ON_RATE_CHANGED, postlistener12)

	rtobj:removePortActionListener(ComponentActionListener.PortActionListenerType.ADD_PORT, portlistener1)
	rtobj:removePortActionListener(ComponentActionListener.PortActionListenerType.REMOVE_PORT, portlistener2)
	
	rtobj:removeExecutionContextActionListener(ComponentActionListener.ExecutionContextActionListenerType.EC_ATTACHED, eclistener1)
	rtobj:removeExecutionContextActionListener(ComponentActionListener.ExecutionContextActionListenerType.EC_DETACHED, eclistener2)
	

	rtobj:preOnInitialize()
	rtobj:preOnFinalize()
	rtobj:preOnStartup()
	rtobj:preOnShutdown()
	rtobj:preOnActivated()
	rtobj:preOnDeactivated()
	rtobj:preOnAborting()
	rtobj:preOnError()
	rtobj:preOnReset()
	rtobj:preOnExecute()
	rtobj:preOnStateUpdate()
	rtobj:preOnRateChanged()
	rtobj:postOnInitialize()
	rtobj:postOnFinalize()
	rtobj:postOnStartup()
	rtobj:postOnShutdown()
	rtobj:postOnActivated()
	rtobj:postOnDeactivated()
	rtobj:postOnAborting()
	rtobj:postOnError()
	rtobj:postOnReset()
	rtobj:postOnExecute()
	rtobj:postOnStateUpdate()
	rtobj:postOnRateChanged()

	local value = {_value="1"}
	rtobj:bindParameter("test1",value,"1")
	luaunit.assertNotEquals(rtobj:getConfigService(), nil)
	rtobj:updateParameters("default")
	luaunit.assertNotEquals(rtobj:getExecutionContext(0), nil)
	luaunit.assertEquals(#rtobj:get_owned_contexts(), 2)
	luaunit.assertEquals(#rtobj:get_participating_contexts(), 0)

	luaunit.assertEquals(rtobj:get_context_handle(ec), 1)
	
	local prop = Properties.new()
	prop:setProperty("naming.names","sample.rtc")
	rtobj:setProperties(prop)

	luaunit.assertEquals(rtobj:getNamingNames()[1], "sample.rtc")

	luaunit.assertNotEquals(rtobj:get_configuration(), nil)
	
	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")

	local d_out = {tm={sec=0,nsec=0},data=0}
	local outOut = OutPort.new("out",d_out,"::RTC::TimedLong")


	luaunit.assertIsTrue(rtobj:addInPort("in",inIn))
	luaunit.assertIsTrue(rtobj:addOutPort("out",outOut))
	luaunit.assertIsFalse(rtobj:addInPort("in",inIn))
	luaunit.assertIsFalse(rtobj:addOutPort("out",outOut))


	luaunit.assertIsTrue(rtobj:removeInPort(inIn))
	luaunit.assertIsTrue(rtobj:removeOutPort(outOut))
	luaunit.assertIsFalse(rtobj:removeInPort(inIn))
	luaunit.assertIsFalse(rtobj:removeOutPort(outOut))

	local prof = rtobj:get_component_profile()

	

	luaunit.assertEquals(prof.instance_name, "instance_name2") 

	rtobj:onAddPort()
	rtobj:onRemovePort()
	rtobj:onAttachExecutionContext()
	rtobj:onDetachExecutionContext()

	luaunit.assertIsTrue(rtobj:is_alive(ec))

	local ec2 = OpenHRPExecutionContext.new()
	ec2:init(Properties.new())
	luaunit.assertEquals(rtobj:attach_context(ec2),1000)
	luaunit.assertEquals(rtobj:detach_context(1000),ReturnCode_t.RTC_OK)


	luaunit.assertEquals(#rtobj:get_ports(),0)
	rtobj:on_finalize()

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
