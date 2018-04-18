local LuaUnit = require "luaunit"
local BufferStatus = require "openrtm.BufferStatus"

TestBufferStatus = {}
function TestBufferStatus:test_toString()
	assertEquals( BufferStatus.toString(BufferStatus.BUFFER_OK), 'BUFFER_OK' )
	assertEquals( BufferStatus.toString(BufferStatus.BUFFER_ERROR), 'BUFFER_ERROR' )
	assertEquals( BufferStatus.toString(BufferStatus.BUFFER_FULL), 'BUFFER_FULL' )
	assertEquals( BufferStatus.toString(BufferStatus.BUFFER_EMPTY), 'BUFFER_EMPTY' )
	assertEquals( BufferStatus.toString(BufferStatus.NOT_SUPPORTED), 'NOT_SUPPORTED' )
	assertEquals( BufferStatus.toString(BufferStatus.TIMEOUT), 'TIMEOUT' )
	assertEquals( BufferStatus.toString(BufferStatus.PRECONDITION_NOT_MET), 'PRECONDITION_NOT_MET' )
end



LuaUnit:run()
