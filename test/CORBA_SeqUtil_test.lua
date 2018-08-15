local luaunit = require "luaunit"

local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"


local sampleFunc = function(value)
	local obj = {}
	obj._value = value
	local call_func = function(self, value)
		return (self._value == value)
	end
	setmetatable(obj, {__call=call_func})
	return obj
end


local sampleFunc2 = function(value)
	local obj = {}
	obj._value = value
	local call_func = function(self, value)
		value._value = self._value
	end
	setmetatable(obj, {__call=call_func})
	return obj
end




TestCORBA_SeqUtil = {}
function TestCORBA_SeqUtil:test_func()
	local seq = {1,2,3}
	local ret = CORBA_SeqUtil.find(seq, sampleFunc(2))
	luaunit.assertEquals(ret, 2)
	CORBA_SeqUtil.erase_if(seq, sampleFunc(2))
	luaunit.assertEquals(#seq, 2)
	local seq2 = {{_value=1}}
	CORBA_SeqUtil.for_each(seq2, sampleFunc2(3))
	luaunit.assertEquals(seq2[1]._value, 3)
end



local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
