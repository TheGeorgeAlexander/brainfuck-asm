TARGET = interpreter
FLAGS = -f elf64 -w+all

SRC_DIR = src
BUILD_DIR = build


ASM_FILES = $(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES = $(ASM_FILES:$(SRC_DIR)/%.asm=$(BUILD_DIR)/%.o)


$(TARGET): $(OBJ_FILES)
	ld -o $(TARGET) $(OBJ_FILES)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(BUILD_DIR)
	nasm $(FLAGS) $< -o $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
