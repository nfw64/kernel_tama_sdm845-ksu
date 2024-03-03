#!/bin/bash

export TZ='Asia/Kuala_Lumpur'
BUILDTIME=$(date +%H%M)

# Start
echo "Build started"
# Check if gitpod and install dependencies
if [ -d /workspace ] ; then
sudo apt update && sudo apt install -y bc cpio nano bison ca-certificates curl flex gcc git libc6-dev libssl-dev openssl python-is-python3 ssh wget zip zstd sudo make clang gcc-arm-linux-gnueabi software-properties-common build-essential libarchive-tools gcc-aarch64-linux-gnu
fi

# Set variable
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
eval KSU_VERSION=$(expr 10000 + $KSU_GIT_VERSION + 200)
export KBUILD_BUILD_USER=slicer
export KBUILD_BUILD_HOST=nfw64
DEFCONFIG="tama_akatsuki_defconfig"
# Send info to telegram
./telegram.sh msg "$DEFCONFIG" "$KSU_VERSION"

# Update ksu
git submodule update --remote
git submodule update --init --recursive

# Export Clang
TC_DIR="/"

export PATH="$TC_DIR/bin:$PATH"

# Timer
m=$(date +%M)
s=$(date +%S)
# Timer-End

# Build
mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG
make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt

# Timer
echo "Build took : $(expr $(date +%M) - $m) minute(s) and $(expr $(date +%S) - $s) second(s)"
TIMER="$(expr $(date +%M) - $m) minute(s) and $(expr $(date +%S) - $s) second(s)"
# Timer-End

if [ -f out/arch/arm64/boot/Image.gz-dtb ] ; then
cp -R out/arch/arm64/boot/Image.gz-dtb AnyKernel3/Image.gz-dtb
	# Package
	git clone --depth=1 https://github.com/nfw64/AnyKernel3.git AnyKernel3
	cd AnyKernel3
	zip -r9 starfield-ksu-"$BUILDDATE" . -x ".git*" -x "README.md" -x "*.zip"
	mv starfield-ksu-"$BUILDDATE".zip ..
	cd ..
	./telegram.sh file starfield-ksu-"$BUILDDATE".zip "$TIMER"
	# Finish
	cp -R out/arch/arm64/boot boot-out/
	rm -rf out/ AnyKernel3/ log.txt starfield-ksu-*
	echo "Build finished"
else
	# Fail
	./telegram.sh error log.txt
	echo "Build failed"
fi
