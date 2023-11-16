org 100h

jmp code

data:
    prompt db "Input has a Palindrome Word!", 0xA, 0xD
    promptLEN equ $-prompt
    noPalin db "Input does not have Palindrome!", 0xA, 0xD
    noPalinLEN equ $-noPalin

bss:
    userSTR db 101 DUP (?)
    userWORD db 11 DUP (?)
    
code:
    
    mov al, 03h         ; 80x25 color text mode
    mov ah, 0           ; syscall to set video mode
    int 10h

    mov ax, 1003h       ; syscall to toggle intesity/blinking
    mov bx, 0           ; disable blinking. 
    int 10h

    mov dh, 0           ; the row to print in
    mov dl, 0           ; the coloumn to print in
    mov ah, 2           ; syscall to set cursor position
    int 10h
    
    mov cx, 100
    lea bx, userSTR
    
    mov dx, 0
    mov ah, 0x02
    int 10h
    
    userINP:
        call getINP
        cmp al, 0x0D        ; comparing the input to the enter key
        je done             ; if the input is the enter key, jump to done
        cmp al, 0x8
        jne norm
        dec bx
        jmp userINP
        norm:
        mov [bx], al
        inc bx
        loop userINP
    
    done:
        mov [bx+1], 0       ; adding null terminator at the end
        lea si, userSTR
        repeat:
            lea di, userWORD
            cmp [si], 0x0
            je  checkBAD
            call getWORD
            inc si
            dec di
            lea bx, userWORD
            mov al, [bx]
            cmp al, [di]
            lea cx, userWORD
            je firstPASS
            jmp repeat
        
    firstPASS:
        inc bx
        dec di
        mov al, [bx]
        cmp al, [di]
        jne  repeat
        cmp di, cx
        jne firstPASS
        
    
    checkGOOD:
        mov ax, offset prompt
        mov bx, promptLEN
        call printSTR
        jmp fin    
        
        
    checkBAD:
        mov ax, offset noPalin
        mov bx, noPalinLEN
        call printSTR
        
    fin:
        ret
    
    
    getWORD proc
        cmp [si], 0x20
        je goBack
        cmp [si], 0x0
        je goBack
        mov dx, [si]
        mov [di], dx
        inc si
        inc di
        jmp getWORD
        goBack:
        ret
        endp
    
    
    printSTR proc
        push bx         ; push bx to top of stack
        pop cx          ; pop top of stack into cx
        push ax         ; push ax to top of stack
        pop bp          ; pop top of stack into bp
        mov al, 01b     ; to increment the cursor position after printing
        mov bh, 0       ; set page number to 0
        mov bl, 00001111b
        ; First 4 bits are the background color, last 4 bits are the foreground color
        ; 0000/0x00 - Black, 1111/0x0F - White
        push cs         ; push cs to top of stack
        pop es          ; pop top of stack into es
        mov ah, 13h     ; syscall to print string
        int 10h
        ret             ; return to the calling procedure
        endp            ; end procedure


    getINP proc         ; procedure to get input
        mov ah, 00h     ; syscall to get input
        int 16h         ; interrupt 16h
        call printCHAR
        ret             ; return to the calling procedure
        endp            ; end procedure
            
    printCHAR proc
        mov ah, 0x0E
        int 10h
        cmp al, 0x8
        jne noBack
        mov al, 0x20
        mov ah, 0x0Eh
        int 10h
        mov al, 0x8
        mov ah, 0x0E
        int 10h
        noBack:
        ret
        endp