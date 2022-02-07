# ビルド手順

powershellで`install_lua_all.ps1`を実行する。

```
.\install_lua_all.ps1
```

必要に応じてOpenSSLのパスを設定する。

```
$env:OPENSSL_ROOT_DIR = "C:\workspace\openssl\x64"
```


## OpenSSLのビルド

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
