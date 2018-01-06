--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local OutPortProvider= {}
_G["openrtm.OutPortProvider"] = OutPortProvider

GlobalFactory = require "openrtm.GlobalFactory"
Factory = GlobalFactory.Factory
NVUtil = require "openrtm.NVUtil"

OutPortProvider.new = function()
	local obj = {}
	local Manager = require "openrtm.Manager"
	obj._properties = {}
    obj._portType         = ""
    obj._dataType         = ""
    obj._interfaceType    = ""
    obj._dataflowType     = ""
    obj._subscriptionType = ""
    obj._rtcout = Manager:instance():getLogbuf("OutPortProvider")

	function obj:publishInterfaceProfile(prop)
		self._rtcout:RTC_TRACE("publishInterfaceProfile()")
		NVUtil.appendStringValue(prop, "dataport.interface_type",
                                          self._interfaceType)
		NVUtil.append(prop, self._properties)
	end

	function obj:publishInterface(prop)
		self._rtcout:RTC_TRACE("publishInterface()")
		if not NVUtil.isStringValue(prop,
									"dataport.interface_type",
									self._interfaceType) then
			return false
		end

		NVUtil.append(prop, self._properties)
		return true
	end
	function obj:setPortType(port_type)
		self._portType = port_type
	end
	function obj:setDataType(data_type)
		self._dataType = data_type
	end
	function obj:setInterfaceType(interface_type)
		self._interfaceType = interface_type
	end
	function obj:setDataFlowType(dataflow_type)
		self._dataflowType = dataflow_type
	end
	function obj:setSubscriptionType(subs_type)
		self._subscriptionType = subs_type
	end
	return obj
end

OutPortProvider.OutPortProviderFactory = {}
setmetatable(OutPortProvider.OutPortProviderFactory, {__index=Factory.new()})

function OutPortProvider.OutPortProviderFactory:instance()
	return self
end


return OutPortProvider
