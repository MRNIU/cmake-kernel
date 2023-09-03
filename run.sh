#!/bin/bash

# This file is a part of MRNIU/cmake-kernel
# (https://github.com/MRNIU/cmake-kernel).
#
# run.sh for MRNIU/cmake-kernel.
# 在虚拟机中运行内核

# shell 执行出错时终止运行
set -e
# 输出实际执行内容
#set -x

TARGET_ARCH=x86_64
# TARGET_ARCH=riscv64
# TARGET_ARCH=aarch64

# 是否使用 gcc，否则使用 clang
USE_GNU=ON

if [[ ${USE_GNU} == "ON" ]];then
    CMAKE_TOOLCHAIN_FILE=`pwd`/cmake/`uname -m`-${TARGET_ARCH}-gcc.cmake
else
    CMAKE_TOOLCHAIN_FILE=`pwd`/cmake/clang.cmake
fi

# 编译
mkdir -p ./build_${TARGET_ARCH}
cd ./build_${TARGET_ARCH}
# @todo 在使用 CLion 时，在 ide 内部添加 -DUSE_IDE=ON 以让 ide 自动处理 cmake
cmake \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DTARGET_ARCH=${TARGET_ARCH} \
  ..
make run
