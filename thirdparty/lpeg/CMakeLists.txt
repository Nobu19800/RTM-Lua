cmake_minimum_required (VERSION 2.6)

project (lpeg)

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
	lpcap.c
	lpcode.c
	lpprint.c
	lptree.c
	lpvm.c
	lpcap.h
	lpcode.h
	lpprint.h
	lptree.h
	lptypes.h
	lpvm.h
)

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

add_library (lpeg SHARED ${srcs})

if(MSVC)
	target_link_libraries(lpeg lua${LUA_VERSION} ws2_32)
else(MSVC)
	target_link_libraries(lpeg lua${LUA_VERSION})
	set_target_properties (lpeg
                       PROPERTIES PREFIX
                       "")
endif(MSVC)


if(MSVC)
	install(TARGETS lpeg RUNTIME DESTINATION ${LUA_ROOT}/clibs)
else(MSVC)
	install(TARGETS lpeg LIBRARY DESTINATION ${LUA_ROOT}/clibs)
endif(MSVC)

install(FILES re.lua DESTINATION ${LUA_ROOT}/lua)