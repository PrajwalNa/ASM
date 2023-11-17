; Dev: Prajwal Nautiyal

org 100h

jmp .code
    
.data:    
    msg db  "Hello 8086 !"  ; no Carriage Return {0Dh}, Line Feed {0Ah} and  needed
                            ; probably cause I'm not using the DOS syscalls
    
.code:  
        ; set video mode    
        mov ax, 3     ; text mode 80x25, 16 colors, 8 pages (ah=0, al=3)
        int 10h       ; do it!

        mov     ax, 1003h
        mov     bx, 0   ; disable blinking. 
        int     10h
        
        mov dh, 6   ; the row to rpint in, it is also being used as loop counter
	    mov dl, 10  ; the coloumn to print in 
	    mov bh, 0   ; setting page to 0
	    mov ah, 2   ; set cursor position bios call
        int 10h     ; do it!

        print:  
                cmp dh, 2   ; comparing the dh register (loop index) with 2
                je loopend  ; jmp to loopend label if the above instruction satisfies, which will set the ZF{zero flag/equal}
                mov al, 1   ; telling the cpu that the string has graphic attributes
	            mov bl, 2Bh ; setting attributes for text: 2(higher bit)-foreground colour [green] 
	                        ; and B(lower bit)-background colour [light cyan]
	            mov cx, 12  ; the length of the message cause I don't know how to make it calculate it without throwing garbage values
	            push cs     ; pushing the code segment register to top of stack
	            pop es      ; clearing the extra segment register for space probably
	            mov bp, offset msg  ; storing the memory address of msg in base pointer register
	                                ; so that regardless of what is in ds{data segment} at that time
	            mov ah, 13h ; syscall for printing a whole string
	            int 10h     ; do it!
	            dec dh      ; decrementing the loop variable/dh register {row}
	            inc dl      ; adding 1 to increase the dl {coloum}
	            
	    loop print               

        loopend:
        ; clearing the registers
        pop cx
        pop bp
        int 10h
        
        
        
        mov ah, 0
        mov dh, 0
        mov dl, 0
        int 16h
        int 21h
ret         