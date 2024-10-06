.PHONY: clean

all:
	ocamlbuild -use-menhir main.native
	cp main.native ../llang-classical

clean:
	ocamlbuild -clean
	@rm -f *~ main.native \#*

