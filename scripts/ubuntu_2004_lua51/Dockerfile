FROM ubuntu:20.04

COPY RTM-Lua /root/RTM-Lua


RUN apt update\
 && apt install -y --no-install-recommends\
 lua5.1\
 liblua5.1-dev\
 luarocks\
 g++\
 make\
 cmake\
 ca-certificates\
 wget\
 omniorb-nameserver
 
ENV TEST_DIR=/root/test
ENV PORT=2809
ENV LOGDIR=/root/namelog


RUN luarocks install uuid\
 && luarocks install loop\
 && luarocks install luaidl\
 && luarocks install luasocket\
 && luarocks install oil\
 && luarocks install lualogging\
 && luarocks install luaunit


CMD mkdir $TEST_DIR\
 && cd $TEST_DIR/\
 && sh /root/RTM-Lua/scripts/rtm-naming.sh\
 && cp -r /root/RTM-Lua/idl /root/RTM-Lua/lua/idl\
 && cp /root/RTM-Lua/test/MyService.idl $TEST_DIR/MyService.idl\
 && export LUA_PATH=";;/root/RTM-Lua/lua/?.lua;/root/RTM-Lua/test/?.lua;$LUA_PATH"\
 && lua5.1 /root/RTM-Lua/test/all_test51.lua -v


