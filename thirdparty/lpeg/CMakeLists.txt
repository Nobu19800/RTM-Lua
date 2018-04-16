cmake_minimum_required (VERSION 2.6)

project (lpeg)

set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")

if(NOT LUA_ROOT)
	message(FATAL_ERROR "Please set LUA_ROOT.")
endif()

set(LUA_VERSION ${LUA_VERSION} CACHE PATH "set LUA_VERSION")

if(NOT LUA_VERSION)
	message(FATAL_ERROR "Please set LUA_VERSION.")
endif()

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

ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")


include_directories(${LUA_ROOT}/include)
link_directories(${LUA_ROOT}/lib)
add_library (lpeg SHARED ${srcs})
target_link_libraries(lpeg lua${LUA_VERSION})




install(TARGETS lpeg RUNTIME DESTINATION ${LUA_ROOT}/clibs)
install(FILES re.lua DESTINATION ${LUA_ROOT}/lua)