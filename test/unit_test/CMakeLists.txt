
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

target_compile_options(unit_test PRIVATE
        --coverage
)

target_link_options(unit_test PRIVATE
        -fsanitize=leak
        -fsanitize=address
        -fno-omit-frame-pointer
)

target_link_libraries(unit_test PRIVATE
        arch
        driver
        libc
        libcxx
        gtest_main
)

gtest_discover_tests(unit_test)
