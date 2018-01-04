--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ObjectManager= {}
_G["openrtm.ObjectManager"] = ObjectManager

ObjectManager.new = function(predicate)
	local obj = {}
	obj._objects = {} --self.Objects()
	obj._predicate = predicate
	function obj:registerObject(object)
		predi = self._predicate({factory=object})
		for i, _obj in ipairs(self._objects) do
			if predi(_obj) == true then
				return false
			end
		end
		--print(#self._objects)
		table.insert(self._objects, object)
		--print(#self._objects)
		return true
	end
	function obj:unregisterObject(id)
		predi = self._predicate({name=id})
		for i, _obj in ipairs(self._objects) do
			if predi(_obj) == true then
				ret = _obj
				table.remove(self._objects, i)
				return ret
			end
		end
		return nil
	end
	function obj:unregisterObject(id)
		if type(id) == "string" then
			predi = self._predicate({name=id})
		else
			predi = self._predicate({prop=id})
		end
		for i, _obj in ipairs(self._objects) do
			if predi(_obj) == true then
				return _obj
			end
		end
		return nil
	end
	function obj:for_each(p)
		predi = p()
		for i, _obj in ipairs(self._objects) do
			predi(_obj)
		end
		return predi
	end
	function obj:find(id)
		--print(id)
		if type(id) == "string" then
			predi = self._predicate({name=id})
		else
			predi = self._predicate({prop=id})
		end
		for i, _obj in ipairs(self._objects) do
			if predi(_obj) == true then
				return _obj
			end
		end
		return nil
	end
	function obj:getObjects()
		return self._objects
	end

	return obj
end


return ObjectManager
