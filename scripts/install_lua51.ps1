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
$OIL_SOURCE_DIR = "${WORKSPACE}\oil-${OIL_VERSION}"
$OIL_BUILD_DIR = "${WORKSPACE}\build_oil"
$LPEG_SOURCE_DIR = "${WORKSPACE}\lpeg-${LPEG_VERSION}"
$LPEG_BUILD_DIR = "${WORKSPACE}\build_lpeg"


if((Test-Path $LUA_BUILD_DIR) -eq $true){
  Remove-Item $LUA_BUILD_DIR -Recurse
}
if((Test-Path $OIL_BUILD_DIR) -eq $true){
  Remove-Item $OIL_BUILD_DIR -Recurse
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


if((Test-Path $OIL_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "https://github.com/Nobu19800/RTM-Lua/raw/master/thirdparty/oil/oil-${OIL_VERSION}.zip" -OutFile "${WORKSPACE}\oil-${OIL_VERSION}.zip"
  Expand-Archive -Path "oil-${OIL_VERSION}.zip" -DestinationPath "${WORKSPACE}" -Force
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/oil/CMakeLists.txt" -OutFile "${OIL_SOURCE_DIR}\CMakeLists.txt"
cmake "$OIL_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$OIL_BUILD_DIR" -A $ARCH
cmake --build "$OIL_BUILD_DIR" --config Release
cmake --build "$OIL_BUILD_DIR" --config Release --target install


if((Test-Path $LPEG_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-${LPEG_VERSION}.tar.gz" -OutFile "${WORKSPACE}\lpeg-${LPEG_VERSION}.tar.gz"
  tar -xf "${WORKSPACE}\lpeg-${LPEG_VERSION}.tar.gz"
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/lpeg/CMakeLists.txt" -OutFile "${LPEG_SOURCE_DIR}\CMakeLists.txt"
$(Get-Content "${LPEG_SOURCE_DIR}\lptree.c") -replace "int luaopen_lpeg \(lua_State \*L\);","__declspec(dllexport) int luaopen_lpeg (lua_State *L);" > "${LPEG_SOURCE_DIR}\lptree_tmp.c"
Move-Item "${LPEG_SOURCE_DIR}\lptree_tmp.c" "${LPEG_SOURCE_DIR}\lptree.c" -force
cmake "$LPEG_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="${env:LUA_DIR}\moon" -B "$LPEG_BUILD_DIR" -A $ARCH
cmake --build "$LPEG_BUILD_DIR" --config Release
cmake --build "$LPEG_BUILD_DIR" --config Release --target install


Remove-Item ${env:LUA_DIR}\include -Recurse -Force
Remove-Item ${env:LUA_DIR}\lib -Recurse -Force


$LUA_INSTASLL_CC_DIR = "${WORKSPACE}\install\${LUA_INSTASLL_CC_DIR_NAME}"
if((Test-Path $LUA_INSTASLL_CC_DIR) -eq $true){
  Remove-Item $LUA_INSTASLL_CC_DIR -Recurse
}
Copy-Item "$env:LUA_DIR" -destination "$LUA_INSTASLL_CC_DIR" -recurse


Compress-Archive -Path "$env:LUA_DIR" -DestinationPath "${WORKSPACE}\install\${LUA_INSTASLL_DIR_NAME}.zip" -Force
Compress-Archive -Path "$LUA_INSTASLL_CC_DIR" -DestinationPath "${WORKSPACE}\install\${LUA_INSTASLL_CC_DIR_NAME}.zip" -Force