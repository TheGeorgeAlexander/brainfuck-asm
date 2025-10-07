# Brainfuck Assembly Interpreter

This is a [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) interpreter written in x86_64 assembly for Linux. I made this to learn assembly, so this is my first assembly project. I chose to make this because it wasn't too big of a project, while still not as trivial as a simple "Hello World!".


## Compiling

- Requirements
  - `nasm` for compiling
  - `ld` for linking
- Execute `make` to build to the project.


## Running

- Execute `./interpreter` to run the program
- Enter your Brainfuck code and press enter
- It runs! Admire the output of your beautiful code

> [!TIP]
> Use `cat path/to/your/file.b | ./interpreter` if you want to read from a file instead of manually typing/pasting your code.
