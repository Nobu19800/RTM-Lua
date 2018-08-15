local luaunit = require "luaunit"
local InPortPullConnector = require "openrtm.InPortPullConnector"
local ManagerActionListener = require "openrtm.ManagerActionListener"


TestManagerActionListener = {}



local ManagerActionListener_ = {}
ManagerActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.ManagerActionListener.new()})
	obj._preShutdown = 0
	obj._postShutdown = 0
	obj._preReinit = 0
	obj._postReinit = 0
	function obj:preShutdown()
		self._preShutdown = self._preShutdown+1
	end
	function obj:postShutdown()
		self._postShutdown = self._postShutdown+1
	end
	function obj:preReinit()
		self._preReinit = self._preReinit+1
	end
	function obj:postReinit()
		self._postReinit = self._postReinit+1
	end
	return obj
end


local ModuleActionListener_ = {}
ModuleActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.ModuleActionListener.new()})
	obj._preLoad = 0
	obj._postLoad = 0
	obj._preUnload = 0
	obj._postUnload = 0
	function obj:preLoad(modname, funcname)
		self._preLoad = self._preLoad+1
	end
	function obj:postLoad(modname, funcname)
		self._postLoad = self._postLoad+1
	end
	function obj:preUnload(modname)
		self._preUnload = self._preUnload+1
	end
	function obj:postUnload(modname)
		self._postUnload = self._postUnload+1
	end

	return obj
end

local RtcLifecycleActionListener_ = {}
RtcLifecycleActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.RtcLifecycleActionListener.new()})
	obj._preCreate = 0
	obj._postCreate = 0
	obj._preConfigure = 0
	obj._postConfigure = 0
	obj._preInitialize = 0
	obj._postInitialize = 0
	function obj:preCreate(args)
		self._preCreate = self._preCreate+1
	end
	function obj:postCreate(rtobj)
		self._postCreate = self._postCreate+1
	end
	function obj:preConfigure(prop)
		self._preConfigure = self._preConfigure+1
	end
	function obj:postConfigure(prop)
		self._postConfigure = self._postConfigure+1
	end
	function obj:preInitialize()
		self._preInitialize = self._preInitialize+1
	end
	function obj:postInitialize()
		self._postInitialize = self._postInitialize+1
	end

	return obj
end


local NamingActionListener_ = {}
NamingActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.NamingActionListener.new()})

	obj._preBind = 0
	obj._postBind = 0
	obj._preUnbind = 0
	obj._postUnbind = 0


	function obj:preBind(rtobj, name)
		self._preBind = self._preBind+1
	end
	function obj:postBind(rtobj, name)
		self._postBind = self._postBind+1
	end
	function obj:preUnbind(rtobj, name)
		self._preUnbind = self._preUnbind+1
	end
	function obj:postUnbind(rtobj, name)
		self._postUnbind = self._postUnbind+1
	end
	

	return obj
end


local LocalServiceActionListener_ = {}
LocalServiceActionListener_.new = function()
	local obj = {}
	setmetatable(obj, {__index=ManagerActionListener.LocalServiceActionListener.new()})

	obj._preServiceRegister = 0
	obj._postServiceRegister = 0
	obj._preServiceInit = 0
	obj._postServiceInit = 0
	obj._preServiceReinit = 0
	obj._postServiceReinit = 0
	obj._preServiceFinalize = 0
	obj._postServiceFinalize = 0

	function obj:preServiceRegister(service_name)
		self._preServiceRegister = self._preServiceRegister+1
	end
	function obj:postServiceRegister(service_name, service)
		self._postServiceRegister = self._postServiceRegister+1
	end
	function obj:preServiceInit(prop, service)
		self._preServiceInit = self._preServiceInit+1
	end
	function obj:postServiceInit(prop, service)
		self._postServiceInit = self._postServiceInit+1
	end
	function obj:preServiceReinit(prop, service)
		self._preServiceReinit = self._preServiceReinit+1
	end
	function obj:postServiceReinit(prop, service)
		self._postServiceReinit = self._postServiceReinit+1
	end
	function obj:preServiceFinalize(service_name, service)
		self._preServiceFinalize = self._preServiceFinalize+1
	end
	function obj:postServiceFinalize(service_name, service)
		self._postServiceFinalize = self._postServiceFinalize+1
	end
	

	return obj
end


function TestManagerActionListener:test_listener()
	local listeners = ManagerActionListener.ManagerActionListeners.new()
	local listener1 = ManagerActionListener_.new()
	listeners.manager_:addListener(listener1)
	local listener2 = ModuleActionListener_.new()
	listeners.module_:addListener(listener2)
	local listener3 = RtcLifecycleActionListener_.new()
	listeners.rtclifecycle_:addListener(listener3)
	local listener4 = NamingActionListener_.new()
	listeners.naming_:addListener(listener4)
	local listener5 = LocalServiceActionListener_.new()
	listeners.localservice_:addListener(listener5)

	
	listeners.manager_:preShutdown()
	luaunit.assertEquals(listener1._preShutdown,1)
	listeners.manager_:postShutdown()
	luaunit.assertEquals(listener1._postShutdown,1)
	listeners.manager_:preReinit()
	luaunit.assertEquals(listener1._preReinit,1)
	listeners.manager_:postReinit()
	luaunit.assertEquals(listener1._postReinit,1)

	listeners.module_:preLoad("","")
	luaunit.assertEquals(listener2._preLoad,1)
	listeners.module_:postLoad("","")
	luaunit.assertEquals(listener2._postLoad,1)
	listeners.module_:preUnload("")
	luaunit.assertEquals(listener2._preUnload,1)
	listeners.module_:postUnload("")
	luaunit.assertEquals(listener2._postUnload,1)

	listeners.rtclifecycle_:preCreate(nil)
	luaunit.assertEquals(listener3._preCreate,1)
	listeners.rtclifecycle_:postCreate(nil)
	luaunit.assertEquals(listener3._postCreate,1)
	listeners.rtclifecycle_:preConfigure(nil)
	luaunit.assertEquals(listener3._preConfigure,1)
	listeners.rtclifecycle_:postConfigure(nil)
	luaunit.assertEquals(listener3._postConfigure,1)
	listeners.rtclifecycle_:preInitialize()
	luaunit.assertEquals(listener3._preInitialize,1)
	listeners.rtclifecycle_:postInitialize()
	luaunit.assertEquals(listener3._postInitialize,1)

	listeners.naming_:preBind(nil,nil)
	luaunit.assertEquals(listener4._preBind,1)
	listeners.naming_:postBind(nil,nil)
	luaunit.assertEquals(listener4._postBind,1)
	listeners.naming_:preUnbind(nil,nil)
	luaunit.assertEquals(listener4._preUnbind,1)
	listeners.naming_:postUnbind(nil,nil)
	luaunit.assertEquals(listener4._postUnbind,1)

	listeners.localservice_:preServiceRegister("")
	luaunit.assertEquals(listener5._preServiceRegister,1)
	listeners.localservice_:postServiceRegister("",nil)
	luaunit.assertEquals(listener5._postServiceRegister,1)
	listeners.localservice_:preServiceInit(nil,"")
	luaunit.assertEquals(listener5._preServiceInit,1)
	listeners.localservice_:postServiceInit(nil,"")
	luaunit.assertEquals(listener5._postServiceInit,1)
	listeners.localservice_:preServiceReinit(nil,"")
	luaunit.assertEquals(listener5._preServiceReinit,1)
	listeners.localservice_:postServiceReinit(nil,"")
	luaunit.assertEquals(listener5._postServiceReinit,1)
	listeners.localservice_:preServiceFinalize("",nil)
	luaunit.assertEquals(listener5._preServiceFinalize,1)
	listeners.localservice_:postServiceFinalize("",nil)
	luaunit.assertEquals(listener5._postServiceFinalize,1)


end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
