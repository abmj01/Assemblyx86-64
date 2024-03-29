section .data
    strNumber dq '999999', 0 ; Example of a valid string
    isNegative db 0
    intResult dq 0

section .bss
  ;  intResult resq 1  ; Reserve space for the result integer
  str1 resq 1

section .text
    global _start

_start:
    mov r12, [strNumber]
    mov [str1], r12

    mov rsi, str1      ; Address of the string to rsi
    mov r8, 0              ; Clear r8 for the result
    xor eax, eax            ; Clear eax for general use
    mov al, [rsi]           ; Load the first character of the string

    ; Check for valid sign or digit
    cmp al, '-'
    je checkNextChar
    cmp al, '+'
    je checkNextChar
    cmp al, '0'
    jl invalidInput
    cmp al, '9'
    jg invalidInput

checkNextChar:
    inc rsi                  ; Move to the next character for validation

validateLoop:
    mov al, [rsi]            ; Load the next character
    cmp al, 0              ; Check if NULL
    je startConversion       ; If NULL, end of string and valid
    cmp al, '0'
    jl invalidInput          ; Less than '0' is invalid
    cmp al, '9'
    jg invalidInput          ; Greater than '9' is invalid
    inc rsi                  ; Move to the next character
    jmp validateLoop

startConversion:
    mov rsi, strNumber       ; Reset RSI to start of the string for conversion
    mov al, [rsi]            ; Re-check for a sign
    cmp al, '-'
    je negativeNumber
    cmp al, '+'
    je positiveNumber
    jmp convertLoop          ; If no sign, start conversion

negativeNumber:
    mov byte [isNegative], 1     ; Mark as negative
    inc rsi                      ; Skip the sign for conversion
    jmp convertLoop

positiveNumber:
    mov byte [isNegative], 0    ; Mark as positive
    inc rsi                     ; Skip the sign for conversion

convertLoop:
    mov rax, 0                  ; Clear RAX
    mov al, [rsi]
    inc rsi
    cmp al, 0
    je conversionDone
    sub al, '0'
    imul r8, r8, 10
    add r8, rax
    jmp convertLoop

conversionDone:
    mov [intResult], r8       ; Store the result
    cmp byte [isNegative], 1
    jne exitProgram
             ; Jump if not negative
    neg qword [intResult]      ; Negate the result if negative

exitProgram:
    ; Cleanly exit the program
    mov rax, 60
    mov rdi, 0
    syscall

invalidInput:
    mov qword [intResult], 0xFFFFFFFF ; Indicate invalid input
    jmp exitProgram
