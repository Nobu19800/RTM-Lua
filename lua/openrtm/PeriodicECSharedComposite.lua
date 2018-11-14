---------------------------------
--! @file PeriodicECSharedComposite.lua
--! @brief 複合コンポーネント用RTC定義
---------------------------------

--[[
Copyright (c) 2018 Nobuhiko Miyamoto
]]

local PeriodicECSharedComposite = {}
--_G["openrtm.PeriodicECSharedComposite"] = PeriodicECSharedComposite

local oil = require "oil"
local StringUtil = require "openrtm.StringUtil"
local ConfigurationListener = require "openrtm.ConfigurationListener"
local ConfigurationSetListener = ConfigurationListener.ConfigurationSetListener
local SdoOrganization = require "openrtm.SdoOrganization"
local Organization_impl = SdoOrganization.Organization_impl
local RTCUtil = require "openrtm.RTCUtil"
local RTObject = require "openrtm.RTObject"
local ConfigurationListener = require "openrtm.ConfigurationListener"
local ConfigurationSetListenerType = ConfigurationListener.ConfigurationSetListenerType
local Factory = require "openrtm.Factory"
local Properties = require "openrtm.Properties"



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


-- 文字列を指定文字で分割
-- @param _is 分割文字
-- @return 分割後の文字列のリスト
function stringToStrVec(_type, _is)
    local p = StringUtil.split(_is, ",")
    return true, StringUtil.strip(p)
end


local setCallback = {}

-- コンフィギュレーション設定時のコールバック関数オブジェクト初期化
-- @param org オーガナイゼーションオブジェクト
-- @return 関数オブジェクト
setCallback.new = function(org)
    local obj = {}
    setmetatable(obj, {__index=ConfigurationSetListener.new()})
    obj._org = org
    -- コールバック関数
    -- @param config_set コンフィギュレーションセット
	function obj:call(config_set)
		self._org:updateDelegatedPorts()
	end
    return obj
end


local addCallback = {}
-- コンフィギュレーション追加時のコールバック関数オブジェクト初期化
-- @param org オーガナイゼーションオブジェクト
-- @return 関数オブジェクト
addCallback.new = function(org)
    local obj = {}
    setmetatable(obj, {__index=ConfigurationSetListener.new()})
    obj._org = org
    -- コールバック関数
    -- @param config_set コンフィギュレーションセット
	function obj:call(config_set)
		self._org:updateDelegatedPorts()
	end
    return obj
end


local PeriodicECOrganization = {}

-- 複合コンポーネント構成オブジェクト初期化
-- @param rtobj rtobj
-- @return 複合コンポーネント構成オブジェクト
PeriodicECOrganization.new = function(rtobj)
    local obj = {}
    setmetatable(obj, {__index=Organization_impl.new(rtobj:getObjRef())})
    obj._rtobj      = rtobj
    obj._ec         = nil
    obj._rtcMembers = {}
    local Manager = require "openrtm.Manager"
    obj._rtcout = Manager:instance():getLogbuf("rtobject.PeriodicECOrganization")
    obj._expPorts = {}
    obj:createRef()


    local Member = {}
    -- 複合コンポーネントメンバー初期化
    -- @param rtobj rtobj
    -- @return メンバー
    Member.new = function(rtobj)
        local obj = {}
        obj._rtobj   = rtobj
        obj._profile = rtobj:get_component_profile()
        obj._eclist  = rtobj:get_owned_contexts()
        obj._config  = rtobj:get_configuration()

        -- メンバーの要素入れ替え
        -- @param self 
        -- @param x 入れ替え元のオブジェクト 
        -- @return 自身のオブジェクト
        local call_func = function(self, x)
            self:swap(x)
            return self
        end

        setmetatable(obj, {__call=call_func})

        -- メンバーの要素入れ替え
        -- @param self 
        -- @param x 入れ替え元のオブジェクト 
        -- @return 自身のオブジェクト
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

    -- メンバー追加
    -- @param sdo_list 追加するsdo
    -- @return true：追加成功
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

    -- メンバー設定
    -- @param sdo_list 設定するsdo
    -- @return true：設定成功
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

    -- メンバー削除
    -- @param id 削除するメンバーのid
    -- @return true：削除成功
    function obj:remove_member(id)
        self._rtcout:RTC_DEBUG("remove_member(id = %s)", id)
        local rm_rtc = {}
        for k,member in ipairs(self._rtcMembers) do
            if tostring(id) == tostring(member._profile.instance_name) then
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

    -- 全てのメンバー削除
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

    -- SDOをDataFlowComponentに変換する
    -- @param sdo SDO
    -- @return ret, dfc
    -- ret：trueで変換成功
    -- dfc：DataFlowComponent
    function obj:sdoToDFC(sdo)
        if sdo == oil.corba.idl.null then
            return false, nil
        end

        local Manager = require "openrtm.Manager"
		local orb = Manager:instance():getORB()
        local dfc = RTCUtil.newproxy(orb, sdo,"IDL:OpenRTM/DataFlowComponent:1.0")
        
        if dfc == oil.corba.idl.null then
            return false, nil
        end

        return true, dfc
    end

    -- メンバーの実行コンテキストを停止
    -- @param member メンバー
    function obj:stopOwnedEC(member)
        local ecs = member._eclist
        for k,ec in ipairs(ecs) do
            ec:stop()
        end
    end
    
    -- メンバーの実行コンテキストを開始
    -- @param member メンバー
    function obj:startOwnedEC(member)
        local ecs = member._eclist
        for k,ec in ipairs(ecs) do
            ec:start()
        end
    end

    -- メンバーに構成オブジェクト(複合コンポーネント)を設定
    -- @param member メンバー
    function obj:addOrganizationToTarget(member)
        local conf = member._config
        if conf == oil.corba.idl.null then
            return
        end

        conf:add_organization(self._objref)
    end

    -- メンバーから構成オブジェクト(複合コンポーネント)を削除
    -- @param member メンバー
    function obj:removeOrganizationFromTarget(member)
        if member._config == oil.corba.idl.null then
            return
        end
        
        member._config:remove_organization(self._pId)
    end

    -- メンバーに複合コンポーネントのECを追加
    -- @param member メンバー
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

    -- RTCに複合コンポーネントのECを追加
    -- RTCが複合コンポーネントの場合は子コンポーネントにECを追加する
    -- @param rtobj RTC
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

    -- メンバーから複合コンポーネントのECを削除
    -- @param member メンバー
    function obj:removeParticipantFromEC(member)
        if self._ec == oil.corba.idl.null or self._ec == nil then
            local ecs = self._rtobj:get_owned_contexts()
            if #ecs > 0 then
                self._ec = ecs[1]
            else
                self._rtcout:RTC_FATAL("no owned EC")
            end
        end

        self._ec:remove_component(member._rtobj)

        
        local orglist = member._rtobj:get_owned_organizations()
        --print(#orglist)

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

    -- 複合コンポーネントにメンバーのポートを追加する
    -- @param menber メンバー
    -- @param portlist 追加するポート名一覧
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
                self._rtobj:addPortRef(prof.port_ref)
                self._rtcout:RTC_DEBUG("Port %s was delegated.", port_name)
            end
        end
    end

    -- 複合コンポーネントからメンバーのポートを削除する
    -- @param menber メンバー
    -- @param portlist 削除するポート名一覧
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
                self._rtobj:removePortRef(prof.port_ref)
                table.remove(portlist, StringUtil.table_index(portlist, port_name))
                self._rtcout:RTC_DEBUG("Port %s was deleted.", port_name)
            end
        end
    end

    -- 複合コンポーネントに追加するポート一覧更新
    function obj:updateExportedPortsList()
        local plist = self._rtobj:getProperties():getProperty("conf.default.exported_ports")
        if #plist > 0 then
            local p = StringUtil.split(plist, ",")
            self._expPorts = StringUtil.strip(p)
        end
    end

    -- 複合コンポーネントのポート更新
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
-- @param manager マネージャ
-- @return 複合コンポーネント
PeriodicECSharedComposite.new = function(manager)
    local obj = {}
    setmetatable(obj, {__index=RTObject.new(manager)})

  
    obj._members = {_value={}}
    obj:bindParameter("members", obj._members, " ", stringToStrVec)
    local Manager = require "openrtm.Manager"
    obj._rtcout = Manager:instance():getLogbuf("rtobject.periodic_ec_shared")


    

    obj._properties:setProperty("exec_cxt.periodic.sync_transition","NO")
    obj._properties:setProperty("exec_cxt.periodic.sync_activation","NO")
    obj._properties:setProperty("exec_cxt.periodic.sync_deactivation","NO")
    obj._properties:setProperty("exec_cxt.periodic.sync_reset","NO")

    local orb = Manager:instance():getORB()
    obj._ReturnCode_t = orb.types:lookup("::RTC::ReturnCode_t").labelvalue

    obj._shutdown = obj.shutdown
    -- RTC終了処理
    function obj:shutdown()
        self:_shutdown()
        local Manager = require "openrtm.Manager"
        local orb = Manager:instance():getORB()
        
        orb:deactivate(self._org._svr)
    end

    -- RTC初期化時のコールバック関数
    -- @return リターンコード
    -- RTC_OK：問題なし
    function obj:onInitialize()
        self._rtcout:RTC_TRACE("onInitialize()")

        self._ref = self:getObjRef()
        self._objref = self._ref
        self._org = PeriodicECOrganization.new(self)
        table.insert(self._sdoOwnedOrganizations, self._org:getObjRef())

        self._configsets:addConfigurationSetListener(
            ConfigurationSetListenerType.ON_SET_CONFIG_SET,
            setCallback.new(self._org))
    
        self._configsets:addConfigurationSetListener(
            ConfigurationSetListenerType.ON_ADD_CONFIG_SET,
            addCallback.new(self._org))

    
        local active_set = self._properties:getProperty("configuration.active_config",
                                                  "default")
        
        if self._configsets:haveConfig(active_set) then
            self._configsets:update(active_set)
        else
            self._configsets:update("default")
        end
        local Manager = require "openrtm.Manager"
        local mgr = Manager:instance()
        local sdos = {}
        for k,member in ipairs(self._members._value) do
            member = string.gsub(member, "|","")
            
            member = StringUtil.eraseHeadBlank(member)
            if member == "" then
            else
                local rtc = mgr:getComponent(member)
                if rtc == nil then
                    print("no RTC found: ", member)
                else
                    sdo = rtc:getObjRef()
                    if sdo == oil.corba.idl.null then
                    else
                        table.insert(sdos, sdo)
                    end
                end
            end
        end
        local success, exception = oil.pcall(
			function()
				self._org:set_members(sdos)
		end)
        
        if not success then
            self._rtcout:RTC_ERROR(exception)
        end
        
    
        return self._ReturnCode_t.RTC_OK
    end

    -- アクティブ状態遷移時のコールバック関数
    -- @param exec_handle 実行コンテキストのID
    -- @return リターンコード
    -- RTC_OK：問題なし
    function obj:onActivated(exec_handle)
        self._rtcout:RTC_TRACE("onActivated(%d)", exec_handle)
        local sdos = self._org:get_members()
    
        for k,sdo in ipairs(sdos) do
            local Manager = require "openrtm.Manager"
            local orb = Manager:instance():getORB()
            local rtc = RTCUtil.newproxy(orb, sdo,"IDL:omg.org/RTC/RTObject:1.0")

            self:activateChildComp(rtc)
        end

        local len_ = #self._members._value
    
        local str_ = ""
        if len_ > 1 then
            str_ = "s were"
        else
            str_ = "was"
        end
    
        self._rtcout:RTC_DEBUG("%d member RTC%s activated.", len_, str_)
        
        return self._ReturnCode_t.RTC_OK
    end

    -- 子コンポーネントのアクティブ化
    -- 子コンポーネントが複合コンポーネントの場合は、孫コンポーネントをアクティブ化
    -- @param rtobj 子コンポーネント
    function obj:activateChildComp(rtobj)
        local ecs = self:get_owned_contexts()

        local orglist = rtobj:get_owned_organizations()
        
        if #orglist == 0 then
            ecs[1]:activate_component(rtobj)
        end
          
        for k,org in ipairs(orglist) do
            local child_sdos = org:get_members()
            for j,child_sdo in ipairs(child_sdos) do
                local Manager = require "openrtm.Manager"
                local orb = Manager:instance():getORB()
                local child = RTCUtil.newproxy(orb, child_sdo,"IDL:omg.org/RTC/RTObject:1.0")
                self:activateChildComp(child)
            end
        end
    
    end

    -- 非アクティブ状態遷移時のコールバック関数
    -- @param exec_handle 実行コンテキストのID
    -- @return リターンコード
    -- RTC_OK：問題なし
    function obj:onDeactivated(exec_handle)
        self._rtcout:RTC_TRACE("onDeactivated(%d)", exec_handle)
        local sdos = self._org:get_members()
    
        for k,sdo in ipairs(sdos) do
            local Manager = require "openrtm.Manager"
            local orb = Manager:instance():getORB()
            local rtc = RTCUtil.newproxy(orb, sdo,"IDL:omg.org/RTC/RTObject:1.0")

            self:deactivateChildComp(rtc)
        end
        
        return self._ReturnCode_t.RTC_OK
    end

    -- 子コンポーネントの非アクティブ化
    -- 子コンポーネントが複合コンポーネントの場合は、孫コンポーネントを非アクティブ化
    -- @param rtobj 子コンポーネント
    function obj:deactivateChildComp(rtobj)
        local ecs = self:get_owned_contexts()

        local orglist = rtobj:get_owned_organizations()
        if #orglist == 0 then
            ecs[1]:deactivate_component(rtobj)
        end
          
        for k,org in ipairs(orglist) do
            local child_sdos = org:get_members()
            for j,child_sdo in ipairs(child_sdos) do
                local Manager = require "openrtm.Manager"
                local orb = Manager:instance():getORB()
                local child = RTCUtil.newproxy(orb, child_sdo,"IDL:omg.org/RTC/RTObject:1.0")
                self:deactivateChildComp(child)
            end
        end
    
    end


    -- リセット実行時のコールバック関数
    -- @param exec_handle 実行コンテキストのID
    -- @return リターンコード
    -- RTC_OK：問題なし
    function obj:onReset(exec_handle)
        self._rtcout:RTC_TRACE("onReset(%d)", exec_handle)
        local sdos = self._org:get_members()
    
        for k,sdo in ipairs(sdos) do
            local Manager = require "openrtm.Manager"
            local orb = Manager:instance():getORB()
            local rtc = RTCUtil.newproxy(orb, sdo,"IDL:omg.org/RTC/RTObject:1.0")

            self:resetChildComp(rtc)
        end
        
        return self._ReturnCode_t.RTC_OK
    end

    -- 子コンポーネントのリセット
    -- 子コンポーネントが複合コンポーネントの場合は、孫コンポーネントをリセット
    -- @param rtobj 子コンポーネント
    function obj:resetChildComp(rtobj)
        local ecs = self:get_owned_contexts()

        local orglist = rtobj:get_owned_organizations()
        if #orglist == 0 then
            ecs[1]:reset_component(rtobj)
        end
          
        for k,org in ipairs(orglist) do
            local child_sdos = org:get_members()
            for j,child_sdo in ipairs(child_sdos) do
                local Manager = require "openrtm.Manager"
                local orb = Manager:instance():getORB()
                local child = RTCUtil.newproxy(orb, child_sdo,"IDL:omg.org/RTC/RTObject:1.0")
                self:resetChildComp(child)
            end
        end
    
    end
    -- 終了時コールバック関数
    -- @param rtobj 子コンポーネント
    -- @return リターンコード
    -- RTC_OK：問題なし
    function obj:onFinalize()
        self._rtcout:RTC_TRACE("onFinalize()")
        self._org:removeAllMembers()
        self._rtcout:RTC_PARANOID("onFinalize() done")
        return self._ReturnCode_t.RTC_OK
    end

    return obj
end

-- 周期実行コンテキスト生成ファクトリ登録
PeriodicECSharedComposite.Init = function(manager)
    local prof = Properties.new({defaults_map=periodicecsharedcomposite_spec})
	manager:registerFactory(prof,
	    PeriodicECSharedComposite.new,
	    Factory.Delete)
end


return PeriodicECSharedComposite
