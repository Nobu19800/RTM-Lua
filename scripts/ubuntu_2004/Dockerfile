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
 wget\
 libssl-dev
 
ENV TEST_DIR=/root/test

RUN mkdir /root/cothread
RUN wget -O - https://github.com/renatomaia/cothread/archive/refs/tags/v0.1.1.tar.gz\
 | tar xfz - -C /root/cothread --strip-components 1\
 && cd /root/cothread\
 && luarocks make /root/cothread/etc/cothread-0.1-1.rockspec
 
RUN mkdir /root/luatuple
RUN wget -O - https://github.com/renatomaia/luatuple/archive/refs/tags/v1.0beta2.tar.gz\
 | tar xfz - -C /root/luatuple --strip-components 1\
 && cd /root/luatuple\
 && luarocks make /root/luatuple/etc/tuple-1.0beta-1.rockspec
 
RUN luarocks install loopparsing
RUN luarocks install loopserializing
RUN luarocks install loopcomp
RUN luarocks install luasec

RUN mkdir /root/struct
RUN wget -O - http://www.inf.puc-rio.br/~roberto/struct/struct-0.3.tar.gz\
 | tar xfz - -C /root/struct --strip-components 1\
 && wget -O /root/struct/CMakeLists.txt https://raw.githubusercontent.com/Nobu19800/RTM-Lua/master/thirdparty/struct/CMakeLists.txt\
 && ls /root/struct/\
 && ls /root\
 && ls /\
 && cmake /root/struct -DCMAKE_INSTALL_PREFIX=$TEST_DIR -B /tmp/struct/build\
 && cmake --build /tmp/struct/build --config Release\
 && cmake --build /tmp/struct/build --config Release --target install


CMD touch /root/share/test.txt

