require "oil"

local coroutine = require "coroutine"

ExecutionContext = {}
ExecutionContext.new = function()
	local obj = {}
	obj.run = function()
		while true do
			print("run")
			coroutine.yield(1)
		end
	end
	return obj
end



oil.main(function()





	local testEC = {state=1}
	function testEC:is_running()
		print("is_running")
		return true
	end
	function testEC:get_rate()
		print("get_rate")
		return 1000.0
	end
	function testEC:get_component_state(comp)
		print("get_component_state")
		print(self.state)
		return self.state
	end
	function testEC:get_kind()
		print("get_kind")
		return 0
	end
	function testEC:activate_component(comp)
		print("activate_component")
		self.state = 2
		return 0
	end
	function testEC:deactivate_component(comp)
		print("deactivate_component")
		self.state = 1
		return 0
	end
	function testEC:get_profile()
		print("get_profile")
		return {kind=0,rate=1000.0,owner=self.rtc, participants={},
				 properties={}}
	end

	local testComp = {}
	function testComp:get_component_profile()
		print("get_component_profile")
		return {instance_name="testComp",type_name="testComp",
				  description="description",version="0", vendor="Nobuhiko Miyamoto",
				  category="test",port_profiles={},
				  parent=testComp,properties={
				  {name="implementation_id",value="testComp"}, {name="type_name",value="testComp"},
				  {name="description",value="description"},{name="version",value="0"},
				  {name="vendor",value="Nobuhiko Miyamoto"},{name="category",value="test"},
				  {name="activity_type",value="STATIC"},{name="max_instance",value="1"},
				  {name="language",value="Lua"},{name="lang_type",value="SCRIPT"},
				  {name="instance_name",value="testComp0"}
				  }
				  }
	end
	function testComp:initialize()
		return 0
	end
	function testComp:get_ports()
		print("get_ports")
		return {}
	end
	function testComp:get_owned_contexts()
		print("get_owned_contexts")
		return {self.ec}
	end
	function testComp:get_participating_contexts()
		print("get_participating_contexts")
		return {}
	end
	function testComp:is_alive(exec_context)
		print("is_alive")
		return true
	end
	function testComp:get_context(exec_handle)
		print("get_context")

		return self.ec
	end
	function testComp:get_context_handle(cxt)
		print("get_context_handle")
		return 0
	end


	local testPort = {}
	function testPort:get_port_profile()
		print("get_port_profile")
		return {name="testPort",interfaces={},port_ref=nil,connector_profiles={},
				 owner=nil, properties={}}
	end
	function testPort:get_connector_profiles()
		print("get_connector_profiles")
		return {}
	end
	function testPort:get_connector_profile()
		print("get_connector_profile")
		return {name="test",connector_id="test",ports={},
				properties={}}
	end






	local orb = oil.init{ flavor = "intercepted;corba;typed;cooperative;base", port=2810 }
	oil.newthread(orb.run, orb)


	orb:loadidlfile("CosNaming.idl")
	orb:loadidlfile("hello.idl")
	orb:loadidlfile("RTC.idl")
	orb:loadidlfile("OpenRTM.idl")




	testComp = orb:newservant(testComp, "testComp", "IDL:openrtm.aist.go.jp/OpenRTM/DataFlowComponent:1.0")
	testEC = orb:newservant(testEC, nil, "IDL:omg.org/RTC/ExecutionContextService:1.0")
	testComp.ec = testEC
	testEC.rtc = testComp


	ref = orb:tostring(testEC)
	ref = orb:newproxy(ref,"IDL:omg.org/RTC/ExecutionContextService:1.0")







	name = "corbaloc:iiop:localhost:2809/NameService"
	ns = orb:newproxy(name,"IDL:omg.org/CosNaming/NamingContext:1.0")

	ns:rebind({{id="testComp",kind="rtc"}},testComp)


	ec = ExecutionContext.new()
	oil.newthread(ec.run)

end)
