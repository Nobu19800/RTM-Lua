cmake_minimum_required (VERSION 2.6)

project (socket)

set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")
set(LUA_VERSION ${LUA_VERSION} CACHE STRING "set LUA_VERSION")

if(MSVC)
	
	if(NOT LUA_ROOT)
		message(FATAL_ERROR "Please set LUA_ROOT.")
	endif()
	

	if(NOT LUA_VERSION)
		message(FATAL_ERROR "Please set LUA_VERSION.")
	endif()
else(MSVC)
	if(NOT LUA_VERSION)
		set(LUA_VERSION 5.1)
	endif()
endif(MSVC)

set(srcs
	src/auxiliar.c
	src/buffer.c
	src/except.c
	src/inet.c
	src/io.c
	src/luasocket.c
	src/options.c
	src/select.c
	src/tcp.c
	src/timeout.c
	src/udp.c
	src/auxiliar.h
	src/buffer.h
	src/except.h
	src/inet.h
	src/io.h
	src/luasocket.h
	src/options.h
	src/select.h
	src/socket.h
	src/tcp.h
	src/timeout.h
	src/udp.h
)

if(MSVC)
	set(srcs ${srcs} src/wsocket.h src/wsocket.c)
else(MSVC)
	set(srcs ${srcs} src/usocket.h src/usocket.c src/unix.h)
endif(MSVC)


if(MSVC)
	ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
endif(MSVC)


if(MSVC)
else(MSVC)
	if(LUA_ROOT)
	else(LUA_ROOT)
		include_directories(/usr/include/lua${LUA_VERSION})
	endif(LUA_ROOT)
endif(MSVC)

if(LUA_ROOT)
	include_directories(${LUA_ROOT}/include)
	link_directories(${LUA_ROOT}/lib)
endif(LUA_ROOT)

add_library (luasoket SHARED ${srcs})

if(MSVC)
	target_link_libraries(luasoket lua${LUA_VERSION} ws2_32)
else(MSVC)
	target_link_libraries(luasoket lua${LUA_VERSION})
	set_target_properties (luasoket
                       PROPERTIES PREFIX
                       "")
endif(MSVC)




SET_TARGET_PROPERTIES(luasoket PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/socket)
SET_TARGET_PROPERTIES(luasoket PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/socket)
SET_TARGET_PROPERTIES(luasoket PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/socket)
SET_TARGET_PROPERTIES(luasoket PROPERTIES OUTPUT_NAME core)


if(MSVC)
	ADD_DEFINITIONS("-DMIME_API=__declspec(dllexport)")
endif(MSVC)


add_library (mine SHARED  src/mime.c src/mime.h)

if(MSVC)
	target_link_libraries(mine lua${LUA_VERSION} ws2_32)
else(MSVC)
	target_link_libraries(mine lua${LUA_VERSION})
	set_target_properties (mine
                       PROPERTIES PREFIX
                       "")
endif(MSVC)

SET_TARGET_PROPERTIES(mine PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/mine)
SET_TARGET_PROPERTIES(mine PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/mine)
SET_TARGET_PROPERTIES(mine PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/mine)
SET_TARGET_PROPERTIES(mine PROPERTIES OUTPUT_NAME core)


set(lua_files 
	src/ftp.lua
	src/http.lua
	src/ltn12.lua
	src/mbox.lua
	src/smtp.lua
	src/tp.lua
	src/url.lua
)

if(MSVC)
	install(TARGETS luasoket RUNTIME DESTINATION ${LUA_ROOT}/clibs/socket)
	install(TARGETS mine RUNTIME DESTINATION ${LUA_ROOT}/clibs/mine)
else(MSVC)
	install(TARGETS luasoket LIBRARY DESTINATION ${LUA_ROOT}/clibs/socket)
	install(TARGETS mine LIBRARY DESTINATION ${LUA_ROOT}/clibs/mine)
endif(MSVC)
install(FILES ${lua_files} DESTINATION ${LUA_ROOT}/lua/socket)
install(FILES src/socket.lua DESTINATION ${LUA_ROOT}/lua)
install(FILES src/mime.lua DESTINATION ${LUA_ROOT}/lua)