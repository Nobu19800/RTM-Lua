--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local TimeValue= {}
_G["openrtm.TimeValue"] = TimeValue

local TIMEVALUE_ONE_SECOND_IN_USECS = 1000000

TimeValue.new = function(sec, usec)
	local obj = {}
	local sub_func = function(self, tm)
		res = TimeValue.new()
		if self.tv_sec >= tm.tv_sec then
			if self.tv_usec >= tm.tv_usec then
				res.tv_sec  = self.tv_sec  - tm.tv_sec
				res.tv_usec = self.tv_usec - tm.tv_usec
			else
				res.tv_sec  = self.tv_sec  - tm.tv_sec - 1
				res.tv_usec = (self.tv_usec + TIMEVALUE_ONE_SECOND_IN_USECS) - tm.tv_usec
			end
		else
			if tm.tv_usec >= self.tv_usec then
				res.tv_sec  = -(tm.tv_sec  - self.tv_sec)
				res.tv_usec = -(tm.tv_usec - self.tv_usec)
			else
				res.tv_sec  = -(tm.tv_sec - self.tv_sec - 1)
				res.tv_usec = -(tm.tv_usec + TIMEVALUE_ONE_SECOND_IN_USECS) + self.tv_usec
			end
		end

		res:normalize()
		return res
	end
	local add_func = function(self, tm)
		res = TimeValue.new()
		res.tv_sec  = self.tv_sec  + tm.tv_sec
		res.tv_usec = self.tv_usec + tm.tv_usec
		if res.tv_usec > TIMEVALUE_ONE_SECOND_IN_USECS then
			res.tv_sec = res.tv_sec + 1
			res.tv_usec = res.tv_usec - TIMEVALUE_ONE_SECOND_IN_USECS
		end
		res:normalize()
		return res
	end
	local str_func = function(self)
		ret = ""..self.tv_sec..(self.tv_usec / TIMEVALUE_ONE_SECOND_IN_USECS)
		return ret
	end


	setmetatable(obj, {__add =add_func,__sub=sub_func,__tostring=str_func})
	function obj:sec()
		return self.tv_sec
	end
	function obj:usec()
		return self.tv_usec
	end
	function obj:set_time(_time)
		self.tv_sec  = _time - _time%1
		self.tv_usec = (_time - self.tv_sec) * TIMEVALUE_ONE_SECOND_IN_USECS
		self.tv_usec = self.tv_usec - self.tv_usec%1
		return self
	end
	function obj:toDouble()
		return self.tv_sec + self.tv_usec / TIMEVALUE_ONE_SECOND_IN_USECS
	end
	function obj:sign()
		if self.tv_sec > 0 then
			return 1
		end
		if self.tv_sec < 0 then
			return -1
		end
		if self.tv_usec > 0 then
			return 1
		end
		if self.tv_usec < 0 then
			return -1
		end
		return 0
	end

	function obj:normalize()
		if self.tv_usec >= TIMEVALUE_ONE_SECOND_IN_USECS then
			self.tv_sec = self.tv_sec + 1
			self.tv_usec = self.tv_usec - TIMEVALUE_ONE_SECOND_IN_USECS

			while self.tv_usec >= TIMEVALUE_ONE_SECOND_IN_USECS do
				self.tv_sec = self.tv_sec + 1
				self.tv_usec = self.tv_usec - TIMEVALUE_ONE_SECOND_IN_USECS
			end

		elseif self.tv_usec <= -TIMEVALUE_ONE_SECOND_IN_USECS then
			self.tv_sec = self.tv_sec - 1
			self.tv_usec = self.tv_usec + TIMEVALUE_ONE_SECOND_IN_USECS

			while self.tv_usec <= -TIMEVALUE_ONE_SECOND_IN_USECS do
				self.tv_sec = self.tv_sec - 1
				self.tv_usec = self.tv_usec + TIMEVALUE_ONE_SECOND_IN_USECS
			end
		end


		if self.tv_sec >= 1 and self.tv_usec < 0 then
			self.tv_sec = self.tv_sec - 1
			self.tv_usec = self.tv_usec + TIMEVALUE_ONE_SECOND_IN_USECS

		elseif self.tv_sec < 0 and self.tv_usec > 0 then
			self.tv_sec = self.tv_sec + 1
			self.tv_usec = self.tv_usec - TIMEVALUE_ONE_SECOND_IN_USECS
		end
	end

	if type(sec) == "string" then
		sec = tonumber(sec)
	end
	if type(usec) == "string" then
		usec = tonumber(usec)
	end
	if sec ~= nil and usec == nil then
		if sec >= 0.0 then
			dbHalfAdj_ = 0.5
		else
			dbHalfAdj_ = -0.5
		end

		obj.tv_sec = sec - sec%1
		obj.tv_usec = (sec - obj.tv_sec) *
                          TIMEVALUE_ONE_SECOND_IN_USECS + dbHalfAdj_
		obj.tv_usec = obj.tv_usec - obj.tv_usec%1
		obj:normalize()

		return obj
	end
	if sec == nil then
      obj.tv_sec = 0
    else
      obj.tv_sec = sec - sec%1
	end

    if usec == nil then
      obj.tv_usec = 0
    else
      obj.tv_usec = usec - usec%1
	end
    obj:normalize()
	return obj

end


return TimeValue
