cmake_minimum_required(VERSION 3.16)

project(uart-reg)

set(CMAKE_EXPORT_COMPILE_COMMANDS true)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(main "src/main.cpp")
