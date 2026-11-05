#pragma once

// ------------------------------------------------------------------------------

#include <string>
#include "../analizador_sintatico/parser.tab.h"

// ------------------------------------------------------------------------------

using uint = unsigned int;
using std::string;

// ------------------------------------------------------------------------------

enum class SymbolCategory {
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

struct symbol {
    yytokentype type;
    string category;
    string name;
    uint line;
    uint columnStart;
    uint columnEnd;
    string scope;
    
    symbol(){};

    symbol(
        yytokentype type, 
        string cat, 
        string name, 
        uint line, 
        uint start,
        uint end,
        string scope = ""
    ) : type(type), category(cat), name(name), line(line), columnStart(start), columnEnd(end), scope(scope){};

    virtual ~symbol() = default;

    string toString() const;
};

// ------------------------------------------------------------------------------

string SymbolTypeToString(yytokentype type);
string SymbolCategoryToString(SymbolCategory cat);
