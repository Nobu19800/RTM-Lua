---------------------------------
--! @file ManagerServant.lua
--! @brief マネージャサーバント定義
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ManagerServant= {}
--_G["openrtm.ManagerServant"] = ManagerServant

local StringUtil = require "openrtm.StringUtil"
local NVUtil = require "openrtm.NVUtil"
local oil = require "oil"
local RTCUtil = require "openrtm.RTCUtil"
local Properties = require "openrtm.Properties"



ManagerServant.CompParam = {}
ManagerServant.CompParam.prof_list = {
				"RTC",
				"vendor",
				"category",
				"implementation_id",
				"language",
				"version"
				}

-- RTCのパラメータ格納オブジェクト初期化
-- @param module_name RTC名、オプション
-- @return RTCのパラメータ格納オブジェクト
ManagerServant.CompParam.new = function(module_name)
	local obj = {}
	module_name = StringUtil.split(module_name, "?")[1]
	local param_list = StringUtil.split(module_name, ":")
	if #param_list < #ManagerServant.CompParam.prof_list then
		obj._type = "RTC"
		obj._vendor = ""
		obj._category = ""
		obj._impl_id = module_name
		obj._language = "Lua"
		obj._version = ""
	else
		obj._type = param_list[1]
		obj._vendor = param_list[2]
		obj._category = param_list[3]
		obj._impl_id = param_list[4]
		if param_list[5] then
			obj._language = param_list[5]
		else
			obj._language = "Lua"
		end
		obj._version = param_list[6]
	end
	return obj
end

-- マネージャサーバント初期化
-- @return マネージャサーバント
ManagerServant.new = function()
	local obj = {}

	-- オブジェクトリファレンス初期化
	-- INSマネージャへの登録
	-- @return true：登録成功、false：登録失敗
	function obj:createINSManager()
		local success, exception = oil.pcall(
			function()
				--print(self._mgr:getConfig())
				local id = self._mgr:getConfig():getProperty("manager.name")
				self._svr = self._mgr:getORB():newservant(self, id, "IDL:RTM/Manager:1.0")
				self._objref = RTCUtil.getReference(self._mgr:getORB(), self._svr, "IDL:RTM/Manager:1.0")
				--print(str)
				--print(self._objref:_non_existent())
			end)
		if not success then
			self._rtcout:RTC_DEBUG(exception)
			return false
		end
		return true
	end

	function obj:exit()
		for k,master in ipairs(self._masters) do
			master:remove_slave_manager(self._objref)
		end
		self._masters = {}
		for k,slave in ipairs(self._slaves) do
			slave:remove_master_manager(self._objref)
		end
		self._slaves = {}

		self._mgr:getORB():deactivate(self._svr)

	end

	-- アドレスからマネージャを検索
	-- @param host_port アドレス、ポート番号
	-- @return マネージャ
	function obj:findManager(host_port)
		return oil.corba.idl.null
	end

	-- マスターマネージャを追加する
	-- @param mgr マネージャ
	-- @return リターンコード
	function obj:add_master_manager(mgr)
		return self._ReturnCode_t.RTC_OK
	end
	-- スレーブマネージャを追加する
	-- @param mgr マネージャ
	-- @return リターンコード
	function obj:add_slave_manager(mgr)
		return self._ReturnCode_t.RTC_OK
	end

	-- オブジェクトリファレンス取得
	-- @return オブジェクトリファレンス
	function obj:getObjRef()
		return self._objref
	end

	-- モジュールのロード
	-- @param pathname ファイルパス
	-- @param initfunc ファクトリ登録関数
	-- @return リターンコード
	function obj:load_module(pathname, initfunc)
		self._rtcout:RTC_TRACE("ManagerServant::load_module("..pathname..", "..initfunc..")")
		self._mgr:load(pathname, initfunc)
		return self._ReturnCode_t.RTC_OK
	end

	-- モジュールのアンロード
	-- @param pathname ファイルパス
	-- @return リターンコード
	function obj:unload_module(pathname)
		self._rtcout:RTC_TRACE("ManagerServant::unload_module("..pathname..")")
		self._mgr:unload(pathname)
		return self._ReturnCode_t.RTC_OK
	end

	-- ロード可能モジュール一覧取得
	-- @return ロード可能モジュール一覧
	function obj:get_loadable_modules()
		return {}
	end

	-- ロード済みモジュール一覧取得
	-- @return ロード可能モジュール一覧
	function obj:get_loaded_modules()
		return {}
	end

	-- ファクトリプロファイル一覧取得
	-- @return ファクトリプロファイル一覧
	function obj:get_factory_profiles()
		return {}
	end

	function obj:findManagerByName(manager_name)
		return oil.corba.idl.null
	end

	function obj:findManager(host_port)
		return oil.corba.idl.null
	end


	function obj:getParameterByModulename(param_name, module_name)
		local arg = module_name[1]
		local pos0, c = string.find(arg, "&"..param_name.."=")
		local pos1, c = string.find(arg, "?"..param_name.."=")

		if pos0 == nil and pos1 == nil then
			return ""
		end
		local pos = 0
		if pos0 == nil then
			pos = pos1
		else
			pos = pos0
		end


		local paramstr = ""
		local endpos, c = string.find(string.sub(arg,pos+1), '&')
		if endpos == nil then
			endpos = string.find(string.sub(arg,pos+1), '?')
			if endpos == nil then
				paramstr = string.sub(arg, pos + 1)
			else
				paramstr = string.sub(arg, pos + 1, endpos)
			end
		else
			paramstr = string.sub(arg, pos + 1, endpos)
		end
		self._rtcout:RTC_VERBOSE(param_name.." arg: "..paramstr)

		local eqpos, c = string.find(paramstr, "=")
		if eqpos == nil then
			eqpos = 0
		end

		paramstr = string.sub(paramstr, eqpos + 1)

		self._rtcout:RTC_DEBUG(param_name.." is "..paramstr)
		if endpos == nil then
			arg = string.sub(arg, 1, pos-1)
		else
			arg = string.sub(arg,1,pos-1)..string.sub(arg, endpos)
		end

		module_name[1] = arg

		return paramstr
	end

	function obj:createComponentByManagerName(module_name)
		local arg = module_name
		local tmp = {arg}
		local mgrstr = self:getParameterByModulename("manager_name",tmp)
		local arg = tmp[1]
		if mgrstr == "" then
			return oil.corba.idl.null
		end

		local mgrobj = oil.corba.idl.null
		if mgrstr ~= "manager_%p" then
			mgrobj = self:findManagerByName(mgrstr)
		end


		local comp_param = ManagerServant.CompParam.new(arg)
		if mgrobj == oil.corba.idl.null then
			local config = self._mgr:getConfig()
			local rtcd_cmd = config:getProperty("manager.modules."..comp_param:language()..".manager_cmd")
			if rtcd_cmd == "" then
				rtcd_cmd = "rtcd_lua"
			end
			local load_path = config:getProperty("manager.modules.load_path")
			local load_path_language = config:getProperty("manager.modules."..comp_param:language()..".load_path")
			load_path = load_path..","..load_path_language
			local cmd = rtcd_cmd
			cmd = cmd.." -o ".."manager.is_master:NO"
			cmd = cmd.." -o ".."manager.corba_servant:YES"
			cmd = cmd.." -o ".."corba.master_manager:"..config:getProperty("corba.master_manager")
			cmd = cmd.." -o ".."manager.name:"..config:getProperty("manager.name")
			cmd = cmd.." -o ".."manager.instance_name:"..mgrstr
			cmd = cmd.." -o ".."\"manager.modules.load_path:"..load_path.."\""
			cmd = cmd.." -o ".."manager.supported_languages:"..comp_param:language()
			cmd = cmd.." -o ".."manager.shutdown_auto:NO"

			self._rtcout:RTC_DEBUG("Invoking command: "..cmd..".")

			local slaves_names = {}
			local regex = 'manager_%d.*'
			if mgrstr == "manager_%p" then
				for k, slave in pairs(self._slaves) do
					local success, exception = oil.pcall(
						function()
							local prof = slave:get_configuration()
							local prop = Properties.new()
							NVUtil.copyToProperties(prop, prof)
							local name = prop:getProperty("manager.instance_name")
							if string.match(name, regex) ~= nil then
								table.insert(slaves_names, name)
							end
					end)
					if not success then
						self._rtcout:RTC_ERROR("Unknown exception cought.")
						self._rtcout:RTC_DEBUG(exception)
						self._slaves:remove(slave)
					end
				end
			end

			local ret = os.execute(cmd)

			oil.tasks:suspend(0.01)
			local count = 0
			local t0_ = os.clock()
			while mgrobj == oil.corba.idl.null do
				if mgrstr == "manager_%p" then
					mgrobj = self:findManager(mgrstr)
					for k, slave in pairs(self._slaves) do
						local success, exception = oil.pcall(
							function()
								local prof = slave.get_configuration()
								local prop = OpenRTM_aist.Properties()
								NVUtil.copyToProperties(prop, prof)
								local name = prop.getProperty("manager.instance_name")

								if string.match(name, regex) ~= nil and not StringUtil.includes(slaves_names, name) then
									mgrobj = slave
								end
						end)
						if not success then
							self._rtcout:RTC_ERROR("Unknown exception cought.")
							self._rtcout:RTC_DEBUG(exception)
							self._slaves:remove(slave)
						end
					end
				else
					mgrobj = self:findManagerByName(mgrstr)
				end

				count = count+1
				if count > 1000 then
					break
				end
				local t1_ = os.clock()
				if (t1_ - t0_) > 10.0 and count > 10 then
					break
				end
				oil.tasks:suspend(0.01)

			end

		end
		if mgrobj == oil.corba.idl.null then
			self._rtcout:RTC_WARN("Manager cannot be found.")
			return oil.corba.idl.null
		end
		self._rtcout:RTC_DEBUG("Creating component on "..mgrstr)
		self._rtcout:RTC_DEBUG("arg: "..arg)
		local rtobj = oil.corba.idl.null
		local success, exception = oil.pcall(
			function()
				rtobj = mgrobj.create_component(arg)
				self._rtcout.RTC_DEBUG("Component created "..arg)
			end)
		if not success then
			self._rtcout.RTC_DEBUG("Exception was caught while creating component.")
			self._rtcout.RTC_ERROR(exception)
			return oil.corba.idl.null
		end
		return rtobj
	end

	function obj:createComponentByAddress(module_name)
		local arg = module_name
		local tmp = {arg}
		local mgrstr = self:getParameterByModulename("manager_address",tmp)
		local arg = tmp[1]
		if mgrstr == "" then
			return oil.corba.idl.null
		end

		local mgrvstr = StringUtil.split(mgrstr, ":")
		if #mgrvstr ~= 2 then
			self._rtcout:RTC_WARN("Invalid manager address: "..mgrstr)
			return oil.corba.idl.null
		end
		local mgrobj = self:findManager(mgrstr)
		local comp_param = ManagerServant.CompParam.new(arg)
		if mgrobj == oil.corba.idl.null then
			local config = self._mgr:getConfig()
			local rtcd_cmd = config:getProperty("manager.modules."..comp_param:language()..".manager_cmd")
			if rtcd_cmd == "" then
				rtcd_cmd = "rtcd_lua"
			end
			local load_path = config:getProperty("manager.modules.load_path")
			local load_path_language = config:getProperty("manager.modules."..comp_param:language()..".load_path")
			load_path = load_path..","..load_path_language
			local cmd = rtcd_cmd
			cmd = cmd.." -o corba.master_manager:"
			cmd = cmd..mgrstr
			cmd = cmd.." -o \"manager.modules.load_path:"
			cmd = cmd..load_path + "\""
			cmd = cmd.." -d "

			self._rtcout:RTC_DEBUG("Invoking command: "..cmd..".")
			local ret = os.execute(cmd)
			oil.tasks:suspend(0.01)
			local count = 0
			local t0_ = os.clock()
			while mgrobj == oil.corba.idl.null do
				mgrobj = self:findManager(mgrstr)
				count = count+1
				if count > 1000 then
					break
				end
				local t1_ = os.clock()
				if (t1_ - t0_) > 10.0 and count > 10 then
					break
				end
				oil.tasks:suspend(0.01)

			end

		end
		if mgrobj == oil.corba.idl.null then
			self._rtcout:RTC_WARN("Manager cannot be found.")
			return oil.corba.idl.null
		end
		self._rtcout:RTC_DEBUG("Creating component on "..mgrstr)
		self._rtcout:RTC_DEBUG("arg: "..arg)
		local rtobj = oil.corba.idl.null
		local success, exception = oil.pcall(
			function()
				rtobj = mgrobj.create_component(arg)
				self._rtcout.RTC_DEBUG("Component created "..arg)
			end)
		if not success then
			self._rtcout.RTC_DEBUG("Exception was caught while creating component.")
			self._rtcout.RTC_ERROR(exception)
			return oil.corba.idl.null
		end
		return rtobj
	end

	-- RTC生成
	-- @param module_name RTC名、オプション(RTC?param1=xxx&param2=yyy)
	-- @return RTC
	function obj:create_component(module_name)
		self._rtcout:RTC_TRACE("create_component("..module_name..")")
		local rtc = self:createComponentByAddress(module_name)
		if rtc ~= oil.corba.idl.null then
			return rtc
		end
		rtc = self:createComponentByManagerName(module_name)
		if rtc ~= oil.corba.idl.null then
			return rtc
		end
		local tmp = {module_name}
		self:getParameterByModulename("manager_address",tmp)
		module_name = tmp[1]

		local comp_param = ManagerServant.CompParam.new(module_name)

		if self._isMaster then

			for k, slave in ipairs(self._slaves) do
				local success, exception = oil.pcall(
					function()
						local prof = slave:get_configuration()
						local prop = Properties.new()
						NVUtil.copyToProperties(prop, prof)
						local slave_lang = prop.getProperty("manager.language")
						if slave_lang == comp_param:language() then
							rtc = slave:create_component(module_name)
						end
				end)
				if not success then
					self._rtcout:RTC_ERROR("Unknown exception cought.")
					self._rtcout:RTC_DEBUG(exception)
					self._slaves:remove(slave)
				end
				if rtc ~= oil.corba.idl.null then
					return rtc
				end
			end

			if manager_name == "" then
				module_name = module_name + "&manager_name=manager_%p"
				rtc = self:createComponentByManagerName(module_name)
				return rtc
			end
		else
			--print(module_name)
			rtc = self._mgr:createComponent(module_name)
			if rtc ~= nil then
				return rtc:getObjRef()
			end
		end

		return oil.corba.idl.null
	end

	-- RTC削除
	-- @param instance_name インスタンス名
	-- @return リターンコード
	function obj:delete_component(instance_name)
		self._rtcout:RTC_TRACE("delete_component("..instance_name..")")
		local comp_ = self._mgr:getComponent(instance_name)
		if comp_ == nil then
			self._rtcout:RTC_WARN("No such component exists: "..instance_name)
			return self._ReturnCode_t.BAD_PARAMETER
		end

		local success, exception = oil.pcall(
			function()
				comp_:exit()
			end)
		if not success then
			self._rtcout:RTC_ERROR("Unknown exception was raised, when RTC was finalized.")
			return self._ReturnCode_t.RTC_ERROR
		end

		return self._ReturnCode_t.RTC_OK
	end

	-- RTC一覧取得
	-- @return RTC一覧
	function obj:get_components()
		self._rtcout:RTC_TRACE("get_components()")


		local rtcs = self._mgr:getComponents()
		local crtcs = {}


		for i, rtc in ipairs(rtcs) do
			table.insert(crtcs, rtc:getObjRef())
		end

		return crtcs
	end

	-- RTCのプロファイル一覧取得
	-- @return RTCのプロファイル一覧
	function obj:get_component_profiles()
		local rtcs = self._mgr:getComponents()
		local cprofs = {}

		for i, rtc in ipairs(rtcs) do
			table.insert(cprofs, rtc:get_component_profile())
		end
		return cprofs

	end

	-- マネージャのプロファイル取得
	-- @return プロファイル
	function obj:get_profile()
		self._rtcout:RTC_TRACE("get_profile()")
		local prof = {properties={}}
		NVUtil.copyFromProperties(prof.properties, self._mgr:getConfig():getNode("manager"))

		return prof
	end

	-- マネージャのコンフィギュレーション取得
	-- @return コンフィギュレーション
	function obj:get_configuration()
		self._rtcout:RTC_TRACE("get_configuration()")
		local nvlist = {}
		NVUtil.copyFromProperties(nvlist, self._mgr:getConfig())
		return nvlist
	end

	-- マネージャのコンフィギュレーション設定
	-- @param name キー
	-- @param value 値
	-- @return リターンコード
	function obj:set_configuration(name, value)
		self._rtcout:RTC_TRACE("set_configuration(name = "..name..", value = "..value..")")
		self._mgr:getConfig():setProperty(name, value)
		return self._ReturnCode_t.RTC_OK
	end

	-- マスターマネージャかスレーブマネージャかの確認
	-- @return true：マスターマネージャ、false：スレーブマネージャ
	function obj:is_master()
		local ret = ""
		if self._isMaster then
			ret = "YES"
		else
			ret = "NO"
		end
		self._rtcout:RTC_TRACE("is_master(): "..ret)
		return self._isMaster
	end

	-- マスターマネージャ一覧取得
	-- @return マスターマネージャ一覧
	function obj:get_master_managers()
		self._rtcout:RTC_TRACE("get_master_managers()")
		return self._masters
	end


	-- マスターマネージャ削除
	-- @param mgr マネージャ
	-- @return リターンコード
	function obj:remove_master_manager(mgr)
		return self._ReturnCode_t.PRECONDITION_NOT_MET
	end

	-- スレーブマネージャ一覧取得
	-- @return スレーブマネージャ一覧
	function obj:get_slave_managers()
		self._rtcout:RTC_TRACE("get_slave_managers(), "..#self._slaves.." slaves")
		return self._slaves
	end


	-- スレーブマネージャ削除
	-- @param mgr マネージャ
	-- @return リターンコード
	function obj:remove_slave_manager(mgr)
		return self._ReturnCode_t.PRECONDITION_NOT_MET
	end

	-- マネージャのコピー作成
	-- @return リターンコード
	function obj:fork()
		return self._ReturnCode_t.PRECONDITION_NOT_MET
	end

	-- マネージャ終了
	-- @return リターンコード
	function obj:shutdown()
		return self._ReturnCode_t.PRECONDITION_NOT_MET
	end

	-- マネージャ再起動
	-- @return リターンコード
	function obj:restart()
		return self._ReturnCode_t.PRECONDITION_NOT_MET
	end

	-- RTCのオブジェクトリファレンス取得
	-- 未実装
	-- @param name
	-- @return
	function obj:get_service(name)
		return oil.corba.idl.null
	end

	local Manager = require "openrtm.Manager"
	obj._mgr    = Manager:instance()
	obj._ReturnCode_t = obj._mgr:getORB().types:lookup("::RTC::ReturnCode_t").labelvalue

    obj._owner  = oil.corba.idl.null
    obj._rtcout = obj._mgr:getLogbuf("ManagerServant")
    obj._isMaster = false
    obj._masters = {}
    obj._slaves = {}

	local config = obj._mgr:getConfig()

    obj._objref = oil.corba.idl.null


	if not obj:createINSManager() then
		obj._rtcout:RTC_WARN("Manager CORBA servant creation failed.")
		return obj
	end



    obj._rtcout:RTC_TRACE("Manager CORBA servant was successfully created.")

    if StringUtil.toBool(config:getProperty("manager.is_master"), "YES", "NO", true) then
		obj._rtcout:RTC_TRACE("This manager is master.")
		obj._isMaster = true
		return obj
    else
		obj._rtcout:RTC_TRACE("This manager is slave.")
		local success, exception = oil.pcall(
			function()
				local owner = obj:findManager(config:getProperty("corba.master_manager"))
				if owner == oil.corba.idl.null then
					obj._rtcout:RTC_INFO("Master manager not found")
					return
				end
				obj:add_master_manager(owner)
				owner:add_slave_manager(obj._objref)
		end)
		if not success then
			obj._rtcout:RTC_ERROR("Unknown exception cought.")
			obj._rtcout:RTC_ERROR(exception)
		end
    end

	return obj
end

return ManagerServant
