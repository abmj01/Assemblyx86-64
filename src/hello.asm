
section .data
    hello db 'Hello, World!', 10

section .text
    global _start

_start:
    ; write 'Hello, World!' to stdout
    mov eax, 4       ; syscalll number for write
    mov ebx, 1       ; file descriptor 1 is stdout
    mov ecx, hello   ; pointer to the message
    mov edx, 13      ; length of the message
    int 0x80         ; make the system call

    ; exit program
    mov eax, 1       ; syscall number for exit
    xor ebx, ebx     ; exit code 0
    int 0x80         ;make the system call
    