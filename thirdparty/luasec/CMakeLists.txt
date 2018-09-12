cmake_minimum_required (VERSION 2.6)

project (ssl)

if(MSVC)
	set(LUA_ROOT ${LUA_ROOT} CACHE PATH "set LUA_ROOT")
	if(NOT LUA_ROOT)
		message(FATAL_ERROR "Please set LUA_ROOT.")
	endif()
	set(LUA_VERSION ${LUA_VERSION} CACHE STRING "set LUA_VERSION")

	if(NOT LUA_VERSION)
		message(FATAL_ERROR "Please set LUA_VERSION.")
	endif()

	set(OPENSSL_ROOT ${OPENSSL_ROOT} CACHE PATH "set OPENSSL_ROOT")
	if(NOT OPENSSL_ROOT)
		message(FATAL_ERROR "Please set OPENSSL_ROOT.")
	endif()

else(MSVC)
	if(NOT LUA_VERSION)
		set(LUA_VERSION 5.1)
	endif()
endif(MSVC)


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

if(OPENSSL_ROOT)
	include_directories(${OPENSSL_ROOT}/include)
	link_directories(${OPENSSL_ROOT}/lib)
endif(OPENSSL_ROOT)



add_library (luasocket STATIC ${srcs})







set(srcs
	src/compat.h
	src/config.c
	src/context.c
	src/context.h
	src/ec.c
	src/ec.h
	src/options.h
	src/ssl.c
	src/ssl.h
	src/x509.c
	src/x509.h
)



#if(MSVC)
#	ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
#endif(MSVC)


include_directories(${CMAKE_SOURCE_DIR}/src)

set(SSL_LIBRARIES libssl libcrypto)


add_library (ssl SHARED ${srcs})

if(MSVC)
	target_link_libraries(ssl lua${LUA_VERSION} ws2_32 luasocket ${SSL_LIBRARIES})
else(MSVC)
	target_link_libraries(ssl lua${LUA_VERSION} luasocket ${SSL_LIBRARIES})
	set_target_properties (ssl
                       PROPERTIES PREFIX
                       "")
endif(MSVC)




install(TARGETS ssl RUNTIME DESTINATION ${LUA_ROOT}/clibs)
install(FILES src/https.lua src/ssl.lua DESTINATION ${LUA_ROOT}/lua)