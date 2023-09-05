
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
        --coverage
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

add_custom_command(TARGET unit_test
        COMMENT "Gen convage unit_test report ..."
        POST_BUILD
        DEPENDS unit_test
        WORKING_DIRECTORY ${unit_test_BINARY_DIR}
        COMMAND
        ${LCOV_EXE} --rc lcov_branch_coverage=1 -c -d ./CMakeFiles/unit_test.dir -o ut-coverage.info
        COMMAND
        ${LCOV_EXE} --rc lcov_branch_coverage=1 -e ut-coverage.info "*src*" -o ut-coverage.info
        COMMAND
        ${GENHTML_EXE} ut-coverage.info
)

gtest_discover_tests(unit_test)
