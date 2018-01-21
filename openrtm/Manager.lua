--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]



local Manager= {}
_G["openrtm.Manager"] = Manager

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
		ret = {}
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



function InstanceName(argv)
	local obj = {}
	if argv.prop then
		obj._name = argv.prop:getProperty("instance_name")
	elseif argv.factory then
		obj._name = argv.factory:getInstanceName()
	elseif argv.name then
		obj._name = argv.name
	end

	local call_func = function(self, comp)
		return (self._name == comp:getInstanceName())
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

function FactoryPredicate(argv)
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

	local call_func = function(self, factory)
		if self._impleid == "" then
			return false
		end
		_prop = Properties.new({prop=factory:profile()})
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


function ECFactoryPredicate(argv)
	local obj = {}
	if argv.name then
		obj._name  = argv.name
	elseif argv.factory then
		obj._name = argv.factory:name()
	end

	local call_func = function(self, factory)
		return (self._name == factory:name())
	end
	setmetatable(obj, {__call=call_func})
	return obj
end



function ModulePredicate(prop)
	local obj = {}
	obj._prop  = prop

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

Finalized = {}

Finalized.new = function()
	local obj = {}
	obj.comps = {}
	return obj
end

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





function Manager:terminate()

end

function Manager:shutdown()
	self._listeners.manager_:preShutdown()
	self:shutdownComponents()
	self:shutdownNaming()
	self:shutdownORB()
	self:shutdownManager()
	self._listeners.manager_:postShutdown()
	self:shutdownLogger()
end



function Manager:instance()
	return self
end

function Manager:join()

end
function Manager:setModuleInitProc(proc)
	self._initProc = proc
end

function Manager:activateManager()
	return true
end

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

function Manager:step()
	oil.main(function()
		oil.newthread(self._orb.step, self._orb)
	end)
end


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
function Manager:unloadModule(fname)

end
function Manager:unloadAll(fname)

end
function Manager:getLoadedModules()

end
function Manager:getLoadableModules()

end
function Manager:registerFactory(profile, new_func, delete_func)
	--print(profile:getProperty("type_name"))
	self._rtcout:RTC_TRACE("Manager.registerFactory("..profile:getProperty("type_name")..")")
	policy_name = self._config:getProperty("manager.components.naming_policy","process_unique")
	policy = NumberingPolicyFactory:instance():createObject(policy_name)
	factory = FactoryLua.new(profile, new_func, delete_func, policy)
	--print(self._factory.registerObject)
	return self._factory:registerObject(factory)
end
function Manager:getFactoryProfiles()

end
function Manager:registerECFactory(name, new_func, delete_func)

end
function Manager:getModulesFactories()

end
function Manager:createComponent(comp_args)
	self._rtcout:RTC_TRACE("Manager.createComponent("..comp_args..")")
	comp_prop = Properties.new()
    comp_id   = Properties.new()
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
	factory = self._factory:find(comp_id)
	--print(factory)
	if factory == nil then
		self._rtcout:RTC_ERROR("createComponent: Factory not found: "..
			comp_id:getProperty("implementation_id"))
	end
	prop = factory:profile()
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
	prop_ = prop:getNode("port")
	prop_:mergeProperties(self._config:getNode("port"))
	comp = factory:create(self)
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
function Manager:registerComponent(comp)
    self._rtcout:RTC_TRACE("Manager.registerComponent("..comp:getInstanceName()..")")

	print(comp:getInstanceName())
    self._compManager:registerObject(comp)
    names = comp:getNamingNames()

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
function Manager:unregisterComponent(comp)
    self._rtcout:RTC_TRACE("Manager.unregisterComponent("..comp:getInstanceName()..")")
    self._compManager:unregisterObject(comp:getInstanceName())
    names = comp:getNamingNames()

    --self._listeners.naming_:preUnbind(comp, names)
    for i,name in ipairs(names) do
		self._rtcout:RTC_TRACE("Unbind name: "..name)
		self._namingManager:unbindObject(name)
	end
    --self._listeners.naming_:postUnbind(comp, names)
end
function Manager:createContext(ec_args)

end
function Manager:deleteComponent(argv)
	if argv.instance_name ~= nil then
		self._rtcout.RTC_TRACE("Manager.deleteComponent("..instance_name..")")
		local _comp = self._compManager:find(instance_name)
		if _comp ~= nil then
			self._rtcout:RTC_WARN("RTC "..instance_name.." was not found in manager.")
			return
		end
		self:deleteComponent({comp=_comp})
	elseif argv.comp ~= nil then
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
	end
end
function Manager:getComponent(instance_name)
    self._rtcout:RTC_TRACE("Manager.getComponent("..instance_name..")")
    return self._compManager:find(instance_name)
end
function Manager:addManagerActionListener(listener,autoclean)

end
function Manager:removeManagerActionListener(listener)

end
function Manager:addModuleActionListener(listener, autoclean)

end
function Manager:removeModuleActionListener(listener)

end
function Manager:addRtcLifecycleActionListener(listener, autoclean)

end
function Manager:removeRtcLifecycleActionListener(listener)

end
function Manager:addNamingActionListener(listener, autoclean)

end
function Manager:removeNamingActionListener(listener)

end
function Manager:addLocalServiceActionListener(listener, autoclean)

end
function Manager:removeLocalServiceActionListener(listener)

end
function Manager:getORB()
	--print(self._rtcout)
	--print(self)
	self._rtcout:RTC_TRACE("Manager.getORB()")
	--print(self._orb)
	return self._orb
end
function Manager:initManager(argv)
	config = ManagerConfig.new(argv)
	self._config = Properties.new()
	config:configure(self._config)
end
function Manager:shutdownManager()

end
function Manager:initLogstreamFile()

end
function Manager:initLogstreamPlugins()

end
function Manager:initLogstreamOthers()

end
function Manager:initLogger()
	self._rtcout = self:getLogbuf()
end
function Manager:shutdownLogger()

end
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

function Manager:findIdLFile(name)
	local fpath = StringUtil.dirname(debug.getinfo(1)["short_src"])
	--print(fpath)
	local _str = string.gsub(fpath,"\\","/").."../../idl/"..name
	--print(_str)
	return _str
end

function Manager:createORBOptions()

end
function Manager:createORBEndpoints(endpoints)

end
function Manager:createORBEndpointOption(opt, endpoints)

end
function Manager:shutdownORB()
	self._orb:shutdown()
end
function Manager:initNaming()
	self._rtcout:RTC_TRACE("Manager.initNaming()")
	self._namingManager = NamingManager.new(self)
	--print(StringUtil.toBool(self._config:getProperty("naming.enable"), "YES", "NO", true))
	if not StringUtil.toBool(self._config:getProperty("naming.enable"), "YES", "NO", true) then
		return true
	end
	meths = StringUtil.split(self._config:getProperty("naming.type"),",")

	for i, meth in ipairs(meths) do
		--print(meth)
		names = StringUtil.split(self._config:getProperty(meth..".nameservers"), ",")
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
function Manager:shutdownNaming()

end
function Manager:initExecContext()
	self._rtcout:RTC_TRACE("Manager.initExecContext()")
	PeriodicExecutionContext.Init(self)
	OpenHRPExecutionContext.Init(self)
	return true
end
function Manager:initComposite()

end
function Manager:initFactories()
	FactoryInit()
end
function Manager:initTimer()

end
function Manager:endpointPropertySwitch()

end
function Manager:setEndpointProperty(objref)

end
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
    prop = self._config:getNode("manager")
    names = StringUtil.split(prop:getProperty("naming_formats"),",")

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
function Manager:initLocalService()

end
function Manager:shutdownComponents()

end
function Manager:cleanupComponent(comp)

end
function Manager:cleanupComponents()
    self._rtcout:RTC_VERBOSE("Manager.cleanupComponents()")

    self._rtcout:RTC_VERBOSE(#self._finalized.comps.." components are marked as finalized.")
    for i, _comp in ipairs(self._finalized.comps) do
		self:deleteComponent({comp=_comp})
	end

    self._finalized.comps = {}
end
function Manager:notifyFinalized(_comp)
    self._rtcout:RTC_TRACE("Manager.notifyFinalized()")

    --table.insert(self._finalized.comps, _comp)
	self:deleteComponent({comp=_comp})
end
function Manager:procComponentArgs(comp_arg, comp_id, comp_conf)
	id_and_conf_str = StringUtil.split(comp_arg, "?")
	id_and_conf = {}
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
	prof = CompParam.prof_list
	param_num = #prof
	--print(prof[1],id_and_conf[1])
	if id_and_conf[1]:find(":") == nil then
		id_and_conf[1] = prof[1]..":::"..id_and_conf[1].."::"
	end


	id_str = StringUtil.split(id_and_conf[1], ":")
	id = {}
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
		conf_str = StringUtil.split(id_and_conf[2], "&")
		conf = {}
		for k, v in pairs(conf_str) do
			v = StringUtil.eraseHeadBlank(v)
			v = StringUtil.eraseTailBlank(v)
			table.insert(conf, v)
		end
		for i = 1,#conf do
			keyval_str = StringUtil.split(conf[i], "=")
			keyval = {}
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
function Manager:procContextArgs(ec_args, ec_id, ec_conf)

end
function Manager:configureComponent(comp, prop)
	category  = comp:getCategory()
    type_name = comp:getTypeName()
    inst_name = comp:getInstanceName()
	type_conf = category.."."..type_name..".config_file"
	name_conf = category.."."..inst_name..".config_file"
	type_prop = Properties.new()
	name_prop = Properties.new()
	config_fname = {}
	if self._config:getProperty(name_conf) ~= "" then
	end
	if self._config:findNode(category.."."..inst_name) then
	end
	if self._config:getProperty(type_conf) ~= "" then
	end
	if self._config:findNode(category.."."..type_name) then
	end
	comp:setProperties(prop)
	type_prop:mergeProperties(name_prop)
	type_prop:setProperty("config_file",StringUtil.flatten(StringUtil.unique_sv(config_fname)))
	comp:setProperties(type_prop)
	comp_prop = Properties.new({prop=comp:getProperties()})
	naming_formats = self._config:getProperty("naming.formats")
	if comp_prop:findNode("naming.formats") then
		naming_formats = comp_prop:getProperty("naming.formats")
	end
	naming_formats = StringUtil.flatten(StringUtil.unique_sv(StringUtil.split(naming_formats, ",")))
	--print(naming_formats)
	naming_names = self:formatString(naming_formats, comp:getProperties())
	--print(naming_names)
	comp:getProperties():setProperty("naming.formats",naming_formats)
	comp:getProperties():setProperty("naming.names",naming_names)
	--print(comp:getProperties())
end
function Manager:mergeProperty(prop, file_name)

end
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
		n = string.sub(name_,num,num)
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
				env = ""
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
function Manager:getLogbuf(name)
	if name == nil then
		name = "Manager"
	end
	if StringUtil.toBool(self._config:getProperty("logger.enable"), "YES", "NO", true) then
		--print(LogStream.new())
		return LogStream.new():getLogger(name)
	end
	if self._rtcout == nil then
		self._rtcout = LogStream.new(name)
		self._rtcout:setLogLevel(self._config:getProperty("logger.log_level"))
		return self._rtcout:getLogger(name)
	else
		return self._rtcout:getLogger(name)
	end
end
function Manager:getConfig()
	return self._config
end
function Manager:try_direct_load(file_name)

end
function Manager:publishPorts(comp)

end
function Manager:subscribePorts(comp)

end
function Manager:getPortsOnNameServers(nsname, kind)

end
function Manager:connectDataPorts(port, target_ports)

end
function Manager:connectServicePorts(port, target_ports)

end
function Manager:initPreConnection()

end
function Manager:initPreActivation()

end
function Manager:initPreCreation()

end
function Manager:getManagerServant()
    self._rtcout:RTC_TRACE("Manager.getManagerServant()")
    return self._mgrservant
end

function Manager:getComponents()
    self._rtcout:RTC_TRACE("Manager.getComponents()")
    return self._compManager:getObjects()
end

function Manager:getNaming()

end


function Manager:load(fname, initfunc)
	return self._ReturnCode_t.PRECONDITION_NOT_MET
end

function Manager:unload(fname)

end


function Manager:setModuleInitProc(proc)
	self._initProc = proc
end

function Manager:setinitThread(thread)
	self._initThread = thread
end

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


Manager.is_main = function()
	return (debug.getinfo(4 + (offset or 0)) == nil)
end


return Manager


