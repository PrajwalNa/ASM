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

; section for initialised values in Intel/Linux syntax        
.data:
    promptNum db "Enter a two digits: "
    promptLen equ $ - offset promptNum
    prompt2 db  "Enter up to 10 characters: "
    prompt2Len equ $ - offset prompt2
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
        
        mov     cx, 2
        mov     bx, 0
        getNum:
            mov     ah, 00h
            int     16h
        
            call    vld
        
            and     al, 0Fh         
            ; bitwise & operation on user input to convert it into dec
            ; only works on single digit hex values, i.e. will only convert up to 9 into dec
            cmp     cx, 2
            je      first
            mov     bl, c
            add     bl, al
            mov     [c], bl
            jmp     firstEND
            first:
                mov     bl, 10
                mul     bl
                mov     [c], al         ; storing the converted value at the address of c
                loop    getNum  
        
        firstEND:
        mov     dh, 1
        mov     dl, 0
        mov     ah, 2
        int     10h
        
        mov     al, 01b
        mov     bh, 0
        mov     bl, 00001011b
        mov     cx, prompt2Len
        
        push    cs              ; pushing cs into stack
        pop     es
        mov     bp, offset prompt2
        mov     ah, 13h
        int     10h
        
        mov     bx, 0
        mov     cx, 10
        getIn:
            mov     ah, 00h
            int     16h
            cmp     al, 0Dh
            je      resetPointer
            mov     [msg+bx], al
            inc     bx
            loop    getIn
        
        resetPointer:
            mov     [msg+bx], 0
            mov     cx, 0
            
            mov     dh, 0
            mov     dl, 0
            mov     bh, 1
            mov     ah, 2
            int     10h
        
            mov     al, 1
            mov     ah, 05h
            int     10h

    print: 
        cmp     dh, c           ; comparing the dh register (loop index) with counter
        je      loopend         ; jmp to loopend label if the above instruction satisfies
        cmp     dl, 50h
        jg      testC2
        mov     cx, 8
        
        mov     ah, 50h
        
        testC:
            cmp     dl, ah
            je      decCursor
            dec     ah
            loop    testC
            
        jmp     cont
            
        testC2:
            mov     ah, 99h
            
        tc:
            cmp     dl, ah
            je      decCursor
            dec     ah
            loop    tc
        
        jmp     cont         
        
        decCursor:
            mov     dl, 0
            mov     ah, 2
            int     10h
        
        cont:
            call    prntIT          ; calling the printIT function/label to print the string
        
            inc     dh              ; incrementing the loop variable/ row position value of cursor
            inc     dl              ; adding 1 to increase the dl {coloum}
            mov     ah, 2           ; syscall to change cursor position
            int     10h             ; do it!
            jmp     print           ; loop back up

    loopend:
        mov     ah, 00h
        int     16h    
        int     20h
         
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
        ret
    
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