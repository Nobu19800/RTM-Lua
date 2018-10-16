#!/bin/sh


build_path=luamodule_$1
mkdir $build_path

wget http://www.inf.puc-rio.br/~roberto/struct/struct-0.3.tar.gz
mkdir struct
cd struct
tar xf ../struct-0.3.tar.gz
wget https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/struct/CMakeLists.txt
mkdir build
cd build
cmake .. -DLUA_VERSION=5.2
make

cd ../..
cp struct/build/struct.so $build_path/


wget https://github.com/renatomaia/luasocket/archive/v2.0.3.tar.gz
tar xf v2.0.3.tar.gz
cd luasocket-2.0.3
wget https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/luasocket-2.0.3/CMakeLists.txt
mkdir build
cd build
cmake .. -DLUA_VERSION=5.2
make

cd ../..
mkdir $build_path/socket
cp luasocket-2.0.3/build/lib/socket/core.so $build_path/socket