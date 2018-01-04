--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local RingBuffer= {}
_G["openrtm.RingBuffer"] = RingBuffer


local BufferBase = require "openrtm.BufferBase"
local TimeValue = require "openrtm.TimeValue"
local BufferStatus = require "openrtm.BufferStatus"

RingBuffer.RINGBUFFER_DEFAULT_LENGTH = 8

RingBuffer.new = function(length)
	local obj = {}
	setmetatable(obj, {__index=BufferBase.new()})
	if length == nil then
		length = RingBuffer.RINGBUFFER_DEFAULT_LENGTH
	end
	obj._overwrite = true
    obj._readback = true
    obj._timedwrite = false
    obj._timedread  = false
    obj._wtimeout = TimeValue.new(1,0)
    obj._rtimeout = TimeValue.new(1,0)
    obj._length   = length
    obj._wpos = 0
    obj._rpos = 0
    obj._fillcount = 0
    obj._wcount = 0
    obj._buffer = {}

	function obj:init(prop)
		self:__initLength(prop)
		self:__initWritePolicy(prop)
		self:__initReadPolicy(prop)
	end

	function obj:length(n)
		if n == nil then
			return self._length
		end

		if n < 1 then
			return BufferStatus.NOT_SUPPORTED
		end

		self._buffer = {}
		self._length = n
		self:reset()
		return BufferStatus.BUFFER_OK
	end

	function obj:reset()
		self._fillcount = 0
		self._wcount = 0
		self._wpos = 0
		self._rpos = 0
	end

	function obj:wptr(n)
		if n == nil then
			n = 0
		end
		return self._buffer[(self._wpos + n + self._length) % self._length + 1]
	end

	function obj:advanceWptr(n)
		if n == nil then
			n = 1
		end

		if (n > 0 and n > (self._length - self._fillcount)) or
			  (n < 0 and n < (-self._fillcount)) then
			return BufferStatus.PRECONDITION_NOT_MET
		end

		self._wpos = (self._wpos + n + self._length) % self._length
		self._fillcount = self._fillcount + n
		return BufferStatus.BUFFER_OK
    end

	function obj:put(value)
		self._buffer[self._wpos+1] = value
		return BufferStatus.BUFFER_OK
	end


	function obj:write(value, sec, nsec)
		if sec == nil then
			sec = -1
		end
		if nsec == nil then
			nsec = 0
		end
		if self:full() then
			self:advanceRptr()
		end
		self:put(value)
		self:advanceWptr(1)
		return BufferStatus.BUFFER_OK
	end

	function obj:writable()
		return self._length - self._fillcount
	end

	function obj:full()
		return (self._length == self._fillcount)
	end

	function obj:rptr(n)
		if n == nil then
			n = 0
		end
		return self._buffer[(self._rpos + n + self._length) % self._length + 1]
	end

	function obj:advanceRptr(n)
		if n == nil then
			n = 1
		end

		if (n > 0 and n > self._fillcount) or
			  (n < 0 and n < (self._fillcount - self._length)) then
		  return BufferStatus.PRECONDITION_NOT_MET
		end

		self._rpos = (self._rpos + n + self._length) % self._length
		self._fillcount = self._fillcount - n
		return BufferStatus.BUFFER_OK
	end

	function obj:get(value)
		if value == nil then
			return self._buffer[self._rpos+1]
		end

		value._data = self._buffer[self._rpos+1]
		return BufferStatus.BUFFER_OK
	end

	function obj:read(value, sec, nsec)
		if sec == nil then
			sec = -1
		end
		if nsec == nil then
			nsec = 0
		end
		if self:empty() then
			return BufferStatus.BUFFER_EMPTY
		end
		self:get(value)
		self:advanceRptr()
		return BufferStatus.BUFFER_OK
	end

	function obj:readable()
		return self._fillcount
	end

	function obj:empty()
		return (self._fillcount == 0)
	end

	function obj:__initLength(prop)
	end
	function obj:__initWritePolicy(prop)
	end
	function obj:__initReadPolicy(prop)
	end
	obj:reset()


	return obj
end


return RingBuffer
