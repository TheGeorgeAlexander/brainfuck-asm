default rel

global _start

; Defined in code_reader.asm
extern stdin_input
extern file_input



section .data
err_too_many_args db        "Error: Incorrect usage, too many arguments", 10, "Usage:", 10, "    ./interpreter           Manually enter brainfuck code", 10, "    ./interpreter <PATH>    Read brainfuck code from a file", 10
err_too_many_argslen equ    $ - err_too_many_args

err_close_bracket db        10, "Error: No matching closing bracket", 10
err_close_bracketlen equ    $ - err_close_bracket

err_open_bracket db         10, "Error: No matching opening bracket", 10
err_open_bracketlen equ     $ - err_open_bracket

err_dp_too_low db           10, "Error: Can't move data pointer left when at the first cell", 10
err_dp_too_lowlen equ       $ - err_dp_too_low

err_dp_too_high db          10, "Error: Can't move data pointer right when at the last cell (50,000 cells)", 10
err_dp_too_highlen equ      $ - err_dp_too_high



section .bss
codebuffer resb 500001
buffer resb 50000



section .text
; rax: Used for syscalls
; rbx: Bracket counter to find correct matching bracket when jumping
; rcx: Not used (clobbered after syscalls)
; rdx: Used for syscalls
; rdi: Used for syscalls
; rsi: Used for syscalls
; rbp: Not used
; rsp: Not used
; r8:  Length of code buffer
; r9:  brainfuck instruction pointer (starts at code buffer[0])
; r10: brainfuck data pointer
_start:
    pop     rax                 ; Number of CLI arguments
    lea     rdi, [codebuffer]   ; Address of buffer to store code

    cmp     rax, 1              ; Got 0 arguments, read from stdin
    jne     .has_arguments
    call    stdin_input         ; stdin_input(char *codebuffer)
    jmp     has_read_input

.has_arguments:
    cmp     rax, 2              ; Got 1 argument, read from file
    jne     .too_many_arguments
    pop     rsi
    pop     rsi                 ; Pathname of file
    call    file_input          ; file_input(char *codebuffer, char *pathname)
    jmp     has_read_input

.too_many_arguments:
    mov     rax, 1                      ; syscall write
    mov     rdi, 2                      ; stderr
    lea     rsi, [err_too_many_args]    ; error msg address
    mov     rdx, err_too_many_argslen   ; error msg length
    syscall
    jmp     exit_error

has_read_input:
    mov     r8, rax                 ; Length of code
    lea     r9, [codebuffer - 1]    ; brainfuck instruction pointer
    lea     r10, [buffer]           ; brainfuck data pointer

; Loop over all characters in the code
char_loop:
    inc     r9          ; Increment instruction pointer
    mov     al, [r9]    ; Load instruction

    test    al, al      ; NULL means end of program, so exit
    je      exit

    ; See if character matches a brainfuck operation
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
    lea     rax, [buffer + 50000]
    cmp     r10, rax                ; Error if out of bounds
    jl      char_loop
    mov     rax, 1                  ; syscall write
    mov     rdi, 2                  ; stderr
    lea     rsi, [err_dp_too_high]  ; error address
    mov     rdx, err_dp_too_highlen ; error length
    syscall
    jmp     exit_error


op_left:
    dec     r10
    lea     rax, [buffer]
    cmp     r10, rax                ; Error if out of bounds
    jge     char_loop
    mov     rax, 1                  ; syscall write
    mov     rdi, 2                  ; stderr
    lea     rsi, [err_dp_too_low]   ; error address
    mov     rdx, err_dp_too_lowlen  ; error length
    syscall
    jmp     exit_error


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
    cmp     rax, 0          ; 0 characters read (reached EOF)? Set cell to -1
    jne     char_loop
    mov     byte [r10], -1
    jmp     char_loop


op_jmp_fw:
    cmp     byte [r10], 0           ; Don't do anything if cell is not 0
    jne     char_loop

    mov     rbx, 1                  ; Bracket counter
    .march_to_matching:
        inc     r9
        lea     rax, [codebuffer]
        add     rax, r8                     ; Address after code
        cmp     r9, rax                     ; Error if data pointer is out of bounds
        jl      .in_bounds
        mov     rax, 1                      ; syscall write
        mov     rdi, 2                      ; stderr
        lea     rsi, [err_close_bracket]    ; error msg address
        mov     rdx, err_close_bracketlen   ; error msg length
        syscall
        jmp exit_error
    .in_bounds:
        cmp     byte [r9], '['
        jne     .no_opening_bracket
        inc     rbx                     ; Seen opening bracket, increment bracket counter
        jmp     .march_to_matching
    .no_opening_bracket:
        cmp     byte [r9], ']'
        jne     .march_to_matching
        dec     rbx                     ; Seen closing bracket, reduce bracket counter

        test    rbx, rbx
        jne     .march_to_matching      ; Bracket counter not 0? Continue to find matching bracket
        jmp     char_loop               ; Bracket counter 0, we're done here


op_jmp_bw:
    cmp     byte [r10], 0           ; Don't do anything if cell is 0
    je      char_loop

    mov     rbx, 1                  ; Bracket counter
    .march_to_matching:
        dec     r9
        lea     rax, [codebuffer]
        cmp     r9, rax                     ; Error if data pointer is out of bounds
        jge     .in_bounds
        mov     rax, 1                      ; syscall write
        mov     rdi, 2                      ; stderr
        lea     rsi, [err_open_bracket]     ; error msg address
        mov     rdx, err_open_bracketlen    ; error msg length
        syscall
        jmp exit_error
    .in_bounds:
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

exit_error:
    mov     rax, 60     ; syscall exit
    mov     rdi, 1      ; exit code 1
    syscall
