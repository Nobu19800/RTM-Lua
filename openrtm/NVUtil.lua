--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local NVUtil= {}
_G["openrtm.NVUtil"] = NVUtil

local oil = require "oil"
local CORBA_SeqUtil = require "openrtm.CORBA_SeqUtil"
local StringUtil = require "openrtm.StringUtil"

NVUtil.newNV = function(name, value)
	return {name=name, value=value}
end


NVUtil.copyFromProperties = function(nv, prop)
	keys = prop:propertyNames()
	keys_len = table.maxn(keys)
	nv_len = table.maxn(nv)
	if nv_len > 0 then
		for i = 1,nv_len do
			nv[i] = nil
		end
	end

	for i = 1, keys_len do
		table.insert(nv, NVUtil.newNV(keys[i], prop:getProperty(keys[i])))
	end
end


NVUtil.getReturnCode = function(ret_code)
	--print(ret_code)
	if type(ret_code) == "string" then
		local Manager = require "openrtm.Manager"
		local _ReturnCode_t = Manager:instance():getORB().types:lookup("::RTC::ReturnCode_t").labelvalue
		if ret_code == "RTC_OK" then
			return _ReturnCode_t.RTC_OK
		elseif ret_code == "RTC_ERROR" then
			return _ReturnCode_t.RTC_ERROR
		elseif ret_code == "BAD_PARAMETER" then
			return _ReturnCode_t.BAD_PARAMETER
		elseif ret_code == "UNSUPPORTED" then
			return _ReturnCode_t.UNSUPPORTED
		elseif ret_code == "OUT_OF_RESOURCES" then
			return _ReturnCode_t.OUT_OF_RESOURCES
		elseif ret_code == "PRECONDITION_NOT_MET" then
			return _ReturnCode_t.PRECONDITION_NOT_MET
		end
	end
	return ret_code
end




NVUtil.copyToProperties = function(prop, nvlist)
	for i, nv in ipairs(nvlist) do
		--print(i,nv.value)
		local val = NVUtil.any_from_any(nv.value)
		--print(val)
		prop:setProperty(nv.name,val)
	end
end

local nv_find = {}
nv_find.new = function(name)
	local obj = {}
	obj._name  = name
	local call_func = function(self, nv)
		--print(self._name, nv.name)
		return (self._name == nv.name)
	end
	setmetatable(obj, {__call=call_func})
	return obj
end

NVUtil.find_index = function(nv, name)
	return CORBA_SeqUtil.find(nv, nv_find.new(name))
end

NVUtil.appendStringValue = function(nv, _name, _value)
	index = NVUtil.find_index(nv, _name)
	tmp_nv = nv[index]
	if tmp_nv ~= nil then
		tmp_str = NVUtil.any_from_any(tmp_nv.value)
		values = StringUtil.split(tmp_str,",")
		find_flag = false
		for i, val in ipairs(values) do
			if val == _value then
				find_flag = true
			end
		end
		if not find_flag then
			tmp_str = tmp_str..", "
			tmp_str = tmp_str.._value
			tmp_nv.value = tmp_str
		end
	else
		table.insert(nv,{name=_name,value=_value})
	end
end


NVUtil.append = function(dest, src)
	for i, val in ipairs(src) do
		table.insert(dest, val)
	end
end


NVUtil.isStringValue = function(nv, name, value)
	--print(NVUtil.toString(nv, name))
	if NVUtil.isString(nv, name) then
		if NVUtil.toString(nv, name) == value then
			return true
		end
	end
	return false
end


NVUtil.find = function(nv, name)
	index = CORBA_SeqUtil.find(nv, nv_find.new(name))
	if nv[index] ~= nil then
		return nv[index].value
	else
		return nil
	end
end

NVUtil._is_equivalent = function(obj1, obj2, obj1_ref, obj2_ref)

	if obj1._is_equivalent == nil then
		if obj2._is_equivalent == nil then
			return obj1_ref(obj1):_is_equivalent(obj2_ref(obj2))
		else
			return obj1_ref(obj1):_is_equivalent(obj2)
		end
	else
		if obj2._is_equivalent == nil then

			return obj1:_is_equivalent(obj2_ref(obj2))
		else
			return obj1:_is_equivalent(obj2)
		end
	end
end


NVUtil.any_from_any = function(value)
	if type(value) == "table" then
		if value._anyval ~= nil then
			return value._anyval
		end
	end
	return value
end

NVUtil.dump_to_stream = function(nv)
	local out = ""
	for i, n in ipairs(nv) do
		local val = NVUtil.any_from_any(nv[i].value)
		if type(val) == "string" then
			out = out..n.name..": "..val.."\n"
		else
			out = out..n.name..": not a string value \n"
		end
	end
	return out
end

NVUtil.toString = function(nv, name)
	if name == nil then
		return NVUtil.dump_to_stream(nv)
	end

	local str_value = ""
    local ret_value = NVUtil.find(nv, name)
	if ret_value ~= nil then
		local val = NVUtil.any_from_any(ret_value)
		if type(val) == "string" then
			str_value = val
		end
	end
	return str_value
end


NVUtil.isString = function(nv, name)
    local value = NVUtil.find(nv, name)
	if value ~= nil then
		local val = NVUtil.any_from_any(value)
		return (type(val) == "string")
	else
		return false
	end
end


return NVUtil
