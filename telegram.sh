#!/bin/bash

# Copyright 2024 Purrr
# Github @sandatjepil

# Ini Pengaturan buat kirim ke supergroup (grup bertopik)
# Set 1 untuk Ya | 0 untuk Tidak
TG_SUPER=1

# Isi token BOT disini
TG_TOKEN=6939285046:AAEh4ecDpc9Zf7dnm7qubXqFBE9H5S3rymQ

# isi ID channel atau grup
# Pastikan botnya sudah jadi admin
CHATID=-1002105595221
# kalo grupnya bertopic isi ini, kalo ngga kosongin aja
TOPICID=10

#################################################
# BAGIAN INI JANGAN DISENTUH!!
#################################################
BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"
BOT_DEL_URL="https://api.telegram.org/bot$TG_TOKEN/deleteMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$TG_TOKEN/sendDocument"
time=(date)
tg_post_msg(){
	if [ $TG_SUPER = 1 ]
	then
	    curl -s -X POST "$BOT_MSG_URL" \
	    -d chat_id="$CHATID" \
	    -d message_thread_id="$TOPICID" \
	    -d "disable_web_page_preview=true" \
	    -d "parse_mode=html" \
	    -d text="Kernel Build has started
Date : $(date +%r)
Device : akatsuki
Type : global
KSU : $(git submodule | grep -o "KernelSU (v.*)" )
Version : $(make kernelversion)
Clang : $(clang --version | head -1)"
	else
	    curl -s -X POST "$BOT_MSG_URL" \
	    -d chat_id="$CHATID" \
	    -d "disable_web_page_preview=true" \
	    -d "parse_mode=html" \
	    -d text="$1"
	fi
}

tg_error(){
	if [ $TG_SUPER = 1 ]
	then
	    curl -F document=@"$1" "$BOT_BUILD_URL" \
	    -F chat_id="$CHATID"  \
	    -F message_thread_id="$TOPICID" \
	    -F "disable_web_page_preview=true" \
	    -F "parse_mode=Markdown" \
	    -F caption="Kernel compile failed, log attached"
	else
	    curl -F document=@"$1" "$BOT_BUILD_URL" \
	    -F chat_id="$CHATID"  \
	    -F "disable_web_page_preview=true" \
	    -F "parse_mode=Markdown" \
	    -F caption="Kernel compile failed, log attached"
	fi
}

tg_post_build()
{
	#Show the Checksum alongwith caption
	if [ $TG_SUPER = 1 ]
	then
	    curl -F document=@"$1" "$BOT_BUILD_URL" \
	    -F chat_id="$CHATID"  \
	    -F message_thread_id="$TOPICID" \
	    -F "disable_web_page_preview=true" \
	    -F "parse_mode=Markdown" \
	    -F caption="Kernel has finished compiling"
	else
	    curl -F document=@"$1" "$BOT_BUILD_URL" \
	    -F chat_id="$CHATID"  \
	    -F "disable_web_page_preview=true" \
	    -F "parse_mode=Markdown" \
	    -F caption="Kernel has finished compiling"
	fi
}

normal="\033[0m"
orange="\033[1;38;5;208m"
red="\033[1;31m"
green="\033[1;32m"

case "$1" in
  file)
    tg_post_build $2 $3 > /dev/null 2>&1
    echo "file has been sent to telegram"
    ;;
  msg)
    tg_post_msg $2 > /dev/null 2>&1
    echo "action have been logged in telegram"
    ;;
  error)
    tg_error $2 $3 > /dev/null 2>&1
    echo "failed"
    ;;
  help)
    echo "Cara Pemakaian:"
    echo "- Untuk kirim file"
    echo "${green}kirimtele.sh file namafile caption${normal}"
    echo "- Untuk kirim pesan"
    echo "${green}kirimtele.sh msg caption${normal}"
    ;;
  *)
    echo "command tidak ditemukan"
    echo "ketik ${green}kirimtele.sh help${normal}"
    echo "untuk cara penggunaan"
    ;;
esac
#################################################
# BAGIAN INI JANGAN DISENTUH!!
#################################################
