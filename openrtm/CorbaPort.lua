--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CorbaPort= {}
_G["openrtm.CorbaPort"] = CorbaPort

local PortBase = require "openrtm.PortBase"
local Properties = require "openrtm.Properties"
local StringUtil = require "openrtm.StringUtil"
local NVUtil = require "openrtm.NVUtil"
local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"


CorbaProviderHolder = {}
CorbaProviderHolder.new = function(type_name, instance_name, servant)
	local obj = {}

	function obj:instanceName()
		return self._instanceName
	end


	function obj:itypeName()
		return self._typeName
	end


	function obj:ior()
		return self._ior
	end


	function obj:descriptor()
		return self._typeName.."."..self._instanceName
	end


	function obj:activate()
    end


	function obj:deactivate()
    end


	obj._typeName = type_name
    obj._instanceName = instance_name
    obj._servant = servant
	local Manager = require "openrtm.Manager"
	local _mgr = Manager:instance()
	--obj.._oid = _mgr:getPOA():tostring(obj.._servant)

	obj._ior = _mgr:getORB():tostring(obj._servant)
	--obj:deactivate()
	return obj
end


CorbaConsumerHolder = {}
CorbaConsumerHolder.new = function(type_name, instance_name, consumer, owner)
	local obj = {}

    function obj:instanceName()
		return self._instanceName
	end
	function obj:typeName()
		return self._typeName
	end
	function obj:descriptor()
		return self._typeName.."."..self._instanceName
	end

	function obj:setObject(ior)
		self._ior = ior

		return self._consumer:setIOR(ior)

	end

	function obj:releaseObject()
		self._consumer:releaseObject()
	end

    function obj:getIor()
		return self._ior
	end


	obj._typeName = type_name
    obj._instanceName = instance_name
    obj._consumer = consumer
    obj._owner = owner
    obj._ior = ""

	return obj
end


CorbaPort.new = function(name)
	local obj = {}
	setmetatable(obj, {__index=PortBase.new(name)})
	local Manager = require "openrtm.Manager"
	obj._PortInterfacePolarity = Manager:instance():getORB().types:lookup("::RTC::PortInterfacePolarity").labelvalue
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue



	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		self:createRef()

		self._properties:mergeProperties(prop)

		local num = tonumber(self._properties:getProperty("connection_limit","-1"))
		if num == ni then
			self._rtcout:RTC_ERROR("invalid connection_limit value: "..
								 self._properties:getProperty("connection_limit"))
		end

		self:setConnectionLimit(num)
	end


	function obj:registerProvider(instance_name, type_name, provider, idl_file, interface_type)
		self._rtcout:RTC_TRACE("registerProvider(instance="..instance_name..", type_name="..type_name..")")
		if interface_type ~= nil and idl_file ~= nil then
			local Manager = require "openrtm.Manager"
			Manager:instance():getORB():loadidlfile(idl_file)
			provider = Manager:instance():getORB():newservant(provider, nil, interface_type)
		end
		local success, exception = oil.pcall(
			function()
				table.insert(self._providers, CorbaProviderHolder.new(type_name,
														  instance_name,
														  provider))
			end)
		if not success then
			self._rtcout:RTC_ERROR("appending provider interface failed")
			self._rtcout:RTC_ERROR(exception)
			return false
		end


		if not self:appendInterface(instance_name, type_name, self._PortInterfacePolarity.PROVIDED) then
			return false
		end

		return true
	end


	function obj:registerConsumer(instance_name, type_name, consumer, idl_file)
		self._rtcout:RTC_TRACE("registerConsumer()")
		if idl_file ~= nil then
			local Manager = require "openrtm.Manager"
			Manager:instance():getORB():loadidlfile(idl_file)
		end
		if not self:appendInterface(instance_name, type_name, self._PortInterfacePolarity.REQUIRED) then
			return false
		end

		table.insert(self._consumers,CorbaConsumerHolder.new(type_name,
														instance_name,
														consumer,
														self))
		return true
	end

	function obj:activateInterfaces()
		for i, provider in ipairs(self._providers) do
			provider:activate()
		end
    end

	function obj:deactivateInterfaces()
		for i, provider in ipairs(self._providers) do
			provider:deactivate()
		end
    end


	function obj:publishInterfaces(connector_profile)
		self._rtcout:RTC_TRACE("publishInterfaces()")

		local returnvalue = self:_publishInterfaces()

		if returnvalue ~= self._ReturnCode_t.RTC_OK then
			return returnvalue
		end

		local properties = {}

		for i, provider in ipairs(self._providers) do
			local newdesc = string.sub(self._profile.name, 1, #self._ownerInstanceName)..
				".port"..string.sub(self._profile.name, #self._ownerInstanceName+1)
			newdesc = newdesc..".provided."..provider:descriptor()

			table.insert(properties, NVUtil.newNV(newdesc, provider:ior()))


			local olddesc = "port."..provider:descriptor()
			table.insert(properties, NVUtil.newNV(olddesc, provider:ior()))

		end

		CORBA_SeqUtil.push_back_list(connector_profile.properties, properties)

		return self._ReturnCode_t.RTC_OK
	end


	function obj:subscribeInterfaces(connector_profile)
		self._rtcout:RTC_TRACE("subscribeInterfaces()")
		local nv = connector_profile.properties

		local strict = false
		local index = NVUtil.find_index(nv, "port.connection.strictness")
		if index >=  0 then
			local strictness = NVUtil.any_from_any(nv[index].value)
			if "best_effort" == strictness then
				strict = false
			elseif "strict" == strictness then
				strict = true
			end

			self._rtcout:RTC_DEBUG("Connetion strictness is: "..strictness)
		end

		for i, consumer in ipairs(self._consumers) do
			local ior = {}
			--print(nv, consumer)
			--print(self:findProvider(nv, consumer, ior))
			if self:findProvider(nv, consumer, ior) and table.maxn(ior) > 0 then

				self:setObject(ior[1], consumer)

			else
				ior = {}
				--print(self:findProviderOld(nv, consumer, ior), table.maxn(ior))
				if self:findProviderOld(nv, consumer, ior) and table.maxn(ior) > 0 then

					self:setObject(ior[1], consumer)
				else

					if strict then
						self._rtcout:RTC_ERROR("subscribeInterfaces() failed.")
						return self._ReturnCode_t.RTC_ERROR
					end
				end
			end
		end

		self._rtcout:RTC_TRACE("subscribeInterfaces() successfully finished.")

		return self._ReturnCode_t.RTC_OK
	end


 	function obj:unsubscribeInterfaces(connector_profile)
		self._rtcout:RTC_TRACE("unsubscribeInterfaces()")
		local nv = connector_profile.properties

		for i, consumer in ipairs(self._consumers) do
			local ior = {}
			if self:findProvider(nv, consumer, ior) and table.maxn(ior) > 0 then
				self._rtcout:RTC_DEBUG("Correspoinding consumer found.")
				self:releaseObject(ior[1], consumer)
			else
				ior = {}
				if self:findProviderOld(nv, consumer, ior) and table.maxn(ior) > 0 then
					self._rtcout:RTC_DEBUG("Correspoinding consumer found.")
					self:releaseObject(ior[1], consumer)
				end
			end
		end


    end


 	function obj:findProvider(nv, cons, iorstr)

		local newdesc = string.sub(self._profile.name,1,#self._ownerInstanceName)..
			".port"..string.sub(self._profile.name,#self._ownerInstanceName+1)
		newdesc = newdesc..".required."..cons:descriptor()


		local cons_index = NVUtil.find_index(nv, newdesc)
		--print(newdesc)
		--print(#nv)
		--for i,v in ipairs(nv) do
		--	print(v.name, v.value)
		--end
		if cons_index < 0 then
			return false
		end

		local provider = NVUtil.any_from_any(nv[cons_index].value)
		if provider == "" then
			self._rtcout:RTC_WARN("Cannot extract Provider interface descriptor")
			return false
		end


		local prov_index = NVUtil.find_index(nv, provider)
		if prov_index < 0 then
			return false
		end

		local ior_ = NVUtil.any_from_any(nv[prov_index].value)
		if ior_ == "" then
			self._rtcout:RTC_WARN("Cannot extract Provider IOR string")
			return false
		end

		if type(iorstr) == "table" then
			table.insert(iorstr, ior_)
		end

		self._rtcout:RTC_ERROR("interface matched with new descriptor: "..newdesc)

		return true
	end

	function obj:findProviderOld(nv, cons, iorstr)
		local olddesc = "port."..cons:descriptor()

		--print(olddesc)

		--for i,v in ipairs(nv) do
		--	print(v.name, v.value)
		--end

		local index = NVUtil.find_index(nv, olddesc)


		if index < 0 then
			return false
		end



		local ior_ = NVUtil.any_from_any(nv[index].value)
		--print(ior_)

		if ior_ == "" then
			self._rtcout:RTC_WARN("Cannot extract Provider IOR string")
			return false
		end

		if type(iorstr) == "table" then
			table.insert(iorstr, ior_)
		end

		self._rtcout:RTC_ERROR("interface matched with old descriptor: "..olddesc)

		return true
	end


	function obj:setObject(ior, cons)
		if "null" == ior then
			return true
		end

		if "nil"  == ior then
			return true
		end


		--if "IOR:" ~= string.sub(ior,1,4) then
		--	return false
		--end


		if not cons:setObject(ior) then
			self._rtcout:RTC_ERROR("Cannot narrow reference")
			return false
		end

		self._rtcout:RTC_TRACE("setObject() done")
		return true
	end

	function obj:releaseObject(ior, cons)
		if ior == cons:getIor() then
			cons:releaseObject()
			self._rtcout:RTC_DEBUG("Consumer "..cons:descriptor().." released.")
			return true
		end

		self._rtcout:RTC_WARN("IORs between Consumer and Connector are different.")
		return false
	end

	function obj:activateInterfaces()
		self._rtcout:RTC_TRACE("activateInterfaces()")
		for i, provider in ipairs(self._providers) do
			provider:activate()
		end
	end

	function obj:deactivateInterfaces()
		self._rtcout:RTC_TRACE("deactivateInterfaces()")
		for i, provider in ipairs(self._providers) do
			provider:deactivate()
		end
	end



	obj:addProperty("port.port_type", "CorbaPort")
    obj._properties = Properties.new()
    obj._providers = {}
    obj._consumers = {}

	return obj
end


return CorbaPort
