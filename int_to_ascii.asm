; Simple example program to convert an
; integer into an ASCII string.
; *********************************************************
; Data declarations
section .data
; -----
; Define constants
NULL equ 0
EXIT_SUCCESS equ 0 ; successful operation
SYS_exit equ 60 ; code for terminate
; -----
; Define Data.
intNum dd -977549



section .bss
strNum resb 8


; *********************************************************


section .text
global _start
_start:
; Convert an integer to an ASCII string.
; -----
; Part A - Successive division
mov eax, dword [intNum]          ; get integer
mov rcx, 0                       ; digitCount = 0
mov ebx, 10                      ; set for dividing by 10
divideLoop:
mov edx, 0
idiv ebx                        ; divide number by 10
push rdx                        ; push remainder
inc rcx                         ; increment digitCount
cmp eax, 0                      ; if (result > 0)
jne divideLoop                  ; goto divideLoop
; -----
; Part B - Convert remainders and store
mov rbx, strNum                 ; get addr of string
mov rdi, 0                      ; idx = 0

popLoop:
pop rax                         ; pop intDigit
add al, "0"                     ; char = int + "0"
mov byte [rbx+rdi], al          ; string[idx] = char
inc rdi                         ; increment idx
loop popLoop                    ; if (digitCount > 0)
; goto popLoop
mov byte [rbx+rdi], NULL        ; string[idx] = NULL

;-----------------------------------------------------------------------------
mov rax, strNum
call _print
;-----------------------------------------------------------------------------

; -----
; Done, terminate program.
last:
mov rax, SYS_exit ; call code for exit
mov rdi, EXIT_SUCCESS ; exit with success
syscall



;-----------------------------------------------------------------------------
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

   _int_to_ascii:
       mov rbx, 0
       mov rcx, 0
       mov rax, qword [num1]      ; Load the integer
       cdq                          ; Convert DWORD in eax to QWORD in edx:eax (sign-extend for idiv)
       mov ebx, 10                  ; Set divisor for dividing by 10
       cmp eax, 0                   ; Check if the number is negative
       jge divideLoop               ; If not negative, start dividing the integer
       neg eax                      ; Negate the number to make it positive for conversion
       mov byte [strResult], '-'    ; Store '-' sign for negative numbers
       jmp divideLoop               ; Jump to division loop

   divideLoop:
       mov edx, 0             ; Clear edx for idiv operation
       idiv ebx               ; Signed divide edx:eax by ebx
       push rdx               ; Push remainder
       inc rcx                ; Increment digit count
       cmp eax, 0             ; check if eax == 0
       jne divideLoop         ; Continue loop if eax != 0

       mov rbx, strResult     ; Address of string
       add rbx, 1             ; Skip the sign character
       mov rdi, 0             ; idx = 0

    popLoop:
       pop rax                ; Pop intDigit
       add al, "0"           ; Convert to ASCII
       mov [rbx+rdi], al      ; Store char in string

       inc rdi                ; Increment idx

       loop popLoop           ; Continue loop until digitCount == 0
       mov byte [rbx+rdi], 10 ; Add a new line after number

   ret