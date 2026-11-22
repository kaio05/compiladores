#include "AnalisadorLexico.h"
#include <iostream>

// ------------------------------------------------------------------------------

using std::cout;

// ------------------------------------------------------------------------------

AnalisadorLexico::AnalisadorLexico() {}

// ------------------------------------------------------------------------------

AnalisadorLexico::AnalisadorLexico(ifstream& instream, ostream& outstream)
{
    lexer.switch_streams(instream, outstream);
}

// ------------------------------------------------------------------------------

AnalisadorLexico::~AnalisadorLexico()
{
    if (!validTokens.empty()) {
        for (auto symb : validTokens) {
            delete symb;
        }

        validTokens.clear();
    }

    if (!unknownTokens.empty()) {
        for (auto symb : unknownTokens) {
            delete symb;
        }

        unknownTokens.clear();
    }
}

// ------------------------------------------------------------------------------

int AnalisadorLexico::yylex() 
{
    int readToken = lexer.yylex();

    if (readToken <= 0) {
        return readToken;
    }

    yyTokenCategory tokenClass = classifyTokens(readToken);

    currentToken = token(
        static_cast<yytokentype>(readToken),
        tokenClass,
        lexer.YYText(),
        lexer.lineno(),
        yyColumnStart,
        yyColumnEnd
    );

    classifiedTokens[tokenClass]++;

    if (readToken == UNKNOWN) {
        unknownTokens.push_back(new token(currentToken));
    } else {
        validTokens.push_back(new token(currentToken));
    }

    return readToken;
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::yySwitchStreams(ifstream& instream, ostream& outstream)
{
    lexer.switch_streams(instream, outstream);

    if (!validTokens.empty()) {
        for (auto symb : validTokens) {
            delete symb;
        }
        validTokens.clear();
    }

    if (!classifiedTokens.empty()) {
        classifiedTokens.clear();
    }

    if (!unknownTokens.empty()) {
        for (auto symb : unknownTokens) {
            delete symb;
        }
        unknownTokens.clear();
    }
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::start()
{
    cout << "===============\n" << "Visão analítica\n" << "===============\n";

    while(this->yylex() > 0) {
        cout << "<Token: " 
             << TokenTypeToString(currentToken.type) << ", " 
             << TokenCategoryToString(currentToken.category) << ", " 
             << "\"" << currentToken.name << "\"" 
             << ", line: " << currentToken.line
             << ", column start:" << yycolumnStart 
             << ", column end: " << yycolumnEnd
             << ">\n";
    }

    cout << "\nFim do arquivo.\n\n";

    printResults();
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::printResults()
{
    cout << "=================\n" << "Tabela de síntese\n" << "=================\n";

    for(auto pair: classifiedTokens) {
        cout << TokenCategoryToString(pair.first) << ": "<< pair.second << "\n";
    }

    if (!unknownTokens.empty()) {
        cout << "\n\n";
        cout << "====================\n" << "Tokens desconhecidos\n" << "====================\n";

        for (auto token : unknownTokens) {
            cout << "Caractere: \"" 
            << token->name << "\" desconhecido." 
            << " Linha: " << token->line 
            << ". Colunas: " << token->columnStart
            << " a " << token->columnEnd << "."
            << "\n";
        }
    }
}

// ------------------------------------------------------------------------------

token* AnalisadorLexico::TokenAtBack(int index) 
{
    if (validTokens.empty()) {
        return nullptr;
    }

    auto endIterator = validTokens.end();
    endIterator--;

    for (int i = 0; i < index; i++) {
        endIterator--;
    }

    return *endIterator;
}

// ------------------------------------------------------------------------------

yyTokenCategory AnalisadorLexico::classifyTokens(uint type)
{
    if (type >= (uint)yyTokenCategory::CLASS_STEREOTYPES && type < (uint)yyTokenCategory::RESERVED_WORDS) {
        return yyTokenCategory::CLASS_STEREOTYPES; 
    } 
    else if (type >= (uint)yyTokenCategory::RESERVED_WORDS && type < (uint)yyTokenCategory::GENERALIZATION) {
        return yyTokenCategory::RESERVED_WORDS;
    } 
    else if (type >= (uint)yyTokenCategory::GENERALIZATION && type < (uint)yyTokenCategory::PRIMITIVE_TYPE) {
        return yyTokenCategory::GENERALIZATION;
    }
    else if (type >= (uint)yyTokenCategory::PRIMITIVE_TYPE && type < (uint)yyTokenCategory::META_ATTRIBUTE) {
        return yyTokenCategory::PRIMITIVE_TYPE;
    }
    else if (type >= (uint)yyTokenCategory::META_ATTRIBUTE && type < (uint)yyTokenCategory::RELATION_STEREOTYPES) {
        return yyTokenCategory::META_ATTRIBUTE;
    } 
    else if (type >= (uint)yyTokenCategory::RELATION_STEREOTYPES && type < (uint)yyTokenCategory::RELATION_OP) {
        return yyTokenCategory::RELATION_STEREOTYPES;
    }
    else if (type >= (uint)yyTokenCategory::RELATION_OP && type < (uint)yyTokenCategory::SPECIAL_SYMBOL) {
        return yyTokenCategory::RELATION_OP;
    }
    else if (type >= (uint)yyTokenCategory::SPECIAL_SYMBOL && type < (uint)yyTokenCategory::NUMBER_LITERAL){
        return yyTokenCategory::SPECIAL_SYMBOL;
    }

    return static_cast<yyTokenCategory>(type);
}
