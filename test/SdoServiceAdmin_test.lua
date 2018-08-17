local luaunit = require "luaunit"
local SdoServiceAdmin = require "openrtm.SdoServiceAdmin"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local SdoServiceConsumerBase = require "openrtm.SdoServiceConsumerBase"
local SdoServiceConsumerFactory = SdoServiceConsumerBase.SdoServiceConsumerFactory
local SdoServiceProviderBase = require "openrtm.SdoServiceProviderBase"
local SdoServiceProviderFactory = SdoServiceProviderBase.SdoServiceProviderFactory

local StringUtil = require "openrtm.StringUtil"
local Factory = require "openrtm.Factory"

TestSdoServiceAdmin = {}


local RTObjectMock = {}
RTObjectMock.new = function(prop)
	local obj = {}
	obj._prop = prop
	function obj:getProperties()
		return self._prop
	end
	return obj
end




local SdoServiceConsumerBaseTest = {}
SdoServiceConsumerBaseTest.new = function()
	local obj = {}
	setmetatable(obj, {__index=SdoServiceConsumerBase.new()})
	function obj:init(rtobj, profile)
		self._profile = profile
		return true
	end
	function obj:reinit(profile)
		self._profile = profile
		return true
	end
	function obj:getProfile()
		return self._profile
	end
	function obj:finalize()
	end
	return obj
end


local SdoServiceConsumerBaseTest2 = {}
SdoServiceConsumerBaseTest2.new = function()
	local obj = {}
	setmetatable(obj, {__index=SdoServiceConsumerBase.new()})
	function obj:init(rtobj, profile)
		self._profile = profile
		return false
	end
	function obj:reinit(profile)
		self._profile = profile
		return true
	end
	function obj:getProfile()
		return self._profile
	end
	function obj:finalize()
	end
	return obj
end

local SdoServiceProviderBaseTest = {}
SdoServiceProviderBaseTest.new = function()
	local obj = {}
	setmetatable(obj, {__index=SdoServiceProviderBase.new()})
	obj:createRef()
	function obj:init(rtobj, profile)
		self._profile = profile
		return true
	end
	function obj:reinit(profile)
		self._profile = profile
		return true
	end
	function obj:getProfile()
		return self._profile
	end
	function obj:finalize()
	end
	return obj
end



function TestSdoServiceAdmin:test_service()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0","-o"})--,"logger.file_name: stdout"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	
	local orb = mgr:getORB()

	local prop = Properties.new()
	local condumerfactory_ = SdoServiceConsumerFactory:instance()

	condumerfactory_:addFactory("IDL:SdoServiceTest:1.0",
						SdoServiceConsumerBaseTest.new,
						Factory.Delete)
	condumerfactory_:addFactory("IDL:SdoServiceTest2:1.0",
						SdoServiceConsumerBaseTest2.new,
						Factory.Delete)


	local providerfactory_ = SdoServiceProviderFactory:instance()

	providerfactory_:addFactory("IDL:SdoServiceTest:1.0",
						SdoServiceProviderBaseTest.new,
						Factory.Delete)

	prop:setProperty("sdo.service.consumer.available_services",
								StringUtil.flatten(condumerfactory_:getIdentifiers()))
    prop:setProperty("sdo.service.provider.available_services",
								StringUtil.flatten(providerfactory_:getIdentifiers()))
	prop:setProperty("sdo.service.provider.enabled_services", "all")
	prop:setProperty("sdo.service.consumer.enabled_services", "all")
	--print(StringUtil.flatten(condumerfactory_:getIdentifiers()))
	local rtobj = RTObjectMock.new(prop)

	local sdoservice = SdoServiceAdmin.new(rtobj)
	--luaunit.assertNotEquals(conf:getObjRef(),nil)
	sdoservice:init(rtobj)

	local provider = SdoServiceProviderBaseTest.new()
	local sprof = {id="id1",
					interface_type="IDL:SdoServiceTest:1.0",
					properties={},
					service=provider}
	luaunit.assertIsTrue(sdoservice:addSdoServiceConsumer(sprof))
	luaunit.assertIsTrue(sdoservice:addSdoServiceConsumer(sprof))

	local provider = SdoServiceProviderBaseTest.new()
	local sprof1 = {id="id2",
					interface_type="IDL:SdoServiceTest2:1.0",
					properties={},
					service=provider}
	luaunit.assertIsFalse(sdoservice:addSdoServiceConsumer(sprof1))

	luaunit.assertIsTrue(sdoservice:isEnabledConsumerType(sprof))
	luaunit.assertIsTrue(sdoservice:isExistingConsumerType(sprof))
	

	luaunit.assertIsTrue(sdoservice:removeSdoServiceConsumer("id1"))
	luaunit.assertIsFalse(sdoservice:removeSdoServiceConsumer("id1"))


	local sprof2 = {id="id1",
				interface_type="IDL:dummy:1.0",
				properties={},
				service=provider}
	luaunit.assertIsFalse(sdoservice:addSdoServiceConsumer(sprof2))

	sdoservice:exit()

	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
