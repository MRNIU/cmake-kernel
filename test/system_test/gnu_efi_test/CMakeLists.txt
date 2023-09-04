
# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# CMakeLists.txt for MRNIU/cmake-kernel.

# 设置项目名与版本
project(
        gnu-efi-test
        VERSION 0.0.1
)

enable_language(CXX)

add_executable(${PROJECT_NAME}_boot.elf
        boot.cpp
        ${CMAKE_SOURCE_DIR}/src/boot/load_elf.cpp
        ${CMAKE_SOURCE_DIR}/src/boot/ostream.cpp
        ${CMAKE_SOURCE_DIR}/src/boot/graphics.cpp
        ${CMAKE_SOURCE_DIR}/src/boot/memory.cpp
)

add_header_boot(${PROJECT_NAME}_boot.elf)
add_header_3rd(${PROJECT_NAME}_boot.elf)

target_compile_options(${PROJECT_NAME}_boot.elf PRIVATE
        ${DEFAULT_BOOT_COMPILE_OPTIONS}
)

target_link_options(${PROJECT_NAME}_boot.elf PRIVATE
        ${DEFAULT_BOOT_LINK_OPTIONS}
)

target_link_libraries(${PROJECT_NAME}_boot.elf PRIVATE
        ${DEFAULT_BOOT_LINK_LIB}
)

add_dependencies(${PROJECT_NAME}_boot.elf
        ${COMPILE_DEPENDS}
)

add_custom_target(${PROJECT_NAME}_boot.efi DEPENDS ${PROJECT_NAME}_boot.elf)
add_custom_command(TARGET ${PROJECT_NAME}_boot.efi
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMAND ${CMAKE_OBJCOPY} ${PROJECT_NAME}_boot.elf ${PROJECT_NAME}_boot.efi
        -S
        -R .comment
        -R .note.gnu.build-id
        -R .gnu.hash
        -R .dynsym
        --target=efi-app-${TARGET_ARCH} --subsystem=10
        COMMENT "Build ${PROJECT_NAME}_boot.efi done."
)

add_executable(${PROJECT_NAME}_kernel.elf
        main.cpp
)

add_header_kernel(${PROJECT_NAME}_kernel.elf)

target_compile_options(${PROJECT_NAME}_kernel.elf PRIVATE
        ${DEFAULT_KERNEL_COMPILE_OPTIONS}
)

target_link_options(${PROJECT_NAME}_kernel.elf PRIVATE
        ${DEFAULT_KERNEL_LINK_OPTIONS}
)

add_custom_command(TARGET ${PROJECT_NAME}_kernel.elf POST_BUILD
        COMMENT "Move kernel to 0xC0000000"
        COMMAND ${CMAKE_OBJCOPY} --adjust-vma 0xC0000000 ${PROJECT_NAME}_kernel.elf
)

add_custom_target(${PROJECT_NAME}_run DEPENDS ${PROJECT_NAME}_boot.efi ${PROJECT_NAME}_kernel.elf ovmf)
add_custom_command(TARGET ${PROJECT_NAME}_run
        COMMENT "Run ${PROJECT_NAME} in qemu."
        COMMAND mkdir -p ./image
        COMMAND cp ./${PROJECT_NAME}_boot.efi ./image/
        COMMAND cp ./${PROJECT_NAME}_kernel.elf ./image/
        COMMAND qemu-system-x86_64
        -m 4096M
        -serial stdio -monitor telnet::2333,server,nowait -net none
        -bios ${ovmf_BINARY_DIR}/OVMF_${TARGET_ARCH}.fd
        -hda fat:rw:./image/
)

# 在 qemu 中调试
add_custom_target(${PROJECT_NAME}_debug DEPENDS ${PROJECT_NAME}_boot.efi ${PROJECT_NAME}_kernel.elf ovmf
        COMMENT "Debug Kernel in qemu ..."
        COMMAND ${CMAKE_COMMAND} -E echo ${QEMU_FLAGS}
        COMMAND qemu-system-${TARGET_ARCH}
        -m 128M
        -serial stdio -monitor telnet::2333,server,nowait -net none
        -bios ${ovmf_BINARY_DIR}/OVMF_${TARGET_ARCH}.fd
        -hda fat:rw:./image/
        -S
        -gdb ${QEMU_GDB_PORT}
)
