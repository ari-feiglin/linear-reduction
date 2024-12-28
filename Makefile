all:
	eval $(opam env)
	$(MAKE) -C ./Source
	eval $(opam env)
	$(MAKE) -C ./Classical-Source
	eval $(opam env)
	$(MAKE) -C ./Optimized-Source
