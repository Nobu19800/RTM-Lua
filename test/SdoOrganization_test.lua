local luaunit = require "luaunit"
local SdoOrganization = require "openrtm.SdoOrganization"
local Properties = require "openrtm.Properties"
local oil = require "oil"
local ConfigAdmin = require "openrtm.ConfigAdmin"
local NVUtil = require "openrtm.NVUtil"

TestSdoOrganization = {}

local SDO_Moc = {}
SDO_Moc.new = function(id)
	local obj = {}
	obj._id = id
	function obj:get_owned_organizations()
	end
	function obj:get_sdo_id()
		return self._id
	end
	function obj:get_device_profile()
	end
	function obj:get_service_profiles()
	end
	function obj:get_service_profile(id)
	end
	function obj:get_sdo_service(id)
	end
	function obj:get_configuration()
	end
	function obj:get_monitoring()
	end
	function obj:get_organizations()
	end
	function obj:get_status_list()
	end
	function obj:get_status()
	end
	return obj
end



function TestSdoOrganization:test_org()
	local mgr = require "openrtm.Manager"
	mgr:init({"-o","corba.step.count:0"})--,"-o","logger.file_name: stdout"})
	mgr:activateManager()
	mgr:runManager(true)

	local ReturnCode_t  = mgr._ReturnCode_t
	
	local orb = mgr:getORB()

	local sdo = SDO_Moc.new("sdo")
	local org = SdoOrganization.Organization_impl.new(sdo)
	org:createRef()

	local ret = org:get_organization_id()
	luaunit.assertNotEquals(ret, "")
	local org_property = {properties={}}
	local prop = Properties.new()
	prop:setProperty("testname1","testvalue1")
	NVUtil.copyFromProperties(org_property.properties, prop)

	ret = org:add_organization_property(org_property)
	luaunit.assertIsTrue(ret)


	local org_property2 = org:get_organization_property()
	local prop2 = Properties.new()
	NVUtil.copyToProperties(prop2, org_property2.properties)
	luaunit.assertEquals(prop2:getProperty("testname1"), "testvalue1")

	local prop3 = Properties.new()
	ret = org:set_organization_property_value("testname2","testvalue2")
	luaunit.assertIsTrue(ret)
	local ret = org:get_organization_property_value("testname2")
	luaunit.assertEquals(ret, "testvalue2")
	
	ret = org:set_organization_property_value("testname2","testvalue2-2")
	luaunit.assertIsTrue(ret)
	local ret = org:get_organization_property_value("testname2")
	luaunit.assertEquals(ret, "testvalue2-2")

	local prop4 = Properties.new()
	ret = org:remove_organization_property("testname2")
	luaunit.assertIsTrue(ret)
	local org_property4 = org:get_organization_property()
	NVUtil.copyToProperties(prop4, org_property4.properties)
	luaunit.assertEquals(prop4:getProperty("testname2"), "")

	luaunit.assertEquals(org:get_owner(), sdo)
	local sdo2 = SDO_Moc.new("sdo2")
	ret = org:set_owner(sdo2)
	luaunit.assertEquals(org:get_owner(), sdo2)
	
	local success, exception = oil.pcall(
		function()
			org:get_organization_property_value("")
	end)
	luaunit.assertIsFalse(success)

	local success, exception = oil.pcall(
		function()
			org:get_organization_property_value("dummy")
	end)
	luaunit.assertIsFalse(success)

	local success, exception = oil.pcall(
		function()
			org:set_organization_property_value("","")
	end)
	luaunit.assertIsFalse(success)

	local success, exception = oil.pcall(
		function()
			org:remove_organization_property("")
	end)
	luaunit.assertIsFalse(success)

	local success, exception = oil.pcall(
		function()
			org:remove_organization_property("dummy")
	end)
	luaunit.assertIsFalse(success)

	local success, exception = oil.pcall(
		function()
			org:set_owner(oil.corba.idl.null)
	end)
	luaunit.assertIsFalse(success)


	local sdo3 = SDO_Moc.new("sdo3")
	local sdo4 = SDO_Moc.new("sdo4")
	local sdo5 = SDO_Moc.new("sdo5")
	local sdos = {sdo3,sdo4}
	local sdos2 = {sdo5}


	ret = org:set_members(sdos)
	luaunit.assertIsTrue(ret)
	
	ret = org:get_members()
	luaunit.assertEquals(#ret, 2)

	ret = org:add_members(sdos2)
	luaunit.assertIsTrue(ret)
	ret = org:get_members()
	luaunit.assertEquals(#ret, 3)

	org:remove_member("sdo5")
	ret = org:get_members()
	luaunit.assertEquals(#ret, 2)

	local success, exception = oil.pcall(
		function()
			org:add_members({})
	end)
	luaunit.assertIsFalse(success)


	local success, exception = oil.pcall(
		function()
			org:remove_member("")
	end)
	luaunit.assertIsFalse(success)

	local success, exception = oil.pcall(
		function()
			org:remove_member("dummy")
	end)
	luaunit.assertIsFalse(success)

	luaunit.assertNotEquals(org:getObjRef(),nil)

	orb:deactivate(org._svr)



	mgr:createShutdownThread(0.01)
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
