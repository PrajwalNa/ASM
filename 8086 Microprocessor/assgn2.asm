; Dev: Prajwal Nautiyal
; Assignment 2

; macroName macro [localVariable]
setCol macro len
    mov dl, len     ; set the column number
    inc dl          ; increment the column number
    mov ah, 0x2     ; set the cursor position
    int 10h
    endm

org 100h

jmp code

data:
    setKEY db 0     ; variable to store the temporary key
    
    ; different strings to be printed
    entry db "Enter a message (max 25 chars): ", 0
    entryLen equ $-entry
    
    cipher db "Cipher Text: ", 0
    cipherLen equ $-cipher
    
    decrypt db "Decrypted Text: ", 0
    decryptLen equ $-decrypt
    
    userIN db 26 DUP (0)        ; 25 max chars + 1 for null terminator
    usrLEN dw 0                 ; variable to store the length of the user input
    encrypted db 26 DUP (0)     ; 25 max chars + 1 for null terminator
    decrypted db 26 DUP (0)     ; 25 max chars + 1 for null terminator
    
code:
    ; setting the cursor position
    mov dx, 0
    mov ah, 0x02
    int 10h
    
    ; printing the entry prompt string
    mov ax, offset entry
    mov bx, entryLen
    call printSTR
    
    mov cx, 25
    lea si, userIN
    Input:
        call getINP
        cmp al, 0x0D        ; comparing the input to the enter key
        je done             ; if the input is the enter key, jump to done
        cmp al, 0x8         ; comparing the input with backspace
        jne norm            ; if no backspace continue normal execution
        dec si              ; else decrease the si pointer
        jmp Input           ; and jump to Input
        norm:
        mov [si], al        ; store the input in the userIN array
        inc si              ; increment the si pointer
        inc usrLEN          ; increment the length counter of the user input
        loop Input          ; loop until cx is 0
        
    done:
        call incROW         ; increment the row number
        lea si, userIN      ; load the first address of userIN array into si
        lea di, encrypted   ; load the first address of encrypted array into di
        mov cx, usrLEN      ; load the length of the user input into cx
        cmp [si], 0x4D      ; compare the first character of the user input with '
        jne key53           ; if not equal jump to key53
        mov setKEY, 25      ; else set the key to 25
        jmp KeySet          ; jump to KeySet
        key53: 
        mov setKEY, 53      ; set the key to 53 and fall through to KeySet
    
    KeySet:
    key equ setKEY          ; set the key constant to the value of setKEY, can be done in data section as well
    ; I did it here for convinience in understanding
    call convText           ; call the convText procedure to encrypt the user input
        
    mov ax, offset cipher   ; mov to ax the first address of cipher string prompt
    mov bx, cipherLen       ; mov to bx the length of the cipher string
    call printSTR           ; call the printSTR procedure to print the cipher string
    setCol cipherLen        ; set the column to adjust the cursor position to be after the cipher string
    
    mov ax, offset encrypted    ; mov to ax the first address of encrypted string
    mov bx, usrLEN              ; mov to bx the length of the user input
    call printSTR               ; call the printSTR procedure to print the encrypted string
    call incROW                 ; call the incROW procedure to increment the row number, move to new line
    
    lea si, encrypted       ; load the first address of encrypted array into si
    lea di, decrypted       ; load the first address of decrypted array into di
    mov cx, usrLEN          ; load the length of the user input into cx
    call convText           ; call the convText procedure to decrypt the user input
    
    mov ax, offset decrypt  ; mov to ax the first address of decrypt string prompt
    mov bx, decryptLen      ; mov to bx the length of the decrypt string
    call printSTR           ; call the printSTR procedure to print the decrypt string
    setCol decryptLen       ; set the column to adjust the cursor position to be after the decrypt string
    
    mov ax, offset decrypted    ; mov to ax the first address of decrypted string
    mov bx, usrLEN              ; mov to bx the length of the user input
    call printSTR               ; call the printSTR procedure to print the decrypted string
    ret                     ; return to the operating system              
    
    convText proc
        mov al, [si]        ; load the a character from the user input into al
        xor al, key         ; xor the character with the key
        mov [di], al        ; store the result in the destination array
        inc si              ; inc si to point to the next character in the user input
        inc di              ; inc di to point to the next character in the destination array
        loop convText       ; loop until cx is 0
        ret                 
        endp 
        
        
    printSTR proc
        mov cx, bx      ; mov to cx the length of the string
        mov bp, ax      ; mov to bp the first address of the string
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
        ; so basicaly if someone pressed backspace, the first instruction will move the cursor position back one column
        ; which will the character user wants removed, then after the comparisom
        ; it will print space in that position, then move the cursor back one column again
        ; to compensate for teletype output as it increments the cursor position after printing
        ; so backspace -> character replaced by space -> backspace again to bring print cursor to now empty space
        ; abcd<backspace> -> abc<space replaced 'd'>[cursor after space] -> abc[cursor on space]
        noBack:
        ret
        endp
        
    incROW proc
        inc dh          ; increment the row number
        mov dl, 0       ; set the column number to 0
        mov ah, 0x2     ; set the cursor position
        int 10h
        ret
        endp