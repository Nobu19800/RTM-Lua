--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local GlobalFactory= {}
_G["openrtm.GlobalFactory"] = GlobalFactory

GlobalFactory.Factory = {}

GlobalFactory.Factory.FACTORY_OK = 0
GlobalFactory.Factory.FACTORY_ERROR = 1
GlobalFactory.Factory.ALREADY_EXISTS = 2
GlobalFactory.Factory.NOT_FOUND = 3
GlobalFactory.Factory.INVALID_ARG = 4
GlobalFactory.Factory.UNKNOWN_ERROR = 5

FactoryEntry = {}

function FactoryEntry.new(id, creator, destructor)
	local obj = {}
	obj.id_ = id
	obj.creator_ = creator
	obj.destructor_ = destructor
	return obj
end

GlobalFactory.Factory.new = function()
	local obj = {}
	obj._creators = {}
	obj._objects = {}
	function obj:hasFactory(id)
		if self._creators[id] == nil then
			return false
		else
			return true
		end
	end


	function obj:getIdentifiers()
		idlist = {}
		for i, ver in pairs(self._creators) do
			table.insert(idlist, i)
		end
		return idlist
	end


	function obj:addFactory(id, creator, destructor)
		--print("test",creator,destructor)
		if creator == nil or destructor == nil then
			return GlobalFactory.Factory.INVALID_ARG
		end

		if self._creators[id] ~= nil then
			return GlobalFactory.Factory.ALREADY_EXISTS
		end

		self._creators[id] = FactoryEntry.new(id, creator, destructor)
		return GlobalFactory.Factory.FACTORY_OK
	end



	function obj:removeFactory(id)

		if self._creators[id] == nil then
			return GlobalFactory.Factory.NOT_FOUND
		end

		table.remove(self._creators, id)
		return GlobalFactory.Factory.FACTORY_OK
	end

	function obj:createObject(id)

		if self._creators[id] == nil then
			print("Factory.createObject return nil id: "..id)
			return nil
		end

		obj_ = self._creators[id].creator_()
		self._objects[obj_] = self._creators[id]
		--for k,v in pairs(self._objects) do
		--	print(k,v)
		--end
		return obj_
	end

	function obj:deleteObject(obj, id)

		if id ~= nil then
			if self._creators[id] == nil then
				self._creators[id].destructor_(obj)
				table.remove(self._creators, id)
				return GlobalFactory.Factory.FACTORY_OK
			end
		end

		if self._objects[obj] == nil then
			return GlobalFactory.Factory.NOT_FOUND
		end

		tmp = obj
		self._objects[obj].destructor_(obj)
		--print(table.maxn(self._objects))

		--for k,v in pairs(self._objects) do
		--	print(k,v)
		--end
		self._objects[obj] = nil
		--print(table.maxn(self._objects))
		return GlobalFactory.Factory.FACTORY_OK
	end


	function obj:createdObjects()

		objects_ = {}
		for i, ver in pairs(self._objects) do
			table.insert(objects_, ver)
		end
		return objects_
	end



	function obj:isProducerOf(obj)

		if self._objects[obj] ~= nil then
			return true
		else
			return false
		end

	end


	function obj:objectToIdentifier(obj, id)

		if self._objects[obj] == nil then
			return GlobalFactory.Factory.NOT_FOUND
		end
		id[0] = self._objects[obj].id_
		return GlobalFactory.Factory.FACTORY_OK
	end


	function obj:objectToCreator(obj)
		return self._objects[obj].creator_
	end


	function obj:objectToDestructor(obj)
		return self._objects[obj].destructor_
	end
	return obj
end


GlobalFactory.GlobalFactory = {}
setmetatable(GlobalFactory.GlobalFactory, {__index=GlobalFactory.Factory.new()})



function GlobalFactory.GlobalFactory:instance()
	return self
end


return GlobalFactory
