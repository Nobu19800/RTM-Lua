local luaunit = require "luaunit"
local RingBuffer = require "openrtm.RingBuffer"
local Properties = require "openrtm.Properties"
local BufferStatus = require "openrtm.BufferStatus"


TestRingBuffer = {}


function TestRingBuffer:test_buffer()
	local buffer = RingBuffer.new(3)
	
	local prop = Properties.new()
	
	buffer:init(prop)
	local ret = buffer:read(data,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_EMPTY)
	local ret = buffer:write(1,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)
	local ret = buffer:write(1,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)
	local ret = buffer:write(1,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)
	local ret = buffer:write(1,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)

	prop:setProperty("write.full_policy","do_nothing")
	buffer:init(prop)
	local ret = buffer:write(1,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_FULL)

	local data = {_data=0}
	local ret = buffer:read(data,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)
	luaunit.assertEquals(data._data, 1)
	local ret = buffer:read(data,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)
	local ret = buffer:read(data,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)
	local ret = buffer:read(data,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_OK)

	prop:setProperty("read.empty_policy","do_nothing")
	buffer:init(prop)
	local ret = buffer:read(data,0,0)
	luaunit.assertEquals(ret, BufferStatus.BUFFER_EMPTY)

	luaunit.assertEquals(buffer:readable(),0)
	luaunit.assertTrue(buffer:empty())
	luaunit.assertFalse(buffer:full())
	luaunit.assertEquals(buffer:writable(),3)

	prop:setProperty("length","20")
	buffer:init(prop)

	luaunit.assertEquals(buffer:length(),20)
	buffer:reset()


end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
