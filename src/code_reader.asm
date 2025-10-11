default rel

global stdin_input
global file_input



section .data
ask_input db                "Enter your brainfuck program: "
ask_inputlen equ            $ - ask_input

newlines db                 10, 10

err_file db                 10, "Error: Can't open file to read brainfuck code", 10
err_filelen equ             $ - err_file

err_too_large db            10, "Error: Input too large, code can't be larger than 500 kB", 10
err_too_largelen equ        $ - err_too_large

err_read db                 10, "Error: Error while trying to read the code", 10
err_readlen equ             $ - err_read

err_read_nothing db         10, "Error: Read 0 bytes while trying to read the code", 10
err_read_nothinglen equ     $ - err_read_nothing




section .text
; Paramaters:
;       rdi: Address of code buffer
stdin_input:
    mov     r8, rdi

    mov     rax, 1              ; syscall write
    mov     rdi, 1              ; stdout
    lea     rsi, [ask_input]    ; msg address
    mov     rdx, ask_inputlen   ; msg length
    syscall

    xor     rdi, rdi    ; File descriptor for stdin
    mov     rsi, r8     ; Address of code buffer
    call    read_fd     ; Read from stdin
    mov     r10, rax    ; Length of code that was read

    mov     rax, 1          ; syscall write
    mov     rdi, 1          ; stdout
    lea     rsi, [newlines] ; msg pointer
    mov     rdx, 2          ; msg length (2 characters)
    syscall

    mov     rax, r10    ; Length of code that was read
    ret



; Parameters:
;       rdi: Address of code buffer
;       rsi: Address of pathname
file_input:
    mov     r8, rdi

    mov     rax, 2      ; syscall open
    mov     rdi, rsi    ; Pathname
    xor     rsi, rsi    ; O_RDONLY (read only)
    syscall
    
    test    rax, rax    ; Check for error from open
    jl      .file_error

    mov     rdi, rax    ; File descriptor for the file
    push    rdi
    mov     rsi, r8     ; Address of code buffer
    call    read_fd     ; Read from the file
    mov     rsi, rax    ; Length of code that was read

    mov     rax, 3      ; syscall close
    pop     rdi         ; File descriptor
    syscall

    mov     rax, rsi    ; Length of code that was read
    ret

.file_error:
    mov     rax, 1              ; syscall write
    mov     rdi, 2              ; stderr
    lea     rsi, [err_file]     ; error msg address
    mov     rdx, err_filelen    ; error msg length
    syscall
    jmp     exit_error



; rdi: File descriptor
; rsi: Buffer to read into
read_fd:
    mov     rax, 0              ; syscall read
    mov     rdx, 500001         ; Read max of 50,001 bytes
    syscall

    test    rax, rax
    je      .read_nothing       ; Error if it read 0 bytes
    jl      .read_error         ; Error if it returned an error code

    cmp     rax, 500000         ; Error if input is more than 50,000 bytes
    jg      .read_too_much

    ret                         ; No error, return with code length in rax

.read_error:
    mov     rax, 1              ; syscall write
    mov     rdi, 2              ; stderr
    lea     rsi, [err_read]     ; error msg address
    mov     rdx, err_readlen    ; error msg length
    syscall
    jmp     exit_error

.read_too_much:
    mov     rax, 1                  ; syscall write
    mov     rdi, 2                  ; stderr
    lea     rsi, [err_too_large]    ; error msg address
    mov     rdx, err_too_largelen   ; error msg length
    syscall
    jmp     exit_error

.read_nothing:
    mov     rax, 1                      ; syscall write
    mov     rdi, 2                      ; stderr
    lea     rsi, [err_read_nothing]     ; error msg address
    mov     rdx, err_read_nothinglen    ; error msg length
    syscall
    jmp     exit_error


exit_error:
    mov     rax, 60     ; syscall exit
    mov     rdi, 1      ; exit code 1
    syscall

