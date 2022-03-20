$WORKSPACE = (Convert-Path .)

if($OPENRTMLUA_VERSION -eq $null)
{
  $OPENRTMLUA_VERSION = "0.4.2"
}

if($ARCH -eq $null)
{
  $ARCH = "x64"
}

if($VERSION_OMIT -eq $null)
{
  $VERSION_OMIT = "OFF"
}

$LUA_INSTASLL_DIR_NAME = "openrtm-lua-${OPENRTMLUA_VERSION}-${ARCH}-lua${LUA_SHORTVERSION}"
$LUA_INSTASLL_CC_DIR_NAME = "openrtm-lua-${OPENRTMLUA_VERSION}-cc-${ARCH}-lua${LUA_SHORTVERSION}"
if($VERSION_OMIT -eq "ON")
{
  $LUA_INSTASLL_DIR_NAME = "${LUA_INSTASLL_DIR_NAME}-versionomit"
  $LUA_INSTASLL_CC_DIR_NAME = "${LUA_INSTASLL_CC_DIR_NAME}-versionomit"
}

$env:LUA_DIR = "${WORKSPACE}\install\${LUA_INSTASLL_DIR_NAME}"

$LUA_SOURCE_DIR = "${WORKSPACE}\lua-${LUA_VERSION}"
$LUA_BUILD_DIR = "${WORKSPACE}\build_lua"
$LUASOCKET_SOURCE_DIR = "${WORKSPACE}\luasocket-${LUASOCKET_VERSION}"
$LUASOCKET_BUILD_DIR = "${WORKSPACE}\build_luasocket"
$LUASEC_SOURCE_DIR = "${WORKSPACE}\luasec-${LUASEC_VERSION}"
$LUASEC_BUILD_DIR = "${WORKSPACE}\build_luasec"
$STRUCT_SOURCE_DIR = "${WORKSPACE}\struct-${STRUCT_VERSION}"
$STRUCT_BUILD_DIR = "${WORKSPACE}\build_struct"
$LPEG_SOURCE_DIR = "${WORKSPACE}\lpeg-${LPEG_VERSION}"
$LPEG_BUILD_DIR = "${WORKSPACE}\build_lpeg"
$OPENRTM_EXTFILES_NAME = "openrtm-lua-0.5.0-lua5.2-files"
$OPENRTM_EXTFILES_DIR = "${WORKSPACE}\${OPENRTM_EXTFILES_NAME}"
$OPENRTM_SOURCE_DIR = "${WORKSPACE}\RTM-Lua"
$OPENRTM_SOURCE_CC_DIR = "${WORKSPACE}\RTM-Lua-cc"


if((Test-Path $LUA_BUILD_DIR) -eq $true){
  Remove-Item $LUA_BUILD_DIR -Recurse
}
if((Test-Path $LUASOCKET_BUILD_DIR) -eq $true){
  Remove-Item $LUASOCKET_BUILD_DIR -Recurse
}
if((Test-Path $LUASEC_BUILD_DIR) -eq $true){
  Remove-Item $LUASEC_BUILD_DIR -Recurse
}
if((Test-Path $STRUCT_BUILD_DIR) -eq $true){
  Remove-Item $STRUCT_BUILD_DIR -Recurse
}
if((Test-Path $LPEG_BUILD_DIR) -eq $true){
  Remove-Item $LPEG_BUILD_DIR -Recurse
}
if((Test-Path $env:LUA_DIR) -eq $true){
  Remove-Item $env:LUA_DIR -Recurse
}


if((Test-Path $LUA_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" -OutFile "${WORKSPACE}\lua-${LUA_VERSION}.tar.gz"
  tar -xf "${WORKSPACE}\lua-${LUA_VERSION}.tar.gz"
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/Lua-${LUA_SHORTVERSION}/CMakeLists.txt" -OutFile "${LUA_SOURCE_DIR}\CMakeLists.txt"


cmake "$LUA_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LUA_BUILD_DIR" -A $ARCH -DVERSION_OMIT=$VERSION_OMIT
cmake --build "$LUA_BUILD_DIR" --config Release
cmake --build "$LUA_BUILD_DIR" --config Release --target install


if((Test-Path $LUASOCKET_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "https://github.com/renatomaia/luasocket/archive/refs/tags/v${LUASOCKET_VERSION}.zip" -OutFile "${WORKSPACE}\v${LUASOCKET_VERSION}.zip"
  Expand-Archive -Path "v${LUASOCKET_VERSION}.zip" -DestinationPath "${WORKSPACE}" -Force
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/luasocket-${LUASOCKET_VERSION}/CMakeLists.txt" -OutFile "${LUASOCKET_SOURCE_DIR}\CMakeLists.txt"
cmake "$LUASOCKET_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LUASOCKET_BUILD_DIR" -A $ARCH
cmake --build "$LUASOCKET_BUILD_DIR" --config Release
cmake --build "$LUASOCKET_BUILD_DIR" --config Release --target install


if((Test-Path $LUASEC_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "https://github.com/brunoos/luasec/archive/refs/tags/v${LUASEC_VERSION}.zip" -OutFile "${WORKSPACE}\v${LUASEC_VERSION}.zip"
  Expand-Archive -Path "v${LUASEC_VERSION}.zip" -DestinationPath "${WORKSPACE}" -Force
}



Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/luasec/CMakeLists.txt" -OutFile "${LUASEC_SOURCE_DIR}\CMakeLists.txt"

if($env:OPENSSL_ROOT_DIR -eq $null)
{
  cmake "$LUASEC_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LUASEC_BUILD_DIR" -A $ARCH
}
else
{
  cmake "$LUASEC_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -DOPENSSL_ROOT_DIR="$env:OPENSSL_ROOT_DIR" -B "$LUASEC_BUILD_DIR" -A $ARCH
}
cmake --build "$LUASEC_BUILD_DIR" --config Release
cmake --build "$LUASEC_BUILD_DIR" --config Release --target install



if((Test-Path $STRUCT_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "http://www.inf.puc-rio.br/~roberto/struct/struct-${STRUCT_VERSION}.tar.gz" -OutFile "${WORKSPACE}\struct-${STRUCT_VERSION}.tar.gz"
  New-Item $STRUCT_SOURCE_DIR -ItemType Directory
  tar -xf "${WORKSPACE}\struct-${STRUCT_VERSION}.tar.gz" -C "${STRUCT_SOURCE_DIR}"
}


Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/struct/CMakeLists.txt" -OutFile "${STRUCT_SOURCE_DIR}\CMakeLists.txt"
cmake "$STRUCT_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$STRUCT_BUILD_DIR" -A $ARCH
cmake --build "$STRUCT_BUILD_DIR" --config Release
cmake --build "$STRUCT_BUILD_DIR" --config Release --target install



if((Test-Path $LPEG_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-${LPEG_VERSION}.tar.gz" -OutFile "${WORKSPACE}\lpeg-${LPEG_VERSION}.tar.gz"
  tar -xf "${WORKSPACE}\lpeg-${LPEG_VERSION}.tar.gz"
}


Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/lpeg/CMakeLists.txt" -OutFile "${LPEG_SOURCE_DIR}\CMakeLists.txt"
#Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/lpeg/lptree.c" -OutFile "${LPEG_SOURCE_DIR}\lptree.c"
$(Get-Content "${LPEG_SOURCE_DIR}\lptree.c") -replace "int luaopen_lpeg \(lua_State \*L\);","__declspec(dllexport) int luaopen_lpeg (lua_State *L);" > "${LPEG_SOURCE_DIR}\lptree_tmp.c"
Move-Item "${LPEG_SOURCE_DIR}\lptree_tmp.c" "${LPEG_SOURCE_DIR}\lptree.c" -force
cmake "$LPEG_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="${env:LUA_DIR}\moon" -B "$LPEG_BUILD_DIR" -A $ARCH
cmake --build "$LPEG_BUILD_DIR" --config Release
cmake --build "$LPEG_BUILD_DIR" --config Release --target install




Remove-Item ${env:LUA_DIR}\include -Recurse -Force
Remove-Item ${env:LUA_DIR}\lib -Recurse -Force

if((Test-Path $OPENRTM_EXTFILES_DIR) -eq $false){
  Invoke-WebRequest "https://github.com/Nobu19800/RTM-Lua/releases/download/v0.5.0b/${OPENRTM_EXTFILES_NAME}.zip" -OutFile "${WORKSPACE}\${OPENRTM_EXTFILES_NAME}.zip"
  Expand-Archive -Path "${OPENRTM_EXTFILES_NAME}.zip" -DestinationPath "${WORKSPACE}" -Force
}

Copy-Item "${OPENRTM_EXTFILES_DIR}\examples" -destination "${env:LUA_DIR}\" -recurse
Copy-Item "${OPENRTM_EXTFILES_DIR}\Licenses" -destination "${env:LUA_DIR}\" -recurse
Copy-Item "${OPENRTM_EXTFILES_DIR}\lua" -destination "${env:LUA_DIR}\" -recurse -force
Copy-Item "${OPENRTM_EXTFILES_DIR}\moon" -destination "${env:LUA_DIR}\" -recurse -force
Copy-Item "${OPENRTM_EXTFILES_DIR}\utils" -destination "${env:LUA_DIR}\" -recurse -force


$LUA_INSTASLL_CC_DIR = "${WORKSPACE}\install\${LUA_INSTASLL_CC_DIR_NAME}"
if((Test-Path $LUA_INSTASLL_CC_DIR) -eq $true){
  Remove-Item $LUA_INSTASLL_CC_DIR -Recurse
}
Copy-Item "$env:LUA_DIR" -destination "$LUA_INSTASLL_CC_DIR" -recurse

if((Test-Path $OPENRTM_SOURCE_DIR) -eq $false){
  git clone https://github.com/Nobu19800/RTM-Lua $OPENRTM_SOURCE_DIR
}
if((Test-Path $OPENRTM_SOURCE_CC_DIR) -eq $false){
  git clone https://github.com/Nobu19800/RTM-Lua -b corba_cdr_support $OPENRTM_SOURCE_CC_DIR
}


Copy-Item "${OPENRTM_SOURCE_DIR}\examples" -destination "${env:LUA_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_DIR}\idl" -destination "${env:LUA_DIR}\lua\" -recurse
Copy-Item "${OPENRTM_SOURCE_DIR}\moon" -destination "${env:LUA_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_DIR}\examples" -destination "${env:LUA_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_DIR}\lua" -destination "${env:LUA_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_DIR}\utils\rtcd.lua" -destination "${env:LUA_DIR}\utils\"
Copy-Item "${OPENRTM_SOURCE_DIR}\utils\rtc.conf" -destination "${env:LUA_DIR}\utils\"

Copy-Item "${OPENRTM_SOURCE_CC_DIR}\examples" -destination "${LUA_INSTASLL_CC_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_CC_DIR}\idl" -destination "${LUA_INSTASLL_CC_DIR}\lua\" -recurse
Copy-Item "${OPENRTM_SOURCE_CC_DIR}\moon" -destination "${LUA_INSTASLL_CC_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_CC_DIR}\examples" -destination "${LUA_INSTASLL_CC_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_CC_DIR}\lua" -destination "${LUA_INSTASLL_CC_DIR}\" -recurse -force
Copy-Item "${OPENRTM_SOURCE_CC_DIR}\utils\rtcd.lua" -destination "${LUA_INSTASLL_CC_DIR}\utils\"
Copy-Item "${OPENRTM_SOURCE_CC_DIR}\utils\rtc.conf" -destination "${LUA_INSTASLL_CC_DIR}\utils\"


Compress-Archive -Path "$env:LUA_DIR" -DestinationPath "${WORKSPACE}\install\${LUA_INSTASLL_DIR_NAME}.zip" -Force
Compress-Archive -Path "$LUA_INSTASLL_CC_DIR" -DestinationPath "${WORKSPACE}\install\${LUA_INSTASLL_CC_DIR_NAME}.zip" -Force