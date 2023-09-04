
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        kernel
        VERSION 0.0.1
)

enable_language(CXX)

add_subdirectory(${PROJECT_SOURCE_DIR}/libc)
add_subdirectory(${PROJECT_SOURCE_DIR}/libcxx)
add_subdirectory(${PROJECT_SOURCE_DIR}/arch)
add_subdirectory(${PROJECT_SOURCE_DIR}/driver)

add_executable(${KERNEL_ELF_OUTPUT_NAME} main.cpp)

# 添加头文件
add_header_libc(${KERNEL_ELF_OUTPUT_NAME})
add_header_libcxx(${KERNEL_ELF_OUTPUT_NAME})
add_header_arch(${KERNEL_ELF_OUTPUT_NAME})
add_header_kernel(${KERNEL_ELF_OUTPUT_NAME})
add_header_driver(${KERNEL_ELF_OUTPUT_NAME})
add_header_3rd(${KERNEL_ELF_OUTPUT_NAME})

# 添加依赖
add_dependencies(${KERNEL_ELF_OUTPUT_NAME}
        ${COMPILE_DEPENDS}
        )

# 添加编译参数
target_compile_options(${KERNEL_ELF_OUTPUT_NAME} PRIVATE
        ${DEFAULT_KERNEL_COMPILE_OPTIONS}
        )

# 添加链接参数
target_link_options(${KERNEL_ELF_OUTPUT_NAME} PRIVATE
        ${DEFAULT_KERNEL_LINK_OPTIONS}
        )

# 添加要链接的库
target_link_libraries(${KERNEL_ELF_OUTPUT_NAME} PRIVATE
        ${DEFAULT_KERNEL_LINK_LIB}
        libc
        libcxx
        arch
        driver
        )
