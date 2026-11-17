#pragma once

// ------------------------------------------------------------------------------

#include <fstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <FlexLexer.h>
#include "Token.h"
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
    token currentToken;

    vector<token*> validTokens;
    unordered_map<yyTokenCategory, int> classifiedTokens;
    vector<token*> unknownTokens;

public: 
    AnalisadorLexico();
    AnalisadorLexico(ifstream& instream, ostream& outstream);
    ~AnalisadorLexico();

    void yySwitchStreams(ifstream& instream, ostream& outstream);
    
    int yylex();
    void start();
    void printResults();

    yyTokenCategory classifyTokens(uint type);

    token CurrentToken();
    token TokenAt(int index);
    token* TokenAtBack(int index);

    uint yyline();
    uint currentColumnStart();
    uint currentColumnEnd();

    unordered_map<yyTokenCategory, int>& ClassifiedTokens();
    vector<token*>& UnknownTokens();
};

inline token AnalisadorLexico::CurrentToken() {
    return currentToken;
}

inline token AnalisadorLexico::TokenAt(int index) {
    return *validTokens.at(index);
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

inline unordered_map<yyTokenCategory, int>& AnalisadorLexico::ClassifiedTokens() {
    return classifiedTokens;
}

inline vector<token*>& AnalisadorLexico::UnknownTokens() {
    return unknownTokens;
}
