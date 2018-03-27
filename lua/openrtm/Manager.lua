---------------------------------
--! @file Manager.lua
--! @brief RTC管理マネージャ定義
--! ORB初期化、RTCの生成、モジュールのロード、ロガー初期化、ファクトリ初期化等を実行
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]



local Manager= {}
--_G["openrtm.Manager"] = Manager

local oil = require "oil"
local ObjectManager = require "openrtm.ObjectManager"
local Properties = require "openrtm.Properties"
local StringUtil = require "openrtm.StringUtil"
local ManagerConfig = require "openrtm.ManagerConfig"
local SystemLogger = require "openrtm.SystemLogger"
local LogStream = SystemLogger.LogStream
local NumberingPolicyBase = require "openrtm.NumberingPolicyBase"
local NumberingPolicyFactory = NumberingPolicyBase.NumberingPolicyFactory
local ManagerActionListener = require "openrtm.ManagerActionListener"
local ManagerActionListeners = ManagerActionListener.ManagerActionListeners
local ManagerServant = require "openrtm.ManagerServant"
local CompParam = ManagerServant.CompParam
local NamingManager = require "openrtm.NamingManager"
local FactoryInit = require "openrtm.FactoryInit"
local PeriodicExecutionContext = require "openrtm.PeriodicExecutionContext"
local Factory = require "openrtm.Factory"
local FactoryLua = Factory.FactoryLua
local OpenHRPExecutionContext = require "openrtm.OpenHRPExecutionContext"
local LogstreamBase = require "openrtm.LogstreamBase"
local LogstreamFactory = LogstreamBase.LogstreamFactory


-- ORB_Dummy_ENABLEをtrueに設定した場合、
-- oil関連の処理はすべてダミー関数に置き換えられる
if ORB_Dummy_ENABLE == nil then
	ORB_Dummy_ENABLE = false
end

if ORB_Dummy_ENABLE then

	oil.corba = {}
	oil.corba.idl = {}

	oil.newthread = function(obj)
	--obj()
	end
	function oil.tasks:suspend(t)

	end

	ORB_Dummy = {}

	ORB_Dummy.types = {}

	--oil = {}
	oil.main = function(func)
		func()
	end


	function ORB_Dummy.types:lookup(name)
		local ret = {}
		ret.labelvalue = {}
		if name == "::RTC::ReturnCode_t" then
			ret.labelvalue.RTC_OK = 0
			ret.labelvalue.RTC_ERROR = 1
			ret.labelvalue.BAD_PARAMETER = 2
			ret.labelvalue.UNSUPPORTED = 3
			ret.labelvalue.OUT_OF_RESOURCES = 4
			ret.labelvalue.PRECONDITION_NOT_MET = 5
		elseif name == "::RTC::ExecutionKind" then
			ret.labelvalue.PERIODIC = 0
			ret.labelvalue.EVENT_DRIVEN = 1
			ret.labelvalue.OTHER = 2
		elseif name == "::RTC::LifeCycleState" then
			ret.labelvalue.CREATED_STATE = 0
			ret.labelvalue.INACTIVE_STATE = 1
			ret.labelvalue.ACTIVE_STATE = 2
			ret.labelvalue.ERROR_STATE = 3
		elseif name == "::OpenRTM::PortStatus" then
			ret.labelvalue.PORT_OK = 0
			ret.labelvalue.PORT_ERROR = 1
			ret.labelvalue.BUFFER_FULL = 2
			ret.labelvalue.BUFFER_EMPTY = 3
			ret.labelvalue.BUFFER_TIMEOUT = 4
			ret.labelvalue.UNKNOWN_ERROR = 5
		elseif name == "::RTC::PortInterfacePolarity" then
			ret.labelvalue.PROVIDED = 0
			ret.labelvalue.REQUIRED = 1
		end
		return ret
	end

	function ORB_Dummy:newservant(obj, name, idl)
		return obj
	end

	function ORB_Dummy:tostring(ref)
		return ref
	end

	function ORB_Dummy:newencoder()
		local encoder = {}
		encoder.data = 0
		function encoder:put(data, data_type)
			self.data = data
		end
		function encoder:getdata()

			return self.data
		end


		return encoder
	end

	function ORB_Dummy:newdecoder(cdr)
		local decoder = {}
		decoder.cdr = cdr

		function decoder:get(data_type)
			return self.cdr
		end

		return decoder
	end


	function ORB_Dummy:deactivate(object)

	end

	Dummy_NameServer = {}

	Dummy_NameServer.new = function()
		local obj = {}
		function obj:rebind(name_list, obj)
			print("rebind:")
			for i, name in ipairs(name_list) do
				print(name.id, name.kind)
			end
		end

		function obj:unbind(name_list)
			print("unbind:")
			for i, name in ipairs(name_list) do
				print(name.id, name.kind)
			end
		end
		function obj:bind_new_context(name_list)
			for i, name in ipairs(name_list) do
				print(name.id, name.kind)
			end
			return Dummy_NameServer.new()
		end
		function obj:resolve(name_list)
			for i, name in ipairs(name_list) do
				print(name.id, name.kind)
			end
			return Dummy_NameServer.new()
		end
		return obj
	end

	NameServer_dummy = Dummy_NameServer.new()

	Manager.Dummy_InPortCDR = {}
	Dummy_InPortCDR = Manager.Dummy_InPortCDR
	Dummy_InPortCDR.ref = nil
	Dummy_InPortCDR.new = function()
		local obj = {}
		function obj:put(data)
			return Dummy_InPortCDR.ref:put(data)
		end
		return obj
	end



	function ORB_Dummy:newproxy(ref, proxy,idl)
		local ret = ref
		if oil.VERSION == "OiL 0.4 beta" then
			idl = proxy
		end

		if idl == "IDL:omg.org/CosNaming/NamingContext:1.0" then
			ret = NameServer_dummy
		elseif idl == "IDL:openrtm.aist.go.jp/OpenRTM/InPortCdr:1.0" and ref == "IOR:Dummy" then
			ret = Dummy_InPortCDR.new()
		else
		end
		ret._non_existent = function(self)
			return false
		end
		ret._is_equivalent = function(self, other)
			--print(self, other)
			if self._profile ~= nil then
				if self._profile.name ~= nil then
					if self._profile.name == other._profile.name then
						return true
					end
				end
			end
			return (self == other)
		end
		--print("test2:",ret,ref)
		return ret
	end

end


-- インスタンス名一致判定関数オブジェクト初期化
-- @param argv argv.prop：プロパティ、argv._name：インスタンス名
-- @return インスタンス名一致判定関数オブジェクト
local InstanceName = function(argv)
	local obj = {}
	if argv.prop then
		obj._name = argv.prop:getProperty("instance_name")
	elseif argv.factory then
		obj._name = argv.factory:getInstanceName()
	elseif argv.name then
		obj._name = argv.name
	end
	-- インスタンス名一致判定
	-- @param comp RTC
	-- @return true：一致、false：不一致
	local call_func = function(self, comp)
		return (self._name == comp:getInstanceName())
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

-- RTC生成ファクトリ一致判定関数オブジェクトの初期化
-- @param argv argv.name：型名、argv.prop：プロパティ、factory：ファクトリ
local FactoryPredicate = function(argv)
	local obj = {}
	if argv.name then
		obj._vendor = ""
		obj._category = ""
		obj._impleid = argv.name
		obj._version = ""
	elseif argv.prop then
		obj._vendor = argv.prop:getProperty("vendor")
		obj._category = argv.prop:getProperty("category")
		obj._impleid = argv.prop:getProperty("implementation_id")
		--print(obj._impleid)
		obj._version = argv.prop:getProperty("version")
	elseif argv.factory then
		obj._vendor = argv.factory:profile():getProperty("vendor")
		obj._category = argv.factory:profile():getProperty("category")
		obj._impleid = argv.factory:profile():getProperty("implementation_id")
		obj._version = argv.factory:profile():getProperty("version")
	end

	-- RTC生成ファクトリ一致判定関数
	-- @param self 自身のオブジェクト
	-- @param factory ファクトリ
	-- @return true：一致、false：不一致
	local call_func = function(self, factory)
		if self._impleid == "" then
			return false
		end
		local _prop = Properties.new({prop=factory:profile()})
		--print(factory:profile())
		--print(_prop:)
		--print(self._impleid,_prop:getProperty("implementation_id"))
		--print(self._impleid, self._vendor, self._category, self._version)
		--print(_prop:getProperty("implementation_id"), _prop:getProperty("vendor"), _prop:getProperty("category"), _prop:getProperty("implementation_id"))
		if self._impleid ~= _prop:getProperty("implementation_id") then
			return false
		end
		if self._vendor ~= "" and self._vendor ~= _prop:getProperty("vendor") then
			return false
		end
		if self._category  ~= "" and self._category  ~= _prop:getProperty("category") then
			return false
		end
		if self._version  ~= "" and self._version  ~= _prop:getProperty("version") then
			return false
		end

		return true
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

-- EC生成ファクトリ一致判定関数オブジェクトの初期化
-- @param argv argv.name：型名、argv.factory：ファクトリ
-- @return EC生成ファクトリ一致判定関数オブジェクト
local ECFactoryPredicate = function(argv)
	local obj = {}
	if argv.name then
		obj._name  = argv.name
	elseif argv.factory then
		obj._name = argv.factory:name()
	end
	-- EC生成ファクトリ一致判定関数
	-- @param self 自身のオブジェクト
	-- @param factory ファクトリ
	-- @return true：一致、false：不一致
	local call_func = function(self, factory)
		return (self._name == factory:name())
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


-- モジュール一致判定関数オブジェクト初期化
-- @param prop プロパティ
-- @return モジュール一致判定関数オブジェクト
local ModulePredicate = function(prop)
	local obj = {}
	obj._prop  = prop
	-- モジュール一致判定関数
	-- @param self 自身のオブジェクト
	-- @param prop プロパティ
	-- @return true：一致、false：不一致
	local call_func = function(self, prop)
		if self._prop:getProperty("implementation_id") ~= prop:getProperty("implementation_id") then
			return false
		end
		if self._prop:getProperty("vendor") ~= "" and self._prop:getProperty("vendor") ~= prop:getProperty("vendor") then
			return false
		end
		if self._prop:getProperty("category") ~= "" and self._prop:getProperty("category") ~= prop:getProperty("category") then
			return false
		end
		if self._prop:getProperty("version") ~= "" and self._prop:getProperty("version") ~= prop:getProperty("version") then
			return false
		end
		return true
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

local Finalized = {}

-- 終了したRTCを登録するオブジェクト初期化
-- @return 終了したRTCを登録するオブジェクト
Finalized.new = function()
	local obj = {}
	obj.comps = {}
	return obj
end

-- マネージャ初期化
-- 以下の処理を実行
-- オブジェクトマネージャ(RTC、EC)初期化
-- ファクトリ初期化
-- ロガー初期化
-- 実行コンテキスト生成ファクトリ初期化
-- 複合コンポーネント生成ファクトリ初期化
-- マネージャアクションコールバック関数オブジェクト初期化
-- @param argv コマンドライン引数
-- "-a"：マネージャサーバント無効
-- "-f"：設定ファイル指定
-- "-l"：ロードするモジュール指定
-- "-o"：追加のオプション指定
-- "-a"：アドレス、ポート番号指定
-- "-d"：マスターマネージャに設定
function Manager:init(argv)
	if argv == nil then
		argv = {}
	end
	self._initProc = nil
	self._ecs = {}
	self._orb = nil
	self._compManager = ObjectManager.new(InstanceName)
	self._factory = ObjectManager.new(FactoryPredicate)
	self._ecfactory = ObjectManager.new(ECFactoryPredicate)
	self:initManager(argv)
	self:initFactories()
	self:initLogger()
	self:initExecContext()
	self:initComposite()
	self:initTimer()
	self._finalized = Finalized.new()
    self._listeners = ManagerActionListeners.new()
	self._initThread = nil
end




-- マネージャ終了処理開始
function Manager:terminate()

end

-- マネージャ終了
-- RTC全削除
-- ネーミングマネージャ終了
-- ORB終了
-- ロガー終了
function Manager:shutdown()
	--self._listeners.manager_:preShutdown()
	self:shutdownComponents()
	self:shutdownManagerServant()
	self:shutdownNaming()
	self:shutdownORB()
	self:shutdownManager()
	--self._listeners.manager_:postShutdown()
	self:shutdownLogger()
end



function Manager:instance()
	return self
end

-- マネージャ終了まで待機
function Manager:join()

end

-- 初期化時実行関数の設定
-- 指定関数はrunManager関数で実行される
-- @param proc 関数
-- proc(manager)：マネージャを引数とする関数を定義
function Manager:setModuleInitProc(proc)
	self._initProc = proc
end

-- マネージャアクティブ化
function Manager:activateManager()
	return true
end

-- マネージャ実行
-- 以下の処理を実行する
-- ORBの初期化
-- setModuleInitProc関数で指定した関数実行
-- マネージャサーバント初期化
-- ネーミングマネージャ初期化
-- @param no_block true：ノンブロッキングモードで実行、false：この関数でブロックする
-- ブロックモードで実行する場合は、step関数を適宜実行する必要がある
-- また、周期実行コンテキストなどコルーチンで実行する実行コンテキストは使用できない
function Manager:runManager(no_block)
	if no_block == nil then
		no_block = false
	end
	oil.main(function()

		self:initORB()
		if no_block then
			oil.newthread(self._orb.step, self._orb)
		else
			oil.newthread(self._orb.run, self._orb)
		end

		self:initManagerServant()

		self:initNaming()
		--print(self._orb, self._orb.run)

		if self._initProc ~= nil then
			self._initProc(self)
		end
		if self._initThread ~= nil then
			oil.newthread(self._initThread, self)
		end
		--self._orb:run()
	end)
end

-- CORBAの処理を1ステップ進める
-- ブロックモードの場合のみ有効
function Manager:step()
	oil.main(function()
		oil.newthread(self._orb.step, self._orb)
	end)
end

-- モジュールの読み込み
-- @param fname ファイルパス
-- @param initfunc モジュール登録関数名
-- @return リターンコード
function Manager:loadModule(fname, initfunc)
	self._listeners.module_:preLoad(fname, initfunc)
	local success, exception = oil.pcall(
								function()
								end)
	if not success then
		self._rtcout:RTC_ERROR("Unknown error.")
		return self._ReturnCode_t.RTC_ERROR
	end
	return self._ReturnCode_t.RTC_OK
end

-- モジュールのアンロード
-- @param fname ファイルパス
function Manager:unloadModule(fname)

end

-- すべてのモジュールをアンロード
function Manager:unloadAll()

end

-- ロード済みモジュール一覧取得
-- @return ロード済みモジュール一覧
function Manager:getLoadedModules()
	local ret = {}
	return ret
end

-- ロード可能モジュール一覧取得
-- @return ロード可能モジュール一覧
function Manager:getLoadableModules()
	local ret = {}
	return ret
end

-- RTC生成ファクトリ登録
-- @param profile プロファイル
-- 「manager.components.naming_policy」の要素で名前付けポリシーを指定
-- @param new_func 初期化関数
-- @param delete_func 削除関数
-- @return ファクトリ
function Manager:registerFactory(profile, new_func, delete_func)
	--print(profile:getProperty("type_name"))
	self._rtcout:RTC_TRACE("Manager.registerFactory("..profile:getProperty("type_name")..")")
	local policy_name = self._config:getProperty("manager.components.naming_policy","process_unique")
	local policy = NumberingPolicyFactory:instance():createObject(policy_name)
	local factory = FactoryLua.new(profile, new_func, delete_func, policy)
	--print(self._factory.registerObject)
	return self._factory:registerObject(factory)
end

-- RTC生成ファクトリプロファイル一覧取得
-- return RTC生成ファクトリプロファイル一覧
function Manager:getFactoryProfiles()
	local ret = {}
	return ret
end

-- EC生成ファクトリ登録
-- @param profile プロファイル
-- @param new_func 初期化関数
-- @param delete_func 削除関数
-- @return ファクトリ
function Manager:registerECFactory(name, new_func, delete_func)
end

-- RTC生成ファクトリ一覧取得
-- @return RTC生成ファクトリ一覧
function Manager:getModulesFactories()
	local ret = {}
	return ret
end

-- RTC生成
-- @param comp_args RTC名とオプション(RTC?param1=xxx&param2=yyy)
-- RTC名は「RTC:ベンダ名:カテゴリ名:実装ID:言語名:バージョン」で指定
-- オプションで「instance_name」を指定した場合は、指定インスタンス名のRTCを返す
-- @return RTC
-- 以下の場合はnilを返す
-- comp_argsが不正
-- 指定IDのファクトリがない
-- RTCの生成失敗
-- initialize関数がRTC_OK以外を返す
function Manager:createComponent(comp_args)
	self._rtcout:RTC_TRACE("Manager.createComponent("..comp_args..")")
	local comp_prop = Properties.new()
    local comp_id   = Properties.new()
	if not self:procComponentArgs(comp_args, comp_id, comp_prop) then
		return nil
	end
	if comp_prop:getProperty("instance_name") ~= nil then
		comp = self:getComponent(comp_prop:getProperty("instance_name"))
		if comp ~= nil then
			return comp
		end
	end
	--self._listeners.rtclifecycle_:preCreate(comp_args)
	if comp_prop:findNode("exported_ports") then
	end
	--print(comp_id)
	local factory = self._factory:find(comp_id)
	--print(factory)
	if factory == nil then
		self._rtcout:RTC_ERROR("createComponent: Factory not found: "..
			comp_id:getProperty("implementation_id"))
		return nil
	end
	local prop = factory:profile()
	local inherit_prop = {"config.version",
					"openrtm.name",
                    "openrtm.version",
                    "os.name",
                    "os.release",
                    "os.version",
                    "os.arch",
                    "os.hostname",
                    "corba.endpoints",
                    "corba.endpoints_ipv4",
                    "corba.endpoints_ipv6",
                    "corba.id",
                    "exec_cxt.periodic.type",
                    "exec_cxt.periodic.rate",
                    "exec_cxt.event_driven.type",
                    "exec_cxt.sync_transition",
                    "exec_cxt.sync_activation",
                    "exec_cxt.sync_deactivation",
                    "exec_cxt.sync_reset",
                    "exec_cxt.transition_timeout",
                    "exec_cxt.activation_timeout",
                    "exec_cxt.deactivation_timeout",
                    "exec_cxt.reset_timeout",
                    "exec_cxt.cpu_affinity",
                    "logger.enable",
                    "logger.log_level",
                    "naming.enable",
                    "naming.type",
                    "naming.formats",
                    "sdo.service.provider.available_services",
                    "sdo.service.consumer.available_services",
                    "sdo.service.provider.enabled_services",
                    "sdo.service.consumer.enabled_services",
                    "manager.instance_name"}
	local prop_ = prop:getNode("port")
	prop_:mergeProperties(self._config:getNode("port"))
	local comp = factory:create(self)
	--print(comp:getTypeName())
	--print(comp)
	if self._config:getProperty("corba.endpoints_ipv4") == "" then
		self:setEndpointProperty(comp:getObjRef())
	end
	for i, v in pairs(inherit_prop) do
		if self._config:findNode(v) then
			--print(v, self._config:getProperty(v))
			prop:setProperty(v,self._config:getProperty(v))
		end
	end
	if comp == nil then
		self._rtcout:RTC_ERROR("createComponent: RTC creation failed: "..
							comp_id:getProperty("implementation_id"))
		return nil
	end
	self._rtcout:RTC_TRACE("RTC Created: "..comp_id:getProperty("implementation_id"))
	--self._listeners.rtclifecycle_:postCreate(comp)
	prop:mergeProperties(comp_prop)
	--self._listeners.rtclifecycle_:preConfigure(prop)
	self:configureComponent(comp,prop)
	--self._listeners.rtclifecycle_:postConfigure(prop)
	--self._listeners.rtclifecycle_:preInitialize()
	if comp:initialize() ~= self._ReturnCode_t.RTC_OK then
		self._rtcout:RTC_TRACE("RTC initialization failed: "..
                             comp_id:getProperty("implementation_id"))
		self._rtcout:RTC_TRACE(comp_id:getProperty("implementation_id").." was finalized")
		if comp:exit() ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_DEBUG(comp_id:getProperty("implementation_id").." finalization was failed.")
		end
		return nil
	end
	self._rtcout:RTC_TRACE("RTC initialization succeeded: "..
                           comp_id:getProperty("implementation_id"))
    --self._listeners.rtclifecycle_:postInitialize()
    self:registerComponent(comp)
	return comp
end

-- RTCの登録
-- オブジェクトマネージャへの登録
-- ネーミングマネージャへの登録
-- @param comp RTC
-- @return true：登録成功、false：登録失敗
function Manager:registerComponent(comp)
    self._rtcout:RTC_TRACE("Manager.registerComponent("..comp:getInstanceName()..")")

	--print(comp:getInstanceName())
    self._compManager:registerObject(comp)
    local names = comp:getNamingNames()

    --self._listeners.naming_:preBind(comp, names)

	for i, name in ipairs(names) do
		--print(name)
		self._rtcout:RTC_TRACE("Bind name: "..name)
		self._namingManager:bindObject(name, comp)
	end
    --self._listeners.naming_:postBind(comp, names)

    self:publishPorts(comp)
    self:subscribePorts(comp)

    return true
end

-- RTCの登録解除
-- オブジェクトマネージャから登録解除
-- ネーミングマネージャから登録解除
-- @param comp RTC
function Manager:unregisterComponent(comp)
    self._rtcout:RTC_TRACE("Manager.unregisterComponent("..comp:getInstanceName()..")")
    self._compManager:unregisterObject(comp:getInstanceName())
    local names = comp:getNamingNames()

    --self._listeners.naming_:preUnbind(comp, names)
    for i,name in ipairs(names) do
		self._rtcout:RTC_TRACE("Unbind name: "..name)
		self._namingManager:unbindObject(name)
	end
    --self._listeners.naming_:postUnbind(comp, names)
end

-- 実行コンテキスト生成
-- @param ec_args EC名とオプション(EC&param1=xxx&param2=yyy)
-- @return 実行コンテキスト
function Manager:createContext(ec_args)

end

-- RTCの削除
-- @param argv argv.instance_name：インスタンス名、argv.comp：RTC
-- インスタンス名指定の場合はRTCを検索する
function Manager:deleteComponent(argv)
	if argv.instance_name ~= nil then
		local instance_name = argv.instance_name
		self._rtcout.RTC_TRACE("Manager.deleteComponent("..instance_name..")")
		local _comp = self._compManager:find(instance_name)
		if _comp ~= nil then
			self._rtcout:RTC_WARN("RTC "..instance_name.." was not found in manager.")
			return
		end
		self:deleteComponent({comp=_comp})
	elseif argv.comp ~= nil then
		local comp = argv.comp
		self._rtcout:RTC_TRACE("Manager.deleteComponent(RTObject_impl)")

		self:unregisterComponent(comp)

		local comp_id = comp:getProperties()
		local factory = self._factory:find(comp_id)
		--print(comp_id)

		if factory == nil then
			self._rtcout:RTC_DEBUG("Factory not found: "..
                               comp_id:getProperty("implementation_id"))
			return
		else
			self._rtcout:RTC_DEBUG("Factory found: "..
                               comp_id:getProperty("implementation_id"))
			factory:destroy(comp)
		end
		if StringUtil.toBool(self._config:getProperty("manager.shutdown_on_nortcs"), "YES", "NO", true) then
			local comps = self:getComponents()
			print(#comps)
			if #comps == 0 then
				self:shutdown()
			end
		end
	end
end

-- インスタンス名からRTC取得
-- @param instance_name インスタンス名
-- @return RTC
function Manager:getComponent(instance_name)
    self._rtcout:RTC_TRACE("Manager.getComponent("..instance_name..")")
    return self._compManager:find(instance_name)
end

-- マネージャアクションコールバックの登録
-- @param listener コールバック関数オブジェクト
-- @param autoclean 自動削除フラグ
function Manager:addManagerActionListener(listener,autoclean)

end

-- ネージャアクションコールバックの登録解除
-- @param listener コールバック関数オブジェクト
function Manager:removeManagerActionListener(listener)

end

-- モジュールアクションコールバックの登録
-- @param listener コールバック関数オブジェクト
-- @param autoclean 自動削除フラグ
function Manager:addModuleActionListener(listener, autoclean)

end

-- モジュールアクションコールバックの登録解除
-- @param listener コールバック関数オブジェクト
function Manager:removeModuleActionListener(listener)

end

-- RTC状態遷移アクションコールバックの登録
-- @param listener コールバック関数オブジェクト
-- @param autoclean 自動削除フラグ
function Manager:addRtcLifecycleActionListener(listener, autoclean)

end

-- RTC状態遷移アクションコールバックの登録解除
-- @param listener コールバック関数オブジェクト
function Manager:removeRtcLifecycleActionListener(listener)

end

-- ネームサーバーアクションコールバックの登録
-- @param listener コールバック関数オブジェクト
-- @param autoclean 自動削除フラグ
function Manager:addNamingActionListener(listener, autoclean)

end

-- ネームサーバーアクションコールバックの登録解除
-- @param listener コールバック関数オブジェクト
function Manager:removeNamingActionListener(listener)

end

-- ローカルサービスアクションコールバックの登録
-- @param listener コールバック関数オブジェクト
-- @param autoclean 自動削除フラグ
function Manager:addLocalServiceActionListener(listener, autoclean)

end

-- ローカルサービスアクションコールバックの登録解除
-- @param listener コールバック関数オブジェクト
function Manager:removeLocalServiceActionListener(listener)

end

-- ORB取得
-- @return ORB
function Manager:getORB()
	--print(self._rtcout)
	--print(self)
	self._rtcout:RTC_TRACE("Manager.getORB()")
	--print(self._orb)
	return self._orb
end

-- マネージャ初期化
-- @param argv コマンドライン引数
function Manager:initManager(argv)
	local config = ManagerConfig.new(argv)
	self._config = Properties.new()
	config:configure(self._config)
end

function Manager:shutdownManagerServant()
	if self._mgrservant ~= nil then
		self._mgrservant:exit()
		self._mgrservant = nil
	end
end

-- マネージャ終了
function Manager:shutdownManager()

end

-- ロガーストリーム初期化
-- ファイル出力ロガーを初期化する
-- 「logger」の要素にプロパティを設定
-- logger.file_name：ファイル名
function Manager:initLogstreamFile()
	local logprop = self._config:getNode("logger")
	local logstream = LogstreamFactory:instance():createObject("file")
	if logstream == nil then
		return
	end
	if not logstream:init(logprop) then
		logstream = LogstreamFactory:instance():deleteObject(logstream)
	end
	self._rtcout:addLogger(logstream)
end

-- ロガープラグイン初期化
function Manager:initLogstreamPlugins()

end

-- 外部ロガーモジュール初期化
function Manager:initLogstreamOthers()
	local factory = LogstreamFactory:instance()
    local pp = self._config:getNode("logger.logstream")

    local leaf0 = pp:getLeaf()

    for k,l in pairs(leaf0) do
		local lstype = l:getName()
		local logstream = factory:createObject(lstype)
		if logstream == nil then
			self._rtcout:RTC_WARN("Logstream "..lstype.." creation failed.")
        else
			self._rtcout:RTC_INFO("Logstream "..lstype.." created.")
			if not logstream:init(l) then
				self._rtcout:RTC_WARN("Logstream "..lstype.." init failed.")
				factory:deleteObject(logstream)
				self._rtcout:RTC_WARN("Logstream "..lstype.." deleted.")
			else
				self._rtcout:RTC_INFO("Logstream "..lstype.." added.")
				self._rtcout:addLogger(logstream)
			end
		end
	end
end

-- ロガー初期化
-- @param true：設定成功
function Manager:initLogger()
	self._rtcout = self:getLogbuf()
	--print(self._config:getProperty("logger.enable"), StringUtil.toBool(self._config:getProperty("logger.enable"), "YES", "NO", true))
	if not StringUtil.toBool(self._config:getProperty("logger.enable"), "YES", "NO", true) then
		return true
	end

	self:initLogstreamFile()
	self:initLogstreamPlugins()
	self:initLogstreamOthers()

	self._rtcout:setLogLevel(self._config:getProperty("logger.log_level"))
	self._rtcout:setLogLock(StringUtil.toBool(self._config:getProperty("logger.stream_lock"),
                                                "enable", "disable", false))
    self._rtcout:RTC_INFO(self._config:getProperty("openrtm.version"))
    self._rtcout:RTC_INFO("Copyright (C) 2018")
    self._rtcout:RTC_INFO("  Nobuhiko Miyamoto")
    self._rtcout:RTC_INFO("  Tokyo Metropolitan University")
    self._rtcout:RTC_INFO("Manager starting.")
    self._rtcout:RTC_INFO("Starting local logging.")

    return true
end

-- ロガー終了
function Manager:shutdownLogger()

end

-- ORB初期化
function Manager:initORB()

	if ORB_Dummy_ENABLE then
		self._orb = ORB_Dummy
	else
		self._orb = oil.init{ flavor = "cooperative;corba;intercepted;typed;base;" }

		if oil.VERSION == "OiL 0.5" then
			oil.corba.idl.null = nil
		end

		self._orb:loadidlfile(Manager:findIdLFile("CosNaming.idl"))
		self._orb:loadidlfile(Manager:findIdLFile("RTC.idl"))
		self._orb:loadidlfile(Manager:findIdLFile("OpenRTM.idl"))
		self._orb:loadidlfile(Manager:findIdLFile("DataPort.idl"))
		self._orb:loadidlfile(Manager:findIdLFile("Manager.idl"))
		self._orb:loadidlfile(Manager:findIdLFile("InterfaceDataTypes.idl"))
	end
	self._ReturnCode_t = self._orb.types:lookup("::RTC::ReturnCode_t").labelvalue

end


function Manager:loadIdLFile(name)
	self._orb:loadidlfile(name)
end

-- IDLファイルパス取得
-- @param name IDLファイル名
-- IDLファイルは、Manager.luaの存在するディレクトリの2階層上のディレクトリを検索する
-- @return IDLファイルパス
function Manager:findIdLFile(name)
	local fpath = StringUtil.dirname(string.sub(debug.getinfo(1)["source"],2))
	--local fpath = StringUtil.dirname(string.gsub(debug.getinfo(1)["source"],"@",""))
	--print(fpath)
	local _str = string.gsub(fpath,"\\","/").."../idl/"..name
	--print(_str)
	return _str
end

-- ORBのオプション生成
-- @return オプション
function Manager:createORBOptions()

end

-- プロパティからエンドポイント一覧を取得
-- @param endpoints エンドポイント一覧を格納する変数
function Manager:createORBEndpoints(endpoints)

end

-- エンドポイントのオプション生成
-- @param opt オプションの文字列を格納する変数
-- @param endpoints エンドポイント一覧
function Manager:createORBEndpointOption(opt, endpoints)

end

-- ORB終了
function Manager:shutdownORB()
	self._orb:shutdown()
end

-- ネームサーバー接続初期化
-- 「naming.enable」のプロパティがYESの時に有効
-- 「naming.type」のプロパティでメソッドを指定
-- 「メソッド名.nameservers」で利用するアドレスを指定
-- @return true：初期化成功、false：初期化失敗
function Manager:initNaming()
	self._rtcout:RTC_TRACE("Manager.initNaming()")
	self._namingManager = NamingManager.new(self)
	--print(StringUtil.toBool(self._config:getProperty("naming.enable"), "YES", "NO", true))
	if not StringUtil.toBool(self._config:getProperty("naming.enable"), "YES", "NO", true) then
		return true
	end
	local meths = StringUtil.split(self._config:getProperty("naming.type"),",")

	for i, meth in ipairs(meths) do
		--print(meth)
		local names = StringUtil.split(self._config:getProperty(meth..".nameservers"), ",")
		for j, name in ipairs(names) do
			--print(name)
			self._rtcout:RTC_TRACE("Register Naming Server: "..meth.."/"..name)
			self._namingManager:registerNameServer(meth,name)
		end
	end
	if StringUtil.toBool(self._config:getProperty("naming.update.enable"), "YES", "NO", true) then
	end
	return true
end

-- ネームサーバー接続終了
function Manager:shutdownNaming()

end

-- 実行コンテキスト生成ファクトリ初期化
-- @return true：初期化成功、false：初期化失敗
function Manager:initExecContext()
	self._rtcout:RTC_TRACE("Manager.initExecContext()")
	PeriodicExecutionContext.Init(self)
	OpenHRPExecutionContext.Init(self)
	return true
end

-- 複合コンポーネント生成ファクトリ初期化
-- @return true：登録成功、false：登録失敗
function Manager:initComposite()
	return true
end

-- ファクトリ初期化
-- @return true：登録成功、false：登録失敗
function Manager:initFactories()
	FactoryInit()
	return true
end

-- タイマ初期化
-- @return true：登録成功、false：登録失敗
function Manager:initTimer()
	return true
end
function Manager:endpointPropertySwitch()

end

-- iPv4、iPv6のエンドポイント一覧取得
-- @return エンドポイント一覧
function Manager:setEndpointProperty()
	local ret = {}
	return ret
end

-- マネージャサーバント初期化
-- 「manager.corba_servant」のプロパティがYESの時に有効
-- 「manager.is_master」のプロパティがYESの時にはマスターマネージャで起動
-- @return true：初期化成功、false：初期化失敗
function Manager:initManagerServant()
	self._rtcout:RTC_TRACE("Manager.initManagerServant()")
    if not StringUtil.toBool(
		self._config:getProperty("manager.corba_servant"), "YES","NO",true) then
		return true
	end

	self._mgrservant = ManagerServant.new()

	if self._config:getProperty("corba.endpoints_ipv4") == "" then
		self:setEndpointProperty(self._mgrservant:getObjRef())
	end
    local prop = self._config:getNode("manager")
    local names = StringUtil.split(prop:getProperty("naming_formats"),",")

    if StringUtil.toBool(prop:getProperty("is_master"),
                           "YES","NO",true) then
		--for i, name in ipairs(names) do
		--	local mgr_name = self:formatString(name, prop)
		--	self._namingManager:bindManagerObject(mgr_name, self._mgrservant)
		--end
	end
	if StringUtil.toBool(self._config:getProperty("corba.update_master_manager.enable"),
                           "YES", "NO", true) and
                           not StringUtil.toBool(self._config:getProperty("manager.is_master"),
                                                   "YES", "NO", false) then
	end

	local otherref = nil

	local success, exception = oil.pcall(
		function()
		end)
	if not success then
	end

	return true
end

-- ローカルサービス初期化
-- @return true：初期化成功、false：初期化失敗
function Manager:initLocalService()
	return true
end

-- 全RTC終了処理
function Manager:shutdownComponents()

end

-- RTC登録解除
-- @param comp RTC
function Manager:cleanupComponent(comp)

end

-- 全RTC登録解除
-- 一旦、削除リストに格納したRTCを削除する
function Manager:cleanupComponents()
    self._rtcout:RTC_VERBOSE("Manager.cleanupComponents()")

    self._rtcout:RTC_VERBOSE(#self._finalized.comps.." components are marked as finalized.")
    for i, _comp in ipairs(self._finalized.comps) do
		self:deleteComponent({comp=_comp})
	end

    self._finalized.comps = {}
end

-- RTCを削除リストに追加する
-- @param _comp RTC
function Manager:notifyFinalized(_comp)
    self._rtcout:RTC_TRACE("Manager.notifyFinalized()")

    --table.insert(self._finalized.comps, _comp)
	self:deleteComponent({comp=_comp})
end

-- RTC名、オプションを文字列から取得
-- @param comp_arg RTC名、オプション(RTC?param1=xxx&param2=yyy)
-- RTC名は「RTC:ベンダ名:カテゴリ名:実装ID:言語名:バージョン」で指定
-- @param comp_id RTC型名
-- 以下の要素を格納する
-- vendor：ベンダ名
-- category：カテゴリ名
-- implementation_id：実装ID
-- language：言語名
-- version：バージョン
-- @param comp_conf オプション
-- @return true：取得成功、false：取得失敗
function Manager:procComponentArgs(comp_arg, comp_id, comp_conf)
	local id_and_conf_str = StringUtil.split(comp_arg, "?")
	local id_and_conf = {}
	for k, v in pairs(id_and_conf_str) do
		v = StringUtil.eraseHeadBlank(v)
		v = StringUtil.eraseTailBlank(v)
		table.insert(id_and_conf, v)
	end
	--StringUtil.print_table(id_and_conf)
	if #id_and_conf ~= 1 and #id_and_conf ~= 2 then
		self._rtcout:RTC_ERROR("Invalid arguments. Two or more '?'")
		return false
	end
	local prof = CompParam.prof_list
	local param_num = #prof
	--print(prof[1],id_and_conf[1])
	if id_and_conf[1]:find(":") == nil then
		id_and_conf[1] = prof[1]..":::"..id_and_conf[1].."::"
	end


	local id_str = StringUtil.split(id_and_conf[1], ":")
	local id = {}
	--print(id_and_conf[1],#id_str)
	for k, v in pairs(id_str) do
		v = StringUtil.eraseHeadBlank(v)
		v = StringUtil.eraseTailBlank(v)
		table.insert(id, v)
	end
	if #id ~= param_num then
		self._rtcout:RTC_ERROR("Invalid RTC id format.")
		return false
	end

	if id[1] ~= prof[1] then
		self._rtcout:RTC_ERROR("Invalid id type.")
		return false
	end

	for i = 2,param_num do
		--print(prof[i], id[i])
		comp_id:setProperty(prof[i], id[i])
		--print(prof[i])
		self._rtcout:RTC_TRACE("RTC basic profile "..prof[i]..": "..id[i])
	end

	if #id_and_conf == 2 then
		local conf_str = StringUtil.split(id_and_conf[2], "&")
		local conf = {}
		for k, v in pairs(conf_str) do
			v = StringUtil.eraseHeadBlank(v)
			v = StringUtil.eraseTailBlank(v)
			table.insert(conf, v)
		end
		for i = 1,#conf do
			local keyval_str = StringUtil.split(conf[i], "=")
			local keyval = {}
			for k, v in pairs(keyval_str) do
				v = StringUtil.eraseHeadBlank(v)
				v = StringUtil.eraseTailBlank(v)
				table.insert(keyval, v)
			end
			if #keyval > 1 then
				comp_conf:setProperty(keyval[1],keyval[2])
				self._rtcout:RTC_TRACE("RTC property "..keyval[0]..": "..keyval[1])
			end
		end
	end


	return true
end

-- EC名、オプションを文字列から取得
-- @param ec_args EC名、オプションの文字列
-- @param ec_id EC名
-- @param ec_conf オプション
-- @return true：取得成功、false：取得失敗
function Manager:procContextArgs(ec_args, ec_id, ec_conf)
	return true
end

-- RTCのコンフィギュレーション設定
-- 以下の名前でコンフィグレーションファイルを指定
-- カテゴリ名.型名.config_file
-- カテゴリ名.インスタンス名.config_file
-- @param comp RTC
-- @param prop プロパティ
function Manager:configureComponent(comp, prop)
	local category  = comp:getCategory()
    local type_name = comp:getTypeName()
    local inst_name = comp:getInstanceName()
	local type_conf = category.."."..type_name..".config_file"
	local name_conf = category.."."..inst_name..".config_file"
	local type_prop = Properties.new()
	local name_prop = Properties.new()
	local config_fname = {}
	if self._config:getProperty(name_conf) ~= "" then
	end
	if self._config:findNode(category.."."..inst_name) then
		local temp_ = Properties.new({prop=self._config:getNode(category.."."..inst_name)})
		local keys_ = temp_:propertyNames()
		if not (#keys_ == 1 and keys_[#keys_] == "config_file") then
			name_prop:mergeProperties(self._config:getNode(category.."."..inst_name))
			self._rtcout:RTC_INFO("Component name conf exists in rtc.conf. Merged.")
			self._rtcout:RTC_INFO(name_prop)
			if self._config:findNode("config_file") then
				table.insert(config_fname, self._config:getProperty("config_file"))
			end
		end

	end
	if self._config:getProperty(type_conf) ~= "" then
	end
	if self._config:findNode(category.."."..type_name) then
		local temp_ = Properties.new({prop=self._config:getNode(category.."."..type_name)})
		local keys_ = temp_:propertyNames()
		if not (#keys_ == 1 and keys_[#keys_] == "config_file") then
			type_prop:mergeProperties(self._config:getNode(category.."."..type_name))
			self._rtcout:RTC_INFO("Component name conf exists in rtc.conf. Merged.")
			self._rtcout:RTC_INFO(type_prop)
			if self._config:findNode("config_file") then
				table.insert(config_fname, self._config:getProperty("config_file"))
			end
		end
	end
	comp:setProperties(prop)
	type_prop:mergeProperties(name_prop)
	type_prop:setProperty("config_file",StringUtil.flatten(StringUtil.unique_sv(config_fname)))
	comp:setProperties(type_prop)
	local comp_prop = Properties.new({prop=comp:getProperties()})
	local naming_formats = self._config:getProperty("naming.formats")
	if comp_prop:findNode("naming.formats") then
		naming_formats = comp_prop:getProperty("naming.formats")
	end
	naming_formats = StringUtil.flatten(StringUtil.unique_sv(StringUtil.split(naming_formats, ",")))
	--print(naming_formats)
	local naming_names = self:formatString(naming_formats, comp:getProperties())
	--print(naming_names)
	comp:getProperties():setProperty("naming.formats",naming_formats)
	comp:getProperties():setProperty("naming.names",naming_names)
	--print(comp:getProperties())
end

-- ファイルからプロパティを追加する
-- @param prop プロパティ
-- @param file_name ファイルパス
-- @return true：追加成功、false：追加失敗
function Manager:mergeProperty(prop, file_name)
	return true
end

-- フォーマットに従ってRTC名変換
-- 以下の置き換えを行う
-- %n：インスタンス名
-- %t：型名
-- %m：型名
-- %v：バージョン
-- %V：ベンダ名
-- %c：カテゴリ名
-- %h：ホスト名
-- %M：マネージャ名
-- %p：プロセスID
-- @param naming_format フォーマット
-- @param prop プロパティ
-- @return 変換後文字列
function Manager:formatString(naming_format, prop)
	local name_ = naming_format
	local str_  = ""
    local count = 0
	local len_  = #name_
	local num = 0
	--local ok, ret = xpcall(
	--		function()
	local flag = true
	while(flag) do
		num = num + 1
		local n = string.sub(name_,num,num)
		--print(n)
		if n == "" then
			break
		end
		--print(n,name_)
		if n == '%' then
			count = count + 1
			if count % 2 == 0 then
				str_ = str_..n
			end
		elseif n == '$' then
			count = 0
			num = num + 1
			n = string.sub(name_,num,num)
			if n == "" then
				break
			end
			if n == '{' or n == '(' then
				num = num + 1
				n = string.sub(name_,num,num)
				local env = ""
				local start = num+1
				while(true) do
					if n == '}' or n == ')' then
						break
					elseif n == "" then
						break
					end
					env = env..n
					num = num + 1
					n = string.sub(name_,num,num)
				end
				--envval = os.getenv(env)
				--if envval then
				--	str_ = str_..envval
				--end
			end
		else
			if  count > 0 and count % 2 == 1 then
				count = 0
				if   n == "n" then str_ = str_..prop:getProperty("instance_name")
				elseif n == "t" then str_ = str_..prop:getProperty("type_name")
				elseif n == "m" then str_ = str_..prop:getProperty("type_name")
				elseif n == "v" then str_ = str_..prop:getProperty("version")
				elseif n == "V" then str_ = str_..prop:getProperty("vendor")
				elseif n == "c" then str_ = str_..prop:getProperty("category")
				elseif n == "h" then str_ = str_..self._config:getProperty("os.hostname")
				elseif n == "M" then str_ = str_..self._config:getProperty("manager.name")
				elseif n == "p" then str_ = str_..self._config:getProperty("manager.pid")
				else str_ = str_..n end
			else
				count = 0
				str_ = str_..n
			end
		end
	end
	return str_
	--		end)

end

-- ロガー取得
-- @param name ロガー名
-- @return ロガー
function Manager:getLogbuf(name)
	if name == nil then
		name = "Manager"
	end
	if not StringUtil.toBool(self._config:getProperty("logger.enable"), "YES", "NO", true) then
		--print(LogStream.new())
		return LogStream.new():getLogger(name)
	end
	if self._rtcout == nil then
		self._rtcout = LogStream.new(name)
		--print(self._config:getProperty("logger.log_level"))
		self._rtcout:setLogLevel(self._config:getProperty("logger.log_level"))
		return self._rtcout:getLogger(name)
	else
		return self._rtcout:getLogger(name)
	end
end

-- プロパティ取得
-- @return プロパティ
function Manager:getConfig()
	return self._config
end

-- モジュールを直接ロードする
-- @param file_name ファイルパス
function Manager:try_direct_load(file_name)

end

-- ネームサーバーにポートを登録する
-- @param comp RTC
function Manager:publishPorts(comp)

end

-- ネームサーバーからポートを取得して接続する
-- @param comp RTC
function Manager:subscribePorts(comp)

end

-- ネームサーバーからポート一覧を取得
-- @param nsname パス
-- @param kind kind
-- @return ポート一覧
function Manager:getPortsOnNameServers(nsname, kind)
	local ret = {}
	return ret
end

-- データポートを接続する
-- @param port ポート
-- @param target_ports 接続先のポート一覧
function Manager:connectDataPorts(port, target_ports)

end

-- サービスポートを接続する
-- @param port ポート
-- @param target_ports 接続先のポート一覧
function Manager:connectServicePorts(port, target_ports)

end

-- 起動時にポートを自動接続する関数
function Manager:initPreConnection()

end

-- 起動時にRTCを自動アクティブ化する関数
function Manager:initPreActivation()

end

-- 起動時にRTCを自動生成する関数
function Manager:initPreCreation()

end

-- マネージャサーバント取得
-- @return マネージャサーバント
function Manager:getManagerServant()
    self._rtcout:RTC_TRACE("Manager.getManagerServant()")
    return self._mgrservant
end

-- RTC一覧取得
-- @return RTC一覧
function Manager:getComponents()
    self._rtcout:RTC_TRACE("Manager.getComponents()")
    return self._compManager:getObjects()
end

-- ネーミングマネージャを取得
-- @return ネーミングマネージャ
function Manager:getNaming()

end

-- モジュールのロード
-- @param fname ファイルパス
-- @param initfunc ファクトリ登録関数名
-- @return リターンコード
function Manager:load(fname, initfunc)
	return self._ReturnCode_t.PRECONDITION_NOT_MET
end

-- モジュールのアンロード
-- @param fname ファイルパス
function Manager:unload(fname)

end


-- 未使用
function Manager:setinitThread(thread)
	self._initThread = thread
end

-- CDR符号化
-- @param data 変換前のデータ
-- @param dataType データ型
-- @return CDRバイナリデータ
function Manager:cdrMarshal(data, dataType)

	local encoder = self._orb:newencoder()
	encoder:put(data, self._orb.types:lookup(dataType))
	local cdr = encoder:getdata()
	--for i=1,#cdr do
	--	print(i,string.byte(string.sub(cdr,i,i)))
	--end
	if #cdr == 0 then
	elseif #cdr == 2 then
		cdr = string.sub(cdr,2)
	elseif #cdr == 4 then
		cdr = string.sub(cdr,3)
	else
		cdr = string.sub(cdr,5)
	end
	--for i=1,#cdr do
	--	print(i,string.byte(string.sub(cdr,i,i)))
	--end
	return cdr
end

-- CDR複合化
-- @param cdr CDRバイナリデータ
-- @param dataType データ型
-- @return 変換後のデータ
function Manager:cdrUnmarshal(cdr, dataType)

	if #cdr == 0 then
	elseif #cdr == 1 then
		cdr = string.char(1)..cdr
	elseif #cdr == 2 then
		cdr = string.char(1)..string.char(255)..cdr
	else
		cdr = string.char(1)..string.char(255)..string.char(255)..string.char(255)..cdr
	end
	local decoder = self._orb:newdecoder(cdr)
	local _data = decoder:get(self._orb.types:lookup(dataType))
	return _data
end

-- スタンドアロンコンポーネントかの判定
-- @return true：スタンドアロンコンポーネント、false：rtcdでの実行
Manager.is_main = function()
	return (debug.getinfo(4 + (offset or 0)) == nil)
end


return Manager


