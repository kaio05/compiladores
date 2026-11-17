#pragma once

// ------------------------------------------------------------------------------

#include <string>
#include "../analizador_sintatico/parser.tab.h"

// ------------------------------------------------------------------------------

using uint = unsigned int;
using std::string;

// ------------------------------------------------------------------------------

enum class yyTokenCategory {
    CLASS_STEREOTYPES = yytokentype::EVENT,
    RESERVED_WORDS = yytokentype::RELATION,
    GENERALIZATION = yytokentype::GENSET,
    PRIMITIVE_TYPE = yytokentype::NUMBER,
    META_ATTRIBUTE = yytokentype::ORDERED,
    RELATION_STEREOTYPES = yytokentype::MATERIAL,
    RELATION_OP = yytokentype::DASH,
    SPECIAL_SYMBOL = yytokentype::OPEN_BRACES, 
    NUMBER_LITERAL = yytokentype::NUMBER_LITERAL,
    CARDINALITY = yytokentype::CARDINALITY,
    INSTANCE_NAME = yytokentype::INSTANCE_NAME,
    NEW_TYPE = yytokentype::NEW_TYPE,
    CLASS_NAME = yytokentype::CLASS_NAME,
    RELATION_NAME = yytokentype::RELATION_NAME,
    PACKAGE_NAME = yytokentype::PACKAGE_NAME,
    UNKNOWN_TOKEN = yytokentype::UNKNOWN
};

// ------------------------------------------------------------------------------

struct token {
    yytokentype type;
    yyTokenCategory category;
    string name;
    uint line;
    uint columnStart;
    uint columnEnd;
    
    token(){};

    token(
        yytokentype type, 
        yyTokenCategory cat, 
        string name, 
        uint line, 
        uint start,
        uint end
    ) : type(type), category(cat), name(name), line(line), columnStart(start), columnEnd(end){};

    virtual ~token() = default;

    string toString() const;
};

// ------------------------------------------------------------------------------

string TokenTypeToString(yytokentype type);
string TokenCategoryToString(yyTokenCategory cat);
