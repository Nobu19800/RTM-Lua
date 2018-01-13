--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local RTCUtil= {}
_G["openrtm.RTCUtil"] = RTCUtil


local oil = require "oil"


RTCUtil.newproxy = function(orb, ior, idl)
	if oil.VERSION == "OiL 0.4 beta" then
		return orb:newproxy(ior,idl)
	elseif oil.VERSION == "OiL 0.5" then
		return orb:newproxy(ior,nil,idl)
	end
	return nil
end

RTCUtil.getReference = function(orb, servant, idl)
	if oil.VERSION == "OiL 0.4 beta" then
		local ior = orb:tostring(servant)
		return RTCUtil.newproxy(orb, ior, idl)
	elseif oil.VERSION == "OiL 0.5" then
		return servant
	end
	return nil
end



return RTCUtil
