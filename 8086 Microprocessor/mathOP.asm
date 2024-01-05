; Prajwal Nautiyal
; assgn 1
; conduct a mathematical expression using assembly language and display the result on the screen

; a = 235,b = 138,c = 9935,d = 136

org 100h

jmp .text   
     
.data:
    a   db 235
    b   db 138
    c   dw 9935
    d   db 136
    msg db "The expression (235 * 138) - (9935 / 136):"
    len equ $ - offset msg

.bss:    
    result  dw ?
    temp    dw ?
    resASCII  db 6 DUP (?)
   
.text:  
    ; (a*b) - (c/d)
    mov     al, a               ; moving a to al for mul
    mul     b                   ; multplying value in al and b - a*b result: ax
    mov     [temp], ax          ; moving the 16 bit product to temporary var (2 byte)
    mov     ax, 9935            ; moving value of c into ax for division
    div     d                   ; dividing value of ax with d - c/d  quotient: al, remainder: ah 
    mov     bx, temp            ; moving the product of a & b into bx for processing 
    
    xor     temp, bx            ; clearing value in temp to avoid conflicts with the new one
    mov     byte ptr [temp], al 
    ; moving 8 bit value to 16 bit variable
    ; so using byte ptr and only utilising the first byte
    ; the whole data movement operation was carried out due to conflicts 
    ; in operating a 16 bit register (bx) with an 8 bit register (al)
    sub     bx, temp            ; bx (a*b) - temp (c/d) result: bx
    mov     [result], bx        ; moving the value after substraction to the memory address of result
    
    mov     al, 03h             ; setting video mode to text mode 80x25, 16 Colours, 0-7 pages
    mov     ah, 0               ; syscall
    int     10h                 ; bios interrupt
    
    mov     dh, 0               ; set cursor's row to 0
    mov     dl, 0               ; set cursor's column to 0
    mov     bh, 0               ; set screen page to 0
    mov     ah, 2               ; syscall
    int     10h                 ; bios interrupt
    
    mov     al, 01b             ; bit 0: does the string has attributes?
                                ; bit 1: do you want to increment the cursor after writing
    mov     bl, 0x0A            ; set graphical attributes for writing
                                ; 0x0 - high 4 bits: background [black]
                                ; 0xA - low 4 bits: foreground [green] 
    mov     cx, len             ; num of characters to print
    push    cs                  ; save the Code Segment register value to the stack.                            
    pop     es
    ; pop the top of the stack into the Extra Segment register.
    ; now ES points to our code segment.
    mov     bp, offset msg     
    ; set BP (base pointer) to the offset of msg within its segment.
    ; now ES:BP points to the start of msg1.
    mov     ah, 13h
    int     10h
    
    mov     bh, 0
    mov     ah, 03h             ; retrieving current position of cursor dh=row, dl=coloumn
    int     10h
    
    mov     cx, dx              ; backup cursor position
    
    mov ax, result              ; load result into ax
    mov bx, 10                  ; divisor for conversion to ascii
    lea si, [resASCII+5]        ; point si to end of resASCII, so it starts insert from end

    convert:
        xor     dx, dx          ; clear dx for division
        div     bx              ; divide ax by 10, quotient in ax, remainder in dx
        ; dividing by 10 to separate the digits of the result: 
        ; 32357/10 = 3235, remainder = 7
        ; 3235/10 = 323, remainder = 5
        ; 323/10 = 32, remainder = 3
        ; 32/10 = 3, remainder = 2
        ; 3/10 = 0, remainder = 3
        ; so the result is 3 2 3 5 7 spilt with the loop
        ; and since we are inserting from the end, the order is perfect
        add     dl, '0'         ; convert remainder to ascii
        ; 7 + '0' = 0x7 + 0x30 = 0x37 = '7'
        ; 5 + '0' = 0x5 + 0x30 = 0x35 = '5'
        ; 3 + '0' = 0x3 + 0x30 = 0x33 = '3'
        ; 2 + '0' = 0x2 + 0x30 = 0x32 = '2'
        ; 3 + '0' = 0x3 + 0x30 = 0x33 = '3'
        ; so the result is "3", "2", "3", "5", "7" stored in resASCII with the loop
        dec     si              ; move si to one position closer to beginning in resASCII
        mov     [si], dl        ; store character in resASCII
        test    ax, ax          ; check if quotient is zero
        jnz     convert         ; if not, repeat conversion

    mov     dx, cx              ; restore cusor position
    mov     ah, 2
    int     10h
    
    ; configurations same as above
    mov     al, 01b         
    mov     bl, 0xA
    mov     cx, 5               ; I know the result is 5 characters
    push    cs
    pop     es
    mov     bp, offset resASCII
    mov     ah, 13h
    int     10h

    mov ah, 0h                  ; syscall for waiting a keypress
    int 16h                     ; interrupt to wait for keypress

ret ; return control to operating system // can also use int 20h    