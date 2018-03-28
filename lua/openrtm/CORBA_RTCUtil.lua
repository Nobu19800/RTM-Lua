---------------------------------
--! @file CORBA_RTCUtil.lua
--! @brief RTC操作関数定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CORBA_RTCUtil = {}
--_G["openrtm.CORBA_RTCUtil"] = CORBA_RTCUtil

local oil = require "oil"
local RTObject = require "openrtm.RTObject"
local NVUtil = require "openrtm.NVUtil"


-- RTCから指定IDの実行コンテキストを取得
-- @param rtc RTC
-- @param ec_id
-- @return 実行コンテキスト
CORBA_RTCUtil.get_actual_ec = function(rtc, ec_id)
	local Manager = require "openrtm.Manager"
	local ReturnCode_t  = Manager._ReturnCode_t
	if ec_id == nil then
		ec_id = 0
	end
	if ec_id < 0 then
		return oil.corba.idl.null
	end
	
	
	if rtc == oil.corba.idl.null then
		return oil.corba.idl.null
	end
	
	if ec_id < RTObject.ECOTHER_OFFSET then
		local eclist = rtc:get_owned_contexts()
		if ec_id >= #eclist then
			return oil.corba.idl.null
		end
	
		if eclist[ec_id+1] == nil then
			return oil.corba.idl.null
		end
		return eclist[ec_id+1]
	elseif ec_id >= RTObject.ECOTHER_OFFSET then
		local pec_id = ec_id - OpenRTM_aist.RTObject.ECOTHER_OFFSET
		local eclist = rtc:get_participating_contexts()
		if pec_id >= #eclist then
			return oil.corba.idl.null
		end
		if eclist[pec_id+1] == nil then
			return oil.corba.idl.null
		end
		return eclist[pec_id+1]
	end
end

-- RTCのアクティブ化
-- @param rtc RTC
-- @param ec_id 実行コンテキストのID
-- @return リターンコード
-- RTC_OK：アクティブ化成功
CORBA_RTCUtil.activate = function(rtc, ec_id)
	local Manager = require "openrtm.Manager"
	local ReturnCode_t  = Manager._ReturnCode_t
	if ec_id == nil then
		ec_id = 0
	end
	if rtc == oil.corba.idl.null then
		return ReturnCode_t.BAD_PARAMETER
	end
	local ec = CORBA_RTCUtil.get_actual_ec(rtc, ec_id)
	if ec == oil.corba.idl.null then
		return ReturnCode_t.BAD_PARAMETER
	end
	return ec:activate_component(rtc)
end

-- コネクタプロファイルの生成
-- @param name コネクタ名
-- @param prop_arg 設定
-- データフロー型はデフォルトでpush
-- インターフェース型はデフォルトでdata_service
-- @param port0 ポート0
-- @param port1 ポート1
-- @return コネクタプロファイル
CORBA_RTCUtil.create_connector = function(name, prop_arg, port0, port1)
	local prop = prop_arg
	local conn_prof = {name=name, connector_id="", ports={port0, port1}, properties={}}


	if tostring(prop:getProperty("dataport.dataflow_type")) == "" then
		prop:setProperty("dataport.dataflow_type","push")
	end

 

	if tostring(prop:getProperty("dataport.interface_type")) == "" then
		prop:setProperty("dataport.interface_type","data_service")
	end


	conn_prof.properties = {}
	NVUtil.copyFromProperties(conn_prof.properties, prop)
  
	return conn_prof
end

-- ポートの接続
-- @param name コネクタ名
-- @param prop 設定
-- @param port0 ポート0
-- @param port1 ポート1
-- @return リターンコード
-- RTC_OK：接続成功
CORBA_RTCUtil.connect = function(name, prop, port0, port1)
	local Manager = require "openrtm.Manager"
	local ReturnCode_t  = Manager._ReturnCode_t
	if port0 == oil.corba.idl.null then
		return ReturnCode_t.BAD_PARAMETER
	end
	if port1 == oil.corba.idl.null then
		return ReturnCode_t.BAD_PARAMETER
	end
	if NVUtil._is_equivalent(port0, port1, port0.getPortRef, port1.getPortRef) then
		return ReturnCode_t.BAD_PARAMETER
	end
	local cprof = CORBA_RTCUtil.create_connector(name, prop, port0, port1)
	local ret, prof = port0:connect(cprof)
	--print(ret)
	return ret
end

-- ポート名からポートを取得
-- @param rtc RTC
-- @param port_name ポート名
-- @return ポート
CORBA_RTCUtil.get_port_by_name = function(rtc, port_name)
	if rtc == oil.corba.idl.null then
		return oil.corba.idl.null
	end
	local ports = rtc:get_ports()
	for k,p in ipairs(ports) do
		pp = p:get_port_profile()
		s = pp.name
	
		if port_name == s then
			return p
		end
	end

	return oil.corba.idl.null
end

return CORBA_RTCUtil
