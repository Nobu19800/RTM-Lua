---------------------------------
--! @file Properties.lua
--! @brief �v���p�e�B����֐���`
---------------------------------

--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local Properties= {}
--_G["openrtm.Properties"] = Properties

local StringUtil = require "openrtm.StringUtil"
--string = require string

-- �v���p�e�B������
-- @param argv argv.prop�F�R�s�[���̃v���p�e�B�Aargv.key�Eargv.value�F�L�[�ƒl�Aargv.defaults_map�F�e�[�u��
Properties.new = function(argv)
	local obj = {}
	function obj:init()
		self.default_value = ""
		self.root = nil
		self.empty = ""
		self.leaf = {}
		self.name  = ""
		self.value = ""
		if argv == nil then
			argv = {}
		end
		if argv.prop ~= nil then
			--print(argv.prop:str())
			self.name = argv.prop.name
			self.value = argv.prop.value
			self.default_value = argv.prop.default_value
			local keys = argv.prop:propertyNames()
			--print(#keys)
			for i, _key in ipairs(keys) do
				--print(i, _key)
				local node = argv.prop:getNode(_key)
				--print(node)
				if node ~= nil then
					--print(_key, node.default_value)
					self:setDefault(_key, node.default_value)
					self:setProperty(_key, node.value)
				end
			end
		end
		if argv.key ~= nil then
			self.name = argv.key
			if argv.value == nil then
				self.value = ""
			else
				self.value = argv.value
			end
		end
		if argv.defaults_map ~= nil then
			for _key, _value in pairs(argv.defaults_map) do
				_key = StringUtil.eraseBothEndsBlank(_key)
				_value = StringUtil.eraseBothEndsBlank(_value)
				self:setDefault(_key, _value)
			end
		end
		--[[
		if argv.defaults_str ~= nil then
			local _num = argv.num
			if argv.num == nil then
				_num = 100000
			end
			self:setDefaults(argv.defaults_str, _num)
		end
		]]
	end
	-- �L�[�擾
	-- @return �L�[
	function obj:getName()
		return self.name
	end
	-- �l�擾
	-- @return �l
	function obj:getValue()
		return self.value
	end
	-- �f�t�H���g�l�ݒ�
	-- @param key �L�[
	-- @param default �f�t�H���g�l
	-- @return �l
	function obj:getDefaultValue(key, default)
		if default ~= nil then
			local keys = StringUtil.split(key, "%.")

			local node = self:_getNode(keys, 1, self)
			if node ~= nil then
				if node.value ~= nil then
					return node.value
				else
					return node.default_value
				end
			end
			return self.empty
		else
			local value = self:getProperty(key)
			if value ~= nil then
				return value
			else
				return default
			end
		end
	end
	-- �v���p�e�B�l�擾
	-- @param key �L�[
	-- @param default �f�t�H���g�l
	-- @return �v���p�e�B
	function obj:getProperty(key, default)
		--print(key)
		if default == nil then
			local keys = StringUtil.split(key, "%.")
			local node = self:_getNode(keys, 1, self)
			if node then
				if node.value ~= "" then
					return node.value
				else
					return node.default_value
				end
			end
			return self.empty
		else
			local value = self:getProperty(key)
			if value ~= "" then
				return value
			else
				return default
			end
		end
	end
	-- �f�t�H���g�l�擾
	-- @param key �L�[
	-- @return �f�t�H���g�l
	function obj:getDefault(key)
		local keys = StringUtil.split(key, "%.")
		local node = self:_getNode(keys, 1, self)
		if node ~= nil then
			return node.default_value
		end
		return self.empty
	end
	-- �v���p�e�B�ݒ�
	-- @param key �L�[
	-- @param value �l
	-- @return �v���p�e�B
	function obj:setProperty(key, value)
		--print(self.leaf)
		if value ~= nil then
			local keys = StringUtil.split(key, "%.")
			--print(key,#keys)
			local curr = self
			for _i, _key in ipairs(keys) do
				--print(curr)
				local _next = curr:hasKey(_key)
				if _next == nil then
					_next = Properties.new({key=_key})
					_next.root = curr
					table.insert(curr.leaf,_next)
				end
				curr = _next
			end

			curr.value = value
			return retval
		else
			--print(self:getProperty(key))
			self:setProperty(key, self:getProperty(key))
			local prop = self:getNode(key)
			return prop.value
		end
		return self.root
	end
	-- �f�t�H���g�l�ݒ�
	-- @param key �L�[
	-- @param value �f�t�H���g�l
	-- @return �l
	function obj:setDefault(key, value)
		local keys = StringUtil.split(key, "%.")
		local curr = self
		--print(self.leaf)
		--StringUtil.print_table(keys)
		for _i, _key in ipairs(keys) do
			local _next = curr:hasKey(_key)
			if _next == nil then
				_next = Properties.new({key=_key})
				_next.root = curr
				--print(curr.leaf, _next)
				--print(#curr.leaf)
				table.insert(curr.leaf, _next)
			end
			curr= _next
		end
		if value ~= "" and string.sub(value, -1) ~= "\n" then
			value = string.sub(value, 0, -1)
		end
		curr.default_value = value
		return value
	end
	--�f�t�H���g�l���e�[�u������ݒ�
	-- @param defaults �f�t�H���g�l�̃e�[�u��
	-- @param num �ő吔
	-- @return �v���p�e�B
	function obj:setDefaults(defaults, num)
		if num == nil then
			num = 10000
		end

		--[[for i = 1, #defaults/2 do
			if i > num then
				break
			end
			local _key = defaults[i*2-1]
			local _value = defaults[i*2]
			--print(_key, _value)
			_key = StringUtil.eraseHeadBlank(_key)
			_key = StringUtil.eraseTailBlank(_key)
			_value = StringUtil.eraseHeadBlank(_value)
			_value = StringUtil.eraseTailBlank(_value)
			self:setDefault(_key, _value)
		end
		]]
		local count = 1
		for _key,_value in pairs(defaults) do
			if num < count then
				break
			end
			_key = StringUtil.eraseBothEndsBlank(_key)
			_value = StringUtil.eraseBothEndsBlank(_value)
			self:setDefault(_key, _value)
			count = count+1
		end
		return self.leaf
	end
	-- �w��X�g���[���Ƀv���p�e�B���o��
	-- @param out �A�E�g�X�g���[��
	function obj:list(out)
		self:_store(out, "", self)
		return
	end
	-- �w��X�g���[������v���p�e�B�����
	-- @param inStream �C���X�g���[��
	-- @return �v���p�e�B
	function obj:loadStream(inStream)
		pline = ""
		for i, readStr in inStream do
			if readStr ~= "" then
				local _str = readStr
				_str = StringUtil.eraseHeadBlank(_str)
				local s = string.sub(_str,0,1)
				if s == "#" or s == "!" or s == "\n" then
				else
					--_str = _str.rstrip('\r\n')
					if string.sub(_str,-1) == "\\" and not StringUtil.isEscaped(_str, #_str-1) then
						local tmp = string.sub(_str,0,-1)
						tmp = StringUtil.eraseTailBlank(tmp)
						pline = pline..tmp
					else
						pline = pline.._str
						local key = {}
						local value = {}
						self:splitKeyValue(pline, key, value)
						key = OpenRTM_aist.unescape(key)
						key = StringUtil.eraseHeadBlank(key)
						key = StringUtil.eraseHeadBlank(key)
						value = OpenRTM_aist.unescape(value)
						value = StringUtil.eraseHeadBlank(value)
						value = StringUtil.eraseHeadBlank(value)
						self:setProperty(key, value)
						pline = ""
					end
				end
			end
		end
		return self.leaf
	end
	-- �w��X�g���[���Ƀw�b�_���L�q�����v���p�e�B���o��
	-- @param out �A�E�g�X�g���[��
	-- @param header �w�b�_
	function obj:store(out, header)
		out.write("#"..header.."\n")
		self:_store(out, "", self)
	end
	-- �v���p�e�B�̃L�[�ꗗ���擾
	-- @return �L�[�ꗗ
	function obj:propertyNames()
		local names = {}
		for i, leaf in ipairs(self.leaf) do
			self:_propertyNames(names, leaf.name, leaf)
		end
		return names
	end
	-- �v���p�e�B�̃L�[�̐��擾
	-- @return �L�[�̐�
	function obj:size()
		return #self:propertyNames()
	end
	-- �w��L�[�̃m�[�h������
	-- @param key �L�[
	-- @return �m�[�h
	function obj:findNode(key)
		if key == nil then
			return nil
		end
		--keys = {}
		--self:split(key, '%.', keys)
		local keys = StringUtil.split(key, "%.")
		--print(keys[0])
		--print(self:_getNode(keys, 1, self))
		return self:_getNode(keys, 1, self)
	end
	-- �w��L�[�̃m�[�h���擾
	-- @param key �L�[
	-- @return �m�[�h
	function obj:getNode(key)
		if key == nil then
			return self
		end
		local leaf = self:findNode(key)
		--print(leaf, type(leaf))

		if leaf ~= nil then
			return leaf
		end
		self:createNode(key)
		--print(self:findNode(key), type(self:findNode(key)))
		return self:findNode(key)
	end
	-- �w��L�[�̃m�[�h�𐶐�
	-- @param key �L�[
	-- @return true�F���������Afalse�F�������s
	function obj:createNode(key)
		if key == "" then
			return false
		end
		if self:findNode(key) ~= nil then
			return false
		end
		self:setProperty(key,"")
		return true
	end
	-- �m�[�h�폜
	-- @param leaf_name �L�[
	-- @return �v���p�e�B
	function obj:removeNode(leaf_name)
		for i, leaf in ipairs(self.leaf) do
			if leaf.name == leaf_name then
				local prop = leaf
				table.remove(prop, i)
				return prop
			end
		end
		return nil

	end
	-- �L�[�̑��݊m�F
	-- @param key �L�[
	-- @return �v���p�e�B
	function obj:hasKey(key)
		--print(self.leaf)
		for i, leaf in ipairs(self.leaf) do
			if leaf.name == key then
				return leaf
			end
		end
		return nil
	end
	-- �v���p�e�B�S�폜
	function obj:clear()
		self.leaf = {}
	end
	-- �v���p�e�B�̒ǉ�
	-- @param prop �ǉ����̃v���p�e�B
	-- @return �ǉ���̃v���p�e�B
	function obj:mergeProperties(prop)
		local keys = prop:propertyNames()
		for i = 1, prop:size() do
			self:setProperty(keys[i], prop:getProperty(keys[i]))
		end
		return self
	end
	-- �����񂩂�L�[�ƒl�����o��
	-- @param _str ������(key:value)
	-- @param key �L�[�ꗗ
	-- @param value �l�ꗗ
	-- @return �v���p�e�B
	function obj:splitKeyValue(_str, key, value)

		local length = #_str
		for i = 1, length do
			local s = string.sub(_str,i,i)
			if (s == ":" or s == "=") and not StringUtil.isEscaped(_str, i) then
				table.insert(key,string.sub(_str,1,i-1))
				table.insert(value,string.sub(_str,i+1))
				return
			end
		end
		for i = 1, length do
			if s == " " and not StringUtil.isEscaped(_str, i) then
				table.insert(key,string.sub(_str,1,i-1))
				table.insert(value,string.sub(_str,i+1))
				return
			end
		end
		table.insert(key,_str)
		table.insert(value,"")
		return self.leaf
	end
	-- ������𕪊�����
	-- @param _str ������
	-- @param delim ��������
	-- @param value �l�ꗗ
	-- @return true�G���������Afalse�F�������s
	function obj:split( _str, delim, value)
		if _str == "" then
			return false
		end
		local begin_it = 0
		local length = #_str
		for end_it = 1,length do
			if string.sub(_str,end_it,end_it) == delim and not StringUtil.isEscaped(_str, end_it) then
				table.insert(value,string.sub(_str,begin_it, end_it))
				begin_it = end_it+1
			end
		end
		return true
	end
	-- �m�[�h�擾
	-- @param keys �L�[�ꗗ
	-- @param index �L�[�ꗗ�̃C���f�b�N�X
	-- @param curr ���݂̃m�[�h
	-- @param ���̃m�[�h
	function obj:_getNode(keys, index, curr)
		--print(keys[index])
		local _next = curr:hasKey(keys[index])
		--print(_next)
		if _next == nil then
			return nil
		end
		if index < #keys then
			index = index + 1
			return _next:_getNode(keys, index, _next)
		else
			return _next
		end
	end
	-- �m�[�h�̃L�[�ꗗ�擾
	-- @param names �L�[�ꗗ
	-- @param curr_name ���ݒT�����Ă���L�[
	-- @param curr ���݂̃m�[�h
	function obj:_propertyNames(names, curr_name, curr)
		if #curr.leaf > 0 then
			for i = 1, #curr.leaf do
				local next_name = curr_name.."."..curr.leaf[i].name
				self:_propertyNames(names, next_name, curr.leaf[i])
			end
		else
			table.insert(names,curr_name)
		end
	end
	-- �w��X�g���[���Ƀv���p�e�B���o��
	-- @param out �A�E�g�X�g���[��
	-- @param curr_name ���݂̃L�[
	-- @param curr ���݂̃m�[�h
	function obj:_store(out, curr_name, curr)
		if #curr.leaf > 0 then
			for i = 1, #curr.leaf do
				local next_name = ""
				if curr_name == "" then
					next_name = curr.leaf[i].name
				else
					next_name = curr_name+"."+curr.leaf[i].name
				end
				self:_store(out, next_name, curr.leaf[i])
			end
		else
			local val = curr.value
			if val == "" then
				val = curr.default_value
				out.write(curr_name..": "..val.."\n")
			end
		end
	end
	-- �C���f���g����
	-- @param index ���݂̃C���f���g��
	-- @return �C���f���g
	function obj:indent(index)
		--print("indent")
		local space = ""
		for i = 1, index-1 do
			space = space.."  "
		end
		return space
	end
	-- �v���p�e�B���o�͗p�ɕ�����ɕϊ�
	-- @param out �o�͕�����
	-- @param curr ���݂̃m�[�h
	-- @param index �C���f���g��
	-- @return ������
	function obj:_dump(out, curr, index)
		if index ~= 0 then
			out[1] = out[1]..self:indent(index).."- "..curr.name
		end
		if #curr.leaf == 0 then
			--print("test",curr.default_value, curr.value)
			if curr.value == "" then
				out[1] = out[1]..": "..tostring(curr.default_value).."\n"
			else
				out[1] = out[1]..": "..tostring(curr.value).."\n"
			end
			return out[1]
		end
		if index ~= 0 then
			out[1] = out[1].."\n"
		end
		for i = 1, #curr.leaf do
			self:_dump(out, curr.leaf[i], index + 1)
		end
		return out[1]
	end
	-- �v���p�e�B�擾
	-- @return �v���p�e�B
	function obj:getLeaf()
		return self.leaf
	end

	-- �t�@�C���X�g���[������v���p�e�B��ݒ�
	-- @param inStream �t�@�C���X�g���[��
	function obj:load(inStream)
		local pline = ""
		for readStr in inStream:lines() do

			local _str = StringUtil.eraseHeadBlank(readStr)


			if string.sub(_str,1,1) == "#" or string.sub(_str,1,1) == "!" or string.sub(_str,1,1) == "\n" then
			else

				_str = StringUtil.eraseHeadBlank(_str)

				if string.sub(_str, #_str, #_str) == "\\" and not StringUtil.isEscaped(_str, #_str) then

					local tmp = string.sub(_str,1,#_str-1)
					tmp = StringUtil.eraseTailBlank(tmp)

					pline = pline..tmp
				else
					pline = pline.._str

					local key = {}
					local value = {}
					--print(key)
					self:splitKeyValue(pline, key, value)
					key = StringUtil.unescape(key[1])
					key = StringUtil.eraseHeadBlank(key)
					key = StringUtil.eraseTailBlank(key)

					value = StringUtil.unescape(value[1])
					value = StringUtil.eraseHeadBlank(value)
					value = StringUtil.eraseTailBlank(value)
					--print(key, value)
					self:setProperty(key, value)
					pline = ""
				end
			end
		end
	end
	-- ������ϊ��֐�
	-- @param self ���g�̃I�u�W�F�N�g
	-- @return �ϊ���̕�����
	local str_func = function(self)
		local str = {}
		table.insert(str,"")
		--print(self._dump)
		return self:_dump(str, self, 0)
	end
	obj:init()

	setmetatable(obj, {__tostring =str_func})
	return obj
end


return Properties
