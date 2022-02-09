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
  $LUA_INSTASLL_DIR_NAME = "${LUA_INSTASLL_CC_DIR_NAME}-versionomit"
}

$env:LUA_DIR = "${WORKSPACE}\install\${LUA_INSTASLL_DIR_NAME}"

$LUA_SOURCE_DIR = "${WORKSPACE}\lua-${LUA_VERSION}"
$LUA_BUILD_DIR = "${WORKSPACE}\build_lua"
$OIL_SOURCE_DIR = "${WORKSPACE}\oil-${OIL_VERSION}"
$OIL_BUILD_DIR = "${WORKSPACE}\build_oil"


if((Test-Path $LUA_BUILD_DIR) -eq $true){
  Remove-Item $LUA_BUILD_DIR -Recurse
}
if((Test-Path $OIL_BUILD_DIR) -eq $true){
  Remove-Item $OIL_BUILD_DIR -Recurse
}



if((Test-Path $LUA_SOURCE_DIR) -eq $false){
  Invoke-WebRequest "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" -OutFile "${WORKSPACE}\lua-${LUA_VERSION}.tar.gz"
  tar -xf "${WORKSPACE}\lua-${LUA_VERSION}.tar.gz"
}

Invoke-WebRequest "https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/Lua-${LUA_SHORTVERSION}/CMakeLists.txt" -OutFile "${LUA_SOURCE_DIR}\CMakeLists.txt"


cmake "$LUA_SOURCE_DIR" -DCMAKE_INSTALL_PREFIX="$env:LUA_DIR" -B "$LUA_BUILD_DIR" -A $ARCH -DVERSION_OMIT=$VERSION_OMIT
cmake --build "$LUA_BUILD_DIR" --config Release
cmake --build "$LUA_BUILD_DIR" --config Release --target install
