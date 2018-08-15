local luaunit = require "luaunit"
local DataPortStatus = require "openrtm.DataPortStatus"




TestDataPortStatus = {}


function TestDataPortStatus:test_toString()

	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.PORT_OK), 'PORT_OK' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.PORT_ERROR), 'PORT_ERROR' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.BUFFER_ERROR), 'BUFFER_ERROR' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.BUFFER_FULL), 'BUFFER_FULL' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.BUFFER_EMPTY), 'BUFFER_EMPTY' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.BUFFER_TIMEOUT), 'BUFFER_TIMEOUT' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.SEND_FULL), 'SEND_FULL' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.SEND_TIMEOUT), 'SEND_TIMEOUT' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.RECV_EMPTY), 'RECV_EMPTY' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.RECV_TIMEOUT), 'RECV_TIMEOUT' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.INVALID_ARGS), 'INVALID_ARGS' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.PRECONDITION_NOT_MET), 'PRECONDITION_NOT_MET' )
	luaunit.assertEquals( DataPortStatus.toString(DataPortStatus.CONNECTION_LOST), 'CONNECTION_LOST' )
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
