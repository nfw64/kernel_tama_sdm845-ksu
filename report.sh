#!/bin/bash
TG_SUPER=1
TG_TOKEN=6939285046:AAEh4ecDpc9Zf7dnm7qubXqFBE9H5S3rymQ
CHATID=-1002105595221
TOPICID=10
BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"
BOT_DEL_URL="https://api.telegram.org/bot$TG_TOKEN/deleteMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$TG_TOKEN/sendDocument"
KBUILD_COMPILER_STRING="Cosmic clang 14"

# --Kernel Settings--
DEFCONFIG="tama_akatsuki_defconfig"
export KBUILD_BUILD_USER=synthetic
export KBUILD_BUILD_HOST="Github Actions"

# --Compiler--
export TZ='Asia/Kuala_Lumpur'
BUILDDATE=$(date +%H%M)
KSU_GIT_VERSION=$(cd KernelSU && git rev-list --count HEAD)
eval KSU_VERSION=$(expr 10000 + $KSU_GIT_VERSION + 200)
KARCH=arm64

# --Functions--
tg_post_msg(){
	if [ $TG_SUPER = 1 ]
	then
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

tg_post_build()
{
	if [ $TG_SUPER = 1 ]
	then
	    curl --no-progress-meter -F document=@"$1" "$BOT_BUILD_URL" \
	    -F chat_id="$CHATID"  \
	    -F message_thread_id="$TOPICID" \
	    -F "disable_web_page_preview=true" \
	    -F "parse_mode=Markdown" \
	    -F caption="$2"
	else
	    curl --no-progress-meter -F document=@"$1" "$BOT_BUILD_URL" \
	    -F chat_id="$CHATID"  \
	    -F "disable_web_page_preview=true" \
	    -F "parse_mode=Markdown" \
	    -F caption="$2"
	fi
}

tg_post_msg "<b>Ci Build Triggered</b>%0A<b>Date</b> : <code>$(date "+%D at %I:%M ")</code>%0A<b>Defconfig</b> : <code>$DEFCONFIG</code>%0A<b>Build Host</b> : <code>Github Actions</code>%0A<b>KSU</b> : <code>$KSU_VERSION</code>%0A<b>Version</b> : <code>$(make kernelversion)</code>%0A<b>Clang</b> : <code>$KBUILD_COMPILER_STRING</code>" > /dev/null
