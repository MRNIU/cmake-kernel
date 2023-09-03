
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        test
        VERSION 0.0.1
)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/system_test)

# 仅在 host 环境下进行 ut 和 it
if (TARGET_ARCH STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
    enable_testing()
    include(GoogleTest)

    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/unit_test)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/integration_test)
endif ()
