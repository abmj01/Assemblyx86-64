;integer to ASCII
section .data
    NULL equ 0
    EXIT_SUCCESS equ 0
    SYS_exit equ 60
    intNum dd 123    ;32-bit

section .bss
    strNum resb 12         ; Reserve 12 bytes (including sign and NULL)

section .text
global _start

_start:
; Check for sign and prepare for conversion
    mov eax, dword [intNum]      ; Load the integer
    cdq                          ; Convert DWORD in eax to QWORD in edx:eax (sign-extend for idiv)
    mov ebx, 10                  ; Set divisor for dividing by 10
    cmp eax, 0                   ; Check if the number is negative
    jge divideLoop               ; If not negative, start dividing the integer
    neg eax                      ; Negate the number to make it positive for conversion
    mov byte [strNum], '-'       ; Store '-' sign for negative numbers
    jmp divideLoop               ; Jump to division loop


divideLoop:
    mov edx, 0             ; Clear edx for idiv operation
    idiv ebx               ; Signed divide edx:eax by ebx
    push rdx               ; Push remainder
    inc rcx                ; Increment digit count
    cmp eax, 0             ; check if eax == 0
    jne divideLoop         ; Continue loop if eax != 0

    mov rbx, strNum        ; Address of string
    add rbx, 1             ; Skip the sign character
    mov rdi, 0             ; idx = 0
 popLoop:
    pop rax                ; Pop intDigit
    add al, "0"           ; Convert to ASCII
    mov [rbx+rdi], al      ; Store char in string
    inc rdi                ; Increment idx
    loop popLoop           ; Continue loop until digitCount == 0
    mov byte [rbx+rdi], 10 ; Add a new line after number

;-----------------------------------------------------------------------------
    mov rax, strNum
    call _print
 ;-----------------------------------------------------------------------------
; -----
; Done, terminate program.
    last:
    mov rax, SYS_exit      ; Exit syscall
    mov rdi, EXIT_SUCCESS  ; Successful operation
    syscall                ; Invoke system call

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
