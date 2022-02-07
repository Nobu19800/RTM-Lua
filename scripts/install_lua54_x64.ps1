$LUA_SHORTVERSION = "5.4"
$LUA_VERSION = "${LUA_SHORTVERSION}.4"
if($env:OPENSSL_ROOT_DIR -eq $null)
{
  $env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x64"
}
$LUASOCKET_VERSION = "2.0.3"
$LUASEC_VERSION = "1.0.2"
$STRUCT_VERSION = "0.3"
$LPEG_VERSION = "1.0.2"
#$ARCH = "x64"
#$VERSION_OMIT = "OFF"

& ${PSScriptRoot}\install_lua.ps1
