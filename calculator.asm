section .data
; Constants initialization
   NULL equ 0
   EXIT_SUCCESS equ 0
   SYS_exit equ 60

 ; Variables initialization
   isNegative db 0
   num1 dq 0      
   num2 dq 0
   result dq 0
   AskUser db "Integer calculator. Choose Operand within (+,-,*,/,^): ", 10,0
   firstOp db "Enter first operand: ", 10,0
   secondOp db "Enter second operand: ", 10,0
   invalidOperation db  "Invalid opration! ", 10,0
   resultStr db "The result is: ", 10,0
   wow db "wow!!", 10,0
   pot_user_write db "Enter a number to find it's power of two: ", 10,0

section .bss
; Buffers declaration
   operand resb 1
   strNum1 resq 1
   strNum2 resq 1
   strResult resq 1


section .text
   global _start
   
 _start:

mov rax, AskUser                ; Ask the user
call _print 
 
call _operand_input             ; Get the operation


; Operand input error handeling 

movzx r10 , byte [operand]      ; Move the operand into rax and zero-extend to 64 bits

cmp r10b, '^'                   ; check if the operand is '^', if equall jump to the power of two label
je _pot_exception

cmp r10b , '*'
jb _invalid_operand             ; unsigned, if <op1> < <op2>

cmp r10b , '/'
ja _invalid_operand             ; unsigned, if <op1> > <op2>


mov rax, firstOp                ; Ask user for the first operand
call _print


call _input1                    ; Get first operand


mov rax, secondOp               ; Ask user for the first operand
call _print

call _input2                    ; Get second operand



call _ascii_to_int_one          ; convert strNum1 to integer and initialize it with num1 variable using
                                ; '_ascii_to_int' function


call _ascii_to_int_two           ; convert strNum2 to integer and initialize it with num2 variable using
                                 ; '_ascii_to_int' function


cmp r10b , '+'                  ; make an if else statements to check which operation is needed (+,-,*,/)
je _addition

cmp r10b , '-'                  ;calculate the addition '+', subtraction '-', multiplication '*', or division '/'
je _subtration                  ;of num1 and num2 and initialize it with the 'result' variable

cmp r10b , '*'
je _multiplication

cmp r10b , '/'
je _division
 
_pot_exception:                          ;power of two exception

mov rax, pot_user_write
call _print


call _input1


call _ascii_to_int_one



_power_of_two:
  mov rax, qword[num1]         ; initialize register rax with the memory value using []
  imul rax, qword[num1]        ; reults in rdx:rax
  mov qword[result] , rax      ; initializing the ans from rax register
jmp _print_result


_addition:                     ; simple function to add certain variables
  mov rax, qword[num1]         ; initialize register rax with the memory value using []
  add rax, qword[num2]         ; adding num2 to the already existing num1 in the register
  mov qword[result] , rax      ; initializing the ans from rax register
jmp _print_result


_subtration:                   ; simple function to add certain variables
  mov rax, qword[num1]         ; initialize register rax with the memory value using []
  sub rax, qword[num2]         ; adding num2 to the already existing num1 in the register
  mov qword[result] , rax      ; initializing the ans from rax register
jmp _print_result


_multiplication:               ; simple function to multiply certain variables
  mov rax, qword[num1]         ; initialize register rax with the memory value using []
  imul rax, qword[num2]        ; reults in rdx:rax
  mov qword[result] , rax      ; initializing the ans from rax register
jmp _print_result


_division:                     ; simple function to multiply certain variables
  mov rax, qword[num1]         ; initialize register rax with the memory value using []
  cqo                          ; Sign extend rax into rdx:rax
  idiv rax, qword[num2]        ; reults in rdx:rax
  mov qword[result] , rax      ; initializing the ans from rax register
jmp _print_result 


_print_result:
   mov rax, 0                  
   mov rax, resultStr           ; Print 'resultStr' variable
   call _print
   
   
   call _int_to_ascii          ; convert the 'result' variable from integer to ascii using the '_int_to_ascii' function
   mov rax, strResult          ; and initialize it with 'strResult'
   call _print
   jmp _end                    ; jump to the end of the program                           


_invalid_operand:
   mov rax, invalidOperation
   call _print


_end:
  mov rax, SYS_exit
  mov rdi, EXIT_SUCCESS
  syscall

;----------------------------------------------------------------End of the program-------------------------------------------------------


; Operand input function
_operand_input:
   mov rax, 0
   mov rdi, 0
   mov rsi, operand
   mov rdx, 10
   syscall

   mov rbx, rax               ; copy the number of bytes read to rbx for manipulation
   dec rbx                    ; decrement rbx to get the index of the last character read
      
   mov byte [rsi + rbx], 0    ; replace the newline character with a null terminator
ret  

; First input from the user 'strNum1' buffer function
_input1:
   mov rax, 0 
   mov rdi, 0
   mov rsi, strNum1
   mov rdx, 12
   syscall

   mov rbx, rax                ; copy the number of bytes read to rbx for manipulation
   dec rbx                     ; decrement rbx to get the index of the last character read
    
   mov byte [rsi + rbx], 0     ; replace the newline character with a null terminator
ret

; Second input from the user 'strNum1' buffer function
_input2:
   mov rax, 0 
   mov rdi, 0
   mov rsi, strNum2
   mov rdx, 10
   syscall

   mov rbx, rax               ; copy the number of bytes read to rbx for manipulation
   dec rbx                    ; decrement rbx to get the index of the last character read
    
   mov byte [rsi + rbx], 0    ; replace the newline character with a null terminator
 ret 

;--------------------------------------------integer to ascii function------------------------------------------------------

_int_to_ascii:
    mov rbx, 0
    mov rcx, 0
    mov rax, qword [result]      ; Load the integer
    cdq                          ; Convert DWORD in eax to QWORD in edx:eax (sign-extend for idiv)
    mov ebx, 10                  ; Set divisor for dividing by 10
    cmp eax, 0                   ; Check if the number is negative
    jge divideLoop               ; If not negative, start dividing the integer
    neg eax                      ; Negate the number to make it positive for conversion
    mov byte [strResult], '-'    ; Store '-' sign for negative numbers
    jmp divideLoop               ; Jump to division loop

divideLoop:
    mov edx, 0                   ; Clear edx for idiv operation
    idiv ebx                     ; Signed divide edx:eax by ebx
    push rdx                     ; Push remainder
    inc rcx                      ; Increment digit count
    cmp eax, 0                   ; check if eax == 0
    jne divideLoop               ; Continue loop if eax != 0
         
    mov rbx, strResult           ; Address of string
    add rbx, 1                   ; Skip the sign character
    mov rdi, 0                   ; idx = 0
         
 popLoop:        
    pop rax                      ; Pop intDigit
    add al, "0"                  ; Convert to ASCII
    mov [rbx+rdi], al            ; Store char in string
         
    inc rdi                      ; Increment idx
         
    loop popLoop                 ; Continue loop until digitCount == 0
    mov byte [rbx+rdi], 10       ; Add a new line after number

ret
;------------------------------------------------------------------------------------------------------------



;--------------------------------------ascii to 1st integer----------------------------------------------------

_ascii_to_int_one:
    mov rsi, 0               ; Clear rsi
    mov rsi, strNum1         ; Address of the string to rsi
    mov r8, 0                ; Clear r8 for the result
    xor eax, eax             ; Clear eax for general use
    mov al, [rsi]            ; Load the first character of the string

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
    inc rsi                     ; Move to the next character for validation

validateLoop:
    mov al, [rsi]               ; Load the next character
    cmp al, 0                   ; Check if NULL
    je startConversion          ; If NULL, end of string and valid
    cmp al, '0'
    jl invalidInput             ; Less than '0' is invalid
    cmp al, '9'
    jg invalidInput             ; Greater than '9' is invalid
    inc rsi                     ; Move to the next character
    jmp validateLoop

startConversion:
    mov rsi, strNum1            ; Reset RSI to start of the string for conversion
    mov al, [rsi]               ; Re-check for a sign
    cmp al, '-'
    je negativeNumber
    cmp al, '+'
    je positiveNumber
    jmp convertLoop             ; If no sign, start conversion

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
    cmp al, 0                   ; check if null
    je conversionDone
    sub al, '0'                 ; subtract the ascii letters with '0' that resembles 48 in decimal to find the correct integer value
    imul r8, r8, 10             ; multipy the value inside r8 with 10 to get the correct indexing
    add r8, rax                 ; add what is inside rax to r8
    jmp convertLoop

conversionDone:
    mov [num1], r8              ; Store the result
    cmp byte [isNegative], 1
    jne _end1                   ; Jump if not negative

    neg qword [num1]            ; Negate the result if negative
    jmp _end1   

invalidInput:
mov qword [num1], 0xFFFFFFFF ; Indicate invalid input

_end1:
ret
;----------------------------------------------------------------------------------------------------------------


;--------------------------------------ascii to 2st integer------------------------------------------------------

_ascii_to_int_two:
    mov rsi, 0                      ; Clear rsi
    mov rsi, strNum2                ; Address of the string to rsi
    mov rdi, 0                      ; Clear rdi for the result
    mov eax, 0                      ; Clear eax for general use
    mov al, [rsi]                   ; Load the first character of the string

    ; Check for valid sign or digit
    cmp al, '-'
    je checkNextChar2
    cmp al, '+'
    je checkNextChar2
    cmp al, '0'
    jl invalidInput2
    cmp al, '9'
    jg invalidInput2

checkNextChar2:
    inc rsi                         ; Move to the next character for validation
   
validateLoop2:   
    mov al, [rsi]                   ; Load the next character
    cmp al, 0                       ; Check if NULL
    je startConversion2             ; If NULL, end of string and valid
    cmp al, '0'   
    jl invalidInput2                ; Less than '0' is invalid
    cmp al, '9'   
    jg invalidInput2                ; Greater than '9' is invalid
    inc rsi                         ; Move to the next character
    jmp validateLoop2   
   
startConversion2:   
    mov rsi, strNum2                ; Reset RSI to start of the string for conversion
    mov al, [rsi]                   ; Re-check for a sign
    cmp al, '-'
    je negativeNumber2
    cmp al, '+'
    je positiveNumber2
    jmp convertLoop2                ; If no sign, start conversion

negativeNumber2:
    mov byte [isNegative], 1        ; Mark as negative
    inc rsi                         ; Skip the sign for conversion
    jmp convertLoop2

positiveNumber2:
    mov byte [isNegative], 0        ; Mark as positive
    inc rsi                         ; Skip the sign for conversion

convertLoop2:
    mov rax, 0                      ; Clear RAX
    mov al, [rsi]
    inc rsi                       
    cmp al, 0                       ; chek if 'al' is null
    je conversionDone2
    sub al, '0'                     ; subtract the ascii letters with '0' that resembles 48 in decimal to find the correct integer value
    imul rdi, rdi, 10               ; multipy the value inside r8 with 10 to get the correct indexing
    add rdi, rax                    ; add what is inside rax to r8
    jmp convertLoop2     

conversionDone2:
    mov qword[num2], rdi            ; Store the result
    cmp byte [isNegative], 1
    jne _end2                       ; Jump if not negative
 
    neg qword [num2]                ; Negate the result if negative
    jmp _end2

invalidInput2:
    mov qword [num2], 0xFFFFFFFF    ; Indicate invalid input

_end2:

ret

;-------------------------------------------------------------------------------------------------------------------------




;--------------------------------------------printing function----------------------------------------------------------------


_print:
   push rax                ; push rax to the stack
   mov rbx, 0              ; rbx used to count the length of the string
  
_printLoop:  
   inc rax  
   inc rbx  
   mov cl, byte [rax]      ; Moving the rax register to the 8-bit register of the rcx to hold each character
   cmp cl, 0               ; check if cl is 0
   jne _printLoop          ; If not print jump to the fucntion again and push the next char to thr stack
  
   mov rax, 1  
   mov rdi, 1  
   pop rsi                 ; pop the value from the rax pushed bytes
   mov rdx, rbx            ; move the value of rbx to rdx to get the count of the string

   syscall
 ret
   ;------------------------------------------------------------------------------------------------------------------