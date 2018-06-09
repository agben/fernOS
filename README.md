Writing an operating system is probably on every code hacker's bucket list.
Something that stands on its own and doesn't rely on any other software to function.

Well fernOS is far from being an OS and it still relies on BIOS routines but its a start.

Written in x86 assembly language it currently sits completely within the 512 byte bootloader.
It is therefore quick to start and provides a terminal shell with a few (unhelpful) commands.
>    BOOT --- to reboot  
    HELP --- to list available commands  
    SAY ------ to output a message to the screen e.g. <em>SAY "Hello World"</em>  
    WAIT --- to pause for a specified number of seconds e.g. <em>WAIT5</em>

The shell is currently case insensitive and commands can be combined to form a script.  
e.g. fernOS><em>say"this system will reboot in 9 seconds" wait4 say"goodbye" wait5  boot</em>

See www.benningtons.net for more information about fernOS

When I get time I'll look to add more.

---
**Notes:**
---
Compiled with:
> nasm -f bin -w+all -o fernOS.bin fernOS.asm

Create a new disk image:
>mkdosfs -C fernOS.img 1440

Transfer fernOS to disk image:
>dd if=fernOS.bin of=fernOS.img conv=notrunc

Format floppy disk with new image:
>dd if=fernOS.img of=/dev/fd0

Format USB memorystick with new image:
>dd if=fernOS.img of=/dev/sdb  
*(CHECK IF /dev/sdb IS YOUR MEMORYSTICK and then CHECK AGAIN!)*

---
**fernOS -- Version history (prior to github)**
---
0.0.1 --- 10-May-2015 --- fernOS is born. Boots, keyboard input echoed to screen, new prompt with carriage return  
0.0.2 --- 16-May-2015 --- BIOS and UTIL libraries started, collects command line input for syntax checking  
0.0.3 --- 31-May-2015 --- corrected input buffer overflow bug, no CR on a blank line and setting memory segments
