# ASM
Just a place where I put my misadventures with the Assembly Language

You might need emu 8086 for the 8086 microprocessor code because I'm pretty sure modern x86-64 systems aren't that far backwards compatible

This is more of an ongoing project/learning adventure. I started learning 8086 microprosser assembly and the genereal x86 ISA since I was curious about how the computer works at a low level. I have written a few programs in assembly, such as a palindrome word checker, a basic encryption algorithm which encrypts a string using one Key if the first character input was 'M' and another Key otherwise. I have also tried looking into modern x86-64 assembly and ARM assembly. I am still learning and exploring this domain and I am very excited to learn more about it.

#### Features of this project:
* Handling I/O operations using the BIOS interrupts (int 16h).
* Using the stack to store and retrieve data.
* Using branching and looping to implement the logic of the program.
* Using Procedures and Macros to make the code more readable and maintainable.
* Handling memory operations and cursor postioning in 16 bit x86 ISA.

#### Challenges faced in this project:
* Different types of memory addressing modes and how to use them, learning about how many ways the processor allows you to access memory in a CISC architechure can really be interesting.
* Proper usage of the stack and how to use it to store and retrieve data, initially I was rather confused in my usage of stack as I was just doing an elaborate version of the `mov` instruction.
* Differnt BIOS interrupts and how to use them to perform I/O operations, I had to go through the pages of documentation to find the right interrupt for the operation I wanted to perform.
* Program Control Flow, it was quite an experience learning about the various conditional and unconditional jump alongside the different kinda of flag setting instructions and how to use them.

#### Learning Outcomes:
* Assembly programming, especially using the x86 ISA.
* How the computer works at a low level, how the processor executes instructions and how the memory is accessed.
* Stack operations and how to use it to store and retrieve data, especially useful in a microprocessor like 8086 which has limited number of registers.
* BIOS interrupts of 8086 microprocessor, modern processors run on kernal syscalls which differ based on the OS.

Example Run of palinCheck:
<p align=centre>
  <img src="https://github.com/PrajwalNa/ASM/blob/ef7c72d643a5e664d5672e93f8e2d179c3866765/8086%20Microprocessor/palinCheck.gif">
</p>
