cmake_minimum_required (VERSION 2.8.13)

project (bit)

find_package(Lua REQUIRED)

if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		if(EXISTS $ENV{LUA_DIR})
			set(CMAKE_INSTALL_PREFIX "$ENV{LUA_DIR}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
		endif()
	endif()
endif()



set(srcs
	src/oilbit.c
	src/oilbit.h
)

if(MSVC)
	ADD_DEFINITIONS("-DOIL_API=__declspec(dllexport)")
endif(MSVC)

include_directories(${LUA_INCLUDE_DIR})


add_library (bit SHARED ${srcs})

if(MSVC)
	target_link_libraries(bit ${LUA_LIBRARIES} ws2_32)
else(MSVC)
	target_link_libraries(bit ${LUA_LIBRARIES})
	set_target_properties (bit
                       PROPERTIES PREFIX
                       "")
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





add_library (core SHARED ${srcs})

if(MSVC)
	target_link_libraries(core ${LUA_LIBRARIES} ws2_32)
else(MSVC)
	target_link_libraries(core ${LUA_LIBRARIES})
	set_target_properties (core
                       PROPERTIES PREFIX
                       "")
endif(MSVC)



install(DIRECTORY ${CMAKE_SOURCE_DIR}/lua/loop DESTINATION lua)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/lua/luaidl DESTINATION lua)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/lua/oil DESTINATION lua)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/lua/socket DESTINATION lua)


set(lua_files
	${CMAKE_SOURCE_DIR}/lua/idl2lua.lua
	${CMAKE_SOURCE_DIR}/lua/luaidl.lua
	${CMAKE_SOURCE_DIR}/lua/oil.lua
	${CMAKE_SOURCE_DIR}/lua/precompiler.lua
	${CMAKE_SOURCE_DIR}/lua/preloader.lua
	${CMAKE_SOURCE_DIR}/lua/socket.lua
)

install(FILES ${lua_files} DESTINATION lua)

if(MSVC)
	install(TARGETS bit RUNTIME DESTINATION clibs/oil)
	install(TARGETS core RUNTIME DESTINATION clibs/socket)
else(MSVC)
	install(TARGETS bit LIBRARY DESTINATION clibs/oil)
	install(TARGETS core LIBRARY DESTINATION clibs/socket)
endif(MSVC)
