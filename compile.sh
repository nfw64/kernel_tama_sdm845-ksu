#!/bin/bash
# copy right by zetaxbyte
# you can rich me on telegram t.me/@zetaxbyte

cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"

if [ -d /workspace ] ; then
git submodule update --init --recursive
./c-depend.sh
fi

echo -e "$cyan===========================\033[0m"
echo -e "$cyan= START COMPILING KERNEL  =\033[0m"
echo -e "$cyan===========================\033[0m"

# change DEFCONFIG to you are defconfig name or device codename
./telegram.sh msg
DEFCONFIG="tama_akatsuki_defconfig"

# you can set you name or host name(optional)

export KBUILD_BUILD_USER=To.Infinity.And.Beyond
export KBUILD_BUILD_HOST=nfw64

# change TC_DIR(directory) with your clang

TC_DIR="/"

# do not modify export PATCH it's been including with TC_DIR

export PATH="$TC_DIR/bin:$PATH"


mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG
make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt

if [ -f out/arch/arm64/boot/Image.gz-dtb ] ; then
    ./package.sh
    echo -e "$cyan===========================\033[0m"
    echo -e "$cyan=  SUCCESS COMPILE KERNEL =\033[0m"
    echo -e "$cyan===========================\033[0m"
else
./telegram.sh error log.txt
echo -e "$red!ups...something wrong!?\033[0m"
fi
