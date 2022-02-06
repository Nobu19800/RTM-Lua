cmake_minimum_required (VERSION 2.8.13)

project (lpeg)

find_package(Lua REQUIRED)

if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		if(EXISTS $ENV{LUA_DIR})
			set(CMAKE_INSTALL_PREFIX "$ENV{LUA_DIR}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
		endif()
	endif()
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

if(MSVC)
	ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
endif(MSVC)

include_directories(${LUA_INCLUDE_DIR})

add_library (lpeg SHARED ${srcs})


target_link_libraries(lpeg ${LUA_LIBRARIES})
if(MSVC)
else(MSVC)
	set_target_properties (lpeg
                       PROPERTIES PREFIX
                       "")
endif(MSVC)


install(TARGETS lpeg RUNTIME DESTINATION clibs)

install(FILES re.lua DESTINATION lua)