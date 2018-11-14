# OpenRTM-aist C++ 2.0(開発中)のインストール

※以下の内容は上級者向けの内容です。自信、時間のない人はOpenRTM Luaのcorba_cdr対応版を使ってください。

OpenRTM-aist 1.0系付属のDataPort.idlはOiLでは読み込めないため、OpenRTM-aist 2.0付属のDataPort.idlが必要になります。

corba_cdr対応版では他のIDLファイルを改変することでDataPort.idlの読み込みを可能にしていますが、通常版はOpenRTM-aist 1.2以前、およびOpenRTM.NETと通信することができません。

ただ、開発中のOpenRTM-aist 2.0とは通信できるため、OpenRTM-aist 2.0(開発中)のインストール方法を説明します。

## omniORBの入手
OpenRTM-aistを各自の環境でビルドする必要があります。
まずはビルド済みのomniORBを入手します。Visual Studio、Pythonのバージョンが合っているものを選んでください。

* [omniORB-4.2.2](http://tmp.openrtm.org/pub/omniORB/win32/omniORB-4.2.2/)

## OpenRTM-aistのビルド

[TortoiseSVN](https://ja.osdn.net/projects/tortoisesvn/)等で以下からOpenRTM-aist 2.0のソースコードを入手します。

* [http://svn.openrtm.org/OpenRTM-aist/trunk/OpenRTM-aist/](http://svn.openrtm.org/OpenRTM-aist/trunk/OpenRTM-aist/)

OpenRTM-aistのフォルダに移動して、以下のコマンドでビルドします。

<pre>
mkdir src\lib\coil\common\coil
move src\lib\coil\common\*.* src\lib\coil\common\coil 
copy build\yat.py utils\rtm-skelwrapper 
mkdir build_omni
cd build_omni
cmake -DOMNI_VERSION=42  -DOMNI_MINOR=2 -DOMNITHREAD_VERSION=40 -DORB_ROOT=C:/workspace/omniORB-4.2.2-win64-vc141 -DCORBA=omniORB -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX="C:/workspace/openrtm_install" ..
cmake --build . --config Release
cmake --build . --config Releas --target INSTALL
</pre>

omniORBを配置したフォルダ、コンパイラの種類、インストールするフォルダは適宜編集してください。

環境変数`OpenRTM_DIR`に`C:/workspace/openrtm_install/2.0.0/cmake`を設定してください。
インストールしたフォルダが違う場合は適宜変更してください。


これでインストール完了です。
