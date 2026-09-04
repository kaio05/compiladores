
# Compiladores
CC=g++
LEX=flex++

# Dependências
all: lexer

lexer: lex.yy.cc
	$(CC) lex.yy.cc -std=c++17 -o lexer

lex.yy.cc: lexer.l
	$(LEX) lexer.l

clean:
	rm lexer lex.yy.cc
