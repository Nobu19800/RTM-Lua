local luaunit = require "luaunit"
local ManagerConfig = require "openrtm.ManagerConfig"


TestManagerConfig = {}




function TestManagerConfig:test_config()
	local mgrconf = ManagerConfig.new()
	mgrconf:parseArgs({"-o","param1:value","-d","-p","2810","-f","dummy.conf","-a"})
	--luaunit.assertEquals(listener5._postServiceFinalize,1)
	luaunit.assertIsFalse(mgrconf:findConfigFile())
	luaunit.assertIsFalse(mgrconf:fileExist("dummy.conf"))
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
