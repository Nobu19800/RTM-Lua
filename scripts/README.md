# �r���h�菇

powershell��`install_lua_all.ps1`�����s����B

```
.\install_lua_all.ps1
```

�K�v�ɉ�����OpenSSL�̃p�X��ݒ肷��B

```
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x64"
```


## OpenSSL�̃r���h

set OPENSSL_INSTALL_DIR=C:/workspace/openssl/x64
set OPENSSL_INSTALL_DIR=C:/workspace/openssl/x86
set OPENSSL_INSTALL_DIR=C:/workspace/openssl/x86_arm
set OPENSSL_INSTALL_DIR=C:/workspace/openssl/amd64_arm
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_arm
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64_arm
perl Configure VC-WIN64A --prefix=%OPENSSL_INSTALL_DIR% no-asm shared
perl Configure VC-WIN32 --prefix=%OPENSSL_INSTALL_DIR% no-asm shared
perl Configure VC-WIN32-ARM --prefix=%OPENSSL_INSTALL_DIR% no-asm shared
perl Configure VC-WIN64-ARM --prefix=%OPENSSL_INSTALL_DIR% no-asm shared
nmake install
