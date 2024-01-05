ldr r0,=myString
swi 0x02          ; Print string at address in r0
swi 0x11          ; Halt

myString: .asciz "Hello World!\n"  ; 'z' means add null
