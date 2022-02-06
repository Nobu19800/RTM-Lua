$LUA_SHORTVERSION = "5.2"
$LUA_VERSION = "${LUA_SHORTVERSION}.4"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x64"
$LUASOCKET_VERSION = "2.0.3"
$LUASEC_VERSION = "1.0.2"
$STRUCT_VERSION = "0.3"
$LPEG_VERSION = "1.0.2"
$ARCH = "x64"
#$ARCH = "Win32"

& ${PSScriptRoot}\install_lua.ps1
