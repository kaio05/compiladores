all: parser

# Compiladores
CPP=g++
FLEX=flex++
BISON=bison

# Diretorios
LEXDIR = ../analizador_lexico/
SITDIR = ../analizador_sintatico/

parser: $(LEXDIR)lex.yy.cc $(LEXDIR)Token.o $(LEXDIR)AnalisadorLexico.o parser.tab.c symtable.o relatorio.cpp
	$(CPP) $(LEXDIR)lex.yy.cc $(LEXDIR)Token.o $(LEXDIR)AnalisadorLexico.o parser.tab.c symtable.o relatorio.cpp -std=gnu++20 -o parser

symtable.o: symtable.cpp symtable.h 
	$(CPP) -c symtable.cpp -std=gnu++20 -o symtable.o

../analizador_lexico/AnalisadorLexico.o: parser.tab.c $(LEXDIR)lex.yy.cc $(LEXDIR)Token.o $(LEXDIR)AnalisadorLexico.cpp $(LEXDIR)AnalisadorLexico.h 
	$(CPP) -c $(LEXDIR)AnalisadorLexico.cpp -std=c++20 -o $(LEXDIR)AnalisadorLexico.o

../analizador_lexico/Token.o: parser.tab.c $(LEXDIR)Token.h
	$(CPP) -c $(LEXDIR)Token.cpp -std=c++20 -o $(LEXDIR)Token.o

../analizador_lexico/lex.yy.cc: $(LEXDIR)lexer.l
	$(FLEX) -o $(LEXDIR)lex.yy.cc $(LEXDIR)lexer.l

parser.tab.c: parser.y
	$(BISON) -d parser.y

clean:
	rm -f parser parser.exe $(LEXDIR)lex.yy.cc parser.tab.c parser.tab.h symtable.o $(LEXDIR)Token.o $(LEXDIR)AnalisadorLexico.o
