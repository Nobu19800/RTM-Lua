--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortBase= {}
_G["openrtm.OutPortBase"] = OutPortBase


local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
local Properties = require "openrtm.Properties"
local ConnectorListener = require "openrtm.ConnectorListener"
local ConnectorListeners = ConnectorListener.ConnectorListeners
local PublisherBase = require "openrtm.PublisherBase"
local PublisherFactory = PublisherBase.PublisherFactory
local PortBase = require "openrtm.PortBase"
local StringUtil = require "openrtm.StringUtil"

local InPortConsumer = require "openrtm.InPortConsumer"
local InPortConsumerFactory = InPortConsumer.InPortConsumerFactory
local OutPortProvider = require "openrtm.OutPortProvider"
local OutPortProviderFactory = OutPortProvider.OutPortProviderFactory

local NVUtil = require "openrtm.NVUtil"

local ConnectorBase = require "openrtm.ConnectorBase"
local ConnectorInfo = ConnectorBase.ConnectorInfo

local OutPortPushConnector = require "openrtm.OutPortPushConnector"
local OutPortPullConnector = require "openrtm.OutPortPullConnector"


OutPortBase.new = function(name, data_type)
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



    obj._rtcout:RTC_DEBUG("setting port.port_type: DataOutPort")
    obj:addProperty("port.port_type", "DataOutPort")

	local _data_type = string.sub(data_type, 3)
	_data_type = string.gsub(_data_type, "::", "/")
	_data_type = "IDL:".._data_type..":1.0"
    obj._rtcout:RTC_DEBUG("setting dataport.data_type: "..tostring(data_type))
    obj:addProperty("dataport.data_type", _data_type)


    factory = PublisherFactory:instance()
    pubs = StringUtil.flatten(factory:getIdentifiers())
	pubs = StringUtil.eraseHeadBlank(pubs)



    obj._rtcout:RTC_DEBUG("available subscription_type: "..pubs)
    obj:addProperty("dataport.subscription_type", pubs)
    obj:addProperty("dataport.io_mode", pubs)

    obj._properties    = Properties.new()
    obj._name          = name
    obj._connectors    = {}
    obj._consumers     = {}
    obj._providerTypes = ""
    obj._consumerTypes = ""
	obj._data_type = data_type


    obj._listeners = ConnectorListeners.new()


	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		self:createRef()

		self._properties:mergeProperties(prop)


		self:configure()


		self:initConsumers()
		self:initProviders()


		num = tonumber(self._properties:getProperty("connection_limit","-1"))
		if num == nil then
			self._rtcout:RTC_ERROR("invalid connection_limit value: "..self._properties:getProperty("connection_limit"))
		end
		self:setConnectionLimit(num)

    end
	function obj:configure()
	end
	function obj:initConsumers()
		self._rtcout:RTC_TRACE("initConsumers()")


		factory = InPortConsumerFactory:instance()
		consumer_types = factory:getIdentifiers()
		--print(StringUtil.flatten(consumer_types))
		self._rtcout:RTC_PARANOID("available InPortConsumer: "..StringUtil.flatten(consumer_types))
		tmp_str = StringUtil.normalize(self._properties:getProperty("consumer_types"))
		--print(self._properties:getProperty("consumer_types"))

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




		if table.maxn(consumer_types) > 0 then
			self._rtcout:RTC_PARANOID("dataflow_type push is supported")
			self:appendProperty("dataport.dataflow_type", "push")
			for i, consumer_type in ipairs(consumer_types) do
				self:appendProperty("dataport.interface_type",consumer_type)
			end
		end



		self._consumerTypes = consumer_types
	end
	function obj:initProviders()
		self._rtcout:RTC_TRACE("initProviders()")


		factory = OutPortProviderFactory:instance()
		provider_types  = factory:getIdentifiers()
		self._rtcout:RTC_PARANOID("available OutPortProviders: "..StringUtil.flatten(provider_types))
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



		if table.maxn(provider_types) > 0 then
			self._rtcout:RTC_PARANOID("dataflow_type pull is supported")
			self:appendProperty("dataport.dataflow_type", "pull")
			for i, provider_type in ipairs(provider_types) do
				self:appendProperty("dataport.interface_type",provider_type)
			end
		end

		self._providerTypes = provider_types
	end


	function obj:subscribeInterfaces(cprof)
		self._rtcout:RTC_TRACE("subscribeInterfaces()")



		--print(self._properties)

		local prop = Properties.new(self._properties)


		local conn_prop = Properties.new()

		NVUtil.copyToProperties(conn_prop, cprof.properties)
		--print(cprof.properties[1].value)


		prop:mergeProperties(conn_prop:getNode("dataport"))


		prop:mergeProperties(conn_prop:getNode("dataport.outport"))


		local dflow_type = StringUtil.normalize(prop:getProperty("dataflow_type"))
		local profile = ConnectorInfo.new(cprof.name,
										cprof.connector_id,
										CORBA_SeqUtil.refToVstring(cprof.ports),
										prop)

		--[[local success, exception = oil.pcall(
			function()
				print(prop)
			end)
		print(exception)]]
		--print(dflow_type)
		--print(prop)
		--print(dflow_type)
		--print(prop)
		if dflow_type == "push" then
			self._rtcout:RTC_PARANOID("dataflow_type = push .... create PushConnector")

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

			local ret = connector:setConnectorInfo(profile)
			if ret == self._ReturnCode_t.RTC_OK then
				self._rtcout:RTC_DEBUG("subscribeInterfaces() successfully finished.")
			end


			return self._ReturnCode_t.RTC_OK
		elseif dflow_type == "pull" then
			conn = self:getConnectorById(cprof.connector_id)
			if conn == nil then
				self._rtcout:RTC_ERROR("specified connector not found: "..cprof.connector_id)
				return self._ReturnCode_t.RTC_ERROR
			end

			ret = conn:setConnectorInfo(profile)

			if ret == self._ReturnCode_t.RTC_OK then
				self._rtcout:RTC_DEBUG("subscribeInterfaces() successfully finished.")
			end

			return ret
		end

		self._rtcout:RTC_ERROR("unsupported dataflow_type")

		return self._ReturnCode_t.BAD_PARAMETER
	end

	function obj:publishInterfaces(cprof)
		self._rtcout:RTC_TRACE("publishInterfaces()")


		retval = self:_publishInterfaces()
		if retval ~= self._ReturnCode_t.RTC_OK then
			return retval
		end


		prop = Properties.new(self._properties)

		conn_prop = Properties.new()

		NVUtil.copyToProperties(conn_prop, cprof.properties)
		prop:mergeProperties(conn_prop:getNode("dataport"))

		prop:mergeProperties(conn_prop:getNode("dataport.outport"))



		dflow_type = StringUtil.normalize(prop:getProperty("dataflow_type"))

		if dflow_type == "push" then
			self._rtcout:RTC_PARANOID("dataflow_type = push .... do nothing")
			return self._ReturnCode_t.RTC_OK

		elseif dflow_type == "pull" then
			self._rtcout:RTC_PARANOID("dataflow_type = pull .... create PullConnector")

			provider = self:createProvider(cprof, prop)
			if provider == nil then
				return self._ReturnCode_t.BAD_PARAMETER
			end


			connector = self:createConnector(cprof, prop, {provider_ = provider})
			if connector == nil then
				return self._ReturnCode_t.RTC_ERROR
			end


			provider:setConnector(connector)

			self._rtcout:RTC_DEBUG("publishInterface() successfully finished.")
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
				if consumer_ ~= nil then
					connector = OutPortPushConnector.new(profile, consumer_,
														self._listeners)

				elseif provider_  ~= nil then
					connector = OutPortPullConnector.new(profile, provider_,
														self._listeners)

				else
					self._rtcout:RTC_ERROR("provider or consumer is not passed. returned 0;")
					ret = nil
					return
				end




				if consumer_ ~= nil then
					self._rtcout:RTC_TRACE("OutPortPushConnector created")
				elseif provider_ ~= nil then
					self._rtcout:RTC_TRACE("OutPortPullConnector created")
				end


				table.insert(self._connectors, connector)
				self._rtcout:RTC_PARANOID("connector push backed: "..table.maxn(self._connectors))
				ret = connector
				return
			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR("OutPortPushConnector creation failed")
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
			self._rtcout:RTC_DEBUG("interface_types: "..
								 StringUtil.flatten(self._providerTypes))
			return nil
		end

		self._rtcout:RTC_DEBUG("interface_type: "..prop:getProperty("interface_type"))
		local provider = OutPortProviderFactory:instance():createObject(prop:getProperty("interface_type"))

		if provider ~= nil then
			self._rtcout:RTC_DEBUG("provider created")
			provider:init(prop:getNode("provider"))

			if not provider:publishInterface(cprof.properties) then
				self._rtcout:RTC_ERROR("publishing interface information error")
				OutPortProviderFactory:instance():deleteObject(provider)
				return nil
			end

			return provider
		end

		self._rtcout:RTC_ERROR("provider creation failed")
		return nil
	end
	function obj:createConsumer(cprof, prop)
		--print(prop:getProperty("interface_type"))
		--print(StringUtil.includes(self._consumerTypes, prop:getProperty("interface_type")))
		if prop:getProperty("interface_type") == "" or
			not StringUtil.includes(self._consumerTypes, prop:getProperty("interface_type")) then
			self._rtcout:RTC_ERROR("no consumer  found")
			self._rtcout:RTC_DEBUG("interface_type:  "..prop:getProperty("interface_type"))
			self._rtcout:RTC_DEBUG("interface_types: "..StringUtil.flatten(self._consumerTypes))
			return nil
		end


		self._rtcout:RTC_DEBUG("interface_type: "..prop:getProperty("interface_type"))
		local consumer = InPortConsumerFactory:instance():createObject(prop:getProperty("interface_type"))


		if consumer ~= nil then
			self._rtcout:RTC_DEBUG("consumer  created")
			consumer:init(prop:getNode("consumer"))

			if not consumer:subscribeInterface(cprof.properties) then
				self._rtcout:RTC_ERROR("interface subscription failed.")
				InPortConsumerFactory:instance():deleteObject(provider)
				return nil
			end
			return consumer
		end

		self._rtcout:RTC_ERROR("provider creation failed")
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


return OutPortBase
