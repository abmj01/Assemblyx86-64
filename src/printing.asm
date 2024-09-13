section .data
      text1 db "Hello, World", 10,0
      text2 db "I love you baby!", 10,0

section .text
      global _start

_start:
      mov rax, text1
      call _print

      mov rax, text2
      call _print

      mov rax, 60
      mov rdi, 0
      syscall


;input: rax
;output: print string at rax

_print:
   push rax        ; push rax t0 the stack
   mov rbx, 0      ; rbx used to count the length of the string

_printLoop:
   inc rax
   inc rbx
   mov cl, [rax]    ; Moving the rax register to the 8-bit register of the rcx to hold each character
   cmp cl, 0        ; check if cl is 0
   jne _printLoop   ; If not print jump to the fucntion again and push the next char to thr stack

   mov rax, 1
   mov rdi, 1
   pop rsi          ; pop the value from the rax pushed bytes
   mov rdx, rbx     ; move the value of rbx to rdx to get the count of the string

   syscall
   ret