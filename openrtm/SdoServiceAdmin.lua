--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SdoServiceAdmin= {}
_G["openrtm.SdoServiceAdmin"] = SdoServiceAdmin

SdoServiceAdmin.new = function(rtobj)
	local obj = {}
	obj._rtobj = rtobj
    obj._consumerTypes = {}
    obj._providers = {}
	obj._consumers = {}
    obj._allConsumerEnabled = false
	function obj:init(rtobj)
	end
	function obj:exit()

		for i, provider in ipairs(self._providers) do
			provider:finalize()
		end

		self._providers = {}


		for i, consumer in ipairs(self._consumers) do
			consumer:finalize()
		end

		self._consumers = {}
    end
	return obj
end


return SdoServiceAdmin
