cd %~dp0

mkdir LUA-RFC-4122-UUID-Generator
rem git clone https://github.com/tcjennings/LUA-RFC-4122-UUID-Generator.git
bitsadmin.exe /TRANSFER LICENSE_get https://raw.githubusercontent.com/tcjennings/LUA-RFC-4122-UUID-Generator/master/LICENSE %~dp0\LUA-RFC-4122-UUID-Generator\LICENSE
bitsadmin.exe /TRANSFER main_get https://raw.githubusercontent.com/tcjennings/LUA-RFC-4122-UUID-Generator/master/main.lua %~dp0\LUA-RFC-4122-UUID-Generator\main.lua
bitsadmin.exe /TRANSFER uuid4get https://raw.githubusercontent.com/tcjennings/LUA-RFC-4122-UUID-Generator/master/uuid4.lua %~dp0\LUA-RFC-4122-UUID-Generator\uuid4.lua
bitsadmin.exe /TRANSFER uuid5get https://raw.githubusercontent.com/tcjennings/LUA-RFC-4122-UUID-Generator/master/uuid5.lua %~dp0\LUA-RFC-4122-UUID-Generator\uuid5.lua

cmd /c luarocks --local make
