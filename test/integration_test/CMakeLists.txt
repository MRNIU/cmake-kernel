
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        integration-test
        VERSION 0.0.1
)

add_executable(integration_test
        example.cpp
)

target_compile_options(integration_test PRIVATE
        --coverage
)

target_link_options(integration_test PRIVATE
        --coverage
        -fsanitize=leak 
        -fsanitize=address 
        -fno-omit-frame-pointer
)

target_link_libraries(integration_test PRIVATE
        arch
        driver
        libc
        libcxx
        gtest_main
)

gtest_discover_tests(integration_test)
