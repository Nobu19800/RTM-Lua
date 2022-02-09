#!/bin/sh


build_path=luamodule_$1
mkdir $build_path

wget http://www.tecgraf.puc-rio.br/~maia/oil/oil-0.5.tar.gz
tar xf ./oil-0.5.tar.gz
cd oil-0.5
wget https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/oil/CMakeLists.txt
mkdir build
cd build
cmake ..
make


cd ../../..
mkdir $build_path/socket
cp oil-0.5/src/build/core.so $build_path/socket/
mkdir $build_path/oil
cp oil-0.5/src/build/bit.so $build_path/oil/