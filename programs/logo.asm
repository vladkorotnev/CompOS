; ------------------------------------------------------------------
; Program to display text files and PCX images (320x200, 8-bit only)
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "mikedev.inc"
	ORG 32768


main_start:
	mov bx, filename			; Save filename for now

	mov di, filename

	jmp valid_pcx_extension

valid_pcx_extension:
	mov ax, bx
	mov cx, 36864			; Load PCX at 36864 (4K after program start)
	call os_load_file


	mov ah, 0			; Switch to graphics mode
	mov al, 13h
	int 10h


	mov ax, 0A000h			; ES = video memory
	mov es, ax


	mov si, 36864+80h		; Move source to start of image data
					; (First 80h bytes is header)

	mov di, 0			; Start our loop at top of video RAM

decode:
	mov cx, 1
	lodsb
	cmp al, 192			; Single pixel or string?
	jb single
	and al, 63			; String, so 'mod 64' it
	mov cl, al			; Result in CL for following 'rep'
	lodsb				; Get byte to put on screen
single:
	rep stosb			; And show it (or all of them)
	cmp di, 64001
	jb decode


	mov dx, 3c8h			; Palette index register
	mov al, 0			; Start at colour 0
	out dx, al			; Tell VGA controller that...
	inc dx				; ...3c9h = palette data register

	mov cx, 768			; 256 colours, 3 bytes each
setpal:
	lodsb				; Grab the next byte.
	shr al, 2			; Palettes divided by 4, so undo
	out dx, al			; Send to VGA controller
	loop setpal


	mov ax, 30
	call os_pause

	mov ax, 3			; Back to text mode
	mov bx, 0
	int 10h
	mov ax, 1003h			; No blinking text!
	int 10h

	mov ax, 2000h			; Reset ES back to original value
	mov es, ax
	call os_clear_screen
	jmp close



close:
	call os_clear_screen
	ret

	filename	db 'LOGO.PCX', 0

	skiplines	dw 0


; ------------------------------------------------------------------

