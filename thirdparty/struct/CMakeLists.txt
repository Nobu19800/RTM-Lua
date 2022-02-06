cmake_minimum_required (VERSION 2.8.13)

project (struct)


find_package(Lua REQUIRED)


if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		if(EXISTS $ENV{LUA_DIR})
			set(CMAKE_INSTALL_PREFIX "$ENV{LUA_DIR}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
		endif()
	endif()
endif()

set(srcs
	struct.c
)

if(MSVC)
	ADD_DEFINITIONS("-DLUA_BUILD_AS_DLL")
	ADD_DEFINITIONS("-DLUA_LIB")
endif(MSVC)

include_directories(${LUA_INCLUDE_DIR})

add_library (struct SHARED ${srcs})

target_link_libraries(struct ${LUA_LIBRARIES})
if(MSVC)
else(MSVC)
	set_target_properties (struct
                       PROPERTIES PREFIX
                       "")
endif(MSVC)



if(MSVC)
	install(TARGETS struct RUNTIME DESTINATION clibs)
else(MSVC)
	install(TARGETS struct LIBRARY DESTINATION clibs)
endif(MSVC)