local openrtm  = require "openrtm"

local Properties = {}


function Properties:new(defaults_map)
	--for k,v in pairs(defaults_map) do
	--	print(k,v)
	--end
	return openrtm.Properties.new({defaults_map=defaults_map})
end


return Properties
