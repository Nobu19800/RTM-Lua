--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortBase= {}
_G["openrtm.InPortBase"] = InPortBase

local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
local Properties = require "openrtm.Properties"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorListeners = ConnectorListener.ConnectorListeners
local PublisherBase = require "openrtm.PublisherBase"
local PublisherFactory = PublisherBase.PublisherFactory
local PortBase = require "openrtm.PortBase"
local StringUtil = require "openrtm.StringUtil"
local CdrBufferBase = require "openrtm.CdrBufferBase"
local CdrBufferFactory = CdrBufferBase.CdrBufferFactory


local OutPortConsumer = require "openrtm.OutPortConsumer"
local OutPortConsumerFactory = OutPortConsumer.OutPortConsumerFactory
local InPortProvider = require "openrtm.InPortProvider"
local InPortProviderFactory = InPortProvider.InPortProviderFactory

local NVUtil = require "openrtm.NVUtil"


local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo

local InPortPushConnector = require "openrtm.InPortPushConnector"
local InPortPullConnector = require "openrtm.InPortPullConnector"


InPortBase.new = function(name, data_type)
	local obj = {}
	setmetatable(obj, {__index=PortBase.new(name)})
	local Manager = require "openrtm.Manager"
	obj._ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue

	obj._rtcout = Manager:instance():getLogbuf(name)
	obj._rtcout:RTC_DEBUG("Port name: "..name)

	--local svr = Manager:instance():getORB():newservant(obj, nil, "IDL:omg.org/RTC/PortService:1.0")
	--local str = Manager:instance():getORB():tostring(svr)
	--obj._objref = Manager:instance():getORB():newproxy(str,"IDL:omg.org/RTC/PortService:1.0")
	--obj._profile.port_ref = obj._objref


    obj._singlebuffer  = true
    obj._thebuffer     = nil
    obj._properties    = Properties.new()
    obj._providerTypes = ""
    obj._consumerTypes = ""
    obj._connectors    = {}

    obj._rtcout:RTC_DEBUG("setting port.port_type: DataInPort")
    obj:addProperty("port.port_type", "DataInPort")

    obj._rtcout:RTC_DEBUG("setting port.data_type: "..tostring(data_type))
	local _data_type = string.sub(data_type, 3)
	_data_type = string.gsub(_data_type, "::", "/")
	_data_type = "IDL:".._data_type..":1.0"
    obj:addProperty("dataport.data_type", _data_type)

    obj:addProperty("dataport.subscription_type", "Any")
    obj._value = nil
    obj._listeners = ConnectorListeners.new()
	obj._data_type = data_type
	--print(data_type)


	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		self:createRef()

		self._properties:mergeProperties(prop)
		if self._singlebuffer then
			self._rtcout:RTC_DEBUG("single buffer mode.")
			self._thebuffer = CdrBufferFactory:instance():createObject("ring_buffer")
			--print(self._thebuffer, self._thebuffer.write)
			if self._thebuffer == nil then
				self._rtcout:RTC_ERROR("default buffer creation failed")
			end
		else
			self._rtcout:RTC_DEBUG("multi buffer mode.")
		end



		self:initProviders()
		self:initConsumers()

		num = tonumber(self._properties:getProperty("connection_limit","-1"))
		if num == nil then
			self._rtcout:RTC_ERROR("invalid connection_limit value: "..self._properties:getProperty("connection_limit"))
		end
		self:setConnectionLimit(num)
    end
	function obj:initConsumers()
		self._rtcout:RTC_TRACE("initConsumers()")


		factory = OutPortConsumerFactory:instance()
		consumer_types = factory:getIdentifiers()

		self._rtcout:RTC_PARANOID("available InPortConsumer: "..StringUtil.flatten(consumer_types))
		tmp_str = StringUtil.normalize(self._properties:getProperty("consumer_types"))
		if self._properties:hasKey("consumer_types") and tmp_str  ~= "all" then
			self._rtcout:RTC_DEBUG("allowed consumers: "..self._properties:getProperty("consumer_types"))

			temp_types = consumer_types
			consumer_types = {}
			active_types = StringUtil.split(self._properties:getProperty("consumer_types"), ",")

			table.sort(temp_types)
			table.sort(active_types)

			consumer_types = temp_types

			for i, v in ipairs(active_types) do
				consumer_types[#consumer_types+1] = v
			end
		end



		if #consumer_types > 0 then
			self._rtcout:RTC_PARANOID("dataflow_type pull is supported")
			self:appendProperty("dataport.dataflow_type", "pull")
			for i, consumer_type in ipairs(consumer_types) do
				self:appendProperty("dataport.interface_type",consumer_type)
			end
		end

		self._consumerTypes = consumer_types
	end
	function obj:initProviders()
		self._rtcout:RTC_TRACE("initProviders()")


		factory = InPortProviderFactory:instance()
		provider_types  = factory:getIdentifiers()
		self._rtcout:RTC_PARANOID("available InPortProviders: "..StringUtil.flatten(provider_types))
		tmp_str = StringUtil.normalize(self._properties:getProperty("provider_types"))
		if self._properties:hasKey("provider_types") and tmp_str  ~= "all" then
			self._rtcout:RTC_DEBUG("allowed providers: "..self._properties:getProperty("allowed"))

			temp_types = provider_types
			provider_types = {}
			active_types = StringUtil.split(self._properties:getProperty("provider_types"), ",")

			table.sort(temp_types)
			table.sort(active_types)

			provider_types = temp_types

			for i, v in ipairs(active_types) do
				provider_types[#provider_types+1] = v
			end
		end



		if #provider_types > 0 then
			self._rtcout:RTC_PARANOID("dataflow_type push is supported")
			self:appendProperty("dataport.dataflow_type", "push")
			for i, provider_type in ipairs(provider_types) do
				self:appendProperty("dataport.interface_type",provider_type)
			end
		end

		self._providerTypes = provider_types
	end

	function obj:publishInterfaces(cprof)

		self._rtcout:RTC_TRACE("publishInterfaces()")


		local retval = self:_publishInterfaces()
		if retval ~= self._ReturnCode_t.RTC_OK then
			return retval
		end


		local prop = Properties.new(self._properties)

		local conn_prop = Properties.new()
		NVUtil.copyToProperties(conn_prop, cprof.properties)
		prop:mergeProperties(conn_prop:getNode("dataport"))


		prop:mergeProperties(conn_prop:getNode("dataport.inport"))


		local dflow_type = prop:getProperty("dataflow_type")
		dflow_type = StringUtil.normalize(dflow_type)

		if dflow_type == "push" then
			self._rtcout:RTC_DEBUG("dataflow_type = push .... create PushConnector")


			provider = self:createProvider(cprof, prop)

			if provider == nil then
				self._rtcout:RTC_ERROR("InPort provider creation failed.")
				return self._ReturnCode_t.BAD_PARAMETER
			end


			connector = self:createConnector(cprof, prop, {provider_ = provider})

			if connector == nil then
				self._rtcout:RTC_ERROR("PushConnector creation failed.")
				return self._ReturnCode_t.RTC_ERROR
			end
			--print(self._data_type)
			connector:setDataType(self._data_type)
			provider:setConnector(connector)

			self._rtcout:RTC_DEBUG("publishInterfaces() successfully finished.")
			return self._ReturnCode_t.RTC_OK

		elseif dflow_type == "pull" then
			self._rtcout:RTC_DEBUG("dataflow_type = pull .... do nothing")
			return self._ReturnCode_t.RTC_OK
		end

		self._rtcout:RTC_ERROR("unsupported dataflow_type")
		return self._ReturnCode_t.BAD_PARAMETER
	end



	function obj:subscribeInterfaces(cprof)
		self._rtcout:RTC_TRACE("subscribeInterfaces()")




		local prop = Properties.new(self._properties)

		local conn_prop = Properties.new()

		NVUtil.copyToProperties(conn_prop, cprof.properties)
		--print(cprof.properties[1].value)


		prop:mergeProperties(conn_prop:getNode("dataport"))

		prop:mergeProperties(conn_prop:getNode("dataport.inport"))



		local dflow_type = StringUtil.normalize(prop:getProperty("dataflow_type"))
		local profile = ConnectorInfo.new(cprof.name,
										cprof.connector_id,
										CORBA_SeqUtil.refToVstring(cprof.ports),
										prop)
		--print(dflow_type)
		if dflow_type == "push" then

			conn = self:getConnectorById(cprof.connector_id)
			if conn == nil then
				self._rtcout:RTC_ERROR("specified connector not found: "..cprof.connector_id)
				return self._ReturnCode_t.RTC_ERROR
			end

			ret = conn:setConnectorInfo(profile)

			if ret == self._ReturnCode_t.RTC_OK then
				self._rtcout:RTC_DEBUG("subscribeInterfaces() successfully finished.")
			end

			self._rtcout:RTC_PARANOID("dataflow_type = push .... create PushConnector")

			return ret
		elseif dflow_type == "pull" then

			consumer = self:createConsumer(cprof, prop)
			--print(consumer)
			if consumer == nil then
				return self._ReturnCode_t.BAD_PARAMETER
			end


			connector = self:createConnector(cprof, prop, {consumer_ = consumer})
			--print(connector)


			if connector == nil then
				return self._ReturnCode_t.RTC_ERROR
			end
			connector:setDataType(self._data_type)

			local ret = connector:setConnectorInfo(profile)
			if ret == self._ReturnCode_t.RTC_OK then
				self._rtcout:RTC_DEBUG("subscribeInterfaces() successfully finished.")
			end


			return self._ReturnCode_t.RTC_OK
		end

		self._rtcout:RTC_ERROR("unsupported dataflow_type")

		return self._ReturnCode_t.BAD_PARAMETER
	end


	function obj:createConnector(cprof, prop, args)
		local provider_ = args.provider_
		local consumer_ = args.consumer_
		local profile = ConnectorInfo.new(cprof.name,
									cprof.connector_id,
									CORBA_SeqUtil.refToVstring(cprof.ports),
									prop)
		local connector = nil

		local ret = nil
		local success, exception = oil.pcall(
			function()
				if provider_ ~= nil then
					if self._singlebuffer then
						--print(self._thebuffer)
						connector = InPortPushConnector.new(profile, provider_,
																   self._listeners,
																   self._thebuffer)
					else
						connector = InPortPushConnector.new(profile, provider_,
																   self._listeners)
					end

				elseif consumer_ ~= nil then
					if self._singlebuffer then
						connector = InPortPullConnector.new(profile, consumer_,
																   self._listeners,
																   self._thebuffer)
					else
						connector = InPortPullConnector.new(profile, consumer_,
																   self._listeners)
					end

				else
					self._rtcout:RTC_ERROR("provider or consumer is not passed. returned 0;")
					ret = nil
					return
				end




				if provider_ ~= nil then
					self._rtcout:RTC_TRACE("InPortPushConnector created")
				elseif consumer_ ~= nil then
					self._rtcout:RTC_TRACE("InPortPullConnector created")
				end


				table.insert(self._connectors, connector)
				self._rtcout:RTC_PARANOID("connector push backed: "..#self._connectors)
				ret = connector
				return
			end)
		if not success then
			self._rtcout:RTC_ERROR("InPortPushConnector creation failed")
			self._rtcout:RTC_ERROR(exception)
			return nil
		end
		return ret
	end





	function obj:createProvider(cprof, prop)
		if prop:getProperty("interface_type") == "" or
			not StringUtil.includes(self._providerTypes, prop:getProperty("interface_type")) then
			self._rtcout:RTC_ERROR("no provider found")
			self._rtcout:RTC_DEBUG("interface_type:  "..prop:getProperty("interface_type"))
			self._rtcout:RTC_DEBUG("interface_types: "..StringUtil.flatten(self._providerTypes))
			return nil
		end


		self._rtcout:RTC_DEBUG("interface_type: "..prop:getProperty("interface_type"))
		local provider = InPortProviderFactory:instance():createObject(prop:getProperty("interface_type"))


		if provider ~= nil then
			self._rtcout:RTC_DEBUG("provider created")
			provider:init(prop:getNode("provider"))

			if not provider:publishInterface(cprof.properties) then
				self._rtcout:RTC_ERROR("publishing interface information error")
				InPortProviderFactory:instance():deleteObject(provider)
				return nil
			end
			--[[for i,v in ipairs(cprof.properties) do
				print(v.name,v.value)
				v.value = NVUtil.any_from_any(v.value)
			end]]
			return provider
		end

		self._rtcout:RTC_ERROR("provider creation failed")
		return nil
	end


	function obj:createConsumer(cprof, prop)
		if prop:getProperty("interface_type") == "" or
			  not StringUtil.includes(self._consumerTypes, prop:getProperty("interface_type")) then
			self._rtcout:RTC_ERROR("no consumer found")
			self._rtcout:RTC_DEBUG("interface_type:  "..prop:getProperty("interface_type"))
			self._rtcout:RTC_DEBUG("interface_types: "..
								 StringUtil.flatten(self._consumerTypes))
			return nil
		end

		self._rtcout:RTC_DEBUG("interface_type: "..prop:getProperty("interface_type"))
		local consumer = OutPortConsumerFactory:instance():createObject(prop:getProperty("interface_type"))

		if consumer ~= nil then
			self._rtcout:RTC_DEBUG("consumer created")
			consumer:init(prop:getNode("consumer"))

			if not consumer:subscribeInterface(cprof.properties) then
				self._rtcout:RTC_ERROR("interface subscription failed.")
				OutPortConsumerFactory:instance():deleteObject(consumer)
				return nil
			end
			return consumer
		end

		self._rtcout:RTC_ERROR("consumer creation failed")
		return nil
	end

	function obj:getConnectorById(id)
		self._rtcout:RTC_TRACE("getConnectorById(id = "..id..")")

		for i, con in ipairs(self._connectors) do
			if id == con:id() then
				return con
			end
		end

		self._rtcout:RTC_WARN("ConnectorProfile with the id("..id..") not found.")
		return nil
	end

	function obj:unsubscribeInterfaces(connector_profile)
	    self._rtcout:RTC_TRACE("unsubscribeInterfaces()")

		local id = connector_profile.connector_id
		self._rtcout:RTC_PARANOID("connector_id: "..id)

		for i, con in ipairs(self._connectors) do
			if id == con:id() then
				con:deactivate()
				con:disconnect()
				self._connectors[i] = nil
				self._rtcout:RTC_TRACE("delete connector: "..id)
				return
			end
		end


		self._rtcout:RTC_ERROR("specified connector not found: "..id)
	end

	function obj:activateInterfaces()
		self._rtcout:RTC_TRACE("activateInterfaces()")
		for i, con in ipairs(self._connectors) do
			con:activate()
			self._rtcout:RTC_DEBUG("activate connector: "..
								con:name().." "..con:id())
		end
	end

	function obj:deactivateInterfaces()
		self._rtcout:RTC_TRACE("deactivateInterfaces()")
		for i, con in ipairs(self._connectors) do
			con:deactivate()
			self._rtcout:RTC_DEBUG("deactivate connector: "..
								con:name().." "..con:id())
		end
	end

	return obj
end





return InPortBase
