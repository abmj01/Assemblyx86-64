section .data

EXIT_SUCCESS equ 0       ; constant definition for exist success
SYS_exit equ 60          ; constant definition for system exit

 
 num1 dq 65000000        ; Variables initialization
 num2 dq 53400000        
 ans ddq 0                ; 128-bit

section .text
     global _start
_start:                     ; start of the program
     call _multiplication   

mov rax, SYS_exit           
mov rdi, EXIT_SUCCESS
syscall                     ; end of the program


 _multiplication:          ; simple function to multiply certain variables
 mov rax, qword[num1]      ; initialize register rax with the memory value using []
 mul rax, qword[num2]      ; reults in rdx:rax
 mov qword[ans] , rax      ; initializing the ans from rax register
 mov qword[ans + 8], rdx   ; take the Most significant 64-bits

 ret                       ; return