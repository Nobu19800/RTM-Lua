---------------------------------
--! @file PeriodicECSharedComposite.lua
--! @brief 複合コンポーネント用RTC定義
---------------------------------

--[[
Copyright (c) 2018 Nobuhiko Miyamoto
]]

local PeriodicECSharedComposite = {}
--_G["openrtm.PeriodicECSharedComposite"] = PeriodicECSharedComposite

local StringUtil = require "openrtm.StringUtil"
local ConfigurationListener = require "openrtm.ConfigurationListener"
local ConfigurationSetListener = ConfigurationListener.ConfigurationSetListener
local SdoOrganization = require "openrtm.SdoOrganization"
local Organization_impl = SdoOrganization.Organization_impl
local RTCUtil = require "openrtm.RTCUtil"



-- RTCの仕様をテーブルで定義する
local periodicecsharedcomposite_spec = {
    ["implementation_id"]="PeriodicECSharedComposite",
    ["type_name"]="PeriodicECSharedComposite",
    ["description"]="PeriodicECSharedComposite",
    ["version"]="1.0",
    ["vendor"]="jp.go.aist",
    ["category"]="composite.PeriodicECShared",
    ["activity_type"]="DataFlowComponent",
    ["max_instance"]="0",
    ["language"]="Python",
    ["lang_type"]="script",
    ["exported_ports"]="",
    ["conf.default.members"]="",
    ["conf.default.exported_ports"]=""}


function stringToStrVec(_is)
    _is = StringUtil.eraseHeadBlank(_is)
    return StringUtil.split(_is)
end


local setCallback = {}
setCallback.new = function(org)
    local obj = {}
    setmetatable(obj, {__index=ConfigurationSetListener.new()})
    obj._org = org
	function obj:call(config_set)
		self._org:updateDelegatedPorts()
	end
    return obj
end


local addCallback = {}
addCallback.new = function(org)
    local obj = {}
    setmetatable(obj, {__index=ConfigurationSetListener.new()})
    obj._org = org
	function obj:call(config_set)
		self._org:updateDelegatedPorts()
	end
    return obj
end


local PeriodicECOrganization = {}
PeriodicECOrganization.new = function(rtobj)
    local obj = {}
    setmetatable(obj, {__index=Organization_impl.new(rtobj:getObjRef())})
    obj._rtobj      = rtobj
    obj._ec         = nil
    obj._rtcMembers = {}
    local Manager = require "openrtm.Manager"
    obj._rtcout = Manager:instance():getLogbuf("rtobject.PeriodicECOrganization")
    obj._expPorts = {}


    local Member = {}
    Member.new = function(rtobj)
        local obj = {}
        obj._rtobj   = rtobj
        obj._profile = rtobj.get_component_profile()
        obj._eclist  = rtobj.get_owned_contexts()
        obj._config  = rtobj.get_configuration()
        local call_func = function(self, x)
            self:swap(x)
            return self
        end

        setmetatable(obj, {__call=call_func})
        
        function obj:swap(x)
            local rtobj   = x._rtobj
            local profile = x._profile
            local eclist  = x._eclist
            local config  = x._config
      
            x._rtobj   = self._rtobj
            x._profile = self._profile
            x._eclist  = self._eclist
            x._config  = self._config

            self._rtobj   = rtobj
            self._profile = profile
            self._eclist  = eclist
            self._config  = config
        end
        return obj
    end


    obj._add_members = obj.add_members
    function obj:add_members(sdo_list)
        self._rtcout:RTC_DEBUG("add_members()")
        self:updateExportedPortsList()
        for k,sdo in ipairs(sdo_list) do
            local ret,dfc = self:sdoToDFC(sdo)
            if not ret then
                table.remove(sdo_list, StringUtil.table_index(sdo_list, sdo))
            else
                local member = Member.new(dfc)
                self:stopOwnedEC(member)
                self:addOrganizationToTarget(member)
                self:addParticipantToEC(member)
                self:addPort(member, self._expPorts)
                table.insert(self._rtcMembers, member)                
            end
        end
        local result = self:_add_members(sdo_list)
        return result
    end

    obj._set_members = obj.set_members
    function obj:set_members(sdo_list)
        self._rtcout:RTC_DEBUG("set_members()")
        self:removeAllMembers()
        self:updateExportedPortsList()

        for k,sdo in ipairs(sdo_list) do
            local ret,dfc = self:sdoToDFC(sdo)
            if not ret then
                table.remove(sdo_list, StringUtil.table_index(sdo_list, sdo))
            else
                local member = Member.new(dfc)
                self:stopOwnedEC(member)
                self:addOrganizationToTarget(member)
                self:addParticipantToEC(member)
                self:addPort(member, self._expPorts)
                table.insert(self._rtcMembers, member)
            end
        end
      
        local result = self:_set_members(sdo_list)
        return result
    end

    obj._remove_member = obj.remove_member
    function obj:remove_member(id)
        self._rtcout.RTC_DEBUG("remove_member(id = %s)", id)
        rm_rtc = []
        for k,member in ipairs(self._rtcMembers) do
            if str(id) ~= str(member._profile.instance_name) then
                self:removePort(member, self._expPorts)
                self._rtobj:getProperties():setProperty("conf.default.exported_ports", StringUtil.flatten(self._expPorts))
                self:removeParticipantFromEC(member)
                self:removeOrganizationFromTarget(member)
                self:startOwnedEC(member)
                table.insert(rm_rtc, member)
            end
        end

        for k,m in ipairs(rm_rtc) do
            table.remove(self._rtcMembers, StringUtil.table_index(self._rtcMembers, m))
        end
            
        local result = self:_remove_member(id)
        return result
    end

    function obj:removeAllMembers()
        self._rtcout:RTC_DEBUG("removeAllMembers()")
        self:updateExportedPortsList()
        for k,member in ipairs(self._rtcMembers) do
            self:removePort(member, self._expPorts)
            self:removeParticipantFromEC(member)
            self:removeOrganizationFromTarget(member)
            self:startOwnedEC(member)
            self:_remove_member(member._profile.instance_name)
        end
        self._rtcMembers = {}
        self._expPorts   = {}
    end

    function obj:sdoToDFC(sdo)
        if sdo == oil.corba.idl.null then
            return false, nil
        end

        local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()
        local dfc = RTCUtil.newproxy(orb, ior,"IDL:openrtm.aist.go.jp/OpenRTM/DataFlowComponent:1.0")
        
        if dfc == oil.corba.idl.null then
            return false, nil
        end

        return true, dfc
    end

    function obj:stopOwnedEC(member)
        local ecs = member._eclist
        for k,ec in ipairs(ecs) do
            ec:stop()
        end
    end
    
    function obj:startOwnedEC(member)
        local ecs = member._eclist
        for k,ec in ipairs(ecs) do
            ec:start()
        end
    end

    function obj:addOrganizationToTarget(member)
        local conf = member._config
        if conf == oil.corba.idl.null then
            return
        end

        conf:add_organization(self._objref)
    end


    function obj:removeOrganizationFromTarget(member)
        if member._config == oil.corba.idl.null then
            return
        end

        member._config:remove_organization(self._pId)
    end

    function obj:addParticipantToEC(member)
        if self._ec == oil.corba.idl.null or self._ec == nil then
            local ecs = self._rtobj:get_owned_contexts()
            if #ecs > 0 then
                self._ec = ecs[1]
            else
                return
            end
        
        end
        self:addRTCToEC(member._rtobj)
    end


    function obj:addRTCToEC(rtobj)

        local orglist = rtobj:get_owned_organizations()
        if #orglist == 0 then
            self._ec:add_component(rtobj)
        end
    
        for k,org in ipairs(orglist) do
            local sdos = org:get_members()
            for j,sdo in ipairs(sdos) do
                local ret,dfc = self:sdoToDFC(sdo)
                if not ret then
                else
                    self:addRTCToEC(dfc)
                end
            end
        end
    end

    function obj:removeParticipantFromEC(member)
    if self._ec == oil.corba.idl.null or self._ec == nil then
        local ecs = self._rtobj:get_owned_contexts()
        if #ecs > 0 then
            self._ec = ecs[1]
        else
            self._rtcout:RTC_FATAL("no owned EC")
        end
        self._ec:remove_component(member._rtobj)

    
        local orglist = member._rtobj:get_owned_organizations()

        for k,org in ipairs(orglist) do
            local sdos = org:get_members()
            for j,sdo in ipairs(sdos) do
                local ret,dfc = self:sdoToDFC(sdo)
                if not ret then
                else
                    self._ec:remove_component(dfc)
                end
            end
        end
    end

    function obj:addPort(member, portlist)
        self._rtcout:RTC_TRACE("addPort(%s)", StringUtil.flatten(portlist))
        if #portlist == 0 then
            return
        end

        local plist = member._profile.port_profiles
      
        for k,prof in ipairs(plist) do
            local port_name = prof.name

            self._rtcout:RTC_DEBUG("port_name: %s is in %s?", port_name,StringUtil.flatten(portlist))
            if StringUtil.table_index(portlist, port_name) == -1 then
                self._rtcout:RTC_DEBUG("Not found: %s is in %s?", port_name,StringUtil.flatten(portlist))
            else
                self._rtcout:RTC_DEBUG("Found: %s is in %s", port_name,StringUtil.flatten(portlist))
                self._rtobj:addPort(prof.port_ref)
                self._rtcout:RTC_DEBUG("Port %s was delegated.", port_name)
            end
        end
    end


    function obj:removePort(member, portlist)
        self._rtcout:RTC_DEBUG("removePort()")
        if #portlist == 0 then
            return
        end

        local plist = member._profile.port_profiles

        for k,prof in ipairs(plist) do
            local port_name = prof.name
        
            self._rtcout:RTC_DEBUG("port_name: %s is in %s?", port_name,StringUtil.flatten(portlist))
            if StringUtil.table_index(portlist, port_name) == -1 then
                self._rtcout:RTC_DEBUG("Not found: %s is in %s?", port_name,StringUtil.flatten(portlist))
            else
                self._rtcout:RTC_DEBUG("Found: %s is in %s", port_name,StringUtil.flatten(portlist))
                self._rtobj:removePort(prof.port_ref)
                table.remove(portlist, StringUtil.table_index(portlist, port_name))
                self._rtcout:RTC_DEBUG("Port %s was deleted.", port_name)
            end
        end
    end

    function obj:updateExportedPortsList()
        local plist = self._rtobj:getProperties():getProperty("conf.default.exported_ports")
        if #plist > 0 then
            local p = StringUtil.eraseBlank(plist)
            self._expPorts = StringUtil.split(p, ",")
        end
    end


    function obj:updateDelegatedPorts()
        local oldPorts = self._expPorts
        local ports = self._rtobj:getProperties():getProperty("conf.default.exported_ports")
        local newPorts = StringUtil.split(ports, ",")

    
        local removedPorts = StringUtil.difference(oldPorts, newPorts)
        local createdPorts = StringUtil.difference(newPorts, oldPorts)
    
        self._rtcout:RTC_VERBOSE("old    ports: %s", StringUtil.flatten(oldPorts))
        self._rtcout:RTC_VERBOSE("new    ports: %s", StringUtil.flatten(newPorts))
        self._rtcout:RTC_VERBOSE("remove ports: %s", StringUtil.flatten(removedPorts))
        self._rtcout:RTC_VERBOSE("add    ports: %s", StringUtil.flatten(createdPorts))

        for k,member in ipairs(self._rtcMembers) do
            self:removePort(member, removedPorts)
            self:addPort(member, createdPorts)
        end

        self._expPorts = newPorts
    end

    return obj
end


-- 複合コンポーネント初期化
-- @return 複合コンポーネント
PeriodicECSharedComposite.new = function()
    local obj = {}
    return obj
end

return PeriodicECSharedComposite
