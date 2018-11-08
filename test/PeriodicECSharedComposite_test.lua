local luaunit = require "luaunit"
local PeriodicECSharedComposite = require "openrtm.PeriodicECSharedComposite"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local ConfigAdmin = require "openrtm.ConfigAdmin"
local NVUtil = require "openrtm.NVUtil"
local RTObject = require "openrtm.RTObject"
local Factory = require "openrtm.Factory"
local OutPort = require "openrtm.OutPort"
local InPort = require "openrtm.InPort"


TestPeriodicECSharedComposite = {}

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

local RTObjectMock = {}
RTObjectMock.new = function(manager)
	local obj = {}
	setmetatable(obj, {__index=RTObject.new(manager)})
	obj._d_in = {tm={sec=0,nsec=0},data=0}
	obj._inIn = InPort.new("in",obj._d_in,"::RTC::TimedOctet")

	obj._d_out = {tm={sec=0,nsec=0},data=0}
	obj._outOut = InPort.new("out",obj._d_out,"::RTC::TimedOctet")

	function obj:onInitialize()

		self:addInPort("in",self._inIn)
		self:addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK
	end

	return obj
end


local MyModuleInit = function(manager)
	local prof = Properties.new({defaults_map=testcomp_spec})
	manager:registerFactory(prof, RTObjectMock.new, Factory.Delete)
	manager:createComponent("TestComp")
	manager:createComponent("TestComp")
end







function TestPeriodicECSharedComposite:test_composite()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})--,"-o","logger.file_name: stdout"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	
	local orb = mgr:getORB()

	local rtobj = PeriodicECSharedComposite.new(mgr)
	local prop = Properties.new()
	prop:setProperty("exec_cxt.periodic.type","SimulatorExecutionContext")
	prop:setProperty("conf.default.exported_ports","TestComp0.in,TestComp0.out")
	prop:setProperty("conf.default.members","TestComp0")
	prop:setProperty("instance_name","composite")
	prop:setProperty("type_name","type_name")
	prop:setProperty("description","description")
	prop:setProperty("version","version")
	prop:setProperty("vendor","vendor")
	prop:setProperty("category","category")

	rtobj:setProperties(prop)
	rtobj:createRef()
	oil.main(function()
		rtobj:initialize()
	end)

	--print(#rtobj:get_ports())


	--orb:deactivate(org._svr)

	local orgs = rtobj:get_owned_organizations()
	luaunit.assertEquals(#orgs, 1)
	local members = orgs[1]:get_members()
	luaunit.assertEquals(#members, 1)
	local ports = rtobj:get_ports()
	luaunit.assertEquals(#ports, 2)

	local ret = rtobj:onActivated(0)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = rtobj:onDeactivated(0)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = rtobj:onReset(0)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	
	
	local conf = rtobj:get_configuration()
	local confset = conf:get_active_configuration_set()
	conf:set_configuration_set_values(confset)
	

	local rtobj2 = PeriodicECSharedComposite.new(mgr)
	local prop2 = Properties.new()
	prop2:setProperty("exec_cxt.periodic.type","SimulatorExecutionContext")
	prop2:setProperty("conf.default.exported_ports","")
	prop2:setProperty("conf.default.members","TestComp1,dummy")
	prop2:setProperty("instance_name","composite2")
	prop2:setProperty("type_name","type_name")
	prop2:setProperty("description","description")
	prop2:setProperty("version","version")
	prop2:setProperty("vendor","vendor")
	prop2:setProperty("category","category")

	rtobj2:setProperties(prop2)
	rtobj2:createRef()
	oil.main(function()
		rtobj2:initialize()
	end)

	local orgs2 = rtobj2:get_owned_organizations()
	orgs2[1]:add_members({rtobj})

	
	local members2 = orgs2[1]:get_members()
	--print(#members)
	luaunit.assertEquals(#members2, 2)


	local ret = rtobj2:onActivated(0)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = rtobj2:onDeactivated(0)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	local ret = rtobj2:onReset(0)
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	
	--print(members2[1]:get_sdo_id())
	--print(members2[2]:get_sdo_id())
	local ret = orgs2[1]:remove_member("composite")
	luaunit.assertIsTrue(ret)
	local members2 = orgs2[1]:get_members()
	luaunit.assertEquals(#members2, 1)

	local ret = rtobj:onFinalize()
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)
	
	rtobj:shutdown()

	
	
	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
