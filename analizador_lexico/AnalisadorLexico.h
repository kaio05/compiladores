#pragma once

// ------------------------------------------------------------------------------

#include <fstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <FlexLexer.h>
#include "../symbol/Symbol.h"
#include "../analizador_sintatico/parser.tab.h"

// ------------------------------------------------------------------------------

using uint = unsigned int;

using std::ifstream;
using std::ostream;
using std::string;
using std::vector;
using std::unordered_map;

// ------------------------------------------------------------------------------

extern int yycolumnStart;
extern int yycolumnEnd;

// ------------------------------------------------------------------------------

class AnalisadorLexico
{
private:
    static inline int& yyColumnStart = yycolumnStart;
    static inline int& yyColumnEnd = yycolumnEnd;

    yyFlexLexer lexer;
    symbol currentSymbol;

    vector<symbol*> validSymbols;
    unordered_map<SymbolCategory, int> classifiedSymbols;
    vector<symbol*> unknownSymbols;

public: 
    AnalisadorLexico();
    AnalisadorLexico(ifstream& instream, ostream& outstream);
    ~AnalisadorLexico();

    void yySwitchStreams(ifstream& instream, ostream& outstream);
    
    int yylex();
    void start();

    SymbolCategory classifySymbols(uint type);

    symbol CurrentSymbol();
    symbol SymbolAt(int index);
    symbol* SymbolAtBack(int index);

    uint yyline();
    uint currentColumnStart();
    uint currentColumnEnd();

    unordered_map<SymbolCategory, int>& ClassifiedSymbols();
    vector<symbol*>& UnknownSymbols();
};

inline symbol AnalisadorLexico::CurrentSymbol() {
    return currentSymbol;
}

inline symbol AnalisadorLexico::SymbolAt(int index) {
    return *validSymbols.at(index);
}

inline uint AnalisadorLexico::yyline() {
    return lexer.lineno();
}

inline uint AnalisadorLexico::currentColumnStart() {
    return yyColumnStart;
}

inline uint AnalisadorLexico::currentColumnEnd() {
    return yyColumnEnd;
}

inline unordered_map<SymbolCategory, int>& AnalisadorLexico::ClassifiedSymbols() {
    return classifiedSymbols;
}

inline vector<symbol*>& AnalisadorLexico::UnknownSymbols() {
    return unknownSymbols;
}
