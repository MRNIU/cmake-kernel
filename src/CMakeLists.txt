
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# riscv64 不支持 uefi
if (${TARGET_ARCH} STREQUAL "x86_64" OR ${TARGET_ARCH} STREQUAL "aarch64")
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/boot)
endif ()
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/kernel)
