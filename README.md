# cmake-kernel

关键词：cmake kernel cross-compile cmake-templete

用于构建内核的构建系统。



## 设计

用于构建内核的构建系统

构建系统提供的功能：

- [ ] 跨平台

    提供 gcc/clang 的支持

    需要独立的  CMAKE_TOOLCHAIN_FILE 指定编译器等

    组合如下

    |      host      | target  |              gcc              | clang |
    | :------------: | :-----: | :---------------------------: | :---: |
    |   x86_64-osx   | x86_64  |        x86_64_elf-gcc         | TEST  |
    |   x86_64-osx   | aarch64 | aarch64-unknown-linux-gnu-gcc | TEST  |
    |   x86_64-osx   | riscv64 |    riscv64-unknown-elf-gcc    | TEST  |
    |  aarch64-osx   | x86_64  |             TODO              | TODO  |
    |  aarch64-osx   | aarch64 |             TODO              | TODO  |
    |  aarch64-osx   | riscv64 |             TODO              | TODO  |
    | x86_64-ubuntu  | x86_64  |              gcc              | TEST  |
    | x86_64-ubuntu  | aarch64 |     aarch64-linux-gnu-gcc     | TEST  |
    | x86_64-ubuntu  | riscv64 |     riscv64-linux-gnu-gcc     | TEST  |
    | aarch64-ubuntu | x86_64  |             TODO              | TEST  |
    | aarch64-ubuntu | aarch64 |             TODO              | TEST  |
    | aarch64-ubuntu | riscv64 |             TODO              | TEST  |
    | riscv64-ubuntu | x86_64  |             TODO              | TODO  |
    | riscv64-ubuntu | aarch64 |             TODO              | TODO  |
    | riscv64-ubuntu | riscv64 |             TODO              | TODO  |

    host: 编译平台
    target: 内核要运行的平台
    gcc: 使用的 gcc 名称
    clang: 使用的 clang 参数
    TODO: 暂无测试条件
    TEST: 需要进一步验证。

- [x] 对第三方依赖的支持/构建

    自动下载并编译第三方依赖

    自动生成相关 licence

    预期使用的第三方内容

    |                          第三方内容                          |                     描述                      |     类型     |
    | :----------------------------------------------------------: | :-------------------------------------------: | :----------: |
    |        [CPM](https://github.com/cpm-cmake/CPM.cmake)         |                 cmake 包管理                  | cmake module |
    | [CPMLicences.cmake](https://github.com/TheLartians/CPMLicenses.cmake) |            为第三方包生成 licence             | cmake module |
    |  [google/googletest](https://github.com/google/googletest)   |                     测试                      |      库      |
    |   [easylogingpp](https://github.com/amrayn/easyloggingpp)    |                     日志                      |      库      |
    |           [rttr](https://github.com/rttrorg/rttr)            |         c++ 反射库，在设备驱动部分用          |      库      |
    | [Format.cmake](https://github.com/TheLartians/Format.cmake)  | 代码格式化，支持 clang-format 与 cmake-format | cmake module |
    |        [FreeImage](http://freeimage.sourceforge.net/)        |                   图片渲染                    |      库      |
    |            [Freetype](https://www.freetype.org/)             |                   字体渲染                    |      库      |
    |   [opensbi](https://github.com/riscv-software-src/opensbi)   |                  riscv 引导                   |      库      |
    |     [gnu-efi](https://sourceforge.net/projects/gnu-efi/)     |                 gnu uefi 引导                 |      库      |
    |      [posix-uefi](https://gitlab.com/bztsrc/posix-uefi)      |                posix uefi 引导                |      库      |
    |                [ovmf](SimpleKernel/3rd/ovmf)                 |             qemu 使用的 uefi 固件             |     bin      |
    |          [edk2](https://github.com/tianocore/edk2)           |        构建 qemu 使用的 uefi 固件 ovmf        |      库      |

    

- [ ] 文档生成

    doxygen

    1. 使用 doxygen 从注释生成文档
    2. doxygen 配置文件

- [x] 构建内核

    生成内核 elf 文件

- [x] 运行内核

    在 qemu 上运行内核

- [ ] 代码格式化

    格式化全部代码

- [ ] 单元测试

    测试

- [ ] CI

    github action、codecov

- [ ] 定义项目信息

    版本号、自动生成头文件

- [x] 指定输出目录

    将第三方依赖、内核等编译生成的文件放到指定位置

- [x] 调试

    使用 make debug 等进入调试模式

- [ ] 工具链的构建

    gcc/qemu/docker

- [ ] IDE 支持

    vscode，Clion



## 实现



## 使用

根目录 CMakeList.txt 可用参数如下

|          参数          |         合法值（默认值）         | 类型 |                  说明                   |
| :--------------------: | :------------------------------: | :--: | :-------------------------------------: |
|  ENABLE_BUILD_RELEASE  |           ON/OFF(OFF)            | BOOL |              是否为发布版               |
| ENABLE_GENERATOR_MAKE  |            ON/OFF(ON)            | BOOL |  是否使用 make 构建，OFF 则使用 ninja   |
|  ENABLE_COMPILER_GNU   |            ON/OFF(ON)            | BOOL |     是否使用 gcc，OFF 则使用 clang      |
|     ENABLE_GNU_EFI     |            ON/OFF(ON)            | BOOL | 是否使用 gnu-efi，OFF 则使用 posix-uefi |
|  ENABLE_TEST_COVERAGE  |            ON/OFF(ON)            | BOOL |           是否开启测试覆盖率            |
|      ENABLE_GDB      |           ON/OFF(OFF)            | BOOL |           是否启用 gdb 调试，为 ON           |
|        PLATFORM        |               qemu               | STR  |               运行的平台                |
|      TARGET_ARCH       | x86_64, riscv64, aarch64(x86_64) | STR  |                目标架构                 |
|  BOOT_ELF_OUTPUT_NAME  |            (boot.elf)            | STR  |             引导 elf 文件名             |
|  BOOT_EFI_OUTPUT_NAME  |            (boot.efi)            | STR  |             引导 efi 文件名             |
| KERNEL_ELF_OUTPUT_NAME |           (kernel.elf)           | STR  |             内核 elf 文件名             |
| KERNEL_EFI_OUTPUT_NAME |           (kernel.efi)           | STR  |             内核 efi 文件名             |
|                        |                                  |      |                                         |
|                        |                                  |      |                                         |
|                        |                                  |      |                                         |



```shell
cmake \
  -DTARGET_ARCH=x86_64 \
  -DTARGET_ARCH=x86_64 \
  -DBOOT_ELF_OUTPUT_NAME="myboot.elf" \
  -DKERNEL_ELF_OUTPUT_NAME="mykernel.elf" \
  ..
```

### 调试

```shell
cmake \
  -DTARGET_ARCH=x86_64 \
  -DBOOT_ELF_OUTPUT_NAME="myboot.elf" \
  -DKERNEL_ELF_OUTPUT_NAME="mykernel.elf" \
  -DENABLE_GDB=ON \
  ..
```

构建系统行为

1. 编译出带 -g -ggdb 参数的内核
2. 将 gdbinit 复制到根目录 .gdbinit
3. 启动 qemu，在 2333 端口开放 telnet，在 1234 端口开放 gdb、
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

更多调试命令请参考 [gdb 手册 ](https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_toc.html)

### 文档生成

### 测试覆盖率



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

- ss

- 124

- 5435

- sfsf

