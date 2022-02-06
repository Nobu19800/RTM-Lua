cmake_minimum_required (VERSION 2.8.13)

project (socket)

find_package(Lua REQUIRED)

if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		if(EXISTS $ENV{LUA_DIR})
			set(CMAKE_INSTALL_PREFIX "$ENV{LUA_DIR}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
		endif()
	endif()
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
)

if(MSVC)
	set(srcs ${srcs} wsocket.h wsocket.c)
else(MSVC)
	set(srcs ${srcs} usocket.h usocket.c unix.h)
endif(MSVC)


if(MSVC)
	ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
endif(MSVC)


include_directories(${LUA_INCLUDE_DIR})


if(MSVC)
	target_link_libraries(luasoket ${LUA_LIBRARIES} ws2_32)
else(MSVC)
	target_link_libraries(luasoket ${LUA_LIBRARIES})
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


add_library (mine SHARED  src/mime.c src/mime.h src/compat.c src/compat.h)



if(MSVC)
	target_link_libraries(mine ${LUA_LIBRARIES} ws2_32)
else(MSVC)
	target_link_libraries(mine ${LUA_LIBRARIES})
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
	src/headers.lua
	src/http.lua
	src/ltn12.lua
	src/mbox.lua
	src/mime.lua
	src/smtp.lua
	src/tp.lua
	src/url.lua
)
if(MSVC)
	install(TARGETS luasoket RUNTIME DESTINATION clibs/socket)
	install(TARGETS mine RUNTIME DESTINATION clibs/mine)
else(MSVC)
	install(TARGETS luasoket LIBRARY DESTINATION clibs/socket)
	install(TARGETS mine LIBRARY DESTINATION clibs/mine)
endif(MSVC)
install(FILES ${lua_files} DESTINATION lua/socket)
install(FILES src/socket.lua DESTINATION lua)