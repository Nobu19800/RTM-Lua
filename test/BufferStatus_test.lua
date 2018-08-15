local luaunit = require "luaunit"
local BufferStatus = require "openrtm.BufferStatus"

TestBufferStatus = {}
function TestBufferStatus:test_toString()
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.BUFFER_OK), 'BUFFER_OK' )
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.BUFFER_ERROR), 'BUFFER_ERROR' )
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.BUFFER_FULL), 'BUFFER_FULL' )
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.BUFFER_EMPTY), 'BUFFER_EMPTY' )
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.NOT_SUPPORTED), 'NOT_SUPPORTED' )
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.TIMEOUT), 'TIMEOUT' )
	luaunit.assertEquals( BufferStatus.toString(BufferStatus.PRECONDITION_NOT_MET), 'PRECONDITION_NOT_MET' )
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
