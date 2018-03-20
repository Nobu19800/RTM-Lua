cmake_minimum_required (VERSION 2.6)

set(target lua5.3)
project (${target})


set(srcs
	src/lapi.c
	src/lauxlib.c
	src/lbaselib.c
	src/lbitlib.c
	src/lcode.c
	src/lcorolib.c
	src/lctype.c
	src/ldblib.c
	src/ldebug.c
	src/ldo.c
	src/ldump.c
	src/lfunc.c
	src/lgc.c
	src/linit.c
	src/liolib.c
	src/llex.c
	src/lmathlib.c
	src/lmem.c
	src/loadlib.c
	src/lobject.c
	src/lopcodes.c
	src/loslib.c
	src/lparser.c
	src/lstate.c
	src/lstring.c
	src/lstrlib.c
	src/ltable.c
	src/ltablib.c
	src/ltm.c
	src/lundump.c
	src/lutf8lib.c
	src/lvm.c
	src/lzio.c
)

set(headers
	src/lapi.h
	src/lauxlib.h
	src/lcode.h
	src/lctype.h
	src/ldebug.h
	src/ldo.h
	src/lfunc.h
	src/lgc.h
	src/llex.h
	src/llimits.h
	src/lmem.h
	src/lobject.h
	src/lopcodes.h
	src/lparser.h
	src/lprefix.h
	src/lstate.h
	src/lstring.h
	src/ltable.h
	src/ltm.h
	src/lua.h
	src/lua.hpp
	src/luaconf.h
	src/lualib.h
	src/lundump.h
	src/lvm.h
	src/lzio.h
)




add_definitions("-DLUA_BUILD_AS_DLL")


add_library (${target} SHARED  ${srcs} ${headers}  src/luac.c)
add_executable (lua  src/lua.c)
target_link_libraries(lua ${target})

install(TARGETS ${target} ARCHIVE DESTINATION lib)
install(TARGETS ${target} RUNTIME DESTINATION bin)
install(TARGETS lua RUNTIME DESTINATION bin)
install(FILES ${headers} DESTINATION include)
