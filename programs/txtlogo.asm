; ------------------------------------------------------------------
; Program to display logo
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "mikedev.inc"
	ORG 32768


main_start:
	call draw_background

	; call os_file_selector		; Get filename

	; jc near close			; Quit if Esc pressed in dialog box

	mov bx, filename			; Save filename for now

	mov di, filename

	call os_hide_cursor
	jmp valid_txt_extension	; Skip ahead if so

setpal:
	lodsb				; Grab the next byte.
	shr al, 2			; Palettes divided by 4, so undo
	out dx, al			; Send to VGA controller
	loop setpal


	call os_wait_for_key

	mov ax, 3			; Back to text mode
	mov bx, 0
	int 10h
	mov ax, 1003h			; No blinking text!
	int 10h

	mov ax, 2000h			; Reset ES back to original value
	mov es, ax
	call os_clear_screen
	jmp main_start


draw_background:
	mov ax, title_msg		; Set up screen
	mov bx, footer_msg
	mov cx, WHITE_ON_BLACK
	call os_draw_background
	ret



	; Meanwhile, if it's a text file...

valid_txt_extension:
	mov ax, bx
	mov cx, 36864			; Load file 4K after program start
	call os_load_file


	; Now BX contains the number of bytes in the file, so let's add
	; the load offset to get the last byte of the file in RAM

	add bx, 36864


	mov cx, 0			; Lines to skip when rendering
	mov word [skiplines], 0


	pusha
	mov ax, txt_title_msg		; Set up screen
	mov bx, txt_footer_msg
	mov cx, WHITE_ON_BLACK	; Black text on white background
	call os_draw_background
	popa



txt_start:
	pusha

	mov bl, WHITE_ON_BLACK		; Black text on white background
	mov dh, 2
	mov dl, 0
	mov si, 80
	mov di, 23
	call os_draw_block		; Overwrite old text for scrolling

	mov dh, 2			; Move cursor to near top
	mov dl, 0
	call os_move_cursor

	popa


	mov si, 36864			; Start of text data
	mov ah, 0Eh			; BIOS char printing routine


redraw:
	cmp cx, 0			; How many lines to skip?
	je loopy
	dec cx

skip_loop:
	lodsb				; Read bytes until newline, to skip a line
	cmp al, 10
	jne skip_loop
	jmp redraw


loopy:
	lodsb				; Get character from file data

	cmp al, 10			; Return to start of line if carriage return character
	jne skip_return
	call os_get_cursor_pos
	mov dl, 0
	call os_move_cursor

skip_return:
	int 10h				; Print the character

	cmp si, bx			; Have we printed all in the file?
	je finished

	call os_get_cursor_pos		; Are we at the bottom of the display area?
	cmp dh, 23
	je get_input

	jmp loopy


get_input:				; Get cursor keys and Q
	; call os_wait_for_key
	; cmp al, 'q'
	; je close
	; cmp al, 'Q'
	; je close
	; jmp get_input

	; Halt execution for 3 secs

	mov ax, 30
	call os_pause
	jmp close


finished:				; We get here when we've printed the final character
	mov ax, 30
	call os_pause
	jmp close

close:
	call os_clear_screen
	ret

	filename	db 'LOGO.TXT', 0
	txt_extension	db 'TXT', 0
	pcx_extension	db 'PCX', 0

	err_string	db 'Please select a .TXT or .PCX file!', 0

	title_msg	db 'CompOS File Viewer', 0
	footer_msg	db 'Select a .TXT or .PCX file to view, or press Esc to exit', 0

	txt_title_msg	db 'Welcome to CompOS!', 0
	txt_footer_msg	db 'Booting, please wait... ', 0

	skiplines	dw 0


; ------------------------------------------------------------------

