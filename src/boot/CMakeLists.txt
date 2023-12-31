
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

add_executable(boot
    boot.cpp
    load_elf.cpp
    ostream.cpp
    graphics.cpp
    memory.cpp
)

# 添加头文件
add_header_project(boot)
add_header_boot(boot)
add_header_3rd(boot)

# 添加编译参数
target_compile_options(boot PRIVATE
    ${DEFAULT_BOOT_COMPILE_OPTIONS}
)

# 添加链接参数
target_link_options(boot PRIVATE
    ${DEFAULT_BOOT_LINK_OPTIONS}
)

# 添加要链接的库
target_link_libraries(boot PRIVATE
    ${DEFAULT_BOOT_LINK_LIB}
)

# 添加依赖
add_dependencies(boot
    ${COMPILE_DEPENDS}
)

set_target_properties(boot PROPERTIES PREFIX "")
set_target_properties(boot PROPERTIES OUTPUT_NAME ${BOOT_ELF_OUTPUT_NAME})

# readelf -a
readelf_a(boot)

# objdump -D
objdump_D(boot)

# 制作 boot.efi
# 将引导调整为 efi
elf2efi(boot ${BOOT_EFI_OUTPUT_NAME})
