$LUA_SHORTVERSION = "5.3"
$LUA_VERSION = "${LUA_SHORTVERSION}.6"
if($env:OPENSSL_ROOT_DIR -eq $null)
{
  $env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x86"
}
$LUASOCKET_VERSION = "2.0.3"
$LUASEC_VERSION = "1.0.2"
$STRUCT_VERSION = "0.3"
$LPEG_VERSION = "1.0.2"
$ARCH = "Win32"
#$VERSION_OMIT = "OFF"

& ${PSScriptRoot}\install_lua.ps1
