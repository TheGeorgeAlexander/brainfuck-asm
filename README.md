# Brainfuck Assembly Interpreter

This is a [brainfuck](https://en.wikipedia.org/wiki/Brainfuck) interpreter written in x86_64 assembly for Linux. I made this to learn assembly, so this is my first assembly project. I chose to make this because it wasn't too big of a project, while still not as trivial as a simple "Hello World!".

The interpreter has 50,000 brainfuck cells, each is a single byte. The data pointer starts at the leftmost cell. If EOF (end-of-file) is read as input during execution, the cell will be set to -1.


## Compiling

- Requirements
  - `nasm` for compiling
  - `ld` for linking
- Execute `make` to build to the project.


## Running

Your code can't be bigger than 500 kB. Any character that is not a brainfuck command is ignored.
```
Usage:
    ./interpreter           Manually enter brainfuck code
    ./interpreter <PATH>    Read brainfuck code from a file
```
