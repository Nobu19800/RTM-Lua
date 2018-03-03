cmake_minimum_required (VERSION 2.6)

project (socket)

set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")

if(NOT LUA_ROOT)
	message(FATAL_ERROR "Please set LUA_ROOT.")
endif()

set(LUA_VERSION ${LUA_VERSION} CACHE PATH "set LUA_VERSION")

if(NOT LUA_VERSION)
	message(FATAL_ERROR "Please set LUA_VERSION.")
endif()

set(srcs
	src/auxiliar.c
	src/buffer.c
	src/compat.c
	src/except.c
	src/inet.c
	src/io.c
	src/luasocket.c
	src/options.c
	src/select.c
	src/tcp.c
	src/timeout.c
	src/udp.c
	src/wsocket.c
	src/auxiliar.h
	src/buffer.h
	src/compat.h
	src/except.h
	src/inet.h
	src/io.h
	src/luasocket.h
	src/options.h
	src/pierror.h
	src/select.h
	src/socket.h
	src/tcp.h
	src/timeout.h
	src/udp.h
	src/wsocket.h
)

ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")


include_directories(${LUA_ROOT}/include)
link_directories(${LUA_ROOT}/lib)
add_library (luasoket SHARED  ${srcs})
target_link_libraries(luasoket lua${LUA_VERSION} ws2_32)


SET_TARGET_PROPERTIES(luasoket PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/socket)
SET_TARGET_PROPERTIES(luasoket PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/socket)
SET_TARGET_PROPERTIES(luasoket PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/socket)
SET_TARGET_PROPERTIES(luasoket PROPERTIES OUTPUT_NAME core)



ADD_DEFINITIONS("-DMIME_API=__declspec(dllexport)")

add_library (mine SHARED  src/mime.c src/mime.h src/compat.c src/compat.h)
target_link_libraries(mine lua${LUA_VERSION} ws2_32)

SET_TARGET_PROPERTIES(mine PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/mine)
SET_TARGET_PROPERTIES(mine PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/mine)
SET_TARGET_PROPERTIES(mine PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/mine)
SET_TARGET_PROPERTIES(mine PROPERTIES OUTPUT_NAME core)


set(lua_files 
	src/ftp.lua
	src/headers.lua
	src/http.lua
	src/ltn12.lua
	src/mbox.lua
	src/mime.lua
	src/smtp.lua
	src/tp.lua
	src/url.lua
)
install(TARGETS luasoket RUNTIME DESTINATION ${LUA_ROOT}/clibs/socket)
install(TARGETS mine RUNTIME DESTINATION ${LUA_ROOT}/clibs/mine)
install(FILES ${lua_files} DESTINATION ${LUA_ROOT}/lua/socket)
install(FILES src/socket.lua DESTINATION ${LUA_ROOT}/lua)