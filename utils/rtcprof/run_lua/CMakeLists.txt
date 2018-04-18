cmake_minimum_required (VERSION 2.6)

project (run_lua)

add_executable (rtcd_lua rtcd_lua.cpp run_lua.h)


add_executable (rtcprof_lua rtcprof_lua.cpp run_lua.h)