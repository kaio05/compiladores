
# Compilers
CPP = g++
FLEX = flex
BISON = bison

# Compiler flags
CXXFLAGS = -std=c++20 -Wall -Wextra
TARGET = compiler

# Default target
all: $(TARGET)

# Generate the executable
$(TARGET): main.cpp analizador_lexico/lex.yy.c analizador_sintatico/parser.tab.c
	$(CPP) $(CXXFLAGS) -Ianalizador_lexico -Ianalizador_sintatico \
		main.cpp \
		analizador_lexico/lex.yy.c \
		analizador_sintatico/parser.tab.c \
		-o $(TARGET)

# Generate the Flex lexical analyzer
analizador_lexico/lex.yy.c: analizador_lexico/lexer.l analizador_lexico/AnalizadorLexico.h
	$(FLEX) -o $@ $<

# Generate the Bison parser and header
analizador_sintatico/parser.tab.c analizador_sintatico/parser.tab.h &: analizador_sintatico/parser.y
	$(BISON) -d -o analizador_sintatico/parser.tab.c analizador_sintatico/parser.y

# Remove generated files and executable
clean:
	rm -f $(TARGET) \
		analizador_lexico/lex.yy.c \
		analizador_sintatico/parser.tab.c \
		analizador_sintatico/parser.tab.h

.PHONY: all clean
