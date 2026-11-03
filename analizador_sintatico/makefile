all: parser

# Compiladores
CPP=g++
FLEX=flex++
BISON=bison

# Diretorios
LEXDIR = ../analizador_lexico/
SBLDIR = ../symbol/

parser: $(LEXDIR)lex.yy.cc $(LEXDIR)AnalisadorLexico.o parser.tab.c symtable.o relatorio.cpp $(SBLDIR)symbol.o
	$(CPP) $(LEXDIR)lex.yy.cc $(LEXDIR)AnalisadorLexico.o parser.tab.c symtable.o relatorio.cpp $(SBLDIR)symbol.o -std=gnu++20 -o parser

symtable.o: symtable.cpp symtable.h $(SBLDIR)symbol.o
	$(CPP) -c symtable.cpp -std=gnu++20 -o symtable.o

../symbol/symbol.o: $(SBLDIR)Symbol.h $(SBLDIR)Symbol.cpp
	$(CPP) -c $(SBLDIR)Symbol.cpp -std=c++20 -o $(SBLDIR)symbol.o

../analizador_lexico/AnalisadorLexico.o: parser.tab.c $(LEXDIR)lex.yy.cc $(SBLDIR)symbol.o $(LEXDIR)AnalisadorLexico.cpp $(LEXDIR)AnalisadorLexico.h 
	$(CPP) -c $(LEXDIR)AnalisadorLexico.cpp -std=c++20 -o $(LEXDIR)AnalisadorLexico.o

../analizador_lexico/lex.yy.cc: $(LEXDIR)lexer.l
	$(FLEX) -o $(LEXDIR)lex.yy.cc $(LEXDIR)lexer.l

parser.tab.c: parser.y
	$(BISON) -d parser.y

clean:
	rm -f parser parser.exe $(LEXDIR)lex.yy.cc parser.tab.c parser.tab.h symtable.o $(SBLDIR)symbol.o $(LEXDIR)AnalisadorLexico.o
