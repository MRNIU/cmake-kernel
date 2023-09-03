# 构建系统

## 目录及文件介绍

```shell
.
├── 3rd								// 第三方源文件
├── CMakeLists.txt					// 根目录 cmake
├── LICENSE							// 本项目的许可证
├── README.md						// README
├── build_x86_64					// x86_64 架构的编译文件夹
│   ├── _deps						// 第三方源文件编译生成
│   ├── image						// 内核镜像
│   ├── src							// src 目录的编译结果
│   └── test						// test 目录的编译结果
├── cmake							// cmake 模块目录
│   ├── 3rd.cmake					// 管理第三方内容
│   ├── add_header.cmake			// 向 target 添加头文件目录
│   ├── config.cmake				// 项目配置
│   ├── functions.cmake				// cmake 辅助函数
│   └── x86_64-x86_64-gcc.cmake		// x86_64-x86_64-gcc 工具链
├── doc								// 项目文档
│   ├── Doxyfile					// doxygen 配置
│   └── build.md					// 本文件
├── run.sh							// 一键构建、运行脚本
├── src								// 源码目录
│   ├── CMakeLists.txt				// cmake 文件
│   ├── arch						// 架构相关代码
│   │   ├── CMakeLists.txt			// cmake 文件
│   │   ├── include					// 通用头文件目录
│   │   │   └── arch.h				// 通用头文件
│   │   └── x86_64					// x86_64 架构文件
│   │       └── link.ld				// 链接脚本
│   ├── boot						// bootloader 源码
│   │   ├── CMakeLists.txt			// cmake 文件
│   │   ├── boot.cpp				// uefi 引导代码
│   │   └── include					// 头文件目录
│   │       └── boot.h				// 头文件
│   ├── driver						// 驱动目录
│   │   ├── CMakeLists.txt			// cmake 文件
│   │   ├── driver.cpp				// cpp
│   │   └── include					// 头文件目录
│   │       └── driver.h			// 头文件
│   ├── kernel						// 内核目录
│   │   ├── CMakeLists.txt			// cmake 文件
│   │   ├── include					// 头文件目录
│   │   │   └── kernel.h			// 头文件
│   │   └── main.cpp				// 内核入口 cpp
│   ├── libc						// c 库目录
│   │   ├── CMakeLists.txt			// cmake 文件
│   │   ├── include					// 头文件目录
│   │   │   └── libc.h				// 头文件
│   │   └── libc.c					// cpp
│   └── libcxx						// c++ 库目录
│       ├── CMakeLists.txt			// cmake 文件
│       ├── include					// 头文件目录
│       │   └── libcxx.h			// 头文件
│       └── libcxx.cpp				// cpp
├── test							// 测试目录
│   ├── CMakeLists.txt				// cmake 文件
│   ├── integration_test			// 集成测试
│   ├── system_test					// 系统测试
│   │   ├── CMakeLists.txt			// cmake 文件
│   │   └── gnu_efi_test			// gnu-efi 启动测试
│   │       ├── CMakeLists.txt		// cmake 文件 
│   │       └── boot.cpp			// cpp
│   └── unit_test					// 单元测试
└── tools							// 工具目录
    ├── Dockerfile					// dockerfile
    ├── ovmf						// ovmf 文件
    └── startup.nsh					// uefi 初始化脚本
```

每个子模块都有自己的 cmake 文件，上级 cmake 通过 add_subdirectory 将其引入，同时传递由 config.cmake 设置的变量。

所有内核相关代码都在 src 目录下，其中 

1. boot 是引导程序，在生成时为一个独立的 elf 文件。
2. arch 目录下存放了体系结构相关的代码，在有涉及到体系结构内容时应当将实现放在这里，向外提供统接口。
3. driver 目录下是设备驱动。在内核开发初期，可以将驱动代码与内核一起编译，在后期应当提供独立文件。
4. kernel 目录是内核的核心逻辑，内存管理、任务管理等。
5. libc 与 libcxx 是 c/c++ 库的位置，提供内核可用的相关接口。

## 命名规范

- 系统测试

    以测试内容为名称的文件夹。

    cmake project 名为 xxx-test，如 gnu-efi-test。

## 使用

根目录 CMakeList.txt 可用参数如下

|           参数           |             合法值（默认值）             |  类型  |               说明                |
|:----------------------:|:--------------------------------:|:----:|:-------------------------------:|
|     ENABLE_GNU_EFI     |            ON/OFF(ON)            | BOOL | 是否使用 gnu-efi，OFF 则使用 posix-uefi |
|  ENABLE_TEST_COVERAGE  |            ON/OFF(ON)            | BOOL |            是否开启测试覆盖率            |
|        PLATFORM        |               qemu               | STR  |              运行的平台              |
|      TARGET_ARCH       | x86_64, riscv64, aarch64(x86_64) | STR  |              目标架构               |
|  BOOT_ELF_OUTPUT_NAME  |            (boot.elf)            | STR  |           引导 elf 文件名            |
|  BOOT_EFI_OUTPUT_NAME  |            (boot.efi)            | STR  |           引导 efi 文件名            |
| KERNEL_ELF_OUTPUT_NAME |           (kernel.elf)           | STR  |           内核 elf 文件名            |
| KERNEL_EFI_OUTPUT_NAME |           (kernel.efi)           | STR  |           内核 efi 文件名            |
|     QEMU_GDB_PORT      |           (tcp::1234)            | STR  |          qemu gdb 调试端口          |
|    QEMU_MONITOR_ARG    |   (telnet::2333,server,nowait)   | STR  |         qemu monitor 设置         |
|                        |                                  |      |                                 |

```shell
cmake \
  -DTARGET_ARCH=x86_64 \
  -DCMAKE_TOOLCHAIN_FILE=./cmake/x86_64-x86_64-elf.cmake
  -DBOOT_ELF_OUTPUT_NAME="myboot.elf" \
  -DKERNEL_ELF_OUTPUT_NAME="mykernel.elf" \
  ..
make run
```

构建系统会构建所有第三方依赖，boot，kernel，然后生成 image 文件夹，最后在 qemu 中启动。

### 交叉编译

1. 提供 gcc/clang 的支持。

2. 需要独立的  CMAKE_TOOLCHAIN_FILE 指定编译器。
3. gcc 工具链文件的命名规则：host-target-gcc.cmake(本机架构-目标架构-gcc.cmake)

支持的组合如下：

|      host      | target  |              gcc              |    clang    |   CMAKE_TOOLCHAIN_FILE   |
| :------------: | :-----: | :---------------------------: | :---------: | :----------------------: |
|   x86_64-osx   | x86_64  |        x86_64_elf-gcc         |    TEST     |                          |
|   x86_64-osx   | aarch64 | aarch64-unknown-linux-gnu-gcc |    TEST     |                          |
|   x86_64-osx   | riscv64 |    riscv64-unknown-elf-gcc    |    TEST     |                          |
|  aarch64-osx   | x86_64  |             TODO              |    TODO     |                          |
|  aarch64-osx   | aarch64 |             TODO              |    TODO     |                          |
|  aarch64-osx   | riscv64 |             TODO              |    TODO     |                          |
| x86_64-ubuntu  | x86_64  |              gcc              | clang.cmake | x86_64-x86_64-gcc.cmake  |
| x86_64-ubuntu  | aarch64 |     aarch64-linux-gnu-gcc     |    TEST     |                          |
| x86_64-ubuntu  | riscv64 |     riscv64-linux-gnu-gcc     |    TEST     | x86_64-riscv64-gcc.cmake |
| aarch64-ubuntu | x86_64  |             TODO              |    TEST     |                          |
| aarch64-ubuntu | aarch64 |             TODO              |    TEST     |                          |
| aarch64-ubuntu | riscv64 |             TODO              |    TEST     |                          |
| riscv64-ubuntu | x86_64  |             TODO              |    TODO     |                          |
| riscv64-ubuntu | aarch64 |             TODO              |    TODO     |                          |
| riscv64-ubuntu | riscv64 |             TODO              |    TODO     |                          |

host: 编译平台
target: 内核要运行的平台
gcc: 使用的 gcc 名称
clang: 使用的 clang 参数
TODO: 暂无测试条件
TEST: 需要进一步验证。

### 调试

```shell
cmake \
  -DTARGET_ARCH=x86_64 \
  -DCMAKE_TOOLCHAIN_FILE=./cmake/x86_64-x86_64-elf.cmake
  -DBOOT_ELF_OUTPUT_NAME="myboot.elf" \
  -DKERNEL_ELF_OUTPUT_NAME="mykernel.elf" \
  -DENABLE_GDB=ON \
  ..
```

构建系统行为

1. 编译出带 -g -ggdb 参数的内核
2. 将 gdbinit 复制到根目录 .gdbinit
3. 启动 qemu，在 2333 端口开放 telnet，在 1234 端口开放 gdb
4. 等待 gdb 连接

qemu 进入等待状态后，就可以通过 gdb 连接进行调试了

```shell
# 进入 gdb
gdb-multiarch
# 连接到 qemu
> target remote :1234
# 加载调试符号
> file ./build_x86_64/bin/boot.elf
# 运行
> c
```

更多调试命令请参考 [gdb 手册 ](https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_toc.html)。

对 efi 文件的调试需要一些准备步骤，参考 [osdev](https://wiki.osdev.org/Debugging_UEFI_applications_with_GDB)。

### 文档生成

需要安装的程序

```shell
sudo apt install -y doxygen graphviz 
```

生成文档

```shell
make doc
```

使用浏览器打开 `cmake-kernel/build_x86_64/doc/html/index.html` 查看文档。

### 静态分析

使用 clang-tidy 与 cppcheck

需要安装的程序

```shell
sudo apt install -y clang-tidy cppcheck
```

生成文档

```shell
make doc
```

### 测试覆盖率

### docker

提供了统一的 ubuntu+gcc 编译环境。

See [docker.md](./docker.md)。 

### 第三方资源

使用 [CPM](https://github.com/cpm-cmake/CPM.cmake) 进行管理，下载的源文件会放到 3rd 文件夹下，编译结果会放在 build/_deps
文件夹下。

对于原生支持 cmake 的项目，可以直接引用。

不支持的项目需要手动编译。

目前支持的第三方资源


|                                 第三方内容                                 |                  描述                  |      类型      | 正在使用 |
|:---------------------------------------------------------------------:|:------------------------------------:|:------------:|:----:|
|             [CPM](https://github.com/cpm-cmake/CPM.cmake)             |              cmake 包管理               | cmake module |  ✔   |
| [CPMLicences.cmake](https://github.com/TheLartians/CPMLicenses.cmake) |           为第三方包生成 licence            | cmake module |  ✔   |
|       [google/googletest](https://github.com/google/googletest)       |                  测试                  |      库       |      |
|        [easylogingpp](https://github.com/amrayn/easyloggingpp)        |                  日志                  |      库       |      |
|                [rttr](https://github.com/rttrorg/rttr)                |           c++ 反射库，在设备驱动部分用           |      库       |      |
|      [Format.cmake](https://github.com/TheLartians/Format.cmake)      | 代码格式化，支持 clang-format 与 cmake-format | cmake module |      |
|            [FreeImage](http://freeimage.sourceforge.net/)             |                 图片渲染                 |      库       |      |
|                 [Freetype](https://www.freetype.org/)                 |                 字体渲染                 |      库       |      |
|       [opensbi](https://github.com/riscv-software-src/opensbi)        |               riscv 引导               |      库       |  ✔   |
|         [gnu-efi](https://sourceforge.net/projects/gnu-efi/)          |             gnu uefi 引导              |      库       |  ✔   |
|          [posix-uefi](https://gitlab.com/bztsrc/posix-uefi)           |            posix uefi 引导             |      库       |      |
|                     [ovmf](SimpleKernel/3rd/ovmf)                     |           qemu 使用的 uefi 固件           |     bin      |  ✔   |
|               [edk2](https://github.com/tianocore/edk2)               |       构建 qemu 使用的 uefi 固件 ovmf       |      库       |      |
|           [libcxxrt](https://github.com/libcxxrt/libcxxrt)            |              c++ 运行时支持               |      库       |  ✔   |

## 错误处理

- gdbinit

    ```shell
    To enable execution of this file add
            add-auto-load-safe-path /home/nzh_ubuntu/GitHub/cmake-kernel/.gdbinit
    line to your configuration file "/home/yourusername/.config/gdb/gdbinit".
    To completely disable this security protection add
            set auto-load safe-path /
    line to your configuration file "/home/yourusername/.config/gdb/gdbinit".
    For more information about this security protection see the
    "Auto-loading safe path" section in the GDB manual.  E.g., run from the shell:
            info "(gdb)Auto-loading safe path"
    ```

    在你的用户目录下找到 `/home/nzh_ubuntu/.config/gdb/gdbinit`(没有则新建)，将这一句加进去

    ```shell
    add-auto-load-safe-path /home/yourusername/pathtocmakekernel/cmake-kernel/.gdbinit
    ```

- TODO





## TODO

使用 gcc/clang 交叉编译 gnu-efi 

riscv64 支持 uefi

支持 posix-uefi





