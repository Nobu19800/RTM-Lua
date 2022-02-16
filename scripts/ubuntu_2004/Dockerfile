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

RUN mkdir /root/cothread
RUN wget -O - https://github.com/renatomaia/cothread/archive/refs/tags/v0.1.1.tar.gz\
 | tar xfz - -C /root/cothread --strip-components 1\
 && luarocks make /root/cothread/etc/cothread-0.1-1.rockspec


CMD touch /root/share/test.txt

