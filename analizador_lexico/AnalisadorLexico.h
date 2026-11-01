#pragma once

// ------------------------------------------------------------------------------

#include <FlexLexer.h>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include "../analizador_sintatico/parser.tab.h"

// ------------------------------------------------------------------------------

using uint = unsigned int;

using std::ifstream;
using std::ostream;
using std::string;
using std::vector;
using std::map;
using std::unordered_map;

// ------------------------------------------------------------------------------

extern int yycolumnStart;
extern int yycolumnEnd;

// ------------------------------------------------------------------------------

struct token {
    uint type;
    uint classification;
    string lexeme;
    uint line;
    uint columnStart;
    uint columnEnd;
    
    token(){};

    token(uint type, uint classification, string lexeme, uint line, uint start, uint end) 
    : type(type), classification(classification), lexeme(lexeme), line(line), columnStart(start), columnEnd(end){};
};

// ------------------------------------------------------------------------------

enum class tokenClass {
    RESERVED_WORDS = yytokentype::GENSET,
    PRIMITIVE_TYPE = yytokentype::NUMBER,
    META_ATTRIBUTE = yytokentype::ORDERED,
    CLASS_STEREOTYPES = yytokentype::EVENT,
    RELATION_STEREOTYPES = yytokentype::MATERIAL,
    NUMBER_LITERAL = yytokentype::NUMBER_LITERAL,
    DATA_TYPE = yytokentype::DATA_TYPE,
    INSTANCE_NAME = yytokentype::INSTANCE_NAME,
    NEW_TYPE = yytokentype::NEW_TYPE, 
    CLASS_NAME = yytokentype::CLASS_NAME,
    RELATION_NAME = yytokentype::RELATION_NAME, 
    UNKNOWN_SYMBOL = yytokentype::UNKNOWN,
    SPECIAL_SYMBOL = yytokentype::OPEN_BRACES, 
    RELATION_OP = yytokentype::RELATION_KW,
    ENUM = yytokentype::ENUM,
    ATTR_NAME = yytokentype::ATTR_NAME
};

// ------------------------------------------------------------------------------

class AnalisadorLexico
{
private:
    static const map<yytokentype, string> tokenTypeNames;
    static const map<tokenClass, string> tokenClassNames;

    static inline int& yyColumnStart = yycolumnStart;
    static inline int& yyColumnEnd = yycolumnEnd;

    yyFlexLexer lexer;
    token currentToken;

    unordered_map<int, int> classificatedToken;
    vector<token> unknownToken;

public: 
    AnalisadorLexico();
    AnalisadorLexico(ifstream& instream, ostream& outstream);

    int yylex();
    void yySwitchStreams(ifstream& instream, ostream& outstream);

    void start();

    tokenClass classifyTokens(uint type);

    token CurrentToken();
    vector<token>& UnknownToken();
    unordered_map<int, int>& ClassificatedTokens();
};

inline token AnalisadorLexico::CurrentToken() {
    return currentToken;
}

inline vector<token>& AnalisadorLexico::UnknownToken() {
    return unknownToken;
}

inline unordered_map<int, int>& AnalisadorLexico::ClassificatedTokens() {
    return classificatedToken;
}
