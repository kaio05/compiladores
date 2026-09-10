
# Compiladores
CC=g++
LEX=flex++

# Dependências
all: lexer

lexer: lex.yy.cc token.h main.cpp
	$(CC) lex.yy.cc main.cpp -std=c++23 -o lexer 

lex.yy.cc: lexer.l token.h
	$(LEX) lexer.l 

clean:
	rm lexer lex.yy.cc
