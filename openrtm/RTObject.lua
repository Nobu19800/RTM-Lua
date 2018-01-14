--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local RTObject= {}
_G["openrtm.RTObject"] = RTObject

local oil = require "oil"
local PortAdmin = require "openrtm.PortAdmin"
local Properties = require "openrtm.Properties"
local ConfigAdmin = require "openrtm.ConfigAdmin"
local SdoServiceAdmin = require "openrtm.SdoServiceAdmin"
local SdoConfiguration = require "openrtm.SdoConfiguration"
local Configuration_impl = SdoConfiguration.Configuration_impl
local ComponentActionListener = require "openrtm.ComponentActionListener"
local ComponentActionListeners = ComponentActionListener.ComponentActionListeners
local PortConnectListener = require "openrtm.PortConnectListener"
local PortConnectListeners = PortConnectListener.PortConnectListeners
local ManagerConfig = require "openrtm.ManagerConfig"
local ExecutionContextBase = require "openrtm.ExecutionContextBase"
local ExecutionContextFactory = ExecutionContextBase.ExecutionContextFactory
local StringUtil = require "openrtm.StringUtil"
local NVUtil = require "openrtm.NVUtil"
local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
local RTCUtil = require "openrtm.RTCUtil"


RTObject.ECOTHER_OFFSET = 1000


default_conf = {
  "implementation_id","",
  "type_name","",
  "description","",
  "version","",
  "vendor","",
  "category","",
  "activity_type","",
  "max_instance","",
  "language","",
  "lang_type","",
  "conf",""}



local ec_copy = {}
ec_copy.new = function(eclist)
	local obj = {}
	obj._eclist = eclist
	local call_func = function(self, ecs)
		if ecs ~= nil then
			table.insert(self._eclist, ecs)
		end
	end
	setmetatable(obj, {__call=call_func})
	return obj
end



local ec_find = {}
ec_find.new = function(_ec)
	local obj = {}
	obj._ec = _ec



	local call_func = function(self, ecs)
		local ret = -1
		local success, exception = oil.pcall(
			function()
				if ecs ~= nil then

					--print(#self._ec, #ecs)
					--for k, v in pairs(self._ec) do
					--	print( k, v )
					--end
					--print(self._ec:get_profile())
					--print(self._ec, ecs)
					ret = NVUtil._is_equivalent(self._ec, ecs, self._ec.getObjRef, ecs.getObjRef)
					--local Manager = require "openrtm.Manager"
					--local orb = Manager:instance():getORB()
					--ret = (orb:tostring(self._ec) == orb:tostring(ec))
					return
				end
			end)
		if not success then
			print(exception)
			return -1
		end

		return ret
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

RTObject.new = function(manager)
	local obj = {}
	--print(manager)
	obj._manager = manager
	obj._orb = obj._manager:getORB()
	--print(obj._orb)
	obj._portAdmin = PortAdmin.new(obj._manager:getORB())
	obj._rtcout = obj._manager:getLogbuf("rtobject")
	obj._created = true
	obj._properties = Properties.new({defaults_str=default_conf})
	--print(obj._properties:getNode("conf"),type(obj._properties:getNode("conf")))
	obj._configsets = ConfigAdmin.new(obj._properties:getNode("conf"))
	obj._profile = {instance_name="",type_name="",
				  description="description",version="0", vendor="",
				  category="",port_profiles={},
				  parent=oil.corba.idl.null,properties={
				  {name="implementation_id",value=""}, {name="type_name",value=""},
				  {name="description",value=""},{name="version",value=""},
				  {name="vendor",value=""},{name="category",value=""},
				  {name="activity_type",value=""},{name="max_instance",value=""},
				  {name="language",value=""},{name="lang_type",value=""},
				  {name="instance_name",value=""}
				  }
				  }
	obj._sdoservice = SdoServiceAdmin.new(obj)
	obj._SdoConfigImpl = Configuration_impl.new(obj._configsets,obj._sdoservice)
	obj._SdoConfig = obj._SdoConfigImpl:getObjRef()
	obj._execContexts = {}

	obj._sdoOwnedOrganizations = {}
	obj._sdoSvcProfiles = {}
	obj._sdoOrganization = {}
	obj._sdoStatus = {}
	obj._ecMine  = {}
	obj._ecOther = {}
	obj._eclist  = {}
	obj._exiting = false
	obj._readAll = false
	obj._writeAll = false
	obj._readAllCompletion = false
	obj._writeAllCompletion = false
	obj._inports = {}
	obj._outports = {}
	obj._actionListeners = ComponentActionListeners.new()
	obj._portconnListeners = PortConnectListeners.new()
	obj._svr = nil

	obj._ReturnCode_t = obj._orb.types:lookup("::RTC::ReturnCode_t").labelvalue

	function obj:onInitialize(object)
		self._rtcout:RTC_TRACE("onInitialize()")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onFinalize(object)
		self._rtcout:RTC_TRACE("onFinalize()")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onStartup(ec_id)
		self._rtcout:RTC_TRACE("onStartup("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onShutdown(ec_id)
		self._rtcout:RTC_TRACE("onShutdown("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onActivated(ec_id)
		self._rtcout:RTC_TRACE("onActivated("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onDeactivated(ec_id)
		self._rtcout:RTC_TRACE("onDeactivated("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onExecute(ec_id)
		self._rtcout:RTC_TRACE("onExecute("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onAborting(ec_id)
		self._rtcout:RTC_TRACE("onAborting("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onError(ec_id)
		self._rtcout:RTC_TRACE("onError("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onReset(ec_id)
		self._rtcout:RTC_TRACE("onReset("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onStateUpdate(ec_id)
		self._rtcout:RTC_TRACE("onStateUpdate("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:onRateChanged(ec_id)
		self._rtcout:RTC_TRACE("onRateChanged("..ec_id..")")
		return self._ReturnCode_t.RTC_OK
	end
	function obj:initialize()
		self._rtcout:RTC_TRACE("initialize()")
		self:createRef()
		ec_args_ = {}
		if self:getContextOptions(ec_args_) ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("Valid EC options are not available. Aborting")
			return self._ReturnCode_t.BAD_PARAMETER
		end
		if self:createContexts(ec_args_) ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("EC creation failed. Maybe out of resources. Aborting.")
			return self._ReturnCode_t.BAD_PARAMETER
		end
		--self._rtcout:RTC_INFO(#self._ecMine.." execution context"..toSTR_(self._ecMine).." created.")
		ret_ = self:on_initialize()
		self._created = false
		if ret_ ~= self._ReturnCode_t.RTC_OK then
			self._rtcout:RTC_ERROR("on_initialize() failed.")
			return ret_
		end
		self._rtcout:RTC_DEBUG("on_initialize() was properly done.")
		for idx_, ec_ in ipairs(self._ecMine) do
			self._rtcout:RTC_DEBUG("EC"..idx_.." starting.")
			ec_:start()
		end
		self._sdoservice:init(self)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:finalize()
		self._rtcout:RTC_TRACE("finalize()")
		if self._created or not self._exiting then
			return self._ReturnCode_t.PRECONDITION_NOT_MET
		end
		if #self._ecOther ~= 0 then
			self._ecOther = {}
		end
		local ret = self:on_finalize()
		self:shutdown()
		return ret
	end

	function obj:getProperties()
		self._rtcout:RTC_TRACE("getProperties()")
		return self._properties
	end
	function obj:getInstanceName()
		self._rtcout:RTC_TRACE("getInstanceName()")
		return self._profile.instance_name
	end
	function obj:setInstanceName(instance_name)
		self._rtcout:RTC_TRACE("setInstanceName("..instance_name..")")
		self._properties:setProperty("instance_name",instance_name)
		self._profile.instance_name = self._properties:getProperty("instance_name")
	end
	function obj:getTypeName()
		self._rtcout:RTC_TRACE("getTypeName()")
		return self._profile.type_name
	end
	function obj:getCategory()
		self._rtcout:RTC_TRACE("getCategory()")
		return self._profile.category
	end
	function obj:setProperties(prop)
		self._rtcout:RTC_TRACE("setProperties()")
		self._properties:mergeProperties(prop)
		self._profile.instance_name = self._properties:getProperty("instance_name")
		self._profile.type_name = self._properties:getProperty("type_name")
		self._profile.description = self._properties:getProperty("description")
		self._profile.version = self._properties:getProperty("version")
 		self._profile.vendor = self._properties:getProperty("vendor")
		self._profile.category = self._properties:getProperty("category")
	end


	function obj:getObjRef()
		self._rtcout:RTC_TRACE("getObjRef()")
		return self._objref
	end
	function obj:getGlobalContextOptions(global_ec_props)
		self._rtcout:RTC_TRACE("getGlobalContextOptions()")

		prop_ = self._properties:findNode("exec_cxt.periodic")
		if prop_ == nil then
		  self._rtcout:RTC_WARN("No global EC options found.")
		  return self._ReturnCode_t.RTC_ERROR
		end
		--print(prop_)

		self._rtcout:RTC_DEBUG("Global EC options are specified.")
		self._rtcout:RTC_DEBUG(prop_)
		self:getInheritedECOptions(global_ec_props)
		global_ec_props:mergeProperties(prop_)
		return self._ReturnCode_t.RTC_OK
	end
	function obj:getPrivateContextOptions(ec_args)
		self._rtcout:RTC_TRACE("getPrivateContextOptions()")
		if not self._properties.findNode("execution_contexts") then
			self._rtcout:RTC_DEBUG("No component specific EC specified.")
			return self._ReturnCode_t.RTC_ERROR
		end
		return self._ReturnCode_t.RTC_OK
	end
	function obj:getInheritedECOptions(default_opts)
		self._rtcout:RTC_TRACE("getPrivateContextOptions()")
		return self._ReturnCode_t.RTC_OK
	end

	function obj:getContextOptions(ec_args)
		self._rtcout:RTC_DEBUG("getContextOptions()")
		local global_props_ = Properties.new()
		local ret_global_  = self:getGlobalContextOptions(global_props_)
		local ret_private_ = self:getPrivateContextOptions(ec_args)
		if ret_global_ ~= self._ReturnCode_t.RTC_OK and ret_private_ ~= self._ReturnCode_t.RTC_OK then
			return self._ReturnCode_t.RTC_ERROR
		end
		--print(ret_global_, ret_private_)
		if ret_global_ == self._ReturnCode_t.RTC_OK and ret_private_ ~= self._ReturnCode_t.RTC_OK then
			table.insert(ec_args,global_props_)
		end
		return self._ReturnCode_t.RTC_OK
	end
	function obj:createContexts(ec_args)


		ret_  = self._ReturnCode_t.RTC_OK
		avail_ec_ = ExecutionContextFactory:instance():getIdentifiers()

		--print(#ec_args)
		for i,ec_arg_ in ipairs(ec_args) do
			local ec_type_ = ec_arg_:getProperty("type")
			local ec_name_ = ec_arg_:getProperty("name")
			--print(ec_arg_)
			local ret_aec = false
			for i,aec in ipairs(avail_ec_) do
				--print(aec)
				if ec_type_ == aec then
					ret_aec = true

					break
				end
			end
			if not ret_aec then
				self._rtcout:RTC_WARN("EC "..ec_type_.." is not available.")
				self._rtcout:RTC_DEBUG("Available ECs: "..
									StringUtil.flatten(avail_ec_))
			else
				ec_ = ExecutionContextFactory:instance():createObject(ec_type_)
				ec_:init(ec_arg_)
				table.insert(self._eclist, ec_)
				ec_:bindComponent(self)
			end
		end

		if #self._eclist == 0 then
			default_opts = Properties.new()
			ec_type_ = "PeriodicExecutionContext"
			local ec_ = ExecutionContextFactory:instance():createObject(ec_type_)
			ec_:init(default_opts)
			table.insert(self._eclist, ec_)
			ec_:bindComponent(self)
		end
		return ret_
	end
	function obj:on_initialize(ec_args)
		self._rtcout:RTC_TRACE("on_initialize()")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnInitialize(0)
				self._rtcout:RTC_DEBUG("Calling onInitialize().")
				ret = self:onInitialize()
				if ret ~= self._ReturnCode_t.RTC_OK then
					self._rtcout:RTC_ERROR("onInitialize() returns an ERROR ("..ret..")")
				else
					self._rtcout:RTC_DEBUG("onInitialize() succeeded.")
				end
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		local active_set = self._properties:getProperty("configuration.active_config",
                                              "default")
		if self._configsets:haveConfig(active_set) then
			self._rtcout:RTC_DEBUG("Active configuration set: "..active_set.." exists.")
			self._configsets:activateConfigurationSet(active_set)
			self._configsets:update(active_set)
			self._rtcout:RTC_INFO("Initial active configuration set is "..active_set..".")
		else
			self._rtcout:RTC_DEBUG("Active configuration set: "..active_set.." does not exists.")
			self._configsets:activateConfigurationSet("default")
			self._configsets:update("default")
			self._rtcout:RTC_INFO("Initial active configuration set is default-set.")
		end
		return ret_
	end
	function obj:preOnInitialize(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_INITIALIZE]:notify(ec_id)
	end
	function obj:preOnFinalize(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_FINALIZE]:notify(ec_id)
	end
	function obj:preOnStartup(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_STARTUP]:notify(ec_id)
	end
	function obj:preOnShutdown(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_SHUTDOWN]:notify(ec_id)
	end
	function obj:preOnActivated(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_ACTIVATED]:notify(ec_id)
	end
	function obj:preOnDeactivated(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_DEACTIVATED]:notify(ec_id)
	end
	function obj:preOnAborting(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_ABORTING]:notify(ec_id)
	end
	function obj:preOnError(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_ERROR]:notify(ec_id)
	end
	function obj:preOnReset(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_RESET]:notify(ec_id)
	end
	function obj:preOnExecute(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_EXECUTE]:notify(ec_id)
	end
	function obj:preOnStateUpdate(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_STATE_UPDATE]:notify(ec_id)
	end
	function obj:preOnRateChanged(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_RATE_CHANGED]:notify(ec_id)
	end
	function obj:bindContext(exec_context)
		--print(exec_context)
		self._rtcout:RTC_TRACE("bindContext()")
		if exec_context == nil then
			return -1
		end
		for i =1,#self._ecMine do
			if self._ecMine[i] == nil then
				self._ecMine[i] = exec_context
				self:onAttachExecutionContext(i)
				return i-1
			end
		end
		table.insert(self._ecMine, exec_context)
		return #self._ecMine - 1
	end
	function obj:on_startup(ec_id)
		self._rtcout:RTC_TRACE("on_startup("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnStartup(ec_id)
				ret = self:onStartup(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnStartup(ec_id, ret)
		return ret
	end
	function obj:on_shutdown(ec_id)
		self._rtcout:RTC_TRACE("on_shutdown("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnShutdown(ec_id)
				ret = self:onShutdown(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnShutdown(ec_id, ret)
		return ret
	end
	function obj:on_activated(ec_id)
		self._rtcout:RTC_TRACE("on_activated("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		--print("on_activated1")
		local success, exception = oil.pcall(
			function()
				self:preOnActivated(ec_id)
				self._configsets:update()
				ret = self:onActivated(ec_id)
				self._portAdmin:activatePorts()
		end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnActivated(ec_id, ret)
		--print(type(ret))
		return ret
	end
	function obj:on_deactivated(ec_id)
		self._rtcout:RTC_TRACE("on_deactivated("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnDeactivated(ec_id)
				self._portAdmin:deactivatePorts()
				ret = self:onDeactivated(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnDeactivated(ec_id, ret)
		return ret
	end
	function obj:on_aborting(ec_id)
		self._rtcout:RTC_TRACE("on_aborting("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnAborting(ec_id)
				ret = self:onAborting(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnAborting(ec_id, ret)
		return ret
	end
	function obj:on_error(ec_id)
		self._rtcout:RTC_TRACE("on_error("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnError(ec_id)
				ret = self:onError(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self._configsets:update()
		self:postOnError(ec_id, ret)
		return ret
	end
	function obj:on_reset(ec_id)
		self._rtcout:RTC_TRACE("on_reset("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnReset(ec_id)
				ret = self:onReset(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnReset(ec_id, ret)
		return ret
	end
	function obj:on_execute(ec_id)
		self._rtcout:RTC_TRACE("on_execute("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				if self._readAll then
					self:readAll()
				end
				self:preOnExecute(ec_id)
				ret = self:onExecute(ec_id)
				if self._writeAll then
					self:writeAll()
				end
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnExecute(ec_id, ret)
		return ret
	end
	function obj:on_state_update(ec_id)
		self._rtcout:RTC_TRACE("on_state_update("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnStateUpdate(ec_id)
				ret = self:onStateUpdate(ec_id)
				self._configsets:update()
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end

		self:postOnStateUpdate(ec_id, ret)
		return ret
	end
	function obj:on_rate_changed(ec_id)
		self._rtcout:RTC_TRACE("on_rate_changed("..ec_id..")")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnRateChanged(ec_id)
				ret = self:onRateChanged(ec_id)
			end)
		if not success then
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnRateChanged(ec_id, ret)
		return ret
	end
	function obj:readAll()
		self._rtcout:RTC_TRACE("readAll()")
    end
	function obj:writeAll()
		self._rtcout:RTC_TRACE("writeAll()")
    end
	function obj:preOnStartup(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_STARTUP]:notify(ec_id)
    end
	function obj:preOnShutdown(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_SHUTDOWN]:notify(ec_id)
    end
	function obj:preOnActivated(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_ACTIVATED]:notify(ec_id)
    end
	function obj:preOnDeactivated(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_DEACTIVATED]:notify(ec_id)
    end
	function obj:preOnAborting(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_ABORTING]:notify(ec_id)
    end
	function obj:preOnError(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_ERROR]:notify(ec_id)
    end
	function obj:preOnReset(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_RESET]:notify(ec_id)
    end
	function obj:preOnExecute(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_EXECUTE]:notify(ec_id)
    end
	function obj:preOnStateUpdate(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_STATE_UPDATE]:notify(ec_id)
    end
	function obj:preOnRateChanged(ec_id)
		--self._actionListeners.preaction_[PreComponentActionListenerType.PRE_ON_RATE_CHANGED]:notify(ec_id)
    end
	function obj:postOnInitialize(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_INITIALIZE]:notify(ec_id, ret)
    end
	function obj:postOnFinalize(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_FINALIZE]:notify(ec_id, ret)
    end
	function obj:postOnStartup(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_STARTUP]:notify(ec_id, ret)
    end
	function obj:postOnShutdown(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_SHUTDOWN]:notify(ec_id, ret)
    end
	function obj:postOnActivated(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_SHUTDOWN]:notify(ec_id, ret)
    end
	function obj:postOnDeactivated(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_DEACTIVATED]:notify(ec_id, ret)
    end
	function obj:postOnAborting(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_ABORTING]:notify(ec_id, ret)
    end
	function obj:postOnError(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_ERROR]:notify(ec_id, ret)
    end
	function obj:postOnReset(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_RESET]:notify(ec_id, ret)
    end
	function obj:postOnExecute(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_EXECUTE]:notify(ec_id, ret)
    end
	function obj:postOnStateUpdate(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_STATE_UPDATE]:notify(ec_id, ret)
    end
	function obj:postOnRateChanged(ec_id, ret)
		--self._actionListeners.postaction_[PostComponentActionListenerType.POST_ON_RATE_CHANGED]:notify(ec_id, ret)
    end


	function obj:bindParameter(param_name, var, def_val, trans)
		self._rtcout:RTC_TRACE("bindParameter()")
		if trans == nil then
			trans_ = StringUtil.stringTo
		else
			trans_ = trans
		end
		--print(param_name, var, def_val, trans_)
		self._configsets:bindParameter(param_name, var, def_val, trans_)
		return true
	end

	function obj:getConfigService()
		return self._configsets
	end

	function obj:updateParameters(config_set)
		self._rtcout:RTC_TRACE("updateParameters("..config_set..")")
		self._configsets:update(config_set)
    end



	function obj:getExecutionContext(ec_id)
		return self:get_context(ec_id)
	end
	function obj:get_context(ec_id)

		self._rtcout:RTC_TRACE("get_context("..ec_id..")")
		ec_id = ec_id + 1
		if ec_id < RTObject.ECOTHER_OFFSET then
			if self._ecMine[ec_id] ~= nil then
				return self._ecMine[ec_id]
			else
				return oil.corba.idl.null
			end
		end


		index = ec_id - ECOTHER_OFFSET

		if self._ecOther[index] ~= nil then
			return self._ecOther[index]
		end

		return oil.corba.idl.null
	end


	function obj:get_owned_contexts()
		self._rtcout:RTC_TRACE("get_owned_contexts()")
		local execlist = {}
		CORBA_SeqUtil.for_each(self._ecMine, ec_copy.new(execlist))
		--print(#execlist)
		return execlist
	end

	function obj:get_participating_contexts()
		self._rtcout:RTC_TRACE("get_participating_contexts()")
		local execlist = {}
		CORBA_SeqUtil.for_each(self._ecOther, ec_copy.new(execlist))
		return execlist
	end

	function obj:get_context_handle(cxt)
		self._rtcout:RTC_TRACE("get_context_handle()")

		--for i,v in ipairs(self._ecMine) do
		--	print(v)
		--end
		num = CORBA_SeqUtil.find(self._ecMine, ec_find.new(cxt))
		--print(num)
		if num ~= -1 then
			return num
		end

		num = CORBA_SeqUtil.find(self._ecOther, ec_find.new(cxt))
		if num ~= -1 then
			return num + 1000
		end

		return -1
	end

	function obj:getNamingNames()
		self._rtcout:RTC_TRACE("getNamingNames()")
		--print(self._properties)
		ret_str = StringUtil.split(self._properties:getProperty("naming.names"), ",")
		local ret = {}
		for k, v in pairs(ret_str) do
			v = StringUtil.eraseHeadBlank(v)
			v = StringUtil.eraseTailBlank(v)
			table.insert(ret, v)
		end
		return ret
	end

	function obj:get_configuration()
		self._rtcout:RTC_TRACE("get_configuration()")
		if self._SdoConfig == nil then
			error(self._orb:newexcept{"SDOPackage::InterfaceNotImplemented",
				description="InterfaceNotImplemented: get_configuration"
			})
		end
		return self._SdoConfig
	end


	function obj:addPort(port)
		self._rtcout:RTC_TRACE("addPort()")
		self._rtcout:RTC_TRACE("addPort(CorbaPort)")
		local propkey = "port.corbaport."
		local prop = self._properties:getNode(propkey)
		if prop ~= nil then
			self._properties:getNode(propkey):mergeProperties(self._properties:getNode("port.corba"))
		end

		port:init(self._properties:getNode(propkey))
		port:setOwner(self)


		return self._portAdmin:addPort(port)
	end




	function obj:addInPort(name, inport)
		self._rtcout:RTC_TRACE("addInPort("..name..")")

		local propkey = "port.inport."..name
		local prop_ = Properties.new({prop=self._properties:getNode(propkey)})
		prop_:mergeProperties(self._properties:getNode("port.inport.dataport"))
		inport:init(prop_)

		inport:setOwner(self)
		inport:setPortConnectListenerHolder(self._portconnListeners)
		self:onAddPort(inport:getPortProfile())

		local ret = self._portAdmin:addPort(inport)

		if not ret then
			self._rtcout:RTC_ERROR("addInPort() failed.")
			return ret
		end


		table.insert(self._inports, inport)


		return ret
	end



	function obj:addOutPort(name, outport)
		self._rtcout:RTC_TRACE("addOutPort("..name..")")

		local propkey = "port.outport."..name
		local prop_ = Properties.new({prop=self._properties:getNode(propkey)})
		prop_:mergeProperties(self._properties:getNode("port.outport.dataport"))
		outport:init(prop_)

		outport:setOwner(self)
		outport:setPortConnectListenerHolder(self._portconnListeners)
		self:onAddPort(outport:getPortProfile())

		local ret = self._portAdmin:addPort(outport)

		if not ret then
			self._rtcout:RTC_ERROR("addOutPort() failed.")
			return ret
		end


		table.insert(self._outports, outport)


		return ret
	end


	function obj:removeInPort(port)
		self._rtcout:RTC_TRACE("removeInPort()")
		local ret = self:removePort(port)

		if ret ~= nil then
			for i, inport in ipairs(self._inports) do
				if port == inport then
					table.remove(self._inports, i)
					return true
				end
			end
		end
		return false
	end

	function obj:removeOutPort(port)
		self._rtcout:RTC_TRACE("removeOutPort()")
		local ret = self:removePort(port)

		if ret ~= nil then
			for i, outport in ipairs(self._outports) do
				if port == outport then
					table.remove(self._outports, i)
					return true
				end
			end
		end
		return false
	end



	function obj:removePort(port)
		self._rtcout:RTC_TRACE("removePort()")
		self:onRemovePort(port:getPortProfile())
		return self._portAdmin:removePort(port)
	end


	function obj:get_component_profile()
		self._rtcout:RTC_TRACE("get_component_profile()")

		prop_ = {instance_name = self._properties:getProperty("instance_name"),
				 type_name = self._properties:getProperty("type_name"),
				 description = self._properties:getProperty("description"),
				 version = self._properties:getProperty("version"),
				 vendor = self._properties:getProperty("vendor"),
				 category = self._properties:getProperty("category"),
				 port_profiles = self._portAdmin:getPortProfileList(),
				 parent = self._profile.parent,
				 properties = self._profile.properties}
		NVUtil.copyFromProperties(self._profile.properties, self._properties)
		--print(oil.corba.idl.null)
		return prop_
	end

	function obj:onAddPort(pprof)
		--self._actionListeners.portaction_[PortActionListenerType.ADD_PORT]:notify(pprof)
    end
	function obj:onRemovePort(pprof)
		--self._actionListeners.portaction_[PortActionListenerType.REMOVE_PORT]:notify(pprof)
    end
	function obj:onAttachExecutionContext(ec_id)
		--self._actionListeners.ecaction_[ExecutionContextActionListenerType.EC_ATTACHED]:notify(ec_id)
    end
	function obj:onDetachExecutionContext(pprof)
		--self._actionListeners.ecaction_[ExecutionContextActionListenerType.EC_DETACHED]:notify(ec_id)
    end

	function obj:is_alive(exec_context)
		self._rtcout:RTC_TRACE("is_alive()")

		for i, ec in ipairs(self._ecMine) do
			--if exec_context:_is_equivalent(ec) then
			local Manager = require "openrtm.Manager"
			local orb = Manager:instance():getORB()

			if NVUtil._is_equivalent(exec_context, ec, exec_context.getObjRef, ec.getObjRef) then
				return true
			end
		end


		for i, ec in ipairs(self._ecOther) do
			if ec == nil then
				if NVUtil._is_equivalent(exec_context, ec, exec_context.getObjRef, ec.getObjRef) then
					return true
				end
			end
		end

		return false
	end


	function obj:exit()
		self._rtcout:RTC_TRACE("exit()")
		if self._created then
			return self._ReturnCode_t.PRECONDITION_NOT_MET
		end
		if self._exiting then
			return self._ReturnCode_t.RTC_OK
		end

		for i, ec in ipairs(self._ecOther) do
			local success, exception = oil.pcall(
				function()
					if not ec:_non_existent() then
						ec:remove_component(self:getObjRef())
					end
				end)
			if not success then
			end
		end

		self._exiting = true
		return self:finalize()
	end

	function obj:attach_context(exec_context)
		return -1
	end

	function obj:detach_context(ec_id)
		return self._ReturnCode_t.BAD_PARAMETER
	end

	function obj:get_ports()
		self._rtcout:RTC_TRACE("get_ports()")
		return self._portAdmin:getPortServiceList()
	end

	function obj:createRef()
		self._svr = self._orb:newservant(self, nil, "IDL:openrtm.aist.go.jp/OpenRTM/DataFlowComponent:1.0")
		--print(type(self._svr))
		self._objref = RTCUtil.getReference(self._orb, self._svr, "IDL:openrtm.aist.go.jp/OpenRTM/DataFlowComponent:1.0")
	end


	function obj:on_finalize()
		self._rtcout:RTC_TRACE("on_finalize()")
		local ret = self._ReturnCode_t.RTC_ERROR
		local success, exception = oil.pcall(
			function()
				self:preOnFinalize(0)
				ret = self:onFinalize()
			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
			ret = self._ReturnCode_t.RTC_ERROR
		end
		self:postOnFinalize(0, ret)
		return ret
	end


	function obj:shutdown()
		self._rtcout:RTC_TRACE("shutdown()")
		local success, exception = oil.pcall(
			function()
				self:finalizePorts()
				self:finalizeContexts()
				--self._orb:deactivate(self._SdoConfigImpl)
				--self._orb:deactivate(self._objref)
				self._SdoConfigImpl:deactivate()
				if self._svr ~= nil then
					self._orb:deactivate(self._svr)
				end
				self._sdoservice:exit()
			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
		end

		if self._manager ~= nil then
			self._rtcout:RTC_DEBUG("Cleanup on Manager")
			self._manager:notifyFinalized(self)
		end

		self._actionListeners = nil
		self._portconnListeners = nil

	end

	function obj:finalizePorts()
		self._rtcout:RTC_TRACE("finalizePorts()")
		self._portAdmin:finalizePorts()
		self._inports = {}
		self._outports = {}
    end


	function obj:finalizeContexts()
		self._rtcout:RTC_TRACE("finalizeContexts()")

		for i,ec in ipairs(self._eclist) do
			ec:stop()
			local success, exception = oil.pcall(
				function()
					--self._orb:deactivate(ec)
				end)
			if not success then
			end
			ec:exit()
		end

		self._eclist = {}
	end


	return obj
end


return RTObject
