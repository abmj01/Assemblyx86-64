;ASCII to integer
section .data
    strNumber db '-41275', 0 ; Example of a valid string
    ; strNumber db '1+32', 0 ; Example of an invalid string
    ; strNumber db '+1R3', 0 ; Another example of an invalid string

section .bss
    intResult resd 1 ; Reserve space for the result integer
    isNegative resb 1 ; Reserve a byte to store sign information

section .text
    global _start

_start:
    mov rsi, strNumber      ; Address of the string to rsi
    mov rdi, 0              ; Clear rdi for the result
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
    test al, al              ; Check if NULL
    jz startConversion       ; If NULL, end of string and valid
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
    test al, al
    jz conversionDone
    sub al, '0'
    imul rdi, rdi, 10
    add rdi, rax
    jmp convertLoop

conversionDone:
    mov [intResult], rdi       ; Store the result
    jmp exitProgram

invalidInput:
    mov dword [intResult], 0xFFFFFFFF ; Indicate invalid input
    ; Exit program
exitProgram:
    mov rax, 60 
    mov rdi, 0 
    syscall
