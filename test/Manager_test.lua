local luaunit = require "luaunit"

--ORB_Dummy_ENABLE = true
local Manager = require "openrtm.Manager"
local Properties = require "openrtm.Properties"
local StringUtil = require "openrtm.StringUtil"
local RTObject = require "openrtm.RTObject"
local Factory = require "openrtm.Factory"
local OutPort = require "openrtm.OutPort"
local InPort = require "openrtm.InPort"
local CORBA_RTCUtil = require "openrtm.CORBA_RTCUtil"
local ManagerActionListener = require "openrtm.ManagerActionListener"
local oil = require "oil"

TestManager = {}


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

local RTObjectMock2 = {}
RTObjectMock2.new = function()
	local obj = {}
	obj._prop = Properties.new()
	obj._prop:setProperty("instance_name","instance_name")
	obj._prop:setProperty("type_name","type_name")
	obj._prop:setProperty("type_name","type_name")
	obj._prop:setProperty("version","version")
	obj._prop:setProperty("vendor","vendor")
	obj._prop:setProperty("category","category")
	obj._prop:setProperty("os.hostname","hostname")
	obj._prop:setProperty("manager.name","name")
	obj._prop:setProperty("manager.pid","manager.pid")

	function obj:getCategory()
		return "category"
	end
	function obj:getTypeName()
		return "type"
	end
	function obj:getInstanceName()
		return "instance_name"
	end
	function obj:setProperties(prop)
		
	end
	function obj:getProperties(prop)
		return self._prop
	end
	return obj
end

local MyModuleInit = function(manager)
	local prof = Properties.new({defaults_map=testcomp_spec})
	manager:registerFactory(prof, RTObjectMock.new, Factory.Delete)
end



local ManagerActionListener_ = {}
ManagerActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.ManagerActionListener.new()})
	obj._preShutdown = 0
	obj._postShutdown = 0
	obj._preReinit = 0
	obj._postReinit = 0
	function obj:preShutdown()
		self._preShutdown = self._preShutdown+1
	end
	function obj:postShutdown()
		self._postShutdown = self._postShutdown+1
	end
	function obj:preReinit()
		self._preReinit = self._preReinit+1
	end
	function obj:postReinit()
		self._postReinit = self._postReinit+1
	end
	return obj
end


local ModuleActionListener_ = {}
ModuleActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.ModuleActionListener.new()})
	obj._preLoad = 0
	obj._postLoad = 0
	obj._preUnload = 0
	obj._postUnload = 0
	function obj:preLoad(modname, funcname)
		self._preLoad = self._preLoad+1
	end
	function obj:postLoad(modname, funcname)
		self._postLoad = self._postLoad+1
	end
	function obj:preUnload(modname)
		self._preUnload = self._preUnload+1
	end
	function obj:postUnload(modname)
		self._postUnload = self._postUnload+1
	end

	return obj
end

local RtcLifecycleActionListener_ = {}
RtcLifecycleActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.RtcLifecycleActionListener.new()})
	obj._preCreate = 0
	obj._postCreate = 0
	obj._preConfigure = 0
	obj._postConfigure = 0
	obj._preInitialize = 0
	obj._postInitialize = 0
	function obj:preCreate(args)
		self._preCreate = self._preCreate+1
	end
	function obj:postCreate(rtobj)
		self._postCreate = self._postCreate+1
	end
	function obj:preConfigure(prop)
		self._preConfigure = self._preConfigure+1
	end
	function obj:postConfigure(prop)
		self._postConfigure = self._postConfigure+1
	end
	function obj:preInitialize()
		self._preInitialize = self._preInitialize+1
	end
	function obj:postInitialize()
		self._postInitialize = self._postInitialize+1
	end

	return obj
end


local NamingActionListener_ = {}
NamingActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.NamingActionListener.new()})

	obj._preBind = 0
	obj._postBind = 0
	obj._preUnbind = 0
	obj._postUnbind = 0


	function obj:preBind(rtobj, name)
		self._preBind = self._preBind+1
	end
	function obj:postBind(rtobj, name)
		self._postBind = self._postBind+1
	end
	function obj:preUnbind(rtobj, name)
		self._preUnbind = self._preUnbind+1
	end
	function obj:postUnbind(rtobj, name)
		self._postUnbind = self._postUnbind+1
	end
	

	return obj
end


local LocalServiceActionListener_ = {}
LocalServiceActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.LocalServiceActionListener.new()})

	obj._preServiceRegister = 0
	obj._postServiceRegister = 0
	obj._preServiceInit = 0
	obj._postServiceInit = 0
	obj._preServiceReinit = 0
	obj._postServiceReinit = 0
	obj._preServiceFinalize = 0
	obj._postServiceFinalize = 0

	function obj:preServiceRegister(service_name)
		self._preServiceRegister = self._preServiceRegister+1
	end
	function obj:postServiceRegister(service_name, service)
		self._postServiceRegister = self._postServiceRegister+1
	end
	function obj:preServiceInit(prop, service)
		self._preServiceInit = self._preServiceInit+1
	end
	function obj:postServiceInit(prop, service)
		self._postServiceInit = self._postServiceInit+1
	end
	function obj:preServiceReinit(prop, service)
		self._preServiceReinit = self._preServiceReinit+1
	end
	function obj:postServiceReinit(prop, service)
		self._postServiceReinit = self._postServiceReinit+1
	end
	function obj:preServiceFinalize(service_name, service)
		self._preServiceFinalize = self._preServiceFinalize+1
	end
	function obj:postServiceFinalize(service_name, service)
		self._postServiceFinalize = self._postServiceFinalize+1
	end
	

	return obj
end


function TestManager:test_manager()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	local ret = false
	local func = function(mgr)
		ret = true
	end
	mgr:setModuleInitProc(func)
	mgr:runManager(true)
	local ReturnCode_t  = mgr._ReturnCode_t

	luaunit.assertIsTrue(ret)

	ret = mgr:load("SampleModule", "Init")
	--luaunit.assertIsFalse(inIn:isNew())
	--luaunit.assertIsTrue(inIn:isEmpty())
	
	luaunit.assertEquals(ret, ReturnCode_t.RTC_OK)



	luaunit.assertEquals(#mgr:getLoadedModules(),1)
	mgr:unload("SampleModule")
	luaunit.assertEquals(#mgr:getLoadedModules(),0)

	
	mgr:load("SampleModule", "Init")
	luaunit.assertEquals(#mgr:getLoadedModules(),1)
	mgr:unloadAll()
	luaunit.assertEquals(#mgr:getLoadedModules(),0)

	local fpath = StringUtil.dirname(debug.getinfo(1)["short_src"])
	local _str = string.gsub(fpath,"\\","/").."MyService.idl"
	mgr:loadIdLFile(_str)

	local d_out = {tm={sec=0,nsec=0},data=100}
	local cdr = mgr:cdrMarshal(d_out, "::RTC::TimedLong")
	local data = mgr:cdrUnmarshal(cdr, "::RTC::TimedLong")
	luaunit.assertEquals(data.data, 100)

	mgr:getManagerServant()
	mgr:getNaming()

	local prop = Properties.new()
	prop:setProperty("instance_name","instance_name")
	prop:setProperty("type_name","type_name")
	prop:setProperty("type_name","type_name")
	prop:setProperty("version","version")
	prop:setProperty("vendor","vendor")
	prop:setProperty("category","category")
	prop:setProperty("os.hostname","hostname")
	prop:setProperty("manager.name","name")
	prop:setProperty("manager.pid","manager.pid")

	--local str = mgr:formatString("%n/%t/%m/%v/%V/%c/%h/%M/%p", prop)
	local str = mgr:formatString("%n/%t/%m/%v/%V/%c/%M", prop)
	luaunit.assertEquals(str, "instance_name/type_name/type_name/version/vendor/category/manager")
	

	local rtobj = RTObjectMock2.new()
	mgr:configureComponent(rtobj, Properties.new())
	luaunit.assertEquals(rtobj._prop:getProperty("naming.formats"),"%n.rtc")
	
	luaunit.assertEquals(rtobj._prop:getProperty("naming.names"),"instance_name.rtc")

	local comp_prop = Properties.new()
    local comp_id   = Properties.new()
	luaunit.assertIsTrue(mgr:procComponentArgs("RTC:vendor:category:implementation_id:language:version?param1=xxx&param2=yyy", comp_prop, comp_id))

	luaunit.assertEquals(comp_prop:getProperty("vendor"),"vendor")
	luaunit.assertEquals(comp_prop:getProperty("category"),"category")
	luaunit.assertEquals(comp_prop:getProperty("implementation_id"),"implementation_id")
	luaunit.assertEquals(comp_prop:getProperty("language"),"language")
	luaunit.assertEquals(comp_prop:getProperty("version"),"version")

	luaunit.assertEquals(comp_id:getProperty("param1"),"xxx")
	luaunit.assertEquals(comp_id:getProperty("param2"),"yyy")


	luaunit.assertNotEquals(mgr:findIdLFile("test.idl"), "")
	

	
	mgr:createShutdownThread(0.01)

end

function TestManager:test_pre()
	local mgr = require "openrtm.Manager"
	mgr:init({
		"-o","exec_cxt.periodic.type:SimulatorExecutionContext",
		"-o","manager.components.precreate:TestComp",
		"-o","manager.components.preconnect:TestComp0.out?port=TestComp0.in",
		"-o","manager.components.preactivation:TestComp0"
	})

	mgr:addManagerActionListener(ManagerActionListener_.new())
	mgr:addModuleActionListener(ModuleActionListener_.new())
	mgr:addRtcLifecycleActionListener(RtcLifecycleActionListener_.new())
	mgr:addNamingActionListener(NamingActionListener_.new())
	mgr:addLocalServiceActionListener(LocalServiceActionListener_.new())
	

	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)

	local comp0 = mgr:getComponent("TestComp0")
	luaunit.assertNotEquals( comp0, nil)

	luaunit.assertIsTrue(CORBA_RTCUtil.already_connected(comp0._inIn,comp0._outOut))

	luaunit.assertIsTrue(CORBA_RTCUtil.is_in_active(comp0))

	luaunit.assertEquals( #mgr:getComponents(), 1)
	
	oil.main(function()
			mgr:createComponent("TestComp")
		end
	)

	luaunit.assertEquals( #mgr:getComponents(), 2)

	local props = mgr:getFactoryProfiles()
	luaunit.assertNotEquals(#props, 0)


	
	mgr:unloadAll()
	mgr:createShutdownThread(0.01)
end
--[[
function TestManager:test_mod()
	package.loaded["openrtm.Manager"] = nil
	ORB_Dummy_ENABLE = true
	local Manager = require "openrtm.Manager"
	package.loaded["openrtm.Manager"] = nil
	ORB_Dummy_ENABLE = false
	local Manager = require "openrtm.Manager"
end
--]]


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
