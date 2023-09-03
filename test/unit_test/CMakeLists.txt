
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        unit-test
        VERSION 0.0.1
)

add_executable(unit_test
        example.cpp
)

target_link_libraries(unit_test PRIVATE
        gtest_main
)

gtest_discover_tests(unit_test)
