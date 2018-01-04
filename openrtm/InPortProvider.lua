--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortProvider= {}
_G["openrtm.InPortProvider"] = InPortProvider




local GlobalFactory = require "openrtm.GlobalFactory"
local Factory = GlobalFactory.Factory
local NVUtil = require "openrtm.NVUtil"

InPortProvider.new = function()
	local obj = {}
	local Manager = require "openrtm.Manager"
	obj._properties = {}
    obj._interfaceType = ""
    obj._dataflowType = ""
    obj._subscriptionType = ""
    obj._rtcout = Manager:instance():getLogbuf("InPortProvider")
    obj._connector = nil
	function obj:exit()
	end
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
		--for i,v in ipairs(self._properties) do
		--	print(i,v)
		--end

		NVUtil.append(prop, self._properties)
		return true
	end
	function obj:setInterfaceType(interface_type)
		self._rtcout:RTC_TRACE("setInterfaceType("..interface_type..")")
		self._interfaceType = interface_type
	end
	function obj:setDataFlowType(dataflow_type)
		self._rtcout:RTC_TRACE("setDataFlowType("..dataflow_type..")")
		self._dataflowType = dataflow_type
	end
	function obj:setSubscriptionType(subs_type)
		self._rtcout:RTC_TRACE("setSubscriptionType("..subs_type..")")
		self._subscriptionType = subs_type
	end
	function obj:setConnector(connector)
		self._connector = connector
	end

	return obj
end

InPortProvider.InPortProviderFactory = {}
setmetatable(InPortProvider.InPortProviderFactory, {__index=Factory.new()})

function InPortProvider.InPortProviderFactory:instance()
	return self
end


return InPortProvider
