cmake_minimum_required (VERSION 2.6)

project (lcovtools)

set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")

if(NOT LUA_ROOT)
	message(FATAL_ERROR "Please set LUA_ROOT.")
endif()

set(LUA_VERSION ${LUA_VERSION} CACHE PATH "set LUA_VERSION")

if(NOT LUA_VERSION)
	message(FATAL_ERROR "Please set LUA_VERSION.")
endif()

set(srcs
	luacov.cpp
)

if(MSVC)
	ADD_DEFINITIONS("-DLUACOVTOOLS_API=__declspec(dllexport)")
endif(MSVC)

include_directories(${LUA_ROOT}/include)
link_directories(${LUA_ROOT}/lib)
add_library (lcovtools SHARED  ${srcs})
target_link_libraries(lcovtools lua${LUA_VERSION} ws2_32)



install(TARGETS lcovtools RUNTIME DESTINATION ${LUA_ROOT}/clibs)
