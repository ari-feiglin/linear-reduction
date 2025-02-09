all:
	-pdflatex --interaction=nonstopmode paper
	pdflatex paper
	bibtex paper
	pdflatex paper
	pdflatex paper

clean:
	rm -f *~ *.aux *.bbl *.blg *.log *.out paper.pdf *.dvi paper.run.xml paper.bcf
