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
 libssl-dev\
 omniorb-nameserver
 
ENV TEST_DIR=/root/test
ENV PORT=2809
ENV LOGDIR=/root/test/namelog

RUN mkdir /root/cothread
RUN wget -O - https://github.com/renatomaia/cothread/archive/refs/tags/v0.1.1.tar.gz\
 | tar xfz - -C /root/cothread --strip-components 1\
 && cd /root/cothread\
 && luarocks pack etc/cothread-0.1-1.rockspec
 && luarocks install cothread-0.1-1.src.rock
 
RUN mkdir /root/luatuple
RUN wget -O - https://github.com/renatomaia/luatuple/archive/refs/tags/v1.0beta2.tar.gz\
 | tar xfz - -C /root/luatuple --strip-components 1\
 && cd /root/luatuple\
 && luarocks pack etc/tuple-1.0beta-1.rockspec
 && luarocks install tuple-1.0beta-1.src.rock
 
RUN luarocks install loopparsing
RUN luarocks install loopserializing
RUN luarocks install loopcomp
RUN luarocks install luasec
RUN luarocks install luaunit
RUN luarocks install luacov

RUN mkdir /root/struct
RUN wget -O - http://www.inf.puc-rio.br/~roberto/struct/struct-0.3.tar.gz\
 | tar xfz - -C /root/struct\
 && wget -O /root/struct/struct-1.4-1.rockspec https://luarocks.org/manifests/luarocks/struct-1.4-1.rockspec\
 && sed  -i -e 's/lua >= 5.1, < 5.3/lua >= 5.1, <= 5.4/g' /root/struct/struct-1.4-1.rockspec\
 && cd /root/struct\
 && luarocks pack struct-1.4-1.rockspec
 && luarocks install struct-1.4-1.src.rock

RUN mkdir /root/oil
RUN wget -O - https://github.com/renatomaia/oil/archive/refs/tags/OIL_0_7_0.tar.gz\
 | tar xfz - -C /root/oil --strip-components 1\
 && sed  -i -e 's/version = "0.6"/version = "0.6-1"/g' /root/oil/etc/oil-0.6.rockspec\
 && sed  -i -e 's/"looplib >= 2.0beta",//g' /root/oil/etc/oil-0.6.rockspec\
 && cp /root/oil/etc/oil-0.6.rockspec /root/oil/etc/oil-0.6-1.rockspec\
 && cd /root/oil\
 && luarocks pack etc/oil-0.6-1.rockspec
 && luarocks install oil-0.6-1.src.rock

RUN mkdir $TEST_DIR\
 && cd $TEST_DIR/\
 && sh /root/RTM-Lua/scripts/rtm-naming.sh\
 && cp /root/RTM-Lua/.luacov $TEST_DIR/.luacov\
 && export LUA_PATH=";;/root/RTM-Lua/lua/?.lua;/root/RTM-Lua/test/?.lua;$LUA_PATH"\
 && lua -lluacov /root/RTM-Lua/test/all_test.lua -v


CMD touch /root/share/test.txt

