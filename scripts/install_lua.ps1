$WORKSPACE = (Convert-Path .)

if($ARCH -eq $null)
{
  $ARCH = "x64"
}
$env:LUA_DIR = "${WORKSPACE}\install_${LUA_SHORTVERSION}_${ARCH}"
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

if((Test-Path $LUA_BUILD_DIR) -eq "True"){
  Remove-Item $LUA_BUILD_DIR -Recurse
}
if((Test-Path $LUASOCKET_BUILD_DIR) -eq "True"){
  Remove-Item $LUASOCKET_BUILD_DIR -Recurse
}
if((Test-Path $LUASEC_BUILD_DIR) -eq "True"){
  Remove-Item $LUASEC_BUILD_DIR -Recurse
}
if((Test-Path $STRUCT_BUILD_DIR) -eq "True"){
  Remove-Item $STRUCT_BUILD_DIR -Recurse
}
if((Test-Path $LPEG_BUILD_DIR) -eq "True"){
  Remove-Item $LPEG_BUILD_DIR -Recurse
}

if((Test-Path $LUA_SOURCE_DIR) -eq "False"){
  Invoke-WebRequest "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" -OutFile "${WORKSPACE}\lua-${LUA_VERSION}.tar.gz"
  tar -xf "${WORKSPACE}\lua-${LUA_VERSION}.tar.gz"
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/Lua-${LUA_SHORTVERSION}/CMakeLists.txt" -OutFile "${LUA_SOURCE_DIR}\CMakeLists.txt"


cmake "$LUA_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LUA_BUILD_DIR" -A $ARCH
cmake --build "$LUA_BUILD_DIR" --config Release
cmake --build "$LUA_BUILD_DIR" --config Release --target install


if((Test-Path $LUASOCKET_SOURCE_DIR) -eq "False"){
  Invoke-WebRequest "https://github.com/renatomaia/luasocket/archive/refs/tags/v${LUASOCKET_VERSION}.zip" -OutFile "${WORKSPACE}\v${LUASOCKET_VERSION}.zip"
  Expand-Archive -Path "v${LUASOCKET_VERSION}.zip" -DestinationPath "${WORKSPACE}" -Force
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/luasocket-${LUASOCKET_VERSION}/CMakeLists.txt" -OutFile "${LUASOCKET_SOURCE_DIR}\CMakeLists.txt"
cmake "$LUASOCKET_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LUASOCKET_BUILD_DIR" -A $ARCH
cmake --build "$LUASOCKET_BUILD_DIR" --config Release
cmake --build "$LUASOCKET_BUILD_DIR" --config Release --target install


if((Test-Path $LUASEC_SOURCE_DIR) -eq "False"){
  Invoke-WebRequest "https://github.com/brunoos/luasec/archive/refs/tags/v${LUASEC_VERSION}.zip" -OutFile "${WORKSPACE}\v${LUASEC_VERSION}.zip"
  Expand-Archive -Path "v${LUASEC_VERSION}.zip" -DestinationPath "${WORKSPACE}" -Force
}


Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/luasec/CMakeLists.txt" -OutFile "${LUASEC_SOURCE_DIR}\CMakeLists.txt"
cmake "$LUASEC_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -DOPENSSL_ROOT_DIR="$env:OPENSSL_ROOT_DIR" -B "$LUASEC_BUILD_DIR" -A $ARCH
cmake --build "$LUASEC_BUILD_DIR" --config Release
cmake --build "$LUASEC_BUILD_DIR" --config Release --target install


if((Test-Path $STRUCT_SOURCE_DIR) -eq "False"){
  Invoke-WebRequest "http://www.inf.puc-rio.br/~roberto/struct/struct-${STRUCT_VERSION}.tar.gz" -OutFile "${WORKSPACE}\struct-${STRUCT_VERSION}.tar.gz"
  New-Item $STRUCT_SOURCE_DIR -ItemType Directory
  tar -xf "${WORKSPACE}\struct-${STRUCT_VERSION}.tar.gz" -C "${STRUCT_SOURCE_DIR}"
}


Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/struct/CMakeLists.txt" -OutFile "${STRUCT_SOURCE_DIR}\CMakeLists.txt"
cmake "$STRUCT_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$STRUCT_BUILD_DIR" -A $ARCH
cmake --build "$STRUCT_BUILD_DIR" --config Release
cmake --build "$STRUCT_BUILD_DIR" --config Release --target install



if((Test-Path $LPEG_SOURCE_DIR) -eq "False"){
  Invoke-WebRequest "http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-${LPEG_VERSION}.tar.gz" -OutFile "${WORKSPACE}\lpeg-${LPEG_VERSION}.tar.gz"
  tar -xf "${WORKSPACE}\lpeg-${LPEG_VERSION}.tar.gz"
}


Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/lpeg/CMakeLists.txt" -OutFile "${LPEG_SOURCE_DIR}\CMakeLists.txt"
#Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/lpeg/lptree.c" -OutFile "${LPEG_SOURCE_DIR}\lptree.c"
$(Get-Content "${LPEG_SOURCE_DIR}\lptree.c") -replace "int luaopen_lpeg \(lua_State \*L\);","__declspec(dllexport) int luaopen_lpeg (lua_State *L);" > "${LPEG_SOURCE_DIR}\lptree_tmp.c"
Move-Item "${LPEG_SOURCE_DIR}\lptree_tmp.c" "${LPEG_SOURCE_DIR}\lptree.c" -force
cmake "$LPEG_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LPEG_BUILD_DIR" -A $ARCH
cmake --build "$LPEG_BUILD_DIR" --config Release
cmake --build "$LPEG_BUILD_DIR" --config Release --target install