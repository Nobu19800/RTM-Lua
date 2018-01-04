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
    obj._allConsumerEnabled = false
	function obj:init(rtobj)
	end
	return obj
end


return SdoServiceAdmin
