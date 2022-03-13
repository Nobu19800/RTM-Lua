$OPENRTMLUA_VERSION = "0.5.0"

$VERSION_OMIT = "OFF"
$ARCH = "x64"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x64"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1
& ${PSScriptRoot}\install_luajit_x64.ps1

$ARCH = "Win32"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x86"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1
& ${PSScriptRoot}\install_luajit_x64.ps1

$ARCH = "ARM"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x86_arm"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1

$ARCH = "ARM64"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\amd64_arm64"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1


$VERSION_OMIT = "ON"
$ARCH = "x64"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x64"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1


$ARCH = "Win32"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x86"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1

$ARCH = "ARM"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x86_arm"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1


$ARCH = "ARM64"
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\amd64_arm64"

& ${PSScriptRoot}\install_lua51_x64.ps1
& ${PSScriptRoot}\install_lua52_x64.ps1
& ${PSScriptRoot}\install_lua53_x64.ps1
& ${PSScriptRoot}\install_lua54_x64.ps1