local luaunit = require "luaunit"

local NodeNumberingPolicy = require "openrtm.NodeNumberingPolicy"
local RTCUtil = require "openrtm.RTCUtil"
local oil = require "oil"

local Properties = require "openrtm.Properties"

local RTObject = require "openrtm.RTObject"
local Factory = require "openrtm.Factory"




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

TestNodeNumberingPolicy = {}
function TestNodeNumberingPolicy:test_naming()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0","-o","exec_cxt.periodic.type:SimulatorExecutionContext"})
	mgr:activateManager()
	mgr:setModuleInitProc(MyModuleInit)
	mgr:runManager(true)
	
	local policy = NodeNumberingPolicy.new()

	


	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
