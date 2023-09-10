
[![codecov](https://codecov.io/gh/MRNIU/cmake-kernel/graph/badge.svg?token=J7NKK3SBNJ)](https://codecov.io/gh/MRNIU/cmake-kernel)
![workflow](https://github.com/MRNIU/cmake-kernel/actions/workflows/workflow.yml/badge.svg)

# cmake-kernel

关键词：cmake kernel cross-compile cmake-templete

用于构建内核的构建系统。



## 设计

用于构建内核的构建系统

构建系统提供的功能：

- [ ] 跨平台

  |     HOST      |          TARGET          |
    | :-----------: | :----------------------: |
  | x86_64-ubuntu | x86_64, riscv64, aarch64 |
  |  x86_64-osx   |           TODO           |


- [x] 对第三方依赖的支持/构建

    自动下载并编译第三方依赖

    自动生成相关 licence

  目前支持的第三方资源

    |                          第三方内容                          |                     描述                      |     类型     | 正在使用 |
    | :----------------------------------------------------------: | :-------------------------------------------: | :----------: | :------: |
    |        [CPM](https://github.com/cpm-cmake/CPM.cmake)         |                 cmake 包管理                  | cmake module |    ✔     |
    | [CPMLicences.cmake](https://github.com/TheLartians/CPMLicenses.cmake) |            为第三方包生成 licence             | cmake module |    ✔     |
    |  [google/googletest](https://github.com/google/googletest)   |                     测试                      |      库      |    ✔     |
    |   [easylogingpp](https://github.com/amrayn/easyloggingpp)    |                     日志                      |      库      |          |
    |           [rttr](https://github.com/rttrorg/rttr)            |         c++ 反射库，在设备驱动部分用          |      库      |          |
    | [Format.cmake](https://github.com/TheLartians/Format.cmake)  | 代码格式化，支持 clang-format 与 cmake-format | cmake module |          |
    |        [FreeImage](http://freeimage.sourceforge.net/)        |                   图片渲染                    |      库      |          |
    |            [Freetype](https://www.freetype.org/)             |                   字体渲染                    |      库      |          |
    |   [opensbi](https://github.com/riscv-software-src/opensbi)   |                  riscv 引导                   |      库      |    ✔     |
    |     [gnu-efi](https://sourceforge.net/projects/gnu-efi/)     |                 gnu uefi 引导                 |      库      |    ✔     |
    |                [ovmf](SimpleKernel/3rd/ovmf)                 |             qemu 使用的 uefi 固件             |     bin      |    ✔     |
    |          [edk2](https://github.com/tianocore/edk2)           |        构建 qemu 使用的 uefi 固件 ovmf        |      库      |          |
    |       [libcxxrt](https://github.com/libcxxrt/libcxxrt)       |                c++ 运行时支持                 |      库      |    ✔     |

- [x] 文档生成

  使用 doxygen 从注释生成文档

- [x] 构建内核

    生成内核 elf 文件

- [x] 运行内核

    在 qemu 上运行内核

- [x] 代码格式化

    格式化全部代码

- [x] 测试

  单元测试 集成测试 系统测试

- [x] CI

    github action、codecov

- [x] 定义项目信息

    版本号、自动生成头文件

- [x] 指定输出目录

    将第三方依赖、内核等编译生成的文件放到指定位置

- [x] 调试

    使用 make debug 等进入调试模式

## 使用

安装依赖

```shell
sudo apt install --fix-missing -y doxygen graphviz clang-format clang-tidy cppcheck qemu-system lcov gcc g++ gcc-riscv64-linux-gnu g++-riscv64-linux-gnu gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gdb-multiarch
```

根目录 CMakeList.txt 可用参数如下

|           参数           |             合法值（默认值）             | 类型  |       说明        |
|:----------------------:|:--------------------------------:|:---:|:---------------:|
|  COVERAGE_OUTPUT_DIR   |            (coverage)            | STR |   测试覆盖率报告保存路径   |
|        PLATFORM        |               qemu               | STR |      运行的平台      |
|      TARGET_ARCH       | x86_64, riscv64, aarch64(x86_64) | STR |      目标架构       |
|  BOOT_ELF_OUTPUT_NAME  |            (boot.elf)            | STR |   引导 elf 文件名    |
|  BOOT_EFI_OUTPUT_NAME  |            (boot.efi)            | STR |   引导 efi 文件名    |
| KERNEL_ELF_OUTPUT_NAME |           (kernel.elf)           | STR |   内核 elf 文件名    |
|     QEMU_GDB_PORT      |           (tcp::1234)            | STR |  qemu gdb 调试端口  |
|    QEMU_MONITOR_ARG    |   (telnet::2333,server,nowait)   | STR | qemu monitor 设置 |

新建 `CMakeUserPresets.json`，继承 `configurePresets_base`
，填写你需要的参数（see [cmake-presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)）。

构建系统会自动下载并构建所有第三方依赖，boot，kernel，然后生成 image 文件夹，最后在 qemu 中启动（不同架构的流程有区别）。

### 交叉编译

1. 提供 gcc/clang 的支持。

2. 需要独立的 CMAKE_TOOLCHAIN_FILE 指定编译器。
3. gcc 工具链文件的命名规则：host-target-gcc.cmake(本机架构-目标架构-gcc.cmake)

支持的组合如下：

|   编译平台 host    | 运行平台 target |              gcc              | clang |   CMAKE_TOOLCHAIN_FILE   |       NOTE        |
|:--------------:|:-----------:|:-----------------------------:|:-----:|:------------------------:|:-----------------:|
|   x86_64-osx   |   x86_64    |        x86_64_elf-gcc         | TEST  |                          | gcc 没有 sysroot 支持 |
|   x86_64-osx   |   aarch64   | aarch64-unknown-linux-gnu-gcc | TEST  |                          |                   |
|   x86_64-osx   |   riscv64   |    riscv64-unknown-elf-gcc    | TEST  | x86_64-riscv64-gcc.cmake |                   |
|  aarch64-osx   |   x86_64    |             TODO              | TODO  |                          |      暂无测试条件       |
|  aarch64-osx   |   aarch64   |             TODO              | TODO  |                          |      暂无测试条件       |
|  aarch64-osx   |   riscv64   |             TODO              | TODO  |                          |      暂无测试条件       |
| x86_64-ubuntu  |   x86_64    |              gcc              | TEST  | x86_64-x86_64-gcc.cmake  |                   |
| x86_64-ubuntu  |   aarch64   |     aarch64-linux-gnu-gcc     | TEST  |                          |                   |
| x86_64-ubuntu  |   riscv64   |     riscv64-linux-gnu-gcc     | TEST  | x86_64-riscv64-gcc.cmake |                   |
| aarch64-ubuntu |   x86_64    |             TODO              | TEST  |                          |                   |
| aarch64-ubuntu |   aarch64   |             TODO              | TEST  |                          |                   |
| aarch64-ubuntu |   riscv64   |             TODO              | TEST  |                          |                   |
| riscv64-ubuntu |   x86_64    |             TODO              | TODO  |                          |                   |
| riscv64-ubuntu |   aarch64   |             TODO              | TODO  |                          |                   |
| riscv64-ubuntu |   riscv64   |             TODO              | TODO  |                          |                   |

### 调试

```shell
# 删除旧文件
rm -rf build_x86_64
# 生成
cmake --preset build_x86_64
# 编译并运行
cmake --build build_x86_64 --target run_debug
```

构建系统行为

1. 编译出带 -g -ggdb 参数的内核
2. 将 gdbinit 复制到根目录 .gdbinit
3. 以 `QEMU_GDB_PORT` 与 `QEMU_MONITOR_ARG` 启动 qemu
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

生成文档

```shell
cmake --preset=build_x86_64 
cmake --build build_x86_64 --target doc
```

使用浏览器打开 `cmake-kernel/build_x86_64/doc/html/index.html` 查看文档。

### 静态分析

使用 clang-tidy 与 cppcheck

生成文档

```shell
cmake --preset=build_x86_64
cmake --build build_x86_64 --target clang-tidy # 在 build_x86_64 目录下生成 clang_tidy_report.log
cmake --build build_x86_64 --target clang-format # 格式化代码
cmake --build build_x86_64 --target cppcheck # 在 build_x86_64 目录下生成 cppcheck_report.log
```

### 测试覆盖率

只会运行 ut 与 it，在 `build_x86_64/COVERAGE_OUTPUT_DIR` 目录生成测试覆盖率报告。

```shell
cmake --preset=build_x86_64
cmake --build build_x86_64 --target coverage
```

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
|       [google/googletest](https://github.com/google/googletest)       |                  测试                  |      库       |  ✔   |
|        [easylogingpp](https://github.com/amrayn/easyloggingpp)        |                  日志                  |      库       |      |
|                [rttr](https://github.com/rttrorg/rttr)                |           c++ 反射库，在设备驱动部分用           |      库       |      |
|      [Format.cmake](https://github.com/TheLartians/Format.cmake)      | 代码格式化，支持 clang-format 与 cmake-format | cmake module |      |
|            [FreeImage](http://freeimage.sourceforge.net/)             |                 图片渲染                 |      库       |      |
|                 [Freetype](https://www.freetype.org/)                 |                 字体渲染                 |      库       |      |
|       [opensbi](https://github.com/riscv-software-src/opensbi)        |               riscv 引导               |      库       |  ✔   |
|         [gnu-efi](https://sourceforge.net/projects/gnu-efi/)          |             gnu uefi 引导              |      库       |  ✔   |
|                     [ovmf](SimpleKernel/3rd/ovmf)                     |           qemu 使用的 uefi 固件           |     bin      |  ✔   |
|               [edk2](https://github.com/tianocore/edk2)               |       构建 qemu 使用的 uefi 固件 ovmf       |      库       |      |
|           [libcxxrt](https://github.com/libcxxrt/libcxxrt)            |              c++ 运行时支持               |      库       |  ✔   |

## 已知问题

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
