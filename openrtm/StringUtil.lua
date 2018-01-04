--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local StringUtil= {}
_G["openrtm.StringUtil"] = StringUtil

StringUtil.init = function()
	local obj = {}
	return obj
end

StringUtil.eraseHeadBlank = function(_str)
	return string.gsub(_str, "(.-)%s*$", "%1")
end

StringUtil.eraseTailBlank = function(_str)
	return string.gsub(_str, "^%s*(.-)", "%1")
end

StringUtil.normalize = function(_str)
	ret = string.gsub(_str, "^%s*(.-)%s*$", "%1")
	return string.lower(ret)
end

StringUtil.isEscaped = function(_str, pos)
	pos = pos-1

	local i = 0
	while pos >= 0 and string.sub(_str, pos, pos) == "\\" do
		i = i+1
		pos = pos-1
	end

	return (i % 2 == 1)
end


local unescape_functor = {}
unescape_functor.new = function()
	local obj = {}
	obj.count  = 0
	obj._str  = ""
	local call_func = function(self, c)
		if c == "\\" then
			self.count = self.count+1
			if self.count % 2 == 0 then
				self._str = self._str..c
			end
		else
			if self.count > 0 and self.count % 2 == 1 then
				self.count = 0
				if c == 't' then
					self._str=self._str..'\t'
				elseif c == 'n' then
					self._str=self._str..'\n'
				elseif c == 'f' then
					self._str=self._str..'\f'
				elseif c == 'r' then
					self._str=self._str..'\r'
				elseif c == '\"' then
					self._str=self._str..'\"'
				elseif c == '\'' then
					self._str=self._str..'\''
				else
					self._str=self._str..c
				end
			else
				self.count = 0
				self._str=self._str..c
			end
		end
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

StringUtil.unescape = function(_str)
	local functor = unescape_functor.new()
	for i=1,#_str do
		functor(string.sub(_str,i,i))
	end
	return functor._str
end

StringUtil.copy = function(orig)
	local copy = {}
	if type(orig) == 'table' then
		for k, v in ipairs(orig) do
			copy[k] = v
		end
	else
		copy = orig
	end
	return copy
end


StringUtil.deepcopy = function(orig)
	local copy = {}
	if type(orig) == 'table' then
		for k, v in pairs(orig) do
			copy[k] = StringUtil.deepcopy(v)
		end
	else
		copy = orig
	end
	return copy
end




StringUtil.split = function(input, delimiter)
	--print(input:find(delimiter))
	if input:find(delimiter) == nil then
		return { input }
	end
	local result = {}
	local pat = "(.-)" .. delimiter .. "()"
    local lastPos
    for part, pos in string.gfind(input, pat) do
		table.insert(result, part)
        lastPos = pos
    end
    table.insert(result, string.sub(input, lastPos))
    return result
end

StringUtil.print_table = function(tbl)
	for k, v in pairs(tbl) do
		if type(v)=="table" then
			--print( k..":" )
			StringUtil.print_table(v)
		else
			print( k, v )
		end
	end
end

StringUtil.toBool = function(_str, yes, no, default_value)
	if default_value == nil then
		default_value = true
	end
	--print(_str)
	_str = _str:lower()
	yes = yes:lower()
	no = no:lower()
	if _str:match(yes) ~= nil then
		return true
	elseif _str:match(no) ~= nil then
		return true
	end
	return default_value
end




StringUtil.otos = function(n)
	return ""..n
end

StringUtil.in_value = function(tbl, val)
    for k, v in pairs (tbl) do
        if v==val then
			return true
		end
    end
    return false
end

StringUtil.in_key = function(tbl, key)
    for k, v in pairs (tbl) do
        if k==val then
			return true
		end
    end
    return false
end

StringUtil.unique_sv = function(sv)
	unique_strvec = StringUtil.unique_strvec.new()
	for i,v in ipairs(sv) do
		unique_strvec(v)
	end
	return unique_strvec._str
end

StringUtil.unique_strvec = {}
StringUtil.unique_strvec.new = function()
	local obj = {}
	obj._str = {}
	local call_func = function(self, s)
		if StringUtil.in_value(self._str, s) == false then
			table.insert(self._str, s)
			return self._str
		end
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

StringUtil.flatten = function(sv, delimiter)
	if delimiter == nil then
		delimiter = ", "
	end
	if table.maxn(sv) == 0 then
		return ""
	end
	local _str = table.concat(sv, delimiter)

	return _str
end

StringUtil.table_count = function(tbl, value)
	count = 0
	for i, v in ipairs(tbl) do
		if value == v then
			count = 1
		end
	end
	return count
end

StringUtil.includes = function(_list, value, ignore_case)
	if ignore_case == nil then
		ignore_case = true
	end

	if not (type(_list) == "table" or type(_list) == "string") then

		return false
	end

	if type(_list) == "string" then
		_list = StringUtil.split(_list, ",")
	end


	tmp_list = _list
	if ignore_case then
		value = string.lower(value)
		tmp_list = {}
		for i, v in ipairs(_list) do
			table.insert(tmp_list, string.lower(v))
		end
	end
	if StringUtil.table_count(tmp_list, value) > 0 then
		return true
	end

	return false
end

StringUtil._stringToList = function(_type, _str)
	local list_ = StringUtil.split(",")
	local ans = {}
	if #_type < #list_ then
		local sub = #_type - #list_
		for i = 1,sub do
			table.insert(_type, _type[1])
		end
	elseif #_type > #list_ then
		local sub = #_type - #list_
		for i = #list_,#_type_ do
			table.remove(_type, i)
		end
	end
	for i = 1,#list_ do
		if type(_type[i]) == "number" then
			table.insert(ans, tonumber(_str[i]))
		elseif type(_type[i]) == "string" then
			table.insert(ans, tostring(_str[i]))
		end
	end
	return true, ans


end

StringUtil.stringTo = function(_type, _str)
	if type(_type) == "number" then
		local value = tonumber(_str)
		if value ~= nil then
			return true, value
		else
			return false, _type
		end
	elseif type(_type) == "string" then
		local value = tostring(_str)
		if value ~= nil then
			return true, value
		else
			return false, _type
		end
	elseif type(_type) == "table" then
		return StringUtil._stringToList(_type, _str)
	else
		return false, _type
	end

end

return StringUtil
