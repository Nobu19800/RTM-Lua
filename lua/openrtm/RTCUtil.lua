---------------------------------
--! @file RTCUtil.lua
--! @brief RTCヘルパ関数
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local RTCUtil= {}
--_G["openrtm.RTCUtil"] = RTCUtil


local oil = require "oil"

-- オブジェクトのプロキシサーバント生成
-- @param orb ORB
-- @param ior IOR文字列
-- @param idl IDLファイル
-- @return サーバント
RTCUtil.newproxy = function(orb, ior, idl)
	if oil.VERSION == "OiL 0.4 beta" then
		return orb:newproxy(ior,idl)
	elseif oil.VERSION == "OiL 0.5" then
		return orb:newproxy(ior,nil,idl)
	end
	return nil
end

-- オブジェクトリファレンス取得
-- @param orb ORB
-- @param servant サーバント
-- @param idl IDLファイル
-- @return オブジェクトリファレンス
RTCUtil.getReference = function(orb, servant, idl)
	if oil.VERSION == "OiL 0.4 beta" then
		local ior = orb:tostring(servant)
		return RTCUtil.newproxy(orb, ior, idl)
	elseif oil.VERSION == "OiL 0.5" then
		return servant
	end
	return nil
end

RTCUtil.instantiateDataType = function(data_type)
	return {tm={sec=0,nsec=0},data={}}
end



return RTCUtil
