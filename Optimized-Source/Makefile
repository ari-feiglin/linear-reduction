CC := ocamlopt
EXE_NAME := ../ilang-opt
SOURCES := lexer.ml reducer.ml main.ml

all:
	$(CC) $(SOURCES) -o $(EXE_NAME)

clean:
	rm ./*.cmx ./*.cmi ./*.cmo ./*.o $(EXE_NAME)

