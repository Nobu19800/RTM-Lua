cmake_minimum_required (VERSION 2.8.13)

project (ssl)

find_package(Lua REQUIRED)
find_package(OpenSSL REQUIRED)

if(NOT CMAKE_VERSION VERSION_LESS 3.7.0)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
		if(EXISTS $ENV{LUA_DIR})
			set(CMAKE_INSTALL_PREFIX "$ENV{LUA_DIR}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
		endif()
	endif()
endif()



set(srcs
	src/luasocket/buffer.c
	src/luasocket/buffer.h
	src/luasocket/io.c
	src/luasocket/io.h
	src/luasocket/socket.h
	src/luasocket/timeout.c
	src/luasocket/timeout.h
)

if(MSVC)
	set(srcs ${srcs}
		src/luasocket/wsocket.c
		src/luasocket/wsocket.h
	)
else(MSVC)
	set(srcs ${srcs}
		src/luasocket/usocket.c
		src/luasocket/usocket.h
	)
endif(MSVC)

include_directories(${LUA_INCLUDE_DIR} ${OPENSSL_INCLUDE_DIR})

if(${LUA_VERSION_MINOR} GREATER 2)
	ADD_DEFINITIONS(-DLUA_COMPAT_APIINTCASTS)
endif()



add_library (luasocket STATIC ${srcs})



set(srcs
	src/compat.h
	src/config.c
	src/context.c
	src/context.h
	src/ec.c
	src/ec.h
	src/options.h
	src/options.c
	src/ssl.c
	src/ssl.h
	src/x509.c
	src/x509.h
)



#if(MSVC)
#	ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
#endif(MSVC)


include_directories(${CMAKE_SOURCE_DIR}/src)


add_library (ssl SHARED ${srcs})


if(MSVC)
	target_link_libraries(ssl ${LUA_LIBRARIES} ws2_32 luasocket ${OPENSSL_LIBRARIES})
else(MSVC)
	target_link_libraries(ssl ${LUA_LIBRARIES} luasocket ${OPENSSL_LIBRARIES})
	set_target_properties (ssl
                       PROPERTIES PREFIX
                       "")
endif(MSVC)


if(MSVC)
	install(TARGETS ssl RUNTIME DESTINATION clibs)
else(MSVC)
	install(TARGETS ssl LIBRARY DESTINATION clibs)
endif(MSVC)

install(FILES src/https.lua src/ssl.lua src/options.lua DESTINATION lua)

if(WIN32)
	if(OPENSSL_ROOT_DIR)
		file(GLOB OPENSSL_DLLS1 "${OPENSSL_ROOT_DIR}/bin/libcrypto*.dll")
		file(GLOB OPENSSL_DLLS2 "${OPENSSL_ROOT_DIR}/bin/libssl*.dll")
	endif(OPENSSL_ROOT_DIR)
	foreach(library ${OPENSSL_DLLS1};${OPENSSL_DLLS2})
		install(PROGRAMS ${library} DESTINATION bin)
	endforeach()
endif(WIN32)