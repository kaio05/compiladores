
# Compiladores
CPP = g++
FLEX = flex++
BISON = bison

# flags
CPPFLAGS = -std=c++20

# Saida da compilação
TARGET = compiler

all: $(TARGET)

# Gera o excutavel
$(TARGET): main.cpp analizador_lexico/lex.yy.cc analizador_sintatico/parser.tab.c
	$(CPP) $(CPPFLAGS) -Ianalizador_lexico -Ianalizador_sintatico \
		main.cpp \
		analizador_lexico/lex.yy.cc \
		analizador_sintatico/parser.tab.c \
		-o $(TARGET)


#Gera o analizador lexico
analizador_lexico/lex.yy.cc: analizador_lexico/lexer.l analizador_lexico/AnalizadorLexico.h analizador_sintatico/parser.tab.h
	$(FLEX) -o analizador_lexico/lex.yy.cc analizador_lexico/lexer.l


# Gera o analizador sintatico
analizador_sintatico/parser.tab.c analizador_sintatico/parser.tab.h &: analizador_sintatico/parser.y
	$(BISON) -d -o analizador_sintatico/parser.tab.c analizador_sintatico/parser.y


# clean
clean:
	rm -f $(TARGET) \
		analizador_lexico/lex.yy.cc \
		analizador_sintatico/parser.tab.c \
		analizador_sintatico/parser.tab.h

.PHONY: all clean
