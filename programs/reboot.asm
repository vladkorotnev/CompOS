
	BITS 16
	%INCLUDE "mikedev.inc"
	ORG 32768

start:
	mov al, 0xFE
	out 0x64, al
