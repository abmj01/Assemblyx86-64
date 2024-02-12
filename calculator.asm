section .data
   NULL equ 0
   EXIT_SUCCESS equ 0
   SYS_exit equ 60

   strNum1 db "", 0
   strNum2 db "", 0
   AskUser db "Integer calculator. Choose Operand within (+,-,*,/): ", 10,0
   firstOp db "Enter first operand: ", 10,0
   SecondOp db "Enter second operand: ", 10,0
   resultStr db "The result is: ", 10,0


section .bss

   intNum1 resd 1
   intNum2 resd 1
   isNegative resb 1
   operand resb 1




section .text
   global _start
   
   _start:





_input1:
   mov rax, 0 
   mov rdi, 0
   mov rsi, intNum1
   mov rdx, 10
   syscall
   ret

_input2:
   mov rax, 0 
   mov rdi, 0
   mov rsi, intNum2
   mov rdx, 10
   syscall
   ret




_print:
   push rax        ; push rax to the stack
   mov rbx, 0      ; rbx used to count the length of the string

_printLoop:
   inc rax
   inc rbx
   mov cl, byte [rax]    ; Moving the rax register to the 8-bit register of the rcx to hold each character
   cmp cl, 0        ; check if cl is 0
   jne _printLoop   ; If not print jump to the fucntion again and push the next char to thr stack

   mov rax, 1
   mov rdi, 1
   pop rsi          ; pop the value from the rax pushed bytes
   mov rdx, rbx     ; move the value of rbx to rdx to get the count of the string

   syscall
   ret
   ;-----------------------------------------------------------------------------