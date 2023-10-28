;Hello World
;Dev: Prajwal Nautiyal
;Date: 12 August, 2023

; entry point for the program
global _start

; variable definitions go here
section .data:
	message: db "Hello World!", 0xA
	message_length: equ $-message

; the code goes here
section .text:
_start:
	mov eax, 4            	; the syscall for write command
	mov ebx, 1              ; use stdout as the file descriptor
	mov ecx, message        ; use message as the buffer
	mov edx, message_length ; supplying the length
	int 0x80		; calling kernel

	mov eax, 1		; invoke exit syscall
	mov ebx, 0		; exit with code 0
	int 0x80

