# Assembly

What is Assembly?

Assembly language is a “low-level” language and provides the basic instructional
interface to the computer processor. Assembly language is as close to the processor as you can get as a programmer. 


Why Assembly?

There is multiple reasons to use assembly:

- Gain a Better Understanding of Architecture Issues
- Understanding the Tool Chain
- Improve Algorithm Development Skills
- Improve Understanding of Functions/Procedures
- Gain an Understanding of I/O Buffering
- Understand Compiler Scope
- Interrupt Processing Concepts



### Converting Integer value to ASCII characters 

Achieving this is totally not trivial as you have done it in any other high or medium level programming languages. 
Printing an integer from a register to the system call read is a bit complicated and necessitate 
the programmer to make an algorithm to divide that integer and get the remainder of that division and push it to the stack.

In this section we explain how to achieve this step by step

```asm
section .data
    intNum dd -124573       

section .bss
    strNum resb 12         ; Reserve 12 bytes (including sign and NULL)
```

First of all we declare a 32-bit variable `intNum`. Then we reserve 12 bytes of data for `strNum` buffer.

```asm
_start:
; Check for sign and prepare for conversion
    mov eax, dword [intNum]      ; Load the integer
    cdq                          ; Convert DWORD in eax to QWORD in edx:eax (sign-extend for idiv)
    mov ebx, 10                  ; Set divisor for dividing by 10
    cmp eax, 0x0                 ; Check if the number is negative
    jge divideLoop               ; If not negative, start dividing the integer
    neg eax                      ; Negate the number to make it positive for conversion
    mov byte [strNum], '-'       ; Store '-' sign for negative numbers
    jmp divideLoop               ; Jump to division loop
```

After that we start our program by moving the dereference memory of `intNum` to the eax register.
Following,  we convert the (32-bit) double-word eax register to (64-bit) 2x double-word edx:eax register to extend the sign
for `idiv` the signed integer division operation using the `cdq` instruction.

Consequently, we set the divisor 10 to start to the `ebx` register.

After that, we check if the `eax` register is equal to 0 using the `cmp` compare command. If correct we jump using the `jum` 
command to the `divideLoop` label which will be explained in the following section.
If not, we continue to the next line `neg eax` this line negates what's inside the eax register.
Proceeding, we store a '-' sign to the strNum buffer and jump to the `didvideLoop` label.


```asm
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
```

We start by clearing what is inside the `edx` register because this part holds the remainder of the division
operation, in this way we make sure that the `edx` is clear and ready to get the correct remainder value from the `idiv`
operation.

Consequently, we start dividing `idiv ebx`. The `ebx` pre-initialize value 10 in the previous code.
After dividing, the remainder is stored in the `rdx` register and pushed to the stack using the `push` command. 

Following, we increment the `rcx` register because it counts the digit number, and we will use it later in the `popLoop` label.


Then, we check if the `eax` register that hold the remainder value is equal to zero or not, if not we jump to the label `divideLoop` again.
Otherwise, that means that there is no remainder, so we proceed to the next code.

Next, we take the address of `strNum` to the `rbx` register. We add 1 byte to `rbx` to skip the sign character before
popping each character to `strNum`.


After that, we set `rdi` register to 0 to use it as an index to the following `popLoop` label

```asm
 popLoop:
    pop rax                ; Pop intDigit
    add al, "0"            ; Convert to ASCII
    mov [rbx+rdi], al      ; Store char in string
    inc rdi                ; Increment idx
    loop popLoop           ; Continue loop until digitCount == 0
    mov byte [rbx+rdi], 10 ; Add a new line after each number
```

Finally, we pop the pushed integers and assign them correctly to `strNum`.
To accomplish that we first pop to `rax`. After that, we add the Least significant byte `al` of `rax` register with "0" from the 
ASCII table to get the correct value in ASCII for every integer in `al` register.


```asm
   mov [rbx+rdi], al      ; Store char in string
```
Consequently, we store the first popped integer `al` to `[rbx + rdi]` memory. at first `rdi` is set to 0
as you might remember in the previous section this will store the first popped value in the Least Significant Bit,
which will ensure a correct order of bytes to store the precise character to `strNum`.

Following we increment `rdi`, then we declare this magical command in Assembly,
```asm
loop popLoop           ; Continue loop until digitCount == 0
```
This code summarizes three lines of code, you remember in [inc rcx](#L86) we said we will later use it in this function.
This is what `loop` does  
```asm
dec rcx
cmp rcx, 0
jne popLoop
```
It decrements the rcx register, compares it with zero. If not equal gos back to the label `popLoop`. Otherwise, terminate 
the loop and goes to the next line of code.

After finishing adding all the characters to `strNum` add a new line at the end.
using this line of code. 
```asm
 mov byte [rbx+rdi], 10 ; Add a new line after number
```
This basically adds a new line which is decimal 10 in ASCII to end. This can only be done by declaring a byte before `[rbx+rdi]`
Otherwise, an error of invalid size will be shown from the compiler. 

### Converting ASCII characters to Integer value

Why do we need to convert ASCII characters to integers in assembly? Converting ASCII characters to integer is indeed necessary, 
especially when dealing with user input. In this situation we are building a calculator, which necessitates users to input integers onto console. 
And of course you cannot input integers in assembly as it only accepts characters. 
How to convert  ASCII characters to integers in assembly? You can do so by iterating through each character of the string
and then converting each character by subtracting the ASCII value of '0' from the character to obtain its numerical value.

In this section we explain how to achieve this step by step

```asm
section .data
    strNumber dd '-99765', 0 ; Example of a valid string
    isNegative db 0

section .bss
    intResult resq 1  ; Reserve space for the result integer

```
First we begin by declaring a 32-bit variable `strNumber` followed by a null pointer and 8 bit variable `isNegative` which is also followed by a null pointer.
Then we reserve data for `intResult` buffer. We will store our final result at `intResult`.


```asm
_start:
    mov rsi, strNumber      ; Address of the string to rsi
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
```

First, the program begins by moving the address of the string `strNumber` to the register `rsi`. Additionally, we clear the `r8` register.
Following that, we clear the `eax` register for general use. After that, `mov al, [rsi]` Loads the first character of the string into the lower 8 bits of the rax register.

- The program checks if the first character is a '-' sign. If it is, it means that it is a negative number, 
so it jumps to the `checkNextChar` label (will be explained later).

- If the first character is not '-', the program then checks if it is a '+' sign. if it is a '+', it means that it is a positive number, 
and the program jumps to  `checkNextChar` label.

- If the first character is not a sign ('-' or '+'), the program continues to check if it is a digit ('0' to '9'). 
This is done by comparing the character if it is less than 0 or greater 9 if it is then it jumps to the  `invalidInput` label (will be explained later).

```asm
checkNextChar:
    inc rsi                  ; Move to the next character for validation
```
This is the `checkNextChar` label what it basically does is move to the next character.

```asm
invalidInput:
    mov dword [intResult], 0xFFFFFFFF ; Indicate invalid input
    jmp exitProgram
```

This is the `invalidInput` label what it does is indicate invalid input and the jumps to the `exitProgram` label(will be explained at the end).

```asm
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
```

This is the `validateLoop` label.

1. `mov al, [rsi]` loads the next character of the string into the lower 8 bits of the rax register.
2. `test al, al` checks if the character is null.
3.  If the character is null it means that it is at the end of the string, which it then jumps to the `startConversion` label (will be explained next).
4. It also checks if the digit entered is valid.
5. It then increments to the next character and jumps to `validateLoop` to do the same thing for the next character.

```asm
startConversion:
    mov rsi, strNumber       ; Reset RSI to start of the string for conversion
    mov al, [rsi]            ; Re-check for a sign
    cmp al, '-'
    je negativeNumber
    cmp al, '+'
    je positiveNumber
    jmp convertLoop  
```

First, we begin by reseting the `rsi` register. After that, we re-check our first character. If the character is '-' or '+'
we jump to its respective sign for example, if it is '-' we jump to the `negativeNumber` label (both negative and positive label will be explained next).

```asm
negativeNumber:
    mov byte [isNegative], 1     ; Mark as negative
    inc rsi                      ; Skip the sign for conversion
    jmp convertLoop

positiveNumber:
    mov byte [isNegative], 0    ; Mark as positive
    inc rsi                     ; Skip the sign for conversion
```
If the first character is negative it jumps to the `negativeNumber` label which:
1. Initializes the `isNegative` flag to 1, so we can use it later to negate the number.
2. Then we increment to the next character to skip the sign for conversion.
3. Finally, we jump to the `convertLoop` label (will be explained afterwards), so that it does not change the `isNegative` flag to 0.

If the first character is positive it jumps to the `positiveNumber` label which:
1. Initializes the `isNegative` flag to 0, so we can use it later to keep the number positive.
2. Then we increment to the next character to skip the sign for conversion.

```asm
convertLoop:
    mov rax, 0                  ; Clear RAX
    mov al, [rsi]
    inc rsi
    test al, al
    jz conversionDone
    sub al, '0'
    imul r8, r8, 10
    add r8, rax
    jmp convertLoop
```

In the `convertLoop` label we begin by clearing the `rax` register. The `mov al, [rsi]` moves the bytes stored in the `rsi`
register into the lowest 8 bits of the `rax` register. Then `inc rsi` moves to the next character in teh string. 
`test al, al` sets a flag if the result is zero in the `al`(which is the lowest 8 bits in the `rax` register)
it means that it is the end of the string. `jz conversionDone` jump to the `conversionDone` label if the flag is zero.
`sub al, '0'` this subtracts the ASCII value of '0' from the ASCII value of the digit stored in al. It basically converts ASCII 
Characters to integers. `imul r8, r8, 10` this basically multiplies the value in the `r8` register (It holds the current result) by 10
which then shifts the digits in `r8` one position to the left to make new space for a new digit.
`add r8, rax` this adds the current value in `rax` to the total result in `r8` to get the new overall value.
`jmp convertLoop` this jumps back to the same label to create a loop until broken when its at the end of the string.


```asm
conversionDone:
    mov [intResult], r8       ; Store the result
    cmp byte [isNegative], 1
    jne exitProgram 
    neg dword [intResult]      ; Negate the result if negative
```
Finally in the `conversionDone` label it starts by storing the final result held in the `r8` register to a variable called
`intResult`. It then compares the value stored in `isNegative` to 1, if it is it means the result is negative, which
then negates the result using `neg dword [intResult]` afterwards it jumps to the `exitProgram` label.
```asm
exitProgram:
    ; Cleanly exit the program
    mov rax, 60
    mov rdi, 0
    syscall
```
The `exitProgram` label basically exits the program.

### How To Preform Mathematical Operations in Assembly
#### Addition Example:

```asm
 _addition:                
 mov rax, qword[num1]      
 add rax, qword[num2]      
 mov qword[ans] , rax     
 ret                       
```
This is a simple label that performs addition. This label begin by storing the 64 bit value stored in `num1` to the `rax` register.
It then adds what is already stored in the `rax` register to the second 64 bit value stored in `num2 ` using `add` instruction. After 
this the sum of `num1` and `num2` is stored in the `rax` register. Finally it stores the result in a variable `ans`.

#### Multiplication Example:

```asm
 _multiplication:          
 mov rax, qword[num1]      
 mul rax, qword[num2]     
 mov qword[ans] , rax      
 mov qword[ans + 8], rdx   

 ret   
```
In multiplication it is kinda the same. It begins by storing the first value `num1` in the `rax` register. It then uses the `mul` instruction
to multiply what is already stored in the `rax` register to the second value `num2`. Afterwards, it stores the lower 64 bits of the result stored in `rax` register
in a variable `ans`. And then its stores the upper 64 bits of the result stored in `rdx` register in a variable `ans`, 
because when we multiply it becomes 128 bits but registers can only hold 64so we split them.

### Calculator Flow Diagram

![](C:\Users\saifb\Downloads\ababababa\Assemebly.jpg)


The program begins by asking the user to input an operation to use. It them gets the operand from the user and if the 
operation is invalid it prints ("Invalid operation!") and ends the program and if not there is 2 situations.
1. The user chose the power of 2 operation. It begins by recieving a value from the user to power. It then converts the value
from ASCII to int as assembly only accepts characters. Then it performs the operation and gets the final result, which
is then converted from integer to ASCII to display on the console.
2. The user chose (+,-,*,/). It begins by asking the user to input 2 operands. The operands are then converted from ASCII
to int to preform the mathematical operation. The result is then converted from int to ASCII to be displayed at the console.