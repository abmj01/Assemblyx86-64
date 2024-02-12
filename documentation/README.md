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

---------------------------------------------------------------------------------------------

##### Checking the integer if and initializing variables
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

After that, we check if the `eax` register is equal to 0 using the `cmp` compare command. If correct we jump using the `jge` 
command to the `divideLoop` function which will be explained in the following section.
If not, we continue to the next line `neg eax` this line negates what's inside the eax register in the 2's complement so if the number is 7 the command will change it to -7.
Proceeding, we store a '-' sign to the strNum buffer and jump to the `didvideLoop` function.

------------------------------------------------------------------------------------------------

##### Dividing the integers and pushing the remainder to the stack
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

Following, we increment the `rcx` register because it counts the digit number, and we will use it later in the `popLoop` function.


Then, we check if the `eax` register that hold the remainder value is equal to zero or not, if not we jump to the function `divideLoop` again.
Otherwise, that means that there is no remainder, so we proceed to the next code.

Next, we take the address of `strNum` to the `rbx` register. We add 1 byte to `rbx` to skip the sign character before
popping each character to `strNum`.


After that, we set `rdi` register to 0 to use it as an index to the following `popLoop` function.

-------------------------------------------------------------------------------------------------

##### Popping the integers and initializing the integer string variable
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
It decrements the rcx register, compares it with zero. If not equal gos back to the function `popLoop`. Otherwise, terminate 
the loop and goes to the next line of code.

After finishing adding all the characters to `strNum` add a new line at the end.
using this line of code. 
```asm
 mov byte [rbx+rdi], 10 ; Add a new line after number
```
This basically adds a new line which is decimal 10 in ASCII to end. This can only be done by declaring a byte before `[rbx+rdi]`
Otherwise, an error of invalid size will be shown from the compiler. 

 


