;-------------------------------------------------------------------
;					fernOS_UTIL_library
;	x86 assembly code general utilities for fernOS
;					www.benningtons.net
;-------------------------------------------------------------------
;
;LIST OF FUNCTIONS:
;	UTIL_num_to_str		Convert a number into an ASCII string
;	UTIL_str_cmp		Compare two strings
;	UTIL_upper			Convert a char to uppercase


;UTIL_num_to_str:
;-------------------------------------------------------------------
;Convert a number into an ASCII string
; currently commented out to fit fernOS into the bootloader but was useful for debugging
;In: ax, di Out: [di] Destroyed: none
;	In: ax=number to convert, di=pointer to output string
;	Out: [di] memory
;-------------------------------------------------------------------

;	%include "fe_ascii.hsm"		; ASCII definitions

;	pusha								;preserve registers
;	mov		bx, 10						;Base of the decimal system
;	mov		cx, 0						;Number of digits generated

;.divloop:
; 	mov		dx, 0						;will divide dx:ax so initialise and the remainder will be stored in dx
;	div		bx							;Divide ax by the number-base
;	push	dx							;Save remainder on the stack
;	inc		cx							;And count this remainder
;	cmp		ax, 0						;Was the quotient zero?
;	jne		.divloop					;No, do another division

;.outloop:
;	pop		ax							;Else pop recent remainder
;	add		al, '0'						;And convert to a numeral
;	stosb								;Store to memory-buffer
;	loop	.outloop					;Again for other remainders [if(--cx.ne.0) goto .outloop]

;	mov		al, ASCII_NL				;null terminate string
;	stosb

;	popa								;recover registers
;	ret


UTIL_str_cmp:
;-------------------------------------------------------------------
;Compare two strings
;In: si, di Out: ax Destroyed: (si-1), di
;	In: si=pointer to string1, di=pointer to string2
;	Out: ax=-1 (s1<s2), ax=0 (match), ax=1 (s1>s2)
;	Destroyed: (si-1) and di left pointing to 1st mismatch or end of strings
;-------------------------------------------------------------------

	%include "fe_ascii.hsm"		; ASCII definitions

.loop:
	lodsb								;move [si] into ax and inc si
	cmp		al, ASCII_NL				;reached end of s1 and still matching so a match (even though there may be more to s2
	je		.a_match
	cmp 	al, [di]					;else compare char from each string
	jl		.less_than
	jg		.greater_than
	inc		di							;test next char
	jmp		.loop

.less_than:
	mov		ax, -1
	ret

.greater_than:
	mov		ax, 1
	ret

.a_match:
	mov		ax, 0						;actually ax is already ascii null
	ret


UTIL_upper:
;-------------------------------------------------------------------
;Convert a char to uppercase
;In: al Out: al Destroyed: none
;	In: al=ASCII char to convert
;	Out: al=uppercase ASCII char
;-------------------------------------------------------------------

	cmp		al, 'a'
	jl		.end					;below ASCII 'a' so no conversion applied
	cmp		al, 'z'
	jg		.end					;above ASCII 'z' so no conversion applied
	sub		al, 32					;convert a lowercase letter to uppercase
.end:
	ret
