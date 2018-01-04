--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ECFactory= {}
_G["openrtm.ECFactory"] = ECFactory


ECFactory.ECDelete = function(ec)
end


ECFactory.ECFactoryBase = {}

ECFactory.ECFactoryBase.new = function()
	local obj = {}
	function obj:name()
	end
	function obj:create()
	end
	function obj:destroy(ec)
	end
	return obj
end

ECFactory.ECFactoryLua = {}

ECFactory.ECFactoryLua.new = function(name, new_func, delete_func)
	local obj = {}
	setmetatable(obj, {__index=ECFactory.ECFactoryBase.new()})
	obj._name   = name
    obj._New    = new_func
    obj._Delete = delete_func
	function obj:name()
		return self._name
	end
	function obj:create()
		return self._New()
	end
	function obj:destroy(ec)
		self._Delete(ec)
	end
	return obj
end


return ECFactory
