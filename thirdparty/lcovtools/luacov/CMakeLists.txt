cmake_minimum_required (VERSION 2.8.13)

project (lcovtools)

find_package(Lua REQUIRED)


if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		if(EXISTS $ENV{LUA_DIR})
			set(CMAKE_INSTALL_PREFIX "$ENV{LUA_DIR}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
		endif()
	endif()
endif()

set(srcs
	luacov.cpp
)

if(MSVC)
	ADD_DEFINITIONS("-DLUACOVTOOLS_API=__declspec(dllexport)")
endif(MSVC)

include_directories(${LUA_INCLUDE_DIR})


add_library (lcovtools SHARED  ${srcs})

target_link_libraries(lcovtools ${LUA_LIBRARIES})
if(MSVC)
else(MSVC)
	set_target_properties (lcovtools
                       PROPERTIES PREFIX
                       "")
endif(MSVC)


install(TARGETS lcovtools RUNTIME DESTINATION clibs)
