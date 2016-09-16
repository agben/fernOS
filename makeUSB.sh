#! /bin/bash
# -----------------------------------------------------------------------------
# makeUSB		www.benningtons.net			May-2015
# -----------------------------------------------------------------------------
# A simple shell script for generating a new fernOS image and writingit to a USB memory stick (or floppy disk)
#
# USE AT YOUR OWN RISK
# ********************
# Get the memory stick device name wrong (mine is /dev/sdb) and you could wipe your hard drive!
# Get the memory stick device name right and you will erase ALL its contents and replace with only a fresh fernOS image
#
#!
cd ~/Code/fernOS								#move to project folder

#nasm -f bin -w+all -o fernOS.bin fernOS.asm	#compile fernOS

rm fernOS.img									#remove previous image

mkdosfs -C fernOS.img 1440						#Create a new disk image

dd if=fernOS.bin of=fernOS.img conv=notrunc		#Transfer fernOS to disk image

#dd if=fernOS.img of=/dev/fd0					#Format floppy disk with new image

echo -e "\n########## tail of dmesg ##########"
dmesg|tail -5
echo -e "\n###################################"
echo -e "\nAre you certain the removable drive is sdb?";read opt
case $opt in
[Yy])
	dd if=fernOS.img of=/dev/sdb				#Format USB memorystick with new image
	;;
*)
	echo -e "\nAbandonded write to drive"
	;;
esac
