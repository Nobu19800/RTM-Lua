--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local BufferBase = {}
_G["openrtm.BufferBase"] = BufferBase

BufferBase.new = function()
	local obj = {}
	function obj:init(prop)
    end
	function obj:length()
    end
	function obj:reset()
    end
	function obj:wptr(n)
    end
	function obj:advanceWptr(n)
    end
	function obj:put(data)
    end
	function obj:write(value, sec, nsec)
    end
	function obj:writable()
    end
	function obj:full()
    end
	function obj:rptr(n)
    end
	function obj:advanceRptr(n)
    end
	function obj:get()
    end
	function obj:read(value, sec, nsec)
    end
	function obj:readable()
    end
	function obj:empty()
    end
	return obj
end

BufferBase.NullBuffer = {}

BufferBase.NullBuffer.new = function(size)
	local obj = {}
	setmetatable(obj, {__index=BufferBase.new()})
	return obj
end



return BufferBase
