EXE_NAME := ../llang
BUILD_DIR := ./build
SOURCES := lexer.ml reducer.ml main.ml

BUILD_SRC = $(patsubst %.ml,$(BUILD_DIR)/%.cmx,$(SOURCES))

all: $(BUILD_DIR) $(EXE_NAME)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(EXE_NAME): $(BUILD_SRC)
	ocamlopt $^ -o $(EXE_NAME)

$(BUILD_DIR)/%.cmx : %.ml
	ocamlopt -c $< -o $@

clean:
	rm build/* $(EXE_NAME)
