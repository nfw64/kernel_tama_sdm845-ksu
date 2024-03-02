#!/bin/bash
name="starfield-ksu" # zip name
modir=$(pwd)
direct=$modir # change to destination 
cyan="\033[96m"


echo -e "$cyan COMPRESSING FILE\033[0m"
rm -rf $name.zip
cd $modir
(
cd AnyKernel3 ; zip -qr "$name" * ; mv "$name.zip" $modir
)
(
mv "$name.zip" out/arch/arm64/boot/ ; cd out/arch/arm64/boot/ ;
zip -q "$name" "Image.gz-dtb" ; mv "$name.zip" $direct
)

./telegram.sh file "$name.zip"
