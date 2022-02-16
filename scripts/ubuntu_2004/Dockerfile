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
 git\
 wget\
 && git clone https://github.com/renatomaia/cothread
 && cd cothread
 && luarocks make etc/cothread-0.1-1.rockspec


CMD touch /root/share/test.txt

