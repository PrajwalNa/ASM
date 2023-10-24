
org 100h

jmp .code
    
.data:    
    ;msg1 db 'H','e','l','l','o',' ','8','0','8','6',' ','!'
    ;msg2:  dw  0Dh, 0Ah,"sum of num1= 24, num2= 87", 0Dh, 0Ah, 24h
    ;a: db 24
    ;b: db 87
    temp1: dw ?
    
.code:  
        ; set video mode    
        mov al, 03h
	    mov ah, 0
        int 10h       ; do it!

        mov     ax, 1003h
        mov     bx, 0   ; disable blinking. 
        int     10h
        
        mov dh, 0
	    mov dl, 0  ; the coloumn to print in
	    mov ah, 2
        int 10h

        print:  
                cmp     dh, 6  ; comparing the dh register (loop index) with Zero
                je      loopend  ; jmp to loopend label if the above instruction satisfies
                call    prntIT: 
                            db "Hello 8086!!", 0   
                cont:
	            inc     dh      ; decrementing the loop variable
	            inc     dl      ; adding 1 to increase the dl {coloum}
	            mov     ah, 2
	            int     10h
	            jmp     print
	    
	    
	    prntIT:
            mov     cs:temp1, si  ; protect si register
                                  ; by storing it's current position in a temporary variable
            pop     si            ; get return address (ip[index pointer]).
            push    ax            ; store it in ax register.

        next_char:      
            mov     al, cs:[si]   ; copying the target of the memory location 
                                  ; pointed by source index(si) in code segment register
                                  ; basically a pointer but in asm
            inc     si            ; next byte.
            cmp     al, 0
            jz      printed
            mov     bl, 00101110b
            mov     cx, 1        
            mov     ah, 09h       ; teletype function.
            int     10h
            inc     dl
            mov     ah, 2
            int     10h
            jmp     next_char     ; loop.
        printed:
            pop     ax            ; re-store ax register.
            ; si should point to next command after
            ; the call instruction and string definition:
            push    si            ; save new return address into the stack.
            mov     si, cs:temp1  ; re-store si register.
            jmp     cont          ; go back to initial loop     

        loopend:
        ;pop cx
        ;pop bp
        ;int 10h
        ;pop dx
        ;mov ah, 0
        ;mov dx, msg2
        ;mov ah, 09h
        ;int 21h
                
        
        ;mov ah, 0
        ;pop dx
        ;mov ax, a
        ;mov bx, b
        ;add ax, bx
        ;mov ax, 30h
        ;mov z, ax
        ;mov dx, z, 0Dh, 0Ah, 24h
        ;mov ah, 09h
        ;int 21h
        
        
        mov ah, 0
        mov dh, 0
        mov dl, 0
        int 16h
        int 21h
into
ret         