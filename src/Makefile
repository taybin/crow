all: crow print
crow: crow.icn lexer.icn
	icont crow.icn lexer.icn
clean:	
	rm -f crow *.ps *~ *.tex *.aux *.log *.dvi *.idx
install: crow
	cp -f crow /home/trutkin/bin/
print: crow.ps lexer.ps
crow.ps: crow.icn
	lgrind crow.icn > crow.tex
	latex crow.tex
	dvips crow.dvi -o crow.ps
	rm crow.tex crow.aux crow.log crow.dvi crow.idx
lexer.ps: lexer.icn
	lgrind lexer.icn > lexer.tex
	latex lexer.tex
	dvips lexer.dvi -o lexer.ps
	rm lexer.tex lexer.aux lexer.log lexer.dvi lexer.idx
