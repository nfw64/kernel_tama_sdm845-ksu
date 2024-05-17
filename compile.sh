#!/bin/bash
# --Telegram--
export TG_SUPER=1
export TG_TOKEN=6939285046:AAEh4ecDpc9Zf7dnm7qubXqFBE9H5S3rymQ
export CHATID=-1002105595221
export TOPICID=10
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"
export BOT_DEL_URL="https://api.telegram.org/bot$TG_TOKEN/deleteMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$TG_TOKEN/sendDocument"

# --Kernel Settings--
export DEFCONFIG="tama_akatsuki_defconfig"
export KBUILD_BUILD_USER=synthetic
export KBUILD_BUILD_HOST="Github Actions"

# --Compiler--
export TZ='Asia/Kuala_Lumpur'
export BUILDDATE=$(date +%H%M)
export KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
export KSU_VERSION=$(expr 10000 + $KSU_GIT_VERSION + 200)
export KARCH=arm64

# --Functions--
tg_post_msg() {
  if [ $TG_SUPER = 1 ]; then
    curl -s -X POST "$BOT_MSG_URL" \
      -d chat_id="$CHATID" \
      -d message_thread_id="$TOPICID" \
      -d "disable_web_page_preview=true" \
      -d "parse_mode=html" \
      -d text="$1"
  else
    curl -s -X POST "$BOT_MSG_URL" \
      -d chat_id="$CHATID" \
      -d "disable_web_page_preview=true" \
      -d "parse_mode=html" \
      -d text="$1"
  fi
}

tg_post_build() {
  if [ $TG_SUPER = 1 ]; then
    curl --no-progress-meter -F document=@"$1" "$BOT_BUILD_URL" \
      -F chat_id="$CHATID" \
      -F message_thread_id="$TOPICID" \
      -F "disable_web_page_preview=true" \
      -F "parse_mode=Markdown" \
      -F caption="$2"
  else
    curl --no-progress-meter -F document=@"$1" "$BOT_BUILD_URL" \
      -F chat_id="$CHATID" \
      -F "disable_web_page_preview=true" \
      -F "parse_mode=Markdown" \
      -F caption="$2"
  fi
}

check_ksu() {
  if [ ! $INC_KSU = true ]; then
    sed -i '/CONFIG_KSU=/c\CONFIG_KSU=n' arch/$KARCH/configs/$DEFCONFIG
  else
    sed -i '/CONFIG_KSU=/c\CONFIG_KSU=y' arch/$KARCH/configs/$DEFCONFIG
  fi
}

make_kernel() {
  check_ksu
  START=$(date +"%s")
  mkdir -p out
  make O=out ARCH=$KARCH $DEFCONFIG
  make -j$(nproc --all) O=out \
    ARCH=$KARCH \
    LLVM=1 \
    LLVM_IAS=1 \
    AR=llvm-ar \
    NM=llvm-nm \
    LD=ld.lld \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CC=clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi 2>&1 | tee log.txt
  END=$(date +"%s")
  DIFF=$((END - START))
}

gen_zip() {
  git clone --depth=1 https://github.com/nfw64/AnyKernel3.git AnyKernel3
  cp -R out/arch/arm64/boot/Image.gz-dtb AnyKernel3/Image.gz-dtb
  if [ ! $INC_KSU = true ]; then
    (
       cd AnyKernel3
       zip -r9 starfield-ksu-"$BUILDDATE" . -x ".git*" -x "README.md" -x "*.zip"
       mv starfield* ../
    )
  else
    (
       cd AnyKernel3
       zip -r9 starfield-"$BUILDDATE" . -x ".git*" -x "README.md" -x "*.zip"
       mv starfield* ../
    )
  fi
}

post_file() {
  MESSAGE="$(( $DIFF / 60 )) minute(s) and $((DIFF % 60)) second(s)"
  if [ ! $INC_KSU = true ]; then
    tg_post_build starfield*.zip "*Non-KernelSU variant*
Build took $MESSAGE" > /dev/null
  else
    tg_post_build starfield*.zip "*KernelSU variant*
*Build took* : $MESSAGE" > /dev/null
  fi
}

package_kernel() {
  if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    gen_zip
    post_file
    # Finish
    cp -R out/arch/arm64/boot boot-out/
    rm -rf out/ AnyKernel3/ log.txt starfield-ksu-*
  else
    # Fail
    if [ ! $INC_KSU = true ]; then 
      tg_post_build log.txt "*Build for Non-KernelSU variant failed!*" > /dev/null
    else
      tg_post_build log.txt "*Build for KernelSU variant failed!*" > /dev/null
    fi
    exit 1
  fi
}

init_clang() {
  if [ ! -d "clang" ]; then
    echo "Cloning clang"
    REPO=true
    CLANG_BRANCH='release/14.x'
    CLANG_LINK='https://github.com/ZyCromerZ/Clang/releases/download/19.0.0git-20240408-release/Clang-19.0.0git-20240408.tar.gz'
    if [ REPO = true ]; then 
      git clone $CLANG_LINK --depth=1 -b $CLANG_BRANCH --single-branch clang
    else 
      (mkdir clang ; cd clang ; wget -q $CLANG_LINK ; tar -xf *)
    fi
  fi
  if ! command -v bc &>/dev/null; then
    sudo update -y && sudo apt install -y bc bison build-essential ccache curl flex glibc-source g++-multilib gcc-multilib binutils-aarch64-linux-gnu git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python2 tmate ssh neofetch
  fi
  TC_DIR="${PWD}/clang"
  export PATH="$TC_DIR/bin:$PATH"
  KBUILD_COMPILER_STRING="Cosmic clang 14"
  sudo apt install ccache -y
  ccache -M 100G
  export USE_CCACHE=1
}
