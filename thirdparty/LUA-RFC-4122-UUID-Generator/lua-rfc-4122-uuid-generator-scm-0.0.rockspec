package = "lua-rfc-4122-uuid-generator"
version = "scm-0.0"
source = {
   url = "https://github.com/tcjennings/LUA-RFC-4122-UUID-Generator/archive/master.zip",
   dir = "LUA-RFC-4122-UUID-Generator-master",
}

description = {
   summary = "",
   detailed = [[
      
   ]],
   homepage = "",
   license = ""
}


dependencies = {
   "lua >= 5.1"
}


build = {
    type = "builtin",
    modules = {
        ["LUA-RFC-4122-UUID-Generator.main"] = "LUA-RFC-4122-UUID-Generator/main.lua",
        ["LUA-RFC-4122-UUID-Generator.uuid4"] = "LUA-RFC-4122-UUID-Generator/uuid4.lua",
        ["LUA-RFC-4122-UUID-Generator.uuid5"] = "LUA-RFC-4122-UUID-Generator/uuid5.lua"
    }
}