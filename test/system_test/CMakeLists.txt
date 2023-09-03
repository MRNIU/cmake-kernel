
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        system-test
        VERSION 0.0.1
)

if (${TARGET_ARCH} STREQUAL "x86_64" OR ${TARGET_ARCH} STREQUAL "aarch64")
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/gnu_efi_test)
elseif (${TARGET_ARCH} STREQUAL "riscv64")
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/opensbi_test)
endif ()
