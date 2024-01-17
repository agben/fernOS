;--------------------------------------------------------------------
;								fernOS
;	An x86 assembly language based operating system that will be
;	written, and no doubt re-written, as I learn.
;						www.benningtons.net
;	with grateful thanks to the tutorials by Mike Saunders in LXF
;			and the far better Linux Voice magazine.
;--------------------------------------------------------------------

; Compiler settings and parameters
	BITS 16								;Set nasm to 16-bit mode - required for bootloaders

section .text							;protected code area

fernOS:									;main console service
;	An x86 assembly language based operating system

	%include "fe_ascii.hsm"				; ASCII definitions

;fernOS memory map: (segment*16)+offset
;	start	end		size
;	0000	07BF	31k							reserved
;	07C0	08DF	4k + 512b	ds:si, es:di	code + data space
;	08E0	09FF	4k + 512b	ss:sp			stack space
;
	mov		ax, 07C0h					;x86 memory segmentation: data space
	mov 	ds, ax						;can't load directly into ds

	mov		ax, 08E0h					;x86 memory segmentation: stack space
	mov		ss, ax
	mov		sp, 1000h					;stack works backwards from 4k limit into stack space

	mov		ax, ds						;x86 memory segmentation: extra space
	mov 	es, ax

.fernOS_help:							;HELP command jumps to here to redisplay welcome message
	mov		si, bootmsg					;output boot message to screen
	call	BIOS_put_string

.next_prompt:
	mov 	si, prompt
	call	BIOS_put_string				;output next prompt
	mov 	di, inputbuf				;reset di ready for next command
	mov 	word [inpoint], inputbuf	;store pointer to start of input buffer

.console:								;inner loop to allow keyboard command line input
	call	BIOS_get_keystroke			;check keyboard for input. Out=al

	cmp		al, ASCII_SP
	jge		.char_input					;printable character input
	cmp		al, ASCII_CR
	je		.carriage_ret				;return key so goto next line and redisplay prompt
	cmp		al, ASCII_BS
	je		.back_space					;back space key so delete previous char
	jmp		.console					;no valid input so try again

.char_input:
	call	BIOS_put_char				;output character (al) to screen
	call	UTIL_upper					;convert any lowercase letters to uppercase (fernOS is case insensitive)
	stosb								;store ax into [di] and di++
	cmp		di, inpoint					;input buffer overflow?
	jl		.console					;look for next input
	dec		di
	mov		al, ASCII_NL
	stosb								;reverse one and mark end of input with a null
	jmp		.syntax_error

.back_space:
	cmp		di, inputbuf
	je		.console					;no text input so ignore
	mov 	si, bs_str
	call 	BIOS_put_string				;backspace and erase previous char
	dec		di							;clear last char input from buffer
	jmp		.console

.carriage_ret:
	cmp		di, inputbuf
	je		.next_prompt				;no text input so ignore and display next prompt
	mov		al, ASCII_NL
	stosb								;mark end of input string with a null
;	mov 	word [inpoint], inputbuf	;store pointer to start of input buffer

.any_more:
	mov 	si, cmdlist					;start at beginning of the list of commands.
	mov		bx, 0						;count commands checked

.parse_cmds:							;check each command against our input string
	mov 	di, [inpoint]				;set pointer to the start of our entered command
.pc1:
	cmp		byte [di], ASCII_NL
	je		.next_prompt				;no more so display next prompt
	cmp		byte [di], ASCII_SP			;skip any spaces between commands
	jne		.pc2
	inc		di
	jmp		.pc1
.pc2:
	call	UTIL_str_cmp
	cmp		ax, 0
	je		.cmd_match					;matched a valid command

.next_cmd:								;not a match so move si to start of the next command
	cmp		byte [si], ASCII_NL
	je		.find_next_cmd
	inc		si
	jmp		.next_cmd

.find_next_cmd:
	inc		bx
	inc		si
	cmp 	si, synterr					;check location of the string after the command list
	jge 	.syntax_error				;gone beyond list of commands so invalid command entered
	jmp		.parse_cmds					;else try again, si will be pointing to the start of next command

.cmd_match:								;rough output of selected command to check if in right place
	mov 	word [inpoint], di			;store pointer to where we are in input buffer

	cmp		bx,1
	je		.fernOS_help
	cmp		bx,2
	je		.fernOS_say
	cmp		bx,3
	je		.fernOS_wait
	cmp		bx,0
	jne		.syntax_error
	call	BIOS_boot

.syntax_error:
	mov		si, synterr					;display a syntax error message
	call 	BIOS_put_string
	mov 	si, [inpoint]
	call 	BIOS_put_string				;followed by a repeat of the command that was typed
	jmp		.next_prompt


.fernOS_say:							;SAY"HELLO" = output HELLO to the screen
	mov		si, nl_str
	call 	BIOS_put_string
	cmp		byte [di], ASCII_DQ			;error if not using quotes
	jne		.syntax_error
.fs1:
	inc		di							;skip 1st set of quotes
	cmp		byte [di], ASCII_DQ
	je		.fs2						;look through until reaching 2nd set of quotes
	cmp		byte [di], ASCII_NL
	je		.syntax_error				;reached the end rather than quotes so error
	mov		ax, [di]
	call 	BIOS_put_char				;output each character between the quotes
	jmp		.fs1
.fs2:
	inc		di							;skip 2nd set of quotes
	mov 	word [inpoint], di			;store pointer to where we are in input buffer
	jmp		.any_more


.fernOS_wait:							;WAITn = pause n seconds (roughly)
	mov		bl, [di]					;check how long to wait
	sub		bl, '0'						;convert char input to int
	cmp		bl, 0						;if no valid wait time then skip to next command
	jle		.any_more
	cmp		bl, 9						;if no valid wait time then skip to next command
	jg		.any_more
	inc		di							;move past wait time
	mov 	word [inpoint], di			;store pointer to where we are in input buffer
	mov		bh, 0
.fw1:
	call	BIOS_get_time
	mov		ax, dx						;check changes to lower tics
	mov		dx, 0						;ignore upper set of tics
	mov		cx, 10
	div		cx							;remainder goes to dx (the lowest digit of system time)
	cmp		dx, bx						;so count every 10 tics (roughly)
	jne		.fw1
	dec		bx
	cmp		bx, 0
	jg		.fw1
	jmp		.any_more


;Welcome splash and prompt
	bootmsg	db ASCII_LF, ASCII_CR, "fernOS v0.0.3 x86 version", ASCII_LF, ASCII_CR
			db "======", ASCII_LF, ASCII_CR
			db "boot", ASCII_LF, ASCII_CR
			db "help", ASCII_LF, ASCII_CR
			db "say", ASCII_DQ, "hi", ASCII_DQ, " = display hi to screen", ASCII_LF, ASCII_CR
			db "waitn = pause n seconds", ASCII_LF, ASCII_CR, ASCII_NL
	prompt	db ASCII_LF, ASCII_CR, "fernOS>", ASCII_NL

;Commands:	[relies on previous null and being followed by synterr]
	cmdlist	db "BOOT", ASCII_NL, "HELP", ASCII_NL, "SAY", ASCII_NL, "WAIT", ASCII_NL

;Error messages:
	synterr db ASCII_LF, ASCII_CR, "You wot? ", ASCII_NL

;Backspace delete sequence:
	bs_str	db ASCII_BS, ASCII_SP, ASCII_BS, ASCII_NL

;new line sequence:
	nl_str	db ASCII_LF, ASCII_CR, ASCII_NL

	%include "fernOS_BIOS_library.asm"
	%include "fernOS_UTIL_library.asm"

section .bss							;changeable data section
	stringbuf	resb 4					;general purpose
	inputbuf	resb 80					;command line input
	inpoint		resb 2					;pointer to input buffer

section .text							;protected code section
	times	510-($-$$) db 0				;pad remainder of 512 bootloader with nulls
	dw		0AA55h						;valid boot block signature
