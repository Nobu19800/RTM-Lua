cd %~dp0


cd thirdparty\LUA-RFC-4122-UUID-Generator
cmd /c install.bat

cd ..\..
cmd /c luarocks make