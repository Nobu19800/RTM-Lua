cmake_minimum_required (VERSION 2.8.13)

option(VERSION_OMIT  "Omit the version name from the library file name"  No)

set(target lua54)
project (${target})


set(srcs
	src/lapi.c
	src/lauxlib.c
	src/lbaselib.c
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




if(WIN32)
	ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
else(WIN32)
	ADD_DEFINITIONS(-DLUA_USE_POSIX -DLUA_USE_DLOPEN)
endif(WIN32)

ADD_DEFINITIONS(-DLUA_COMPAT_MODULE -DLUA_COMPAT_APIINTCASTS)



add_library (${target} SHARED ${srcs} ${headers} src/luac.c)
if(VERSION_OMIT)
	set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_NAME "lua")
endif(VERSION_OMIT)
add_executable (lua  src/lua.c)
add_executable (luac src/luac.c ${srcs})

if(WIN32)
	target_link_libraries(lua ${target})
else(WIN32)
	#sudo apt-get install ncurses-dev
	target_link_libraries(lua ${target} dl readline history ncurses m)
	target_link_libraries(luac dl readline history ncurses m)
endif(WIN32)


if(WIN32)
	install(TARGETS ${target} ARCHIVE DESTINATION lib)
	install(TARGETS ${target} RUNTIME DESTINATION bin)
else(WIN32)
	install(TARGETS ${target} LIBRARY DESTINATION lib)
endif(WIN32)
install(TARGETS lua RUNTIME DESTINATION bin)
install(TARGETS luac RUNTIME DESTINATION bin)
install(FILES ${headers} DESTINATION include)
