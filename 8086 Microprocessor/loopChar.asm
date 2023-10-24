; Dev: Prajwal Nautiyal

org 100h    
; this directive required for a simple 1 segment .com program
; more segments can be declared by using `segment' keyword
; segments need to be closed with `ends' keyword in MS DOS/MASM syntax
; Intel/Linux syntax uses sections as have been used for labels below 

jmp .text

; section for uninitialised values in Intel/Linux syntax
.bss:    
    temp1 dw ?
    c db ?
    msg db 11 dup (?)
    ; 11 is the number of characters to be stored in the array
    ; dup (?) is used to initialise the array with 0s

; section for initialised values in Intel/Linux syntax        
.data:
    promptNum db "Enter a two digits: "
    promptLen equ $ - offset promptNum
    prompt2 db  "Enter up to 10 characters: "
    prompt2Len equ $ - offset prompt2
    ; $ is the address of the next byte after the current one
    ; so $ - offset promptNum is the length of the string
    numArr db  39h, 38h, 37h, 36h, 35h, 34h, 33h, 32h, 31h, 30h
                    
; section for code in Intel/Linux syntax    
.text:  
        ; set video mode    
        mov     al, 03h         
        ; 00h - text mode. 40x25. 16 colors. 8 page
        ; 03h - text mode. 80x25. 16 colors. 8 pages.
        ; 13h - graphical mode. 40x25. 256 colors. 320x200 pixels. 1 page.
        
        mov     ah, 0           ; syscall to set video mode 
        int     10h             ; do it!

        mov     ax, 1003h       ; syscall to toggle intesity/blinking
        mov     bx, 0           ; disable blinking. 
        int     10h

        mov     dh, 0           ; the row to print in
        mov     dl, 0           ; the coloumn to print in
        mov     ah, 2           ; syscall to set cursor position
        int     10h             ; do it!

        ; offset: '&' in C, so here moving the address of promptNum to dx
        ; you need $ at the end of message for int 21h call
        ;mov     dx, offset promptNum
        ;mov     ah, 09h
        ;int     21h

        mov     al, 01b         ; 
        mov     bh, 0
        mov     bl, 00001011b
        ; high bit {foreground}: 0xB/1011b [bright cyan]
        ; low bit {background}: 0x0/0000b [black]
        mov     cx, promptLen
        ; calculate message size by substracting the address of message from the address of next byte
        push    cs              ; pushing cs into stack
        pop     es
        mov     bp, offset promptNum
        mov     ah, 13h
        int     10h
        
        mov     cx, 2           ; loop counter initialised to 2
        mov     bx, 0
        getNum:
            mov     ah, 00h     ; syscall to get a character
            int     16h         ; do it!
        
            call    vld         ; calling the vld function/label to validate the user input
        
            and     al, 0Fh         
            ; bitwise & operation on user input to convert it into dec
            ; only works on single digit hex values, i.e. will only convert up to 9 into dec
            cmp     cx, 2       ; comparing the loop index with 2
            je      first       ; jmp to first label if the above instruction satisfies
            mov     bl, c       ; moving the value of c to bl
            add     bl, al      ; adding the value of al to bl
            mov     [c], bl     ; storing the converted value at the address of c
            jmp     firstEND    ; jmp to firstEND label
            first:
                mov     bl, 10          ; moving 10 to bl
                mul     bl              ; multiplying the value of al with bl
                mov     [c], al         ; storing the converted value at the address of c
                loop    getNum          ; loop back up
        
        firstEND:
        mov     dh, 1           ; the row to print in
        mov     dl, 0           ; the coloumn to print in
        mov     ah, 2           ; syscall to set cursor position
        int     10h             ; do it!
        
        mov     al, 01b         
        ; - bit 0 is 1, so update the cursor position after printing 
        ; - bit 1 is 0, so text does not have predefined graphics
        mov     bh, 0           ; page number
        mov     bl, 00001011b   
        ; high bit {foreground}: 0xB/1011b [bright cyan]
        ; low bit {background}: 0x0/0000b [black]
        mov     cx, prompt2Len  ; moving the length of prompt2 to cx
        
        push    cs              ; pushing cs into stack
        pop     es              ; popping cs from stack to es [extra segment]
        mov     bp, offset prompt2
        ; moving the address of prompt2 to bp [base pointer]
        mov     ah, 13h         ; syscall to print string
        int     10h             ; do it!
        
        mov     bx, 0           ; bx = 0 / index of msg array
        mov     cx, 10          ; loop counter initialised to 10
        getIn:
            mov     ah, 00h     ; syscall to get a character
            int     16h         ; do it!
            cmp     al, 0Dh     ; comparing the user input with 0Dh [carriage return]
            je      resetPointer
            ; jmp to resetPointer label if the above instruction satisfies
            mov     [msg+bx], al
            ; storing the user input at the address of msg + bx
            inc     bx
            ; incrementing the index of msg array
            loop    getIn
            ; loop back up until cx = 0
        
        resetPointer:           ; label to continue the program, and reset the cursor position
            mov     [msg+bx], 0
            ; storing 0 at the address of msg + bx [end of string]
            mov     cx, 0       ; loop counter initialised to 0
            
            mov     dh, 0       ; the row to print in
            mov     dl, 0       ; the coloumn to print in
            mov     bh, 1       ; page number
            mov     ah, 2       ; syscall to set cursor position
            int     10h         ; do it!
        
            mov     al, 1       ; new active page
            mov     ah, 05h     ; syscall to set active page
            int     10h         ; do it!

    print: 
        cmp     dh, c           ; comparing the dh register (loop index) with counter
        je      loopend         ; jmp to loopend label if the above instruction satisfies
        cmp     dh, 18h         ; check if the cursor is in the last row
        je      changePage      ; jump to change page if its the last row
        back:
        cmp     dl, 50h         ; comparing the dl register (cursor position) with 50h [80d] (boundary of screen)
        jg      testC2          ; jmp to testC2 label if the above instruction satisfies
        mov     cx, 8           ; loop counter initialised to 8
        
        mov     ah, 50h         ; moving 50h to ah
        
        testC:
            cmp     dl, ah      ; comparing the dl register (cursor position in coloumn) with ah
            je      decCursor   ; jmp to decCursor label if the above instruction satisfies
            dec     ah          ; decrementing the value of ah
            loop    testC       ; loop back up for 8 times
            
        jmp     cont            ; jmp to cont label
            
        testC2:
            mov     ah, 99h     ; moving 99h to ah
            
        tc:                     ; label for testC2 loop 
        ; because for some reason the column boundary is 100h in the lower rows
        ; same logic as testC loop
            cmp     dl, ah      
            je      decCursor
            dec     ah
            loop    tc
        
        jmp     cont         
        
        decCursor:              ; label to decrement the cursor position if it reaches the boundary
            mov     dl, 0       ; moving 0 to dl [coloumn]
            mov     ah, 2       ; syscall to set cursor position
            int     10h         ; do it!
        
        cont:
            call    prntIT      ; calling the printIT function/label to print the string
        
            inc     dh          ; incrementing the loop variable/ row position value of cursor
            inc     dl          ; adding 1 to increase the dl {coloum}
            mov     ah, 2       ; syscall to change cursor position
            int     10h         ; do it!
            jmp     print       ; loop back up
            
        changePage:
            inc     bh          ; incrementing the value of page number by one
            cmp     bh, 7       ; check if its the last page
            jg      loopend     ; ending the loop if it is greater than the last page
            ; reseting row and coloumn to zero
            mov     dh, 0
            mov     dl, 0
            mov     ah, 2       ; syscall to set cursor position
            int     10h
            sub     c, 18h
            mov     al, bh      ; setting current active page
            mov     ah, 05h     ; syscall for it
            int     10h
            jmp     back

    loopend:
        mov     ah, 00h         ; syscall to get a character and discard it
        int     16h             ; do it!
        int     20h             ; syscall to terminate the program / deprecated by MS DOS int 21h / but this is hardware interrupt
    
    vld:
        mov     si, offset numArr   ; si = &numArr
        ; alternatively to offset we can use `lea' which is more powerful
        push    ax              ; store it in ax register.

    nextNum:      
        mov     ah, cs:[si]     
        ; copying the target of the memory location 
        ; pointed by source index(si) in code segment register
        ; basically a pointer but in asm
        inc     si              ; next byte.
        cmp     ah, al          ; comparing the user input in al with byte taken in ah
        je      good            ; ifcomparison is success go to good label
        cmp     ah, 0           ; if previous one did not jump and ah now has 0
        je      bad             ; jmp to bad label
        jmp     nextNum         ; loop to next number

    good:
        pop     ax              ; restore ax register.
        ret                     ; return to the program
    
    bad:
        jmp     .text           ; restart the program
    
    prntIT:
        mov si, offset msg      ; alternatively we can push &variable to the si
        push    ax              ; push ax into the stack

    nextChar:      
        mov     al, cs:[si]     
        ; copying the target of the memory location to the lower byte of ax
        ; pointed by source index(si) in code segment register
        ; basically a pointer but in asm
        inc     si              ; next byte.
        cmp     al, 0
        jz      done
        mov     bl, 0xBC        
        ; high bit {foreground}: 0xC/1100b [bright red] 
        ; low bit {background}: 0xB/1011b [bright cyan]
        mov     cx, 1        
        mov     ah, 09h         ; print character call
        int     10h             ; do it!
        inc     dl              ; adding 1 to the value of cursor's horizontal position (column)
        mov     ah, 2           ; syscall to move the cursor
        int     10h             ; do it!
        jmp     nextChar        ; loop to next character

    done:
        pop     ax              ; restore ax register.
        ret                     ; return to the program