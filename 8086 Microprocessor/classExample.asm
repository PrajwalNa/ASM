; Prajwal Nautiyal
; 07 November 2023

; Simple program to get a string of letters from the user and flip the case of the letters
; learnt how to push into and take values from stack
; and how to use the address to access the value stored in the address using lea/offset

org 100h

jmp code

data:
    prompt db "Enter a string of letters, max 15 letters: ", 0
    promptLen equ $-prompt
    promptERR db "Invalid Entry!! try again: ", 0
    promptErrLen equ $-promptERR

bss:
    userIN db 15 dup (?)
    userMOD db 16 dup (?)
    count dw ?
    
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
    
    mov ax, offset prompt       ; the physical address of the string/array to print in ax   
    mov bx, promptLen           ; the length of the string/array to print in bx
    call printSTR               ; calling the print string procedure
    mov bx, offset userIN       ; the physical address of the array to store the user input in bx
    mov dx, 0                   ; the counter to count the number of characters entered
    
    userINP:
    call getINP         ; calling the get input procedure
    cmp al, 0x0D        ; comparing the input to the enter key
    je done             ; if the input is the enter key, jump to done
    call checkINP       ; calling the check input procedure
    cmp al, 0xAA        ; comparing the input to the invalid input
    jne carryON         ; if the input is valid, jump to carryON

    inc dh              ; incrementing the row
    mov dl, 0           ; reseting the coloumn
    mov ah, 2           ; syscall to set cursor position
    int 10h

    mov ax, offset promptERR    ; the physical address of the string/array to print in ax
    mov bx, promptErrLen        ; the length of the string/array to print in bx          
    call printSTR               ; calling the print string procedure
    lea bx, userIN              ; resetting bx to point to the first index address of userIN
    jmp userINP                 ; jump to userINP to get input again
    
    carryON:                    ; if the input is valid, carry on
    xor ah, ah                  ; clearing ah
    mov [bx], ax                ; storing the input in the array
    cmp bx, offset userIN+14    ; comparing the index to the last index of the array
    je done                     ; if the index is the last index, jump to done
    inc bx                      ; incrementing the index address pointer
    inc dx                      ; incrementing the counter
    jmp userINP                 ; jump to userINP to get input for the next index
    
    done:                       ; if the input is the enter key or 15 characters have been entered, the input receiving is done
    mov count, dx               ; storing the number of characters entered in count variable  
    call conv                   ; calling the convert procedure
    inc bx                      ; incrementing the index address pointer
    mov [bx], 0                 ; storing the null terminator in the last index of the array
    mov dl, 0                   ; reseting the coloumn
    mov dh, 2                   ; incrementing the row
    mov ah, 2                   ; syscall to set cursor position
    int 10h                     
    mov bx, count               ; storing the number of characters entered in bx
    mov ax, offset userMOD      ; the physical address of the array to print in ax
    call printSTR               ; calling the print string procedure
    ret                         ; return to the operating system
    
    
    getINP proc         ; procedure to get input
        mov ah, 00h     ; syscall to get input
        int 16h         ; interrupt 16h
        ret             ; return to the calling procedure
        endp            ; end procedure
    
    checkINP proc       ; procedure to check input
        cmp al, 0x20    ; comparing the input to the space character
        je  good        ; if the input is the space character, jump to good
        cmp al, 0x61    ; comparing the input to the lower case a
        jl  up          ; if the input is less than the lower case a, jump to up
        cmp al, 0x7A    ; comparing the input to the lower case z
        jg  bad         ; if the input is greater than the lower case z, jump to bad
        jmp good        ; jump to good since the input is between the lower case a and z
        
        up:                 ; check if the input is between the upper case A and Z
            cmp al, 0x41    ; comparing the input to the upper case A
            jl bad          ; if the input is less than the upper case A, jump to bad
            cmp al, 0x5A    ; comparing the input to the upper case Z
            jg bad          ; if the input is greater than the upper case Z, jump to bad
            jmp good        ; jmp to good since the input is between the upper case A and Z
            
        bad:
            mov al, 0xAA    ; storing the invalid input in al
            ret             ; return to the calling procedure
               
        good:
            ret             ; return to the calling procedure
            
        endp                ; end procedure
        
    conv proc           ; procedure to convert the input to upper case
        push dx         ; push dx to top of stack
        pop cx          ; pop top of stack into cx
        lea si, userIN  ; load the address of userIN into si
        lea bx, userMOD ; load the address of userMOD into bx
        do:             ; do while loop
        mov dx, [si]    ; move the value of si into dx, dx = *si
        cmp dl, 0x20    ; compare the value of dl to the space character
        je  skip        ; if the value of dl is the space character, jump to skip
        cmp dl, 0x61    ; compare the value of dl to the lower case a
        jl  upper       ; if the value of dl is less than the lower case a, jump to upper
        sub dx, 0x20    ; subtract 0x20 from the value of dx, dx = dx - 0x20 to convert to upper case
        mov [bx], dx    ; move the value of dx into the address of bx, &bx = dx
        jmp afterUP     ; jump to afterUP
        upper:          ; to convert the upper case input to lower case 
        add dx, 0x20    ; add 0x20 to the value of dx, dx = dx + 0x20 to convert to lower case
        mov [bx], dx    ; move the value of dx into the address of bx, &bx = dx
        ; one line instruction to move space character to the address of bx in userMOD array
        skip:   mov [bx], dx
        afterUP:        ; after input case conversion
        inc bx          ; increment the address of bx
        inc si          ; increment the address of si
        loop do         ; loop while cx != 0
        ret             ; return to the calling procedure
        endp            ; end procedure
        
        
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
        int 10h         ; interrupt 10h
        ret             ; return to the calling procedure
        endp            ; end procedure