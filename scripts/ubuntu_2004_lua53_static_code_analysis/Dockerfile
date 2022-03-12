FROM ubuntu:20.04

COPY RTM-Lua /root/RTM-Lua


RUN apt update\
 && apt install -y --no-install-recommends\
 lua5.3\
 liblua5.3-dev\
 luarocks\
 g++\
 make\
 cmake\
 ca-certificates\
 wget
 
RUN luarocks install luacheck

CMD cd /root/RTM-Lua\
 && luacheck lua/openrtm/*.lua\
 && luacheck samples/*.lua\
 && luacheck utils/*.lua

