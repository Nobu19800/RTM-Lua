local luaunit = require "luaunit"
local OutPortConsumer = require "openrtm.OutPortConsumer"
local Properties = require "openrtm.Properties"
local NVUtil = require "openrtm.NVUtil"

TestOutPortConsumer = {}





function TestOutPortConsumer:test_consumer()


	local consumer = OutPortConsumer.new()

end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
