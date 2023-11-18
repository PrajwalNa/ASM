; Dev: Prajwal Nautiyal

; macroName macro [localVariable]
setCol macro len
    mov dl, len     ; set the column number
    inc dl          ; increment the column number
    mov ah, 0x2     ; set the cursor position
    int 10h
    endm

org 100h

jmp code

; variable declaration
; ---------------------
data:
    ; some predefined strings to be printed
    entry db "Enter a String: ", 0
    entryLEN equ $-entry
    
    prompt db "Number of palindrome Words in the input: ", 0xA, 0xD
    promptLEN equ $-prompt
    
    noPalin db "Input does not have any Palindrome!", 0xA, 0xD
    noPalinLEN equ $-noPalin
    
    palinPrompt db "Palindromes found: "
    palinLEN equ $-palinPrompt
    
    userSTR db 101 DUP (0)  ; 100 characters + 1 null terminator, for storing the user input
    userWORD db 11 DUP (0)  ; 10 characters + 1 null terminator, for storing the word extracted in the user input
    
    counter dw 0x3030       ; 0x3030 is the ascii value of 00, which is the number 0
    palins db 101 DUP (0)   ; 100 characters + 1 null terminator, for storing the palindromes found
    palinsPos dw 0          ; variable for storing the position of the next character to be written in palins


; the main working part of the program
; -------------------------------------    
code:
    ; setting the cursor position to 0,0
    mov dx, 0
    mov ah, 0x02
    int 10h
    
    ; printing the entry prompt
    mov ax, offset entry
    mov bx, entryLEN
    call printSTR
    
    ; loading address of palins into palinsPos to set to the beginning of palins array
    mov palinsPos, offset palins
    mov cx, 100             ; setting cx to 100, i.e. the length of userSTR
    lea bx, userSTR         ; loading the first address of userSTR into bx
    
    userINP:
        call getINP         ; call getINP to get input
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
        call incROW         ; call incROW to increment the row number to print in new line as the input is done
        lea si, userSTR     ; load the first address of userSTR into si [source string -> source index]
        repeat:
            lea di, userWORD    ; load the first address of userWORD into di [destination string -> destination index]
            cmp [si], 0x0       ; comparing the character at the index pointed by si to null terminator
            je  noWordsLeft     ; if the character is null terminator, jump to noWordsLeft to check for which out to go for
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
        
        ; if palindrome: di -> first character of userWord, bx -> last character of userWord
        ; si -> usrSTR character after the last character of userWord eitherways
        
        ; perform checks on the value of counter to increment it appropriately
        ; si has the address of userSTR position which needs to be preserved
        
        push si             ; saving si to stack
        lea si, counter     ; loading the address of counter into si
        
        cmp [si+1], 0x39    ; comparing the second character (unit's place digit due to little endian) of counter to 9
        jne  normVal        ; if the unit's place is not 9, jump to normVal
        mov [si+1], 0x30    ; else move 0 to the unit's place
        inc [si]            ; increment the ten's place
        
        cmp counter, 0x3939 ; comparing counter to 99
        jl noMAX            ; if counter is less than 99, jump to noMAX
        mov counter, 0x3939 ; else move 99 to counter
        
        normVal:            ; normal increment of counter
        inc [si+1]          ; increment the unit's place
        noMAX:
        
        ; storing the palindrome into the array
        
        mov si, palinsPos   ; move the position of the next character to be written in palins to si
        sub bx, cx          ; bx (last address of userWORD after loop) - cx (first address of userWORD, look at line 77) = length of userWORD
        mov cx, bx          ; move the length of userWORD to cx
        inc cx              ; increment cx since the difference between last and first address is 1 less than the actual length
        
        moveWord:
            mov bx, [di]    ; move the character pointed by di to bx
            mov [si], bx    ; move the character in bx to the palins array at the index pointed by si
            inc di          ; increment di to point to the next character
            inc si          ; increment si to point to the next character
            loop moveWord   ; loop back up to moveWord until cx is 0 (i.e. the whole word is moved)

        mov [si], 0x2C      ; move comma to the index pointed by si
        inc si              ; increment si to point to the next character
        mov [si], 0x20      ; move space to the index pointed by si
        inc si              ; increment si to point to the next character
        mov palinsPos, si   ; save (the position of last character in palins + 1) to palinsPos
        pop si              ; pop si from stack
        jmp repeat          ; jump back up to repeat
        
        
    noWordsLeft:
        cmp counter, 0x3030 ; comparing counter to 00
        je  checkBAD        ; if counter is 00, jump to checkBAD, else fall through into checkGOOD
        
        ; removing the comma after the last character in palins array
        mov si, palinsPos   ; load the last position for palins array (would be pointing to NULL)
        sub si, 2           ; decrement to point to comma (since after each word it was ", ")
        mov [si], 0x20      ; replace comma with space
        mov palinsPos, si   ; save that position
        
    
    checkGOOD:
        mov ax, offset prompt   ; move the address of 'num of palin found' prompt to ax
        mov bx, promptLEN       ; move the length of prompt to bx
        call printSTR           ; call printSTR
        setCol promptLEN        ; set the column number to the length of prompt
        
        mov ax, offset counter  ; move the address of counter to ax
        mov bx, 2               ; move 2 to bx, since the length of counter will always be 2
        call printSTR           ; call printSTR to print the number of palindromes found
        call incROW             ; call incROW to increment the row number to print in new line
        
        mov ax, offset palinPrompt  ; move the address of palinPrompt to ax
        mov bx, palinLEN            ; move the length of palinPrompt to bx
        call printSTR               ; call printSTR
        setCol palinLEN             ; set the column number to the length of palinPrompt
        
        mov ax, offset palins   ; move the address of palins to ax
        mov bx, palinsPos       ; move the position of the last character in palins to bx
        sub bx, ax              ; bx (last address of palins + 1) - ax (first address of palins, look at line 149) = length of palins
        call printSTR
        
        jmp fin                 ; jump to fin
        
        
    checkBAD:
        mov ax, offset noPalin  ; move the address of noPalin to ax
        mov bx, noPalinLEN      ; move the length of noPalin to bx
        call printSTR           ; call printSTR
        
    fin:
        ret
    

; procedures declared below
; --------------------------    
    getWORD proc
        push dx         ; save dx in stack
        nxtCh:
            cmp [si], 0x20      ; comparing the character at the index pointed by si to space
            je goBack           ; if the character is space, jump to goBack, else continue
            cmp [si], 0x0       ; comparing the character at the index pointed by si to null terminator
            je goBack           ; if the character is null terminator, jump to goBack, else continue
            mov dx, [si]        ; move one character from the string pointed by si to dx
            mov [di], dx        ; move the character from dx to the string pointed by di
            inc di              ; increment di to point to the next position to write into
            inc si              ; increment si to point to the next character to read 
            jmp nxtCh           ; jump back up to getWORD
        goBack:
        pop dx          ; get dx from stack
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
     
    incROW proc
        inc dh          ; increment the row number
        mov dl, 0       ; set the column number to 0
        mov ah, 0x2     ; set the cursor position
        int 10h
        ret
        endp