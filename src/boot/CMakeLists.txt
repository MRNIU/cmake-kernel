
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        boot
        VERSION 0.0.1
)

enable_language(CXX)

add_executable(${BOOT_ELF_OUTPUT_NAME}
        boot.cpp
        )

# 添加头文件
add_header_boot(${BOOT_ELF_OUTPUT_NAME})
add_header_3rd(${BOOT_ELF_OUTPUT_NAME})

# 添加依赖
add_dependencies(${BOOT_ELF_OUTPUT_NAME}
        ${COMPILE_DEPENDS}
        )

# 添加编译参数
target_compile_options(${BOOT_ELF_OUTPUT_NAME} PRIVATE
        ${DEFAULT_COMPILE_OPTIONS}
        )

# 添加链接参数
target_link_options(${BOOT_ELF_OUTPUT_NAME} PRIVATE
        ${DEFAULT_LINK_OPTIONS}
        )

# 添加要链接的库
target_link_libraries(${BOOT_ELF_OUTPUT_NAME} PRIVATE
        ${DEFAULT_LINK_LIB}
        )

# readelf -a
readelf_a(${BOOT_ELF_OUTPUT_NAME})

# objdump -D
objdump_D(${BOOT_ELF_OUTPUT_NAME})

# 制作 boot.efi
# 将引导调整为 efi
elf2efi(${BOOT_ELF_OUTPUT_NAME} ${BOOT_EFI_OUTPUT_NAME})
