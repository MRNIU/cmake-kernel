
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# compile_config.cmake for MRNIU/cmake-kernel.
# 配置信息

# 通用编译选项
list(APPEND COMMON_COMPILE_OPTIONS
    # 如果 CMAKE_BUILD_TYPE 为 Release 则使用 -O3 -Werror，否则使用 -O0 -g -ggdb
    $<$<CONFIG:Release>:-O3;-Werror>
    $<$<CONFIG:Debug>:-O0;-g;-ggdb>
    # 打开全部警告
    -Wall
    # 打开额外警告
    -Wextra
    # 启用异常处理机制
    -fexceptions

    # 目标平台编译选项
    # @todo clang 交叉编译参数
    $<$<STREQUAL:${TARGET_ARCH},x86_64>:
    # 禁用 red-zone
    -mno-red-zone
    >

    $<$<STREQUAL:${TARGET_ARCH},riscv64>:
    >

    $<$<STREQUAL:${TARGET_ARCH},aarch64>:
    # 生成 armv8-a 代码
    -march=armv8-a
    # 针对 cortex-a72 优化代码
    -mtune=cortex-a72
    >

    # gcc 特定选项
    $<$<CXX_COMPILER_ID:GNU>:
    >

    # clang 特定选项
    $<$<CXX_COMPILER_ID:Clang>:
    >

    # 平台相关
    $<$<PLATFORM_ID:Darwin>:
    >
)

list(APPEND DEFAULT_BOOT_COMPILE_OPTIONS
    ${COMMON_COMPILE_OPTIONS}
    # 使用 2 字节 wchar_t
    -fshort-wchar
    # 允许 wchar_t
    -fpermissive
    # 生成位置无关代码
    -fPIC

    # 目标平台编译选项
    $<$<STREQUAL:${TARGET_ARCH},x86_64>:
    # 使 gnu-efi
    -DGNU_EFI_USE_MS_ABI
    >

    $<$<STREQUAL:${TARGET_ARCH},aarch64>:
    # 使 gnu-efi
    -DGNU_EFI_USE_MS_ABI
    >
)

list(APPEND DEFAULT_KERNEL_COMPILE_OPTIONS
    ${COMMON_COMPILE_OPTIONS}
)

# 通用链接选项
list(APPEND COMMON_LINK_OPTIONS
    # 不链接 ctr0 等启动代码
    -nostartfiles

    # 目标平台编译选项
    # @todo clang 交叉编译参数
    $<$<STREQUAL:${TARGET_ARCH},x86_64>:
    # 设置最大页大小为 0x1000(4096) 字节
    -z max-page-size=0x1000
    >

    $<$<STREQUAL:${TARGET_ARCH},riscv64>:
    # 链接脚本
    -T ${CMAKE_SOURCE_DIR}/src/kernel/arch/${TARGET_ARCH}/link.ld
    # 不生成位置无关可执行代码
    -no-pie
    >

    $<$<STREQUAL:${TARGET_ARCH},aarch64>:
    >
)

list(APPEND DEFAULT_BOOT_LINK_OPTIONS
    ${COMMON_LINK_OPTIONS}

    # 目标平台编译选项
    $<$<STREQUAL:${TARGET_ARCH},x86_64>:
    # 编译为共享库
    -shared
    # 符号级别绑定
    -Wl,-Bsymbolic
    >
)

list(APPEND DEFAULT_KERNEL_LINK_OPTIONS
    ${COMMON_LINK_OPTIONS}

    $<$<STREQUAL:${TARGET_ARCH},riscv64>:
    # 链接脚本
    -T ${CMAKE_SOURCE_DIR}/src/kernel/arch/${TARGET_ARCH}/link.ld
    # 不生成位置无关可执行代码
    -no-pie
    >
)

# 通用库选项
list(APPEND COMMON_LINK_LIB
    ${libcxxrt_BINARY_DIR}/lib/libcxxrt.a
    # 目标平台编译选项
    $<$<STREQUAL:${TARGET_ARCH},x86_64>:
    >

    $<$<STREQUAL:${TARGET_ARCH},riscv64>:
    >

    $<$<STREQUAL:${TARGET_ARCH},aarch64>:
    >
)

list(APPEND DEFAULT_BOOT_LINK_LIB
    ${COMMON_LINK_LIB}
    # 目标平台编译选项
    $<$<STREQUAL:${TARGET_ARCH},x86_64>:
    # 链接 gnu-efi
    # ${gnu-efi_BINARY_DIR}/gnuefi/reloc_${TARGET_ARCH}.o
    ${gnu-efi_BINARY_DIR}/gnuefi/crt0-efi-${TARGET_ARCH}.o
    ${gnu-efi_BINARY_DIR}/gnuefi/libgnuefi.a
    ${gnu-efi_BINARY_DIR}/lib/libefi.a
    >

    $<$<STREQUAL:${TARGET_ARCH},aarch64>:
    # 链接 gnu-efi
    # ${gnu-efi_BINARY_DIR}/gnuefi/reloc_${TARGET_ARCH}.o
    ${gnu-efi_BINARY_DIR}/gnuefi/crt0-efi-${TARGET_ARCH}.o
    ${gnu-efi_BINARY_DIR}/gnuefi/libgnuefi.a
    ${gnu-efi_BINARY_DIR}/lib/libefi.a
    >
)

list(APPEND DEFAULT_KERNEL_LINK_LIB
    ${COMMON_LINK_LIB}
)

# 编译依赖
if (${TARGET_ARCH} STREQUAL "x86_64")
    list(APPEND COMPILE_DEPENDS
        gnu-efi
        cxxrt-static
    )
elseif (${TARGET_ARCH} STREQUAL "riscv64")
    list(APPEND COMPILE_DEPENDS
        opensbi
        cxxrt-static
    )
elseif (${TARGET_ARCH} STREQUAL "aarch64")
    list(APPEND COMPILE_DEPENDS
        gnu-efi
    )
endif ()
