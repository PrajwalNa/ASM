; Dev: Prajwal Nautiyal

org 100h

jmp code

data:
    prompt db "Input has a Palindrome Word!", 0xA, 0xD
    promptLEN equ $-prompt
    noPalin db "Input does not have Palindrome!", 0xA, 0xD
    noPalinLEN equ $-noPalin

bss:
    userSTR db 101 DUP (?)  ; 100 characters + 1 null terminator
    userWORD db 11 DUP (?)  ; 10 characters + 1 null terminator
    
code:
    mov cx, 100
    lea bx, userSTR

    ; setting the cursor position to 0,0
    mov dx, 0
    mov ah, 0x02
    int 10h
    
    userINP:
        call getINP
        cmp al, 0x0D        ; comparing the input to the enter key
        je done             ; if the input is the enter key, jump to done
        cmp al, 0x8         ; compare input to backspace key
        jne norm            ; if above condition is false, jump to norm
        dec bx              ; else decrement bx to point to the character to be replaced
        jmp userINP         ; jump back up to userINP
        norm:               ; normal execution
        mov [bx], al        ; save the input into the index pointed by bx
        inc bx              ; increment bx to point to the next index
        loop userINP        ; loop back up to userINP until cx is 0
    
    done:
        mov [bx+1], 0           ; adding null terminator at the end of input
        lea si, userSTR         ; load the first address of userSTR into si [source string -> source index]
        repeat:
            lea di, userWORD    ; load the first address of userWORD into di [destination string -> destination index]
            cmp [si], 0x0       ; comparing the character at the index pointed by si to null terminator
            je  checkBAD        ; if the character is null terminator, jump to checkBAD
            call getWORD        ; else call getWORD
            inc si              ; increment si to point to the next character
            dec di              ; decrement di to point to the last character of userWORD
            lea bx, userWORD    ; load the first address of userWORD into bx
            mov al, [bx]        ; mov first character of userWORD to al
            cmp al, [di]        ; comparing the first character of userWORD to the last character of userWORD
            lea cx, userWORD    ; load the first address of userWORD into cx
            je firstPASS        ; if the first character is equal to the last character, jump to firstPASS
            jmp repeat          ; else jump back up to repeat
        
    firstPASS:
        inc bx              ; increment bx to point to the next character forward
        dec di              ; decrement di to point to the next character backward
        mov al, [bx]        ; move the character pointed by bx to al
        cmp al, [di]        ; comparing the character pointed by bx to the character pointed by di
        jne  repeat         ; if the characters are not equal, jump to repeat, else continue
        cmp di, cx          ; comparing di to cx, i.e. checking if di traversed the whole string, which would me that the string is a palindrome
        jne firstPASS       ; if di has not traversed the whole string, jump to firstPASS, else fall through into checkGOOD
        
    
    checkGOOD:
        mov ax, offset prompt   ; move the address of prompt to ax
        mov bx, promptLEN       ; move the length of prompt to bx
        call printSTR           ; call printSTR
        jmp fin                 ; jump to fin
        
        
    checkBAD:
        mov ax, offset noPalin  ; move the address of noPalin to ax
        mov bx, noPalinLEN      ; move the length of noPalin to bx
        call printSTR           ; call printSTR
        
    fin:
        ret
    
    
    getWORD proc
        cmp [si], 0x20      ; comparing the character at the index pointed by si to space
        je goBack           ; if the character is space, jump to goBack, else continue
        cmp [si], 0x0       ; comparing the character at the index pointed by si to null terminator
        je goBack           ; if the character is null terminator, jump to goBack, else continue
        mov dx, [si]        ; move one character from the string pointed by si to dx
        mov [di], dx        ; move the character from dx to the string pointed by di
        inc si              ; increment si to point to the next character
        inc di              ; increment di to point to the next character
        jmp getWORD         ; jump back up to getWORD
        goBack:
        ret
        endp
    
    
    printSTR proc
        mov bp, ax      ; move ax to bp
        mov cx, bx      ; move bx to cx
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
        mov ah, 0x0E    ; syscall to print character in al using teletype output
        int 10h
        cmp al, 0x8     ; comparing the input to the backspace key
        jne noBack      ; if the input is not the backspace key, jump to noBack
        mov al, 0x20    ; else move space to al
        mov ah, 0x0Eh   ; print space
        int 10h
        mov al, 0x8     ; move backspace to al
        mov ah, 0x0E    ; print backspace, basically moving the cursor back one column
        int 10h
        ; abcd<backspace> -> abc<space replaced 'd'>[cursor after space] -> abc[cursor on space]
        noBack:
        ret
        endp