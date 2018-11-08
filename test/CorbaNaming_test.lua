local luaunit = require "luaunit"

local CorbaNaming = require "openrtm.CorbaNaming"
local RTCUtil = require "openrtm.RTCUtil"
local oil = require "oil"




TestCorbaNaming = {}
function TestCorbaNaming:test_naming()
	local mgr = require "openrtm.Manager"
	mgr:init({})
	mgr:activateManager()
	mgr:runManager(true)
	

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
	function hello:getObjRef()
		return svr
	end
	--local ior = orb:tostring(svr)
	local objref = RTCUtil.getReference(orb, svr, "Hello")

	local cn = CorbaNaming.new(orb, "localhost:2809")
	--orb:step()
	local ret = oil.corba.idl.null
	oil.main(function()
		cn:rebindByString("test1.host_cxt/test2.rtc", objref)
		cn:rebindByString("test1.host_cxt/test2.rtc", objref)
		--cn:rebind({{id="test1",kind="host_cxt"},{id="test3",kind="rtc"}}, objref, true)
		--ret = cn:resolve({{id="test1",kind="host_cxt"},{id="test2",kind="rtc"}})
		ret = cn:resolve("test1.host_cxt/test2.rtc")
		ret = cn:resolveStr("test1.host_cxt/test2.rtc")
		ret = RTCUtil.newproxy(orb, ret, "Hello")
		cn:unbind({{id="test1",kind="host_cxt"},{id="test2",kind="rtc"}})
	end)
	oil.main(function()
		cn:rebind({{id="test1",kind="host_cxt"},{id="test3",kind="rtc"}}, objref)
		
		cn:unbind({{id="test1",kind="host_cxt"},{id="test3",kind="rtc"}})
	end)
	luaunit.assertEquals(ret:echo("abc"),"abc")

	local rootcontext = cn:getRootContext()
	local success, exception = pcall(
		function()
			cn:rebindRecursive(rootcontext, 
							{{id="test1",kind="host_cxt"},{id="test3",kind="rtc"}},
							objref)
			cn:unbind({{id="test1",kind="host_cxt"},{id="test2",kind="rtc"}})
			cn:toName("")
			cn:toName("test1")
		end
	)

	local tbl = {{id="test1",kind="host_cxt"},
				{id="test2",kind="host_cxt"},
				{id="test3",kind="rtc"}}
	local ret = cn:subName(tbl,2,3)
	luaunit.assertEquals(ret[1].id,"test2")
	luaunit.assertEquals(ret[2].id,"test3")
	--print(exception)
	luaunit.assertIsFalse(success)
	



	orb:deactivate(svr)
	


	mgr:createShutdownThread(0.01)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
