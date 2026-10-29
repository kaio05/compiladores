all: parser

# Compiladores
CPP=g++
FLEX=flex
BISON=bison

parser: lex.yy.c parser.tab.c symtable.o
	$(CPP) lex.yy.c parser.tab.c symtable.o -std=gnu++20 -o parser

symtable.o: symtable.cpp symtable.h
	$(CPP) -c symtable.cpp -std=gnu++20 -o symtable.o

lex.yy.c: lexer.l
	$(FLEX) lexer.l

parser.tab.c: parser.y
	$(BISON) -d parser.y

clean:
	rm -f parser parser.exe lex.yy.c parser.tab.c parser.tab.h symtable.o
