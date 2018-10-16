#!/bin/sh


build_path=luamodule_$1
mkdir $build_path

wget http://www.tecgraf.puc-rio.br/~maia/oil/oil-0.5.tar.gz
tar xf ./oil-0.5.tar.gz
cd oil-0.5/src
wget https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/oil/src/CMakeLists.txt
mkdir build
cd build
cmake .. -DLUA_VERSION=5.1
make

cd ../..
mkdir $build_path/socket
cp luasocket-2.0.3/build/lib/socket/core.so $build_path/socket
mkdir $build_path/socket
cp luasocket-2.0.3/build/lib/oil/bit.so $build_path/oil