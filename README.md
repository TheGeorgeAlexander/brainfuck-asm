# Brainfuck Assembly Interpreter

This is a [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) interpreter written in x86_64 assembly for Linux. I made this to learn assembly, so this is my first assembly project. I chose to make this because it wasn't too big of a project, while still not as trivial as a simple "Hello World!".


## Compiling

> [!NOTE]
> You will get multiple `warning: 32-bit absolute section-crossing relocation [-w+reloc-abs-dword]` when compiling. This is harmless and I understand the issue, but I'm not sure how to get rid of it without disabling warnings or creating other warnings.

- Requirements
  - `nasm` for compiling
  - `ld` for linking
- Execute `make` to build to the project.


## Running

> [!TIP]
> Don't want to manually paste/type your program each time? Run it from a file with `cat path/to/your/file.b | ./interpreter`

- Execute `./interpreter` to run the program
- Enter your Brainfuck code and press enter
- It runs! Admire the output of your beautiful code
