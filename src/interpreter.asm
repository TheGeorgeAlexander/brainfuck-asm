section .data
ask_input db            "Enter your Brainfuck program: "
ask_inputlen equ        $ - ask_input
error_too_large db      10, "Error: Input too large, code can't be more than 15 kB", 10
error_too_largelen equ  $ - error_too_large
newlines db             10, 10


section .bss
codebuffer resb 15001
buffer resb 30000


section .text
    global _start

; rax: Used for syscalls
; rbx: Bracket counter to find correct matching bracket when jumping
; rcx: Not used (clobbered after syscalls)
; rdx: Used for syscalls
; rdi: Used for syscalls
; rsi: Used for syscalls
; rbp: Not used
; rsp: Not used
; r8:  Length of code buffer
; r9:  Brainfuck instruction pointer (starts at code buffer[0])
; r10: Brainfuck data pointer
_start:
    ; Ask for input
    mov     rax, 1              ; syscall write
    mov     rdi, 1              ; stdout
    lea     rsi, [ask_input]    ; msg address
    mov     rdx, ask_inputlen   ; msg length
    syscall

    ; Read Brainfuck code from stdin
    mov     rax, 0              ; syscall read
    mov     rdi, 0              ; stdin
    lea     rsi, [codebuffer]   ; storage address
    mov     rdx, 15001          ; Read max of 15001 bytes
    syscall

    cmp     rax, 15000                  ; Error if output is more than 15,000 bytes
    jle     .good_input
    mov     rax, 1                      ; syscall write
    mov     rdi, 2                      ; stderr
    lea     rsi, [error_too_large]      ; error msg address
    mov     rdx, error_too_largelen     ; error msg length
    syscall
    mov     rax, 60                     ; syscall exit
    mov     rdi, 1                      ; exit code 1
    syscall

.good_input:
    mov     r8, rax             ; Length of input

    ; Print double newline
    mov     rax, 1          ; syscall write
    mov     rdi, 1          ; stdout
    lea     rsi, [newlines] ; newline characters address
    mov     rdx, 2          ; 2 characters
    syscall

    lea     r9, [codebuffer - 1]    ; Brainfuck instruction pointer
    lea     r10, [buffer]           ; Brainfuck data pointer

; Loop over all characters in the code
char_loop:
    inc     r9         ; Increment instruction pointer
    mov     al, [r9]   ; Load instruction

    test    al, al      ; NULL means end of program, so exit
    je      exit

    ; See if character matches a Brainfuck operation
    cmp     al, '>'
    je      op_right
    cmp     al, '<'
    je      op_left
    cmp     al, '+'
    je      op_inc
    cmp     al, '-'
    je      op_dec
    cmp     al, '.'
    je      op_output
    cmp     al, ','
    je      op_input
    cmp     al, '['
    je      op_jmp_fw
    cmp     al, ']'
    je      op_jmp_bw

    jmp char_loop       ; Unknown character, just continue to next one


op_right:
    inc     r10
    jmp     char_loop


op_left:
    dec     r10
    jmp     char_loop


op_inc:
    inc     byte [r10]
    jmp     char_loop


op_dec:
    dec     byte [r10]
    jmp     char_loop


op_output:
    mov     rax, 1      ; syscall write
    mov     rdi, 1      ; stdout
    lea     rsi, [r10]  ; buffer address
    mov     rdx, 1      ; 1 character
    syscall
    jmp     char_loop


op_input:
    mov     rax, 0          ; syscall read
    mov     rdi, 0          ; stdin
    lea     rsi, [r10]      ; buffer address
    mov     rdx, 1          ; 1 character
    syscall
    cmp     rax, 0          ; 0 characters read (reached EOF)? Set byte to -1
    jne     char_loop
    mov     byte [r10], -1
    jmp     char_loop


op_jmp_fw:
    cmp     byte [r10], 0           ; Don't do anything if byte is not 0
    jne     char_loop

    mov     rbx, 1                  ; Bracket counter
    .march_to_matching:
        inc     r9
        cmp     byte [r9], '['
        jne     .no_opening_bracket
        inc     rbx                 ; Seen opening bracket, increment bracket counter
        jmp     .march_to_matching
    .no_opening_bracket:
        cmp     byte [r9], ']'
        jne     .march_to_matching
        dec     rbx                 ; Seen closing bracket, reduce bracket counter

        test    rbx, rbx
        jne     .march_to_matching  ; Bracket counter not 0? Continue to find matching bracket
        jmp     char_loop           ; Bracket counter 0, we're done here


op_jmp_bw:
    cmp     byte [r10], 0           ; Don't do anything if byte is 0
    je      char_loop

    mov     rbx, 1                  ; Bracket counter
    .march_to_matching:
        dec     r9
        cmp     byte [r9], ']'
        jne     .no_closing_bracket
        inc     rbx                 ; Seen closing bracket, increment bracket counter
        jmp     .march_to_matching
    .no_closing_bracket:
        cmp     byte [r9], '['
        jne     .march_to_matching
        dec     rbx                 ; Seen opening bracket, reduce bracket counter

        test    rbx, rbx
        jne     .march_to_matching  ; Bracket counter not 0? Continue to find matching bracket
        jmp     char_loop           ; Bracket counter 0, we're done here

exit:
    mov     rax, 60     ; syscall exit
    xor     rdi, rdi    ; exit code 0
    syscall
