local luaunit = require "luaunit"
local ComponentActionListener = require "openrtm.ComponentActionListener"

local ComponentActionListeners = ComponentActionListener.ComponentActionListeners
local PreComponentActionListenerType = ComponentActionListener.PreComponentActionListenerType
local PostComponentActionListenerType = ComponentActionListener.PostComponentActionListenerType
local PortActionListenerType = ComponentActionListener.PortActionListenerType
local ExecutionContextActionListenerType = ComponentActionListener.ExecutionContextActionListenerType
local PreComponentActionListener = ComponentActionListener.PreComponentActionListener
local PostComponentActionListener = ComponentActionListener.PostComponentActionListener
local PortActionListener = ComponentActionListener.PortActionListener
local ExecutionContextActionListener = ComponentActionListener.ExecutionContextActionListener
local ComponentActionListener = ComponentActionListener.ComponentActionListener



TestComponentActionListener = {}
function TestComponentActionListener:test_ComponentActionListeners()
	local listeners = ComponentActionListeners.new()
	local listener = PreComponentActionListener.new()
	listeners.preaction_[PreComponentActionListenerType.PRE_ON_INITIALIZE]:addListener(listener, true)
	listeners.preaction_[PreComponentActionListenerType.PRE_ON_INITIALIZE]:notify(0)
	listeners.preaction_[PreComponentActionListenerType.PRE_ON_INITIALIZE]:removeListener(listener)
	local listener = PostComponentActionListener.new()
	listeners.postaction_[PostComponentActionListenerType.POST_ON_INITIALIZE]:addListener(listener, true)
	listeners.postaction_[PostComponentActionListenerType.POST_ON_INITIALIZE]:notify(0,0)
	listeners.postaction_[PostComponentActionListenerType.POST_ON_INITIALIZE]:removeListener(listener)
	local listener = PortActionListener.new()
	listeners.portaction_[PortActionListenerType.ADD_PORT]:addListener(listener, true)
	listeners.portaction_[PortActionListenerType.ADD_PORT]:notify(0)
	listeners.portaction_[PortActionListenerType.ADD_PORT]:removeListener(listener)
	local listener = ExecutionContextActionListener.new()
	listeners.ecaction_[ExecutionContextActionListenerType.EC_ATTACHED]:addListener(listener, true)
	listeners.ecaction_[ExecutionContextActionListenerType.EC_ATTACHED]:notify(0)
	listeners.ecaction_[ExecutionContextActionListenerType.EC_ATTACHED]:removeListener(listener)

end

function TestComponentActionListener:test_toString()

	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_INITIALIZE), 'PRE_ON_INITIALIZE' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_FINALIZE), 'PRE_ON_FINALIZE' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_STARTUP), 'PRE_ON_STARTUP' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_SHUTDOWN), 'PRE_ON_SHUTDOWN' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_ACTIVATED), 'PRE_ON_ACTIVATED' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_DEACTIVATED), 'PRE_ON_DEACTIVATED' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_ABORTING), 'PRE_ON_ABORTING' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_ERROR), 'PRE_ON_ERROR' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_RESET), 'PRE_ON_RESET' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_EXECUTE), 'PRE_ON_EXECUTE' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_STATE_UPDATE), 'PRE_ON_STATE_UPDATE' )
	luaunit.assertEquals( PreComponentActionListener.toString(PreComponentActionListenerType.PRE_ON_RATE_CHANGED), 'PRE_ON_RATE_CHANGED' )

	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_INITIALIZE), 'POST_ON_INITIALIZE' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_FINALIZE), 'POST_ON_FINALIZE' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_STARTUP), 'POST_ON_STARTUP' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_SHUTDOWN), 'POST_ON_SHUTDOWN' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_ACTIVATED), 'POST_ON_ACTIVATED' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_DEACTIVATED), 'POST_ON_DEACTIVATED' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_ABORTING), 'POST_ON_ABORTING' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_ERROR), 'POST_ON_ERROR' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_RESET), 'POST_ON_RESET' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_EXECUTE), 'POST_ON_EXECUTE' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_STATE_UPDATE), 'POST_ON_STATE_UPDATE' )
	luaunit.assertEquals( PostComponentActionListener.toString(PostComponentActionListenerType.POST_ON_RATE_CHANGED), 'POST_ON_RATE_CHANGED' )


	luaunit.assertEquals( PortActionListener.toString(PortActionListenerType.ADD_PORT), 'ADD_PORT' )
	luaunit.assertEquals( PortActionListener.toString(PortActionListenerType.REMOVE_PORT), 'REMOVE_PORT' )


	luaunit.assertEquals( ExecutionContextActionListener.toString(ExecutionContextActionListenerType.EC_ATTACHED), 'EC_ATTACHED' )
	luaunit.assertEquals( ExecutionContextActionListener.toString(ExecutionContextActionListenerType.EC_DETACHED), 'EC_DETACHED' )
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
