# This code sets the minimum required version of CMake to 3.26 and creates a new
# project named node-shim. It then creates a vendor directory and downloads the
# latest version of QuickJS++ into it. The vendor directory is then included and
# the conan build info is included. Finally, an executable is created and linked
# with the conan libraries.

# Latest CMake version as of 2023/03/23
cmake_minimum_required(VERSION 3.26)

project(node-shim)

execute_process(COMMAND mkdir -p ${CMAKE_SOURCE_DIR}/vendor)
# Latest QuickJS++ version as of 2023/03/23
execute_process(
  COMMAND
    curl -fsSLo ${CMAKE_SOURCE_DIR}/vendor/quickjspp.hpp
    https://github.com/ftk/quickjspp/raw/9cee4b4d27271d54b95f6f42bfdc534ebeaaeb72/quickjspp.hpp
    )
include_directories(${CMAKE_SOURCE_DIR}/vendor)

find_package(QUICKJS REQUIRED)

add_executable(node-shim src/index.cpp)
target_link_libraries(node-shim QUICKJS::QUICKJS)
