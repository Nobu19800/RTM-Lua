--[[
Copyright (c) 2017 Nobuhiko Miyamoto
]]

local CORBA_SeqUtil= {}
_G["openrtm.CORBA_SeqUtil"] = CORBA_SeqUtil

CORBA_SeqUtil.find = function(seq, f)
	for i, s in ipairs(seq) do
		--print(f(s))
		if f(s) then
			return i
		end
	end
	return -1
end


CORBA_SeqUtil.refToVstring = function(objlist)
	local iorlist = {}
	local Manager = require "openrtm.Manager"
	local orb = Manager:instance():getORB()
	for i, obj in ipairs(objlist) do
		table.insert(iorlist, obj)
	end
	return iorlist
end

CORBA_SeqUtil.erase_if = function(seq, f)
	local index = CORBA_SeqUtil.find(seq, f)
	if index < 0 then
		return
	end
	table.remove(seq ,index)
end


CORBA_SeqUtil.push_back_list = function(seq1, seq2)
	for i, elem in ipairs(seq2) do
		table.insert(seq1, elem)
	end
end

CORBA_SeqUtil.for_each = function(seq, f)
	for i, s in ipairs(seq) do
		f(s)
	end
end





return CORBA_SeqUtil
