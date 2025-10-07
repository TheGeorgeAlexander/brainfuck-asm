section .data
code db         "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", 0
code_len equ    $ - code - 1
newline db      10

section .bss
buffer resb 30000

section .text
    global _start

_start:
    ; Print entire brainfuck code
    mov     rax, 1          ; syscall write
    mov     rdi, 1          ; stdout
    lea     rsi, [code]     ; code address
    mov     rdx, code_len   ; code length
    syscall

    ; Print newline twice
    mov     rax, 1          ; syscall write
    mov     rdi, 1          ; stdout
    lea     rsi, [newline]  ; newline character address
    mov     rdx, 1          ; 1 char
    syscall
    syscall

    ; Store address to the code in rbx
    lea     rbx, [code - 1]

    ; Brainfuck data pointer
    lea     r12, [buffer]

; Loop over all characters in the code
char_loop:
    inc     rbx
    mov     al, [rbx]
    cmp     al, 0
    je      exit

    cmp     al, '>'
    je      datapointer_right
    cmp     al, '<'
    je      datapointer_left
    cmp     al, '+'
    je      inc_value
    cmp     al, '-'
    je      dec_value
    cmp     al, '.'
    je      output_value
    cmp     al, ','
    je      input_value
    cmp     al, '['
    je      if_zero_go_forward
    cmp     al, ']'
    je      if_nonzero_go_back


datapointer_right:
    inc     r12
    jmp     char_loop

datapointer_left:
    dec     r12
    jmp     char_loop

inc_value:
    inc     byte [r12]
    jmp     char_loop

dec_value:
    dec     byte [r12]
    jmp     char_loop

output_value:
    mov     rax, 1      ; syscall write
    mov     rdi, 1      ; stdout
    lea     rsi, [r12]  ; buffer address
    mov     rdx, 1      ; 1 character
    syscall
    jmp     char_loop

input_value:
    mov     rax, 0      ; syscall read
    mov     rdi, 0      ; stdin
    lea     rsi, [r12]  ; buffer address
    mov     rdx, 1      ; 1 character
    syscall
    jmp     char_loop

if_zero_go_forward:
    ; Don't do anything if data pointer is not 0
    cmp     byte [r12], 0
    jne     char_loop

    ; Bracket counter
    mov     r13, 1
march_to_matching_close:
    inc     rbx
    cmp     byte [rbx], '['
    jne     no_opening_bracket
    inc     r13
    jmp     march_to_matching_close
no_opening_bracket:
    cmp     byte [rbx], ']'
    jne     march_to_matching_close
    dec     r13 ; Seen closing bracket, reduce bracket counter

    ; Only matching if r13 is 0
    cmp     r13, 0
    jne     march_to_matching_close
    jmp     char_loop

if_nonzero_go_back:
    ; Don't do anything if data pointer is 0
    cmp     byte [r12], 0
    je      char_loop

    ; Bracket counter
    mov     r13, 1
march_to_matching_open:
    dec     rbx
    cmp     byte [rbx], ']'
    jne     no_closing_bracket
    inc     r13
    jmp     march_to_matching_open
no_closing_bracket:
    cmp     byte [rbx], '['
    jne     march_to_matching_open
    dec     r13 ; Seen open bracket, reduce bracket counter

    ; Only matching if r13 is 0
    cmp     r13, 0
    jne     march_to_matching_open
    jmp     char_loop

exit:
    mov     rax, 60     ; syscall exit
    xor     rdi, rdi    ; exit code 0
    syscall
