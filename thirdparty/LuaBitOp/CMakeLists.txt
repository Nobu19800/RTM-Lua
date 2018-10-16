cmake_minimum_required (VERSION 2.6)

project (bit)

if(MSVC)
	set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")
	if(NOT LUA_ROOT)
		message(FATAL_ERROR "Please set LUA_ROOT.")
	endif()
	set(LUA_VERSION ${LUA_VERSION} CACHE STRING "set LUA_VERSION")

	if(NOT LUA_VERSION)
		message(FATAL_ERROR "Please set LUA_VERSION.")
	endif()
else(MSVC)
	if(NOT LUA_VERSION)
		set(LUA_VERSION 5.1)
	endif()
endif(MSVC)


set(srcs
	bit.c
)

if(MSVC)
	ADD_DEFINITIONS("-DLUA_BUILD_AS_DLL")
	ADD_DEFINITIONS("-DLUA_LIB")
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

add_library (bit SHARED ${srcs})

if(MSVC)
	target_link_libraries(bit lua${LUA_VERSION} ws2_32)
else(MSVC)
	target_link_libraries(bit lua${LUA_VERSION})
	set_target_properties (bit
                       PROPERTIES PREFIX
                       "")
endif(MSVC)



if(MSVC)
	install(TARGETS bit RUNTIME DESTINATION ${LUA_ROOT}/clibs)
else(MSVC)
	install(TARGETS bit LIBRARY DESTINATION ${LUA_ROOT}/clibs)
endif(MSVC)

