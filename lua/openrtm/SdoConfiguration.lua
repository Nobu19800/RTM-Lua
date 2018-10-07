---------------------------------
--! @file SdoConfiguration.lua
--! @brief コンフィギュレーション操作クラス定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local SdoConfiguration= {}
--_G["openrtm.SdoConfiguration"] = SdoConfiguration

local oil = require "oil"
local NVUtil = require "openrtm.NVUtil"
local Properties = require "openrtm.Properties"
local RTCUtil = require "openrtm.RTCUtil"
local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"

SdoConfiguration.Configuration_impl = {}


-- プロパティからコンフィギュレーションセットに変換
-- @param conf コンフィギュレーションセット
-- @param prop プロパティ
local toConfigurationSet = function(conf, prop)
	conf.description = prop:getProperty("description")
	conf.id = prop:getName()
	--print(prop)
	NVUtil.copyFromProperties(conf.configuration_data, prop)
end

-- コンフィギュレーションセットからプロパティに変換
-- @param prop プロパティ
-- @param conf コンフィギュレーションセット
local toProperties = function(prop, conf)
	NVUtil.copyToProperties(prop, conf.configuration_data)
end

-- コンフィギュレーション操作オブジェクト初期化
-- @param configAdmin コンフィギュレーション管理オブジェクト
-- @param sdoServiceAdmin SDOサービス管理オブジェクト
-- @return コンフィギュレーション操作オブジェクト
SdoConfiguration.Configuration_impl.new = function(configAdmin, sdoServiceAdmin)
	local obj = {}

	obj._deviceProfile = {device_type="",manufacturer="",model="",version="",properties={}}
	obj._serviceProfiles = {}
	obj._parameters = {}
	obj._configsets = configAdmin
	obj._sdoservice = sdoServiceAdmin

	obj._organizations = {}




	local Manager = require "openrtm.Manager"
	obj._orb = Manager:instance():getORB()
	obj._svr = obj._orb:newservant(obj, nil, "IDL:org.omg/SDOPackage/Configuration:1.0")
	obj._objref = RTCUtil.getReference(obj._orb, obj._svr, "IDL:org.omg/SDOPackage/Configuration:1.0")

	obj._rtcout = Manager:instance():getLogbuf("rtobject.sdo_config")


	-- オブジェクトリファレンス取得
	-- @return オブジェクトリファレンス
	function obj:getObjRef()
		return self._objref
	end

	-- オブジェクトリファレンスの非アクティブ化	
	function obj:deactivate()
		local Manager = require "openrtm.Manager"
		Manager:instance():getORB():deactivate(self._svr)
	end


	-- コンフィギュレーションセット取得
	-- @param config_id コンフィギュレーションセットのID
	-- @return コンフィギュレーションセット
	function obj:get_configuration_set(config_id)
		self._rtcout:RTC_TRACE("get_configuration_set("..config_id..")")
		if config_id == "" then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
					description="ID is empty"
				})
		end
		
		if not self._configsets:haveConfig(config_id) then
			self._rtcout:RTC_ERROR("No such ConfigurationSet")
			error(self._orb:newexcept{"SDOPackage::InternalError",
					description="No such ConfigurationSet"
				})
		end



		local configset = self._configsets:getConfigurationSet(config_id)


		local config = {id="",description="",configuration_data={}}
		toConfigurationSet(config, configset)
		return config
	end

	-- アクティブなコンフィギュレーションセット取得
	-- @return コンフィギュレーションセット
	function obj:get_active_configuration_set()
		self._rtcout:RTC_TRACE("get_active_configuration_set()")
		if not self._configsets:isActive() then
			error(self._orb:newexcept{"SDOPackage::NotAvailable",
					description="NotAvailable: Configuration.get_active_configuration_set()"
			})
		end



		local config = {id="",description="",configuration_data={}}
		toConfigurationSet(config, self._configsets:getActiveConfigurationSet())
		return config
	end

	-- 指定のコンフィギュレーションセットをアクティブにする
	-- @param config_id コンフィギュレーションセットのID
	-- @return true：アクティブ化成功
	function obj:activate_configuration_set(config_id)
		self._rtcout:RTC_TRACE("activate_configuration_set("..config_id..")")
		if config_id == "" then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
					description="ID is empty."
			})
		end

		if self._configsets:activateConfigurationSet(config_id) then
			return true
		else
			error(self._orb:newexcept{"SDOPackage::InternalError",
					description="Configuration.activate_configuration_set()."
			})
		end
	end

	-- コンフィギュレーションセットの設定
	-- @param configuration_set コンフィギュレーションセット
	-- @return true：設定成功、false：設定失敗
	function obj:set_configuration_set_values(configuration_set)
		self._rtcout:RTC_TRACE("set_configuration_set_values()")
		if configuration_set == nil or configuration_set.id == "" then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
					description="ID is empty."
			})
		end

		local ret = nil
		local success, exception = oil.pcall(
			function()
				conf = Properties.new({key=configuration_set.id})
				toProperties(conf, configuration_set)

				ret = self._configsets:setConfigurationSetValues(conf)
		end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			error(self._orb:newexcept{"SDOPackage::InternalError",
					description="Configuration::set_configuration_set_values()"
			})
		end
		return ret
	end

	-- デバイスプロファイル設定
	-- @param dProfile デバイスプロファイル
	-- @return true：設定成功
	function obj:set_device_profile(dProfile)
		self._rtcout:RTC_TRACE("set_device_profile()")
		if dProfile == nil then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
						description="dProfile is empty."
				})
		end
		self._deviceProfile = dProfile
		return true
	end

	-- サービスプロファイル追加
	-- @param sProfile サービスプロファイル
	-- @return true：追加成功
	function obj:add_service_profile(sProfile)
		self._rtcout:RTC_TRACE("add_service_profile()")
		if sProfile == nil then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
					description="sProfile is empty."
			})
		end
		local ret = false
		local success, exception = oil.pcall(
			function()
				ret = self._sdoservice:addSdoServiceConsumer(sProfile)
		end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			error(self._orb:newexcept{"SDOPackage::InternalError",
					description="Configuration.add_service_profile"
			})
		end
		return ret
	end
	
	-- 構成オブジェクト追加
	-- @param org 構成オブジェクト
	-- @return true：追加成功
	function obj:add_organization(org)
		self._rtcout:RTC_TRACE("add_organization()")
		if org == nil then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
						description="org is empty."
				})
		end
		table.insert(self._organizations, org)
		return true
	end

	-- サービスプロファイル削除
	-- @param id_ ID
	-- @return true：削除成功
	function obj:remove_service_profile(id_)
		self._rtcout:RTC_TRACE("remove_service_profile("..id_..")")
		if id_ == "" then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
					description="id is empty."
			})
		end
		local ret = false
		local success, exception = oil.pcall(
			function()
				ret = self._sdoservice:removeSdoServiceConsumer(id_)
		end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			error(self._orb:newexcept{"SDOPackage::InternalError",
					description="Configuration.remove_service_profile"
			})
		end
		return ret
	end

	-- オーガナイゼーションオブジェクト削除
	-- @param organization_id ID
	-- @return true：削除成功
	function obj:remove_organization(organization_id)
		self._rtcout:RTC_TRACE("remove_organization("..organization_id..")")
		if organization_id == nil then
			error(self._orb:newexcept{"SDOPackage::InvalidParameter",
						description="id is empty."
				})
		end
		CORBA_SeqUtil.erase_if(self._organizations, self.org_id.new(organization_id))
		
		return true
	end

	-- コンフィギュレーションパラメータ一覧取得
	-- @return コンフィギュレーションパラメータ一覧
	function obj:get_configuration_parameters()
		self._rtcout:RTC_TRACE("get_configuration_parameters()")
		return self._parameters
	end

	-- コンフィギュレーションパラメータのNameValueリスト取得
	-- 未実装
	-- @return NameValueリスト取得
	function obj:get_configuration_parameter_values()
		self._rtcout:RTC_TRACE("get_configuration_parameter_values()")
		local nvlist = {}
		return nvlist
	end

	-- コンフィギュレーションパラメータの設定
	-- 未実装
	-- @param name パラメータ名
	-- @param value 値
	function obj:set_configuration_parameter(name, value)
		self._rtcout:RTC_TRACE("set_configuration_parameter("..name..", value)")
		error(self._orb:newexcept{"SDOPackage::InvalidParameter",
					description="Name/Value is empty."
			})
	end

	-- コンフィギュレーションセット一覧取得
	-- @return コンフィギュレーションセット一覧
	function obj:get_configuration_sets()
		self._rtcout:RTC_TRACE("get_configuration_sets()")
		local config_sets = {}
		local success, exception = oil.pcall(
			function()
				local cf = self._configsets:getConfigurationSets()

				local len_ = #cf

				for i = 1,len_ do
					config_sets[i] = {id="",description="",configuration_data={}}
					toConfigurationSet(config_sets[i], cf[i])
				end
			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
			error(self._orb:newexcept{"SDOPackage::InternalError",
					description="Configuration.get_configuration_sets"
			})
		end

		return config_sets
	end
	
	-- デバイスプロファイル取得
	-- @return デバイスプロファイル
	function obj:getDeviceProfile()
		return self._deviceProfile
	end

	-- SDOサービスプロファイル一覧取得
	-- @return SDOサービスプロファイル一覧
	function obj:getServiceProfiles()
		return self._serviceProfiles
	end

	-- 指定IDのSDOサービスプロファイル取得
	-- @param id 識別子
	-- @return SDOサービスプロファイル
	function obj:getServiceProfile(id)
		local index = CORBA_SeqUtil.find(self._serviceProfiles, self.service_id(id))
		if index < 0 then
			return {id="",
					interface_type="",
					properties={},
					service=oil.corba.idl.null}
		end


		-- 構成オブジェクト一覧取得
		-- @return 構成オブジェクト一覧
		function obj:getOrganizations()
			return self._organizations
		end

		return self._serviceProfiles[index]
	end

	obj.nv_name = {}
	-- NameValueオブジェクトが指定名と一致するかの判定する関数オブジェクト
	-- @param name_ 名前
	-- @return 関数オブジェクト
	obj.nv_name.new = function(name_)
		local obj = {}
		obj._name = tostring(name_)
		-- コールバック関数
		-- @param nv NameValueオブジェクト
		-- @return true：一致
		local call_func = function(self, nv)
			local name_ = tostring(nv.name)
			return (self._name == name_)
		end
		setmetatable(obj, {__call=call_func})
		
		return obj
	end

	obj.service_id = {}
	-- SDOサービスプロファイルが指定名と一致するかの判定する関数オブジェクト
	-- @param name_ 名前
	-- @return 関数オブジェクト
	obj.service_id.new = function(id_)
		local obj = {}
		obj._id = tostring(id_)
		-- コールバック関数
		-- @param s SDOサービスプロファイル
		-- @return true：一致
		local call_func = function(self, s)
			local id_  = tostring(s.id)
			return (self._id == id_)
		end
		setmetatable(obj, {__call=call_func})
		return obj
	end

	obj.org_id = {}
	-- 構成オブジェクトが指定名と一致するかの判定する関数オブジェクト
	-- @param name_ 名前
	-- @return 関数オブジェクト
	obj.org_id.new = function(id_)
		local obj = {}
		obj._id = tostring(id_)
		-- コールバック関数
		-- @param s 構成オブジェクト
		-- @return true：一致
		local call_func = function(self, o)
			local id_  = tostring(o:get_organization_id())
			return (self._id == id_)
		end
		setmetatable(obj, {__call=call_func})
		return obj
	end

	obj.config_id = {}
	-- コンフィギュレーションセットが指定名と一致するかの判定する関数オブジェクト
	-- @param name_ 名前
	-- @return 関数オブジェクト
	obj.config_id.new = function(id_)
		local obj = {}
		obj._id = tostring(id_)
		-- コールバック関数
		-- @param c コンフィギュレーションセット
		-- @return true：一致
		local call_func = function(self, c)
			local id_  = tostring(c.id)
			return (self._id == id_)
		end
		setmetatable(obj, {__call=call_func})
		return obj
	end




	return obj
end




return SdoConfiguration
