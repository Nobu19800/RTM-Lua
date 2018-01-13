--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local ConfigAdmin= {}
_G["openrtm.ConfigAdmin"] = ConfigAdmin

local Properties = require "openrtm.Properties"
local ConfigurationListener = require "openrtm.ConfigurationListener"
local ConfigurationListeners = ConfigurationListener.ConfigurationListeners
local StringUtil = require "openrtm.StringUtil"



Config = {}
Config.new = function(name, var, def_val, trans)
	local obj = {}
	obj.name = name
    obj.default_value = def_val
    obj.string_value = ""
    obj.callback = nil
    obj._var = var
    if trans ~= nil then
		obj._trans = trans
    else
		obj._trans = StringUtil.stringTo
	end
	function obj:setCallback(cbf)
		self.callback = cbf
	end
	function obj:notifyUpdate(key, val)
		self.callback(key, val)
	end
	function obj:update(val)
		if self.string_value == val then
			return true
		end
		self.string_value = val


		local ret, value = self._trans(self._var._value, val)
		if ret then
			self._var._value = value
			self:notifyUpdate(self.name, val)
			return true
		end
		local ret, value = self._trans(self._var._value, self.default_value)
		self._var._value = value
		self:notifyUpdate(self.name, val)
		return false
	end


	return obj
end

ConfigAdmin.new = function(configsets)
	local obj = {}
	obj._configsets = configsets
    obj._activeId   = "default"
    obj._active     = true
    obj._changed    = false
    obj._params     = {}
    obj._emptyconf  = Properties.new()
    obj._newConfig  = {}
    obj._listeners  = ConfigurationListeners.new()
    obj._changedParam = {}

	function obj:bindParameter(param_name, var, def_val, trans)
		if trans == nil then
			trans = StringUtil.stringTo
		end

		if param_name == "" or def_val == "" then
			return false
		end

		--print(self:isExist(param_name))
		if self:isExist(param_name) then
			return false
		end

		local ret, value = trans(var._value, def_val)
		--if type(value) == "table" then
		--	print(#value)
		--end
		var._value = value
		if not ret then
			return false
		end
		local conf_ = Config.new(param_name, var, def_val, trans)
		table.insert(self._params, conf_)
		--print(#self._params)
		conf_:setCallback(function(config_param, config_value)self:onUpdateParam(config_param, config_value) end)
		--print(self:getActiveId())
		self:update(self:getActiveId(), param_name)

		return true
	end


	function obj:unbindParameter(param_name)
		local ret_param = nil
		local ret_index = -1
		for find_idx, param in ipairs(self._params) do
			if param.name == param_name then
				ret_param = param
				ret_index = find_idx
			end
		end

		if ret_index == -1 then
			return false
		end

		table.remove(self._params, ret_index)


		local leaf = self._configsets:getLeaf()
		for i, v in ipairs(leaf) do
			if v:hasKey(param_name) then
				v:removeNode(param_name)
			end
		end

		return true
	end


	function obj:haveConfig(config_id)
		if self._configsets:hasKey(config_id) == nil then
			return false
		else
			return true
		end
	end
	function obj:activateConfigurationSet(config_id)
		if config_id == "" then
			return false
		end
		if string.sub(config_id,1,1) == '_' then
			return false
		end
		if not self._configsets:hasKey(config_id) then
			return false
		end
		self._activeId = config_id
		self._active   = true
		self._changed  = true
		self:onActivateSet(config_id)
	end
	function obj:onActivateSet(config_id)
		--self._listeners.configsetname_[OpenRTM_aist.ConfigurationSetNameListenerType.ON_ACTIVATE_CONFIG_SET]:notify(config_id)
	end

	function obj:update(config_set, config_param)

		if config_set ~= nil and config_param == nil then
			if self._configsets:hasKey(config_set) == false then
				return
			end
			self._changedParam = {}
			local prop = self._configsets:getNode(config_set)
			for i, param in ipairs(self._params) do
				if prop:hasKey(param.name) then
					--print(type(param.name))
					--print(prop:getProperty(param.name))
					param:update(prop:getProperty(param.name))
				end
			end
			self:onUpdate(config_set)
		end


		if config_set ~= nil and config_param ~= nil then
			self._changedParam = {}
			local key = config_set
			key = key.."."..config_param
			for i, conf in ipairs(self._params) do
				--print(conf.name, config_param)
				if conf.name == config_param then
					--print(self._configsets:getProperty(key))
					conf:update(self._configsets:getProperty(key))
				end
			end
		end

		if config_set == nil and config_param == nil then
			self._changedParam = {}
			if self._changed and self._active then
				self:update(self._activeId)
				self._changed = false
			end
		end

    end

	function obj:isExist(param_name)
		if #self._params == 0 then
			return false
		end

		for i, conf in ipairs(self._params) do
			if conf.name == param_name then
				return true
			end
		end

		return false
	end


	function obj:isChanged()
		return self._changed
	end

	function obj:changedParameters()
		return self._changedParam
	end


	function obj:getActiveId()
		return self._activeId
	end


	function obj:haveConfig(config_id)
		if self._configsets:hasKey(config_id) == false then
			return false
		else
			return true
		end
	end

	function obj:isActive()
		return self._active
	end

	function obj:getConfigurationSets()
		return self._configsets:getLeaf()
	end

	function obj:getConfigurationSet(config_id)

		local prop = self._configsets:findNode(config_id)
		if prop == nil then
			return self._emptyconf
		end
		return prop
	end


	function obj:setConfigurationSetValues(config_set)
		local node_ = config_set:getName()
		if node_ == "" or node_ == nil then
			return false
		end

		if not self._configsets:hasKey(node_) then
			return false
		end

		local p = self._configsets:getNode(node_)


		p:mergeProperties(config_set)
		self._changed = true
		self._active  = false
		self:onSetConfigurationSet(config_set)
		return true
	end


	function obj:getActiveConfigurationSet()
		p = self._configsets:getNode(self._activeId)


		return p
	end


	function obj:addConfigurationSet(configset)
		if self._configsets:hasKey(configset:getName()) then
			return false
		end
		local node = configset:getName()


		self._configsets:createNode(node)

		local p = self._configsets:getNode(node)


		p:mergeProperties(configset)
		table.insert(self._newConfig, node)

		self._changed = true
		self._active  = false
		self:onAddConfigurationSet(configset)
		return true
	end

	function obj:removeConfigurationSet(config_id)
		if config_id == "default" then
			return false
		end
		if self._activeId == config_id then
			return false
		end

		local find_flg = false

		local ret_idx = -1
		for idx, conf in ipairs(self._newConfig) do
			if conf == config_id then
				ret_idx = idx
				break
			end
		end


		if ret_idx == -1 then
			return false
		end

		local p = self._configsets:getNode(config_id)
		if p ~= nil then
			p:getRoot():removeNode(config_id)
		end

		table.remove(self._newConfig, ret_idx)



		self._changed = true
		self._active  = false
		self:onRemoveConfigurationSet(config_id)
		return true
	end


	function obj:activateConfigurationSet(config_id)
		if config_id == "" then
			return false
		end


		if string.sub(config_id,1,1) == '_' then
			return false
		end

		if not self._configsets:hasKey(config_id) then
			return false
		end
		self._activeId = config_id
		self._active   = true
		self._changed  = true
		self:onActivateSet(config_id)
		return true
	end

	function obj:setOnUpdate(cb)
		print("setOnUpdate function is obsolete.")
		print("Use addConfigurationSetNameListener instead.")
		--self._listeners.configsetname_[ConfigurationSetNameListenerType.ON_UPDATE_CONFIG_SET]:addListener(cb, false)
    end


	function obj:setOnUpdateParam(cb)
		print("setOnUpdateParam function is obsolete.")
		print("Use addConfigurationParamListener instead.")
		--self._listeners.configparam_[ConfigurationParamListenerType.ON_UPDATE_CONFIG_PARAM]:addListener(cb, false)
    end

	function obj:setOnSetConfigurationSet(cb)
		print("setOnSetConfigurationSet function is obsolete.")
		print("Use addConfigurationSetListener instead.")
		--self._listeners.configset_[ConfigurationSetListenerType.ON_SET_CONFIG_SET]:addListener(cb, false)
    end

	function obj:setOnAddConfigurationSet(cb)
		print("setOnAddConfigurationSet function is obsolete.")
		print("Use addConfigurationSetListener instead.")
		--self._listeners.configset_[ConfigurationSetListenerType.ON_ADD_CONFIG_SET]:addListener(cb, false)
    end

	function obj:setOnRemoveConfigurationSet(cb)
		print("setOnRemoveConfigurationSet function is obsolete.")
		print("Use addConfigurationSetNameListener instead.")
		--self._listeners.configsetname_[ConfigurationSetNameListenerType.ON_REMOVE_CONFIG_SET]:addListener(cb, False)
    end


	function obj:setOnActivateSet(cb)
		print("setOnActivateSet function is obsolete.")
		print("Use addConfigurationSetNameListener instead.")
		--self._listeners.configsetname_[ConfigurationSetNameListenerType.ON_ACTIVATE_CONFIG_SET]:addListener(cb, false)
    end

	function obj:addConfigurationParamListener(_type, listener, autoclean)
		if autoclean == nil then
			autoclean = true
		end
		--self._listeners.configparam_[_type]:addListener(listener, autoclean)
    end

	function obj:removeConfigurationParamListener(_type, listener)
		--self._listeners.configparam_[_type]:removeListener(listener)
    end

	function obj:addConfigurationSetListener(_type, listener, autoclean)
		if autoclean == nil then
			autoclean = true
		end
		--self._listeners.configset_[_type]:addListener(listener, autoclean)
    end

	function obj:removeConfigurationSetListener(_type, listener)
		--self._listeners.configset_[_type]:removeListener(listener)
    end

	function obj:addConfigurationSetNameListener(_type, listener, autoclean)
		if autoclean == nil then
			autoclean = true
		end
		--self._listeners.configsetname_[_type]:addListener(listener, autoclean)
    end


	function obj:removeConfigurationSetNameListener(_type, listener)
		--self._listeners.configsetname_[_type]:removeListener(listener)
    end


	function obj:onUpdate(config_set)
		--self._listeners.configsetname_[ConfigurationSetNameListenerType.ON_UPDATE_CONFIG_SET]:notify(config_set)
    end

	function obj:onUpdateParam(config_param, config_value)
		table.insert(self._changedParam, config_param)
		--self._listeners.configparam_[ConfigurationParamListenerType.ON_UPDATE_CONFIG_PARAM]:notify(config_param, config_value)
    end

	function obj:onSetConfigurationSet(config_set)
		--self._listeners.configset_[ConfigurationSetListenerType.ON_SET_CONFIG_SET]:notify(config_set)
    end

	function obj:onAddConfigurationSet(config_set)
		--self._listeners.configset_[ConfigurationSetListenerType.ON_ADD_CONFIG_SET]:notify(config_set)
    end
	function obj:onRemoveConfigurationSet(config_id)
		--self._listeners.configsetname_[ConfigurationSetNameListenerType.ON_REMOVE_CONFIG_SET]:notify(config_id)
    end

	function obj:onActivateSet(onfig_id)
		--self._listeners.configsetname_[ConfigurationSetNameListenerType.ON_ACTIVATE_CONFIG_SET]:notify(config_id)
    end



	return obj
end


return ConfigAdmin
