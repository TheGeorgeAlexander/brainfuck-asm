TARGET = interpreter

SRC_DIR = src
BUILD_DIR = build

COMPILE_FLAGS = -f elf64
LINKER_FLAGS = -pie -dynamic-linker /lib64/ld-linux-x86-64.so.2

ASM_FILES = $(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES = $(ASM_FILES:$(SRC_DIR)/%.asm=$(BUILD_DIR)/%.o)


all:
	mkdir -p $(BUILD_DIR)
	$(MAKE) -j $(TARGET)

$(TARGET): $(OBJ_FILES)
	ld $(LINKER_FLAGS) $^ -o $(TARGET)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	nasm $(COMPILE_FLAGS) $^ -o $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
