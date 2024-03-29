;--------------------------------------------------------------------
;					fernOS_BIOS_library
;	x86 assembly code BIOS calling utilities for fernOS
;					www.benningtons.net
;--------------------------------------------------------------------
;
;INTERRUPTS USED:
;	Int		AH		AL		Description
;	10		00		option	Set video mode
;	10		0E		ASCII	Video Teletype Output
;	16		00		ASCII	Keyboard Get Keystroke
;	1A		00		flag	Get system time
;	19						System bootstrap loader
;
;LIST OF FUNCTIONS:
;	BIOS_boot				Boot the PC
;	BIOS_get_keystroke		Get keystroke from keyboard
;	BIOS_get_time			Get system time
;	BIOS_put_char			Output character to screen
;	BIOS_put_string			Output string to screen
;	BIOS_set_video			Set video mode


BIOS_boot:
;--------------------------------------------------------------------
;Boot the PC by calling the bootstrap loader
;In: none Out: none Destroyed: none
;--------------------------------------------------------------------

	int		19h							;call bios bootstrap loader
	ret


BIOS_get_keystroke:
;--------------------------------------------------------------------
;Get keystroke from keyboard
;In: none Out: al Destroyed: ah
;	Out: al=ascii character (default null)
;--------------------------------------------------------------------

	mov		ah, 00h						;set upper byte of ax ready for get_keystoke bios call
	mov		al, 00h						;set lower byte to null default		#TODO do I need to initialise?
	int		16h							;call bios to get keystroke
	ret


BIOS_get_time:
;--------------------------------------------------------------------
;Get system time
;In: none Out: cx:dx, al Destroyed: ah
;	Out: cx:dx = clock ticks since midnight, al=midnight flag
;--------------------------------------------------------------------

	mov		ah, 00h						;set upper byte of ax ready for bios call
	int		1Ah							;call bios to get system time
	ret


BIOS_put_char:
;--------------------------------------------------------------------
;Output character to screen
;In: al output Out: none Destroyed: ah
;	In: al=ascii character to output
;--------------------------------------------------------------------

	mov		ah, 0Eh						;set upper byte of ax ready for teletype_output bios call
	int		10h							;call bios to output ascii char in al to screen
	ret


BIOS_put_string:
;--------------------------------------------------------------------
;Output string to screen
;In: si, bl Out: none Destroyed: ax
;	In: si=pointer to a null terminated string, bl=text colour
;--------------------------------------------------------------------

	mov		ah, 0Eh						;set upper byte of ax ready for bios call

.loop:
	lodsb								;step through string, incrementing si and loading char into al
	cmp		al, 0						;test lower byte of ax
	je		.end						;reached null yet?
	int		10h							;call bios to output char
	jmp		.loop						;next char

.end:
	ret


BIOS_set_video:
;--------------------------------------------------------------------
;Set video mode
;In: al Out: none Destroyed: ah
;	In: al=video mode setting (full list at http://www.ctyme.com/intr/rb-0069.htm#Table10)
;		  screen char  resolution  colours
;	0Dh = 40x25  8x8   320x200      16       8   A000 EGA,VGA
;	0Eh = 80x25  8x8   640x200      16       4   A000 EGA,VGA
;--------------------------------------------------------------------

	mov		ah, 0						;clear upper byte of ax
	int		10h							;call bios to set video mode
	ret

