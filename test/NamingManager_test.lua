local luaunit = require "luaunit"
local NamingManager = require "openrtm.NamingManager"
local Properties = require "openrtm.Properties"
local NamingOnCorba = NamingManager.NamingOnCorba
local NamingOnManager = NamingManager.NamingOnManager

local RTObject = require "openrtm.RTObject"
local Factory = require "openrtm.Factory"
local CorbaNaming = require "openrtm.CorbaNaming"

local InPort = require "openrtm.InPort"

TestNamingManager = {}



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

function TestNamingManager:test_namingoncorba()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)


	local orb = mgr:getORB()
	local comp0 = mgr:getComponent("TestComp0")

	local ns = NamingOnCorba.new(orb, "localhost:2809")
	local comps = {}
	oil.main(function()
		ns:bindObject("TestComp02.rtc",comp0._svr)
		local root_cxt = CorbaNaming.new(orb,"localhost:2809"):getRootContext()
		ns:getComponentByName(root_cxt, "TestComp02", comps)
		
	end)
	luaunit.assertNotEquals(comps[1],nil)

	local comps = {}
	oil.main(function()
		comps = ns:string_to_component("rtcname://localhost/TestComp02")
	end)
	luaunit.assertNotEquals(comps[1],nil)


	local comps = {}
	oil.main(function()
		comps = ns:string_to_component("rtcname://localhost/*/TestComp02")
		ns:unbindObject("TestComp02.rtc")
	end)
	luaunit.assertNotEquals(comps[1],nil)


	mgr:createShutdownThread(0.01)
end


function TestNamingManager:test_namingonmanager()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)


	local ns = NamingOnManager.new(orb, mgr)


	mgr:createShutdownThread(0.01)
end


function TestNamingManager:test_namingmanager()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)

	local nm = NamingManager.new(mgr)
	nm:registerNameServer("corba","localhost")

	nm:createNamingObj("corba","localhost")
	nm:createNamingObj("manager","default")

	local comp0 = mgr:getComponent("TestComp0")
	local comps = {}

	local d_in = {tm={sec=0,nsec=0},data=0}
	local inIn = InPort.new("in",d_in,"::RTC::TimedLong")
	local prop = Properties.new()
	inIn:init(prop)

	oil.main(function()
		nm:bindPortObject("port0.port", inIn._svr)
		nm:registerPortName("port0.port",inIn._svr)
		nm:unbindAll()
	end)


	oil.main(function()
		nm:bindManagerObject("mgr0.mgr", mgr:getManagerServant()._svr)
		nm:registerMgrName("mgr0.mgr",mgr:getManagerServant()._svr)
		nm:unbindAll()
	end)


	oil.main(function()
		nm:bindObject("TestComp02.rtc",comp0._svr)
		nm:registerCompName("TestComp02.rtc",comp0._svr)
		nm:unbindObject("TestComp02.rtc")
		nm:bindObject("TestComp02.rtc",comp0._svr)
		comps = nm:getObjects()
		nm:unbindAll()
	end)
	luaunit.assertNotEquals(#comps,0)

	local comps = {}
	oil.main(function()
		nm:bindObject("TestComp02.rtc",comp0._svr)
		comps = nm:string_to_component("rtcname://localhost/TestComp02")
		nm:unbindAll()
	end)

	

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
