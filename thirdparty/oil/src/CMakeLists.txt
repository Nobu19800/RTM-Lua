cmake_minimum_required (VERSION 2.6)

project (bit)

set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")

if(NOT LUA_ROOT)
	message(FATAL_ERROR "Please set LUA_ROOT.")
endif()

set(LUA_VERSION ${LUA_VERSION} CACHE PATH "set LUA_VERSION")

if(NOT LUA_VERSION)
	message(FATAL_ERROR "Please set LUA_VERSION.")
endif()

set(srcs
	oilbit.c
	oilbit.h
)

if(MSVC)
	ADD_DEFINITIONS("-DOIL_API=__declspec(dllexport)")
endif(MSVC)

include_directories(${LUA_ROOT}/include)
link_directories(${LUA_ROOT}/lib)
add_library (bit SHARED  ${srcs})
target_link_libraries(bit lua${LUA_VERSION} ws2_32)



set(srcs
	auxiliar.c
	buffer.c
	except.c
	inet.c
	io.c
	luasocket.c
	options.c
	select.c
	tcp.c
	timeout.c
	udp.c
	wsocket.c
	auxiliar.h
	buffer.h
	except.h
	inet.h
	io.h
	luasocket.h
	options.h
	select.h
	socket.h
	tcp.h
	timeout.h
	udp.h
	wsocket.h
)

if(MSVC)
	ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
endif(MSVC)

include_directories(${LUA_ROOT}/include)
link_directories(${LUA_ROOT}/lib)
add_library (core SHARED  ${srcs})
target_link_libraries(core lua${LUA_VERSION} ws2_32)

install(DIRECTORY ${CMAKE_SOURCE_DIR}/../lua/loop DESTINATION ${LUA_ROOT}/lua)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/../lua/luaidl DESTINATION ${LUA_ROOT}/lua)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/../lua/oil DESTINATION ${LUA_ROOT}/lua)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/../lua/socket DESTINATION ${LUA_ROOT}/lua)

set(lua_files
	${CMAKE_SOURCE_DIR}/../lua/idl2lua.lua
	${CMAKE_SOURCE_DIR}/../lua/luaidl.lua
	${CMAKE_SOURCE_DIR}/../lua/oil.lua
	${CMAKE_SOURCE_DIR}/../lua/precompiler.lua
	${CMAKE_SOURCE_DIR}/../lua/preloader.lua
	${CMAKE_SOURCE_DIR}/../lua/socket.lua
)

install(FILES ${lua_files} DESTINATION ${LUA_ROOT}/lua)

install(TARGETS bit RUNTIME DESTINATION ${LUA_ROOT}/clibs/oil)
install(TARGETS core RUNTIME DESTINATION ${LUA_ROOT}/clibs/socket)
