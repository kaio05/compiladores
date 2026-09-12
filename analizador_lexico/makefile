
# Compiladores
CC=g++
LEX=flex++

# Dependências
all: lexer

lexer: src/lex.yy.cc src/token.h src/main.cpp
	$(CC) src/lex.yy.cc src/main.cpp -std=c++23 -o lexer 

src/lex.yy.cc: src/lexer.l src/token.h
	$(LEX) -o src/lex.yy.cc src/lexer.l 

clean:
	rm lexer src/lex.yy.cc
