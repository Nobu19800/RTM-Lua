---------------------------------
--! @file rtcd.lua
--! @brief RTC-Daemonの起動
---------------------------------


local openrtm  = require "openrtm"




local main = function()
	if #arg ~= 1 then
		print("usage: ")
		print(arg[0], " *.lua ")
	else
		local fullname  = arg[1]
		fullname = string.gsub(fullname, "\\", "/")
		fullname = string.gsub(fullname, "//", "/")
		local dirname   = openrtm.StringUtil.dirname(arg[1])
		local basename  = openrtm.StringUtil.basename(arg[1])

		local classname = string.lower(openrtm.StringUtil.split(basename,"%.")[1])
		local comp_spec_name = classname.."_spec"


		local f = io.open(fullname, "r")
		if f == nil then
			print("Load failed. file name: ", fullname)
			return
		end
		if string.find(f:read("*a"), comp_spec_name) == nil then
			print("Load failed. file name: ", fullname)
			return
		end
		f:close()
		package.path = package.path..";"..dirname.."?.lua"

		local ext_pos = string.find(basename, ".lua")
		local import_name
		if ext_pos ~= nil then
			import_name = string.sub(basename,1,ext_pos-1)
		end

		local mo = require(tostring(import_name))
		local profs = nil
		local dummy_manager = {}
		function dummy_manager:registerFactory(prof,new_func,delete_func)
			profs = prof
		end
		mo.Init(dummy_manager)
		if profs == nil then
			print("Load failed. file name: ", fullname)
		else
			local keys = profs:propertyNames()
			for k,v in pairs(keys) do
				print(v..":"..profs:getProperty(v))
			end
		end

	end
end

main()
