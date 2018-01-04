--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ConnectorBase= {}
_G["openrtm.ConnectorBase"] = ConnectorBase


ConnectorBase.ConnectorInfo = {}
ConnectorBase.ConnectorInfo.new = function(name_, id_, ports_, properties_)
	local obj = {}
	obj.name = name_
	obj.id = id_
	obj.ports = ports_
	obj.properties = properties_
	return obj
end

ConnectorBase.new = function()
	local obj = {}
	function obj:profile()
	end
	function obj:id()
	end
	function obj:name()
	end
	function obj:disconnect()
	end
	function obj:getBuffer()
	end
	function obj:activate()
	end
	function obj:deactivate()
	end
	return obj
end


return ConnectorBase
