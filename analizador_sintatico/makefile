all: parser

# Compiladores
CPP=g++
FLEX=flex
BISON=bison

parser: lex.yy.c parser.tab.c
	$(CPP) lex.yy.c parser.tab.c -std=c++17 -o parser

lex.yy.c: lexer.l
	$(FLEX) lexer.l

parser.tab.c: parser.y
	$(BISON) -d parser.y

clean:
	rm parser lex.yy.c parser.tab.c parser.tab.h
