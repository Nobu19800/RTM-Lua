local luaunit = require "luaunit"
local InPortConsumer = require "openrtm.InPortConsumer"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"

TestInPortConsumer = {}





function TestInPortConsumer:test_consumer()


	local consumer = InPortConsumer.new()

end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
