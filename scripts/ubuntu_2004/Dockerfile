FROM ubuntu:20.04

COPY RTM-Lua /root/RTM-Lua


RUN apt update\
 && apt install -y --no-install-recommends\
 lua5.3\
 luarocks\
 g++\
 make\
 cmake\
 wget
RUN touch test.txt
RUN ls

CMD ls /root/RTM-Lua
