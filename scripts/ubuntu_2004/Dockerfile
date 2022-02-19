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
 curl\
 libssl-dev\
 omniorb-nameserver
 
ENV TEST_DIR=/root/share
ENV PORT=2809
ENV LOGDIR=/root/namelog



RUN mkdir /root/luasocket\
 && wget -O - https://github.com/renatomaia/luasocket/archive/refs/tags/v2.0.3.tar.gz\
 | tar xfz - -C /root/luasocket --strip-components 1\
 && cp -i /root/RTM-Lua/thirdparty/luasocket-2.0.3/luasocket-scm-0.rockspec /root/luasocket/luasocket-scm-0.rockspec\
 && cd /root/luasocket\
 && luarocks make luasocket-scm-0.rockspec


RUN luarocks install loopparsing\
 && luarocks install loopserializing\
 && luarocks install loopcomp\
 && luarocks install uuid\
 && luarocks install loop\
 && luarocks install loopcollections\
 && luarocks install loopcomp\
 && luarocks install loopdebugging\
 && luarocks install loopobjects\
 && luarocks install lualogging\
 && luarocks install luasec\
 && luarocks install luaunit\
 && luarocks install luacov

RUN mkdir /root/cothread\
 && wget -O - https://github.com/renatomaia/cothread/archive/refs/tags/v0.1.1.tar.gz\
 | tar xfz - -C /root/cothread --strip-components 1\
 && cd /root/cothread\
 && luarocks make etc/cothread-0.1-1.rockspec
 
RUN mkdir /root/luatuple\
 && wget -O - https://github.com/renatomaia/luatuple/archive/refs/tags/v1.0beta2.tar.gz\
 | tar xfz - -C /root/luatuple --strip-components 1\
 && cd /root/luatuple\
 && luarocks make etc/tuple-1.0beta-1.rockspec
 

RUN mkdir /root/struct\
 && wget -O - http://www.inf.puc-rio.br/~roberto/struct/struct-0.3.tar.gz\
 | tar xfz - -C /root/struct\
 && wget -O /root/struct/struct-1.4-1.rockspec https://luarocks.org/manifests/luarocks/struct-1.4-1.rockspec\
 && sed  -i -e 's/lua >= 5.1, < 5.3/lua >= 5.1, <= 5.4/g' /root/struct/struct-1.4-1.rockspec\
 && cd /root/struct\
 && luarocks make struct-1.4-1.rockspec

RUN mkdir /root/oil\
 && wget -O - https://github.com/renatomaia/oil/archive/refs/tags/OIL_0_7_0.tar.gz\
 | tar xfz - -C /root/oil --strip-components 1\
 && cp -i /root/RTM-Lua/thirdparty/oil/corba/giop/Codec.lua /root/oil/lua/oil/corba/giop/Codec.lua\
 && sed  -i -e 's/version = "0.6"/version = "0.6-1"/g' /root/oil/etc/oil-0.6.rockspec\
 && sed  -i -e 's/"looplib >= 2.0beta",//g' /root/oil/etc/oil-0.6.rockspec\
 && cp /root/oil/etc/oil-0.6.rockspec /root/oil/etc/oil-0.6-1.rockspec\
 && cd /root/oil\
 && luarocks make etc/oil-0.6-1.rockspec

RUN cd $TEST_DIR/\
 && sh /root/RTM-Lua/scripts/rtm-naming.sh\
 && cp /root/RTM-Lua/.luacov $TEST_DIR/.luacov\
 && cp -r /root/RTM-Lua/idl /root/RTM-Lua/lua/idl\
 && export LUA_PATH=";;/root/RTM-Lua/lua/?.lua;/root/RTM-Lua/test/?.lua;/root/oil/lua/?.lua;$LUA_PATH"\
 && lua5.3 -lluacov /root/RTM-Lua/test/all_test.lua -v
 
RUN ls $TEST_DIR


