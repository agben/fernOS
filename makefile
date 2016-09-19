SHELL = /bin/sh
NASM = /usr/bin/nasm
NASM_FLAGS= -f bin -w+all

all: fernOS.bin
fernOS.bin: fernOS.asm fernOS_BIOS_library.asm fernOS_UTIL_library.asm
	$(NASM) $(NASM_FLAGS) $< -o $@

clean:
	rm fernOS.img

install:
	@echo "\nUSE AT YOUR OWN RISK"
	@echo "********************"
	@echo "Get the memory stick device name wrong (mine is /dev/sdb) and you could wipe your hard drive!"
	@echo "Get the memory stick device name right and you will erase ALL its contents and replace with only a fresh fernOS image"

#mkdosfs is found in the debian dosfstools package
	@/sbin/mkdosfs -C fernOS.img 1440				#Create a new disk image

	@dd if=fernOS.bin of=fernOS.img conv=notrunc	#Transfer fernOS to disk image

	@echo "\nNew fernOS.img file created. Use makeUSB.sh to write it to a USB memory stick of floppy disk."

