$WORKSPACE = (Convert-Path .)

if($OPENRTMLUA_VERSION -eq $null)
{
  $OPENRTMLUA_VERSION = "0.4.2"
}

if($ARCH -eq $null)
{
  $ARCH = "x64"
}

if($VCVARSALLBAT -eq $null)
{
  $VCVARSALL_BAT = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
}

$LUA_INSTASLL_DIR_NAME = "openrtm-lua-${OPENRTMLUA_VERSION}-${ARCH}-LuaJIT${LUAJIT_VERSION}"
$LUA_INSTASLL_CC_DIR_NAME = "openrtm-lua-${OPENRTMLUA_VERSION}-cc-${ARCH}-LuaJIT${LUAJIT_VERSION}"

$env:LUA_DIR = "${WORKSPACE}\install\${LUA_INSTASLL_DIR_NAME}"

$LUA_SOURCE_DIR = "${WORKSPACE}\LuaJIT-${LUAJIT_VERSION}"
$OIL_SOURCE_DIR = "${WORKSPACE}\oil-${OIL_VERSION}"
$OIL_BUILD_DIR = "${WORKSPACE}\build_oil"
$LPEG_SOURCE_DIR = "${WORKSPACE}\lpeg-${LPEG_VERSION}"
$LPEG_BUILD_DIR = "${WORKSPACE}\build_lpeg"
$OPENRTM_EXTFILES_NAME = "openrtm-lua-0.5.0-luajit-files"
$OPENRTM_EXTFILES_DIR = "${WORKSPACE}\${OPENRTM_EXTFILES_NAME}"
$OPENRTM_SOURCE_DIR = "${WORKSPACE}\RTM-Lua"
$OPENRTM_SOURCE_CC_DIR = "${WORKSPACE}\RTM-Lua-cc"


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
  Invoke-WebRequest "https://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.zip" -OutFile "${WORKSPACE}\LuaJIT-${LUAJIT_VERSION}.zip"
  Expand-Archive -Path "${WORKSPACE}\LuaJIT-${LUAJIT_VERSION}.zip" -DestinationPath "${WORKSPACE}" -Force
}

Set-Location -Path ${LUA_SOURCE_DIR}\src

if($ARCH -eq "x64")
{
  cmd /c ${PSScriptRoot}\luajitBuild.bat "$VCVARSALL_BAT" "amd64"
}
elseif($ARCH -eq "Win32")
{
  cmd /c ${PSScriptRoot}\luajitBuild.bat "$VCVARSALL_BAT" "x86"
}


Set-Location -Path ${WORKSPACE}


New-Item "${env:LUA_DIR}" -ItemType Directory -Force
New-Item "${env:LUA_DIR}\bin" -ItemType Directory -Force
New-Item "${env:LUA_DIR}\include" -ItemType Directory -Force
New-Item "${env:LUA_DIR}\lib" -ItemType Directory -Force



Copy-Item "${LUA_SOURCE_DIR}\src\luajit.exe" -destination "${env:LUA_DIR}\bin\"
Copy-Item "${LUA_SOURCE_DIR}\src\lua51.dll" -destination "${env:LUA_DIR}\bin\"
Copy-Item "${LUA_SOURCE_DIR}\src\lua51.lib" -destination "${env:LUA_DIR}\lib\"
Copy-Item "${LUA_SOURCE_DIR}\src\luajit.lib" -destination "${env:LUA_DIR}\lib\"
Copy-Item "${LUA_SOURCE_DIR}\src\*.h" -destination "${env:LUA_DIR}\include\"
Copy-Item "${LUA_SOURCE_DIR}\src\lua.hpp" -destination "${env:LUA_DIR}\include\"


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
#cmake --build "$LPEG_BUILD_DIR" --config Release --target install


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
Copy-Item "$env:LUA_DIR" -destination "$LUA_INSTASLL_CC_DIR" -recurse -force

if((Test-Path $OPENRTM_SOURCE_DIR) -eq $false){
  git clone https://github.com/Nobu19800/RTM-Lua -b corba_cdr_support $OPENRTM_SOURCE_DIR
}
if((Test-Path $OPENRTM_SOURCE_CC_DIR) -eq $false){
  git clone https://github.com/Nobu19800/RTM-Lua $OPENRTM_SOURCE_CC_DIR
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