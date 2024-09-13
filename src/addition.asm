section .data

EXIT_SUCCESS equ 0       ; constant definition for exist success
SYS_exit equ 60          ; constant definition for system exit

 
 num1 dq 65000000        ; Variables initialization
 num2 dq 53400000        
 ans dq 0                

section .text
     global _start
_start:
     mov rax, qword[num1]      ; initialize register rax with the memory value using []
     add rax, qword[num2]      ; adding num2 to the already existing num1 in the register
     mov qword[ans] , rax      ; initializing the ans from rax register

    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
syscall


