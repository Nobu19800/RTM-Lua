---------------------------------
--! @file InPortCorbaCdrConsumer.lua
--! @brief CorbaCdrインターフェースで通信するInPortConsumer定義
--! 「corba_cdr」のインターフェース型で利用可能
--! OpenRTM.idlのPortServiceインターフェース
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local InPortCorbaCdrConsumer= {}
--_G["openrtm.InPortCorbaCdrConsumer"] = InPortCorbaCdrConsumer


local oil = require "oil"
local InPortConsumer = require "openrtm.InPortConsumer"
local CorbaConsumer = require "openrtm.CorbaConsumer"
local DataPortStatus = require "openrtm.DataPortStatus"
local NVUtil = require "openrtm.NVUtil"

local Factory = require "openrtm.Factory"
local InPortConsumerFactory = InPortConsumer.InPortConsumerFactory
local RTCUtil = require "openrtm.RTCUtil"




-- CorbaCdrインターフェースのInPortConsumerオブジェクト初期化
-- @return CorbaCdrインターフェースのInPortConsumerオブジェクト
InPortCorbaCdrConsumer.new = function()
	local obj = {}
	setmetatable(obj, {__index=InPortConsumer.new()})
	setmetatable(obj, {__index=CorbaConsumer.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("InPortCorbaCdrConsumer")
    obj._properties = nil
	obj._PortStatus = Manager:instance():getORB().types:lookup("::OpenRTM::PortStatus").labelvalue

	-- 初期化時にプロパティ設定
	-- @param prop プロパティ
	function obj:init(prop)
		self._rtcout:RTC_TRACE("init()")
		self._properties = prop
    end

	-- データ送信
	-- @param data 送信データ
	-- @return リターンコード
	-- RTC_OK：putオペレーションが正常終了
	-- CONNECTION_LOST：通信失敗
	function obj:put(data)
		self._rtcout:RTC_PARANOID("put()")
		local ret = DataPortStatus.PORT_OK
		local success, exception = oil.pcall(
			function()
				local inportcdr = self:getObject()
				if inportcdr ~= oil.corba.idl.null then
					ret = NVUtil.getPortStatus(inportcdr:put(data))
					ret = self:convertReturnCode(ret)

					return
				end
				ret = DataPortStatus.CONNECTION_LOST
				return
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			return DataPortStatus.CONNECTION_LOST
		end
		return ret
	end

	-- プロパティにインターフェース情報追加
	-- @param properties プロパティ
	function obj:publishInterfaceProfile(properties)
    end
    -- プロパティからインターフェース情報取得
    -- オブジェクトリファレンスの設定
    -- IOR文字列、もしくはリファレンスを取得
    -- dataport.corba_cdr.inport_ior
    -- dataport.corba_cdr.inport_ref
    -- @param properties プロパティ
    -- @return true：設定成功、false：設定失敗
	function obj:subscribeInterface(properties)
		self._rtcout:RTC_TRACE("subscribeInterface()")
		if self:subscribeFromIor(properties) then
			return true
		end
		if self:subscribeFromRef(properties) then
			return true
		end
		return false
    end
    -- プロパティからインターフェース設定解除
    -- IOR文字列、もしくはリファレンスを取得
    -- dataport.corba_cdr.inport_ior
    -- dataport.corba_cdr.inport_ref
    -- @param properties プロパティ
	function obj:unsubscribeInterface(properties)
		self._rtcout:RTC_TRACE("unsubscribeInterface()")

		if self:unsubscribeFromIor(properties) then
			return
		end

		self:unsubscribeFromRef(properties)
    end

	-- IOR文字列からオブジェクトリファレンス設定
	-- @param properties プロパティ
	-- 以下からIOR文字列取得
	-- dataport.corba_cdr.inport_ior
	-- @return true：設定成功、false：設定失敗
	function obj:subscribeFromIor(properties)
		self._rtcout:RTC_TRACE("subscribeFromIor()")

		local index = NVUtil.find_index(properties,
                                           "dataport.corba_cdr.inport_ior")
		--print(index)
		if index < 0 then
			self._rtcout:RTC_ERROR("inport_ior not found")
			return false
		end

		local ior = ""
		if properties[index] ~= nil then
			ior = NVUtil.any_from_any(properties[index].value)
		end

		if ior == "" then
			self._rtcout:RTC_ERROR("inport_ior has no string")
			return false
		end

		local orb = Manager:instance():getORB()
		local _obj = RTCUtil.newproxy(orb, ior,"IDL:OpenRTM/InPortCdr:1.0")



		if _obj == nil then
			self._rtcout:RTC_ERROR("invalid IOR string has been passed")
			return false
		end

		if not self:setObject(_obj) then
			self._rtcout:RTC_WARN("Setting object to consumer failed.")
			return false
		end

		return true
	end



	-- オブジェクトからオブジェクトリファレンス設定
	-- @param properties プロパティ
	-- 以下からリファレンスを取得
	-- dataport.corba_cdr.inport_ref
	-- @return true：設定成功、false：設定失敗
	function obj:subscribeFromRef(properties)
		self._rtcout:RTC_TRACE("subscribeFromRef()")
		local index = NVUtil.find_index(properties,
										"dataport.corba_cdr.inport_ref")
		if index < 0 then
			self._rtcout:RTC_ERROR("inport_ref not found")
			return false
		end

		local _obj = NVUtil.any_from_any(properties[index].value)

		local orb = Manager:instance():getORB()

		_obj = orb:narrow(_obj, "IDL:OpenRTM/InPortCdr:1.0")


		if _obj == nil then
			self._rtcout:RTC_ERROR("prop[inport_ref] is not objref")
			return false
		end


		if not self:setObject(obj) then
			self._rtcout:RTC_ERROR("Setting object to consumer failed.")
			return false
		end

		return true
	end


	-- IOR文字列からオブジェクトリファレンス設定解除
	-- @param properties プロパティ
	-- 以下からIOR文字列取得
	-- dataport.corba_cdr.inport_ior
	-- @return true：設定解除成功、false：設定解除失敗
	function obj:unsubscribeFromIor(properties)
		self._rtcout:RTC_TRACE("unsubscribeFromIor()")
		local index = NVUtil.find_index(properties,
										"dataport.corba_cdr.inport_ior")
		if index < 0 then
			self._rtcout:RTC_ERROR("inport_ior not found")
			return false
		end


		local ior = NVUtil.any_from_any(properties[index].value)


		if ior == "" then
			self._rtcout:RTC_ERROR("prop[inport_ior] is not string")
			return false
		end

		local orb = Manager:instance():getORB()
		local var = RTCUtil.newproxy(orb, ior,"IDL:OpenRTM/InPortCdr:1.0")

		if not NVUtil._is_equivalent(self:_ptr(true), var, self:_ptr(true).getObjRef, var.getObjRef) then
			self._rtcout:RTC_ERROR("connector property inconsistency")
			return false
		end

		self:releaseObject()
		return true
	end

	-- リファレンスからオブジェクト設定解除
	-- @param properties プロパティ
	-- 以下からリファレンスを取得
	-- dataport.corba_cdr.inport_ref
	-- @return true：設定解除成功、false：設定解除失敗
	function obj:unsubscribeFromRef(properties)
		self._rtcout:RTC_TRACE("unsubscribeFromRef()")
		local index = NVUtil.find_index(properties,
										"dataport.corba_cdr.inport_ref")

		if index < 0 then
			return false
		end


		local _obj = NVUtil.any_from_any(properties[index].value)


		if _obj == nil then
			return false
		end

		local obj_ptr = self:_ptr(true)

		if obj_ptr == nil or not NVUtil._is_equivalent(obj_ptr, _obj, obj_ptr.getObjRef, _obj.getObjRef) then
			return false
		end

		self:releaseObject()
		return true
	end

	-- OpenRTM::PortStatusをデータポートステータスに変換
	function obj:convertReturnCode(ret)
		if ret == self._PortStatus.PORT_OK then
			return DataPortStatus.PORT_OK

		elseif ret == self._PortStatus.PORT_ERROR then
			return DataPortStatus.PORT_ERROR

		elseif ret == self._PortStatus.BUFFER_FULL then
			return DataPortStatus.SEND_FULL

		elseif ret == self._PortStatus.BUFFER_TIMEOUT then
			return DataPortStatus.SEND_TIMEOUT

		elseif ret == self._PortStatus.UNKNOWN_ERROR then
			return DataPortStatus.UNKNOWN_ERROR

		else
			return DataPortStatus.UNKNOWN_ERROR
		end
	end

	return obj
end

-- InPortCorbaCdrConsumer生成ファクトリ登録関数
InPortCorbaCdrConsumer.Init = function()
	InPortConsumerFactory:instance():addFactory("corba_cdr",
		InPortCorbaCdrConsumer.new,
		Factory.Delete)
end

return InPortCorbaCdrConsumer
