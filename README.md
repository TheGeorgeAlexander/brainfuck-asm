# Brainfuck Assembly Interpreter

This is a [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) interpreter written in x86_64 assembly for Linux. I made this to learn assembly, so this is my first assembly project. I chose to make this because it wasn't too big of a project, while still not as trivial as a simple "Hello World!".


## Setting the Brainfuck code
Open `src/interpreter.asm` and put your Brainfuck code between the quotation marks on the second line:
```asm
section .data
code db         "<BRAINFUCK CODE HERE>", 0
code_len equ    $ - code - 1
newline db      10
...
```


## Compiling and running

- Requirements:
  - `nasm` for compiling
  - `ld` for linking
- Execute `make` to build to the project.
- Execute `./interpreter` to run the Brainfuck code and see its output!

> [!NOTE]
> You will get `warning: 32-bit absolute section-crossing relocation [-w+reloc-abs-dword]` when compiling. This is harmless and I understand the issue, but I'm not sure how to get rid of it without creating other warnings.

