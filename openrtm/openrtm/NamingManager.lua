---------------------------------
--! @file NamingManager.lua
--! @brief ネーミングマネージャ、名前管理基底クラスの定義
---------------------------------


--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local NamingManager= {}
_G["openrtm.NamingManager"] = NamingManager

local oil = require "oil"
local CorbaNaming = require "openrtm.CorbaNaming"



NamingManager.NamingBase = {}

-- 名前管理基底オブジェクト初期化
-- @return 名前管理オブジェクト
NamingManager.NamingBase.new = function()
	local obj = {}
	-- RTCをネームサーバーに登録
	-- @param name 登録名
	-- @param rtobj RTC
	function obj:bindObject(name, rtobj)
	end
	-- ポートをネームサーバーに登録
	-- @param name 登録名
	-- @param port ポート
	function obj:bindPortObject(name, port)
	end
	-- オブジェクトをネームサーバーから登録解除
	-- @param name 登録名
	function obj:unbindObject(name)
	end
	-- ネームサーバー生存確認
	-- @return true：生存、false：終了済み
	function obj:isAlive()
		return true
	end
	-- 文字列からオブジェクトを取得
	-- @param name オブジェクト名
	-- @return オブジェクト一覧
	function obj:string_to_component(name)
		return {}
	end


	return obj
end

NamingManager.NamingOnCorba = {}

-- CORBAネームサーバー管理オブジェクト初期化
-- @param orb ORB
-- @param names アドレス
-- @return CORBAネームサーバー管理オブジェクト
NamingManager.NamingOnCorba.new = function(orb, names)
	local obj = {}
	setmetatable(obj, {__index=NamingManager.NamingBase.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("manager.namingoncorba")
	obj._cosnaming = CorbaNaming.new(orb,names)
	obj._endpoint = ""
    obj._replaceEndpoint = false

	-- RTCをネームサーバーに登録
	-- @param name 登録名
	-- @param rtobj RTC
	function obj:bindObject(name, rtobj)

		self._rtcout:RTC_TRACE("bindObject(name = "..name..", rtobj or mgr)")
		local success, exception = oil.pcall(
			function()

				self._cosnaming:rebindByString(name, rtobj:getObjRef(), true)

			end)
		if not success then
			--print(exception)
			self._rtcout:RTC_ERROR(exception)
		end

    end

	-- オブジェクトをネームサーバーから登録解除
	-- @param name 登録名
	function obj:unbindObject(name)
		self._rtcout:RTC_TRACE("unbindObject(name  = "..name..")")
		local success, exception = oil.pcall(
			function()
				self._cosnaming:unbind(name)
			end)
		if not success then
			--print(exception)
			self._rtcout.RTC_ERROR(exception)
		end

	end

	return obj
end



NamingManager.NamingOnManager = {}

-- Manager名前管理オブジェクト初期化
-- @param orb ORB
-- @param mgr マネージャ
-- @return Manager名前管理オブジェクト
NamingManager.NamingOnManager.new = function(orb, mgr)
	local obj = {}
	setmetatable(obj, {__index=NamingManager.NamingBase.new()})
	local Manager = require "openrtm.Manager"
	obj._rtcout = Manager:instance():getLogbuf("manager.namingonmanager")
	obj._cosnaming = nil
	obj._orb = orb
    obj._mgr = mgr

	return obj
end

-- 名前管理オブジェクト格納オブジェクト初期化
-- @param meth メソッド名
-- @param name オブジェクト名
-- @param naming 名前管理オブジェクト
-- @return 名前管理オブジェクト格納オブジェクト
NamingManager.NameServer = {}
NamingManager.NameServer.new = function(meth, name, naming)
	local obj = {}
	obj.method = meth
	obj.nsname = name
	obj.ns     = naming
	return obj
end


NamingManager.Comps = {}
-- RTC格納オブジェクト初期化
-- @param n 名前
-- @param _obj RTC
-- @return RTC格納オブジェクト
NamingManager.Comps.new = function(n, _obj)
	local obj = {}
	obj.name = n
	obj.rtobj = _obj
	return obj
end

-- ネーミングマネージャ初期化
-- @param manager マネージャ
-- @return ネーミングマネージャ
NamingManager.new = function(manager)
	local obj = {}
	obj._manager = manager
    obj._rtcout = manager:getLogbuf('manager.namingmanager')
    obj._names = {}
    obj._compNames = {}
    obj._mgrNames  = {}
    obj._portNames = {}
    -- 名前管理オブジェクト登録
    -- @param method メソッド名
    -- @param name_server アドレス
	function obj:registerNameServer(method, name_server)
		--print(self._rtcout)
		self._rtcout:RTC_TRACE("NamingManager::registerNameServer("..method..", "..name_server..")")
		name = self:createNamingObj(method, name_server)
		--print(name)
		table.insert(self._names, NamingManager.NameServer.new(method, name_server, name))
	end
    -- 名前管理オブジェクト生成
    -- @param method メソッド名
    -- @param name_server アドレス
    -- @return 名前管理オブジェクト
	function obj:createNamingObj(method, name_server)
		self._rtcout:RTC_TRACE("createNamingObj(method = "..method..", nameserver = "..name_server..")")

		mth = method

		if mth == "corba" then
			ret = nil
			local success, exception = oil.pcall(
				function()
					name = NamingManager.NamingOnCorba.new(self._manager:getORB(),name_server)

					self._rtcout:RTC_INFO("NameServer connection succeeded: "..method.."/"..name_server)
					ret = name
				end)
			if not success then
				print(exception)
				self._rtcout:RTC_INFO("NameServer connection failed: "..method.."/"..name_server)
			end
			return ret
		elseif mth == "manager" then
			name = NamingManager.NamingOnManager(self._manager:getORB(), self._manager)
			return name
		end
		return nil
	end
	-- RTCをネームサーバーに登録
	-- @param name 登録名
	-- @param rtobj RTC
	function obj:bindObject(name, rtobj)
		self._rtcout:RTC_TRACE("NamingManager::bindObject("..name..")")
		for i, n in ipairs(self._names) do
			if n.ns ~= nil then
				local success, exception = oil.pcall(
					function()
						n.ns:bindObject(name, rtobj)
					end)
				if not success then
					n.ns = nil
				end
			end
		end

		self:registerCompName(name, rtobj)
	end
	-- RTCの登録
	-- @param name 登録名
	-- @param rtobj RTC
	function obj:registerCompName(name, rtobj)
		for i, compName in ipairs(self._compNames) do
			if compName.name == name then
				compName.rtobj = rtobj
				return
			end
		end
		table.insert(self._compNames, NamingManager.Comps.new(name, rtobj))
    end

	-- RTCをネームサーバーから登録解除
	-- @param name 登録名
	function obj:unbindObject(name)
		self._rtcout:RTC_TRACE("NamingManager::unbindObject("..name..")")
		for i,n in ipairs(self._names) do
			if n.ns ~= nil then
				n.ns:unbindObject(name)
			end
		end
		self:unregisterCompName(name)
		self:unregisterMgrName(name)
		self:unregisterPortName(name)
	end

	-- RTCの登録解除
	-- @param name 登録名
	function obj:unregisterCompName(name)
	end
	-- マネージャの登録解除
	-- @param name 登録名
	function obj:unregisterMgrName(name)
	end
	-- ポートの登録解除
	-- @param name 登録名
	function obj:unregisterPortName(name)
	end
	return obj
end



return NamingManager
