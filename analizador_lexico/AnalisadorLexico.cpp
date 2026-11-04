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
    if (!validSymbols.empty()) {
        for (auto symb : validSymbols) {
            delete symb;
        }

        validSymbols.clear();
    }

    if (!unknownSymbols.empty()) {
        for (auto symb : unknownSymbols) {
            delete symb;
        }

        unknownSymbols.clear();
    }
}

// ------------------------------------------------------------------------------

int AnalisadorLexico::yylex() 
{
    int readToken = lexer.yylex();

    if (readToken <= 0) {
        return readToken;
    }

    SymbolCategory symbolClass = classifySymbols(readToken);

    currentSymbol = symbol(
        static_cast<yytokentype>(readToken),
        SymbolCategoryToString(symbolClass),
        lexer.YYText(),
        lexer.lineno(),
        yyColumnStart,
        yyColumnEnd
    );

    classifiedSymbols[symbolClass]++;

    if (readToken == UNKNOWN) {
        unknownSymbols.push_back(new symbol(currentSymbol));
    } else {
        validSymbols.push_back(new symbol(currentSymbol));
    }

    return readToken;
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::yySwitchStreams(ifstream& instream, ostream& outstream)
{
    lexer.switch_streams(instream, outstream);

    if (!validSymbols.empty()) {
        for (auto symb : validSymbols) {
            delete symb;
        }
        validSymbols.clear();
    }

    if (!classifiedSymbols.empty()) {
        classifiedSymbols.clear();
    }

    if (!unknownSymbols.empty()) {
        for (auto symb : unknownSymbols) {
            delete symb;
        }
        unknownSymbols.clear();
    }
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::start()
{
    cout << "===============\n" << "Visão analítica\n" << "===============\n";

    while(this->yylex() > 0) {
        cout << "<Token: " 
             << SymbolTypeToString(currentSymbol.type) << ", " 
             << currentSymbol.category << ", " 
             << "\"" << currentSymbol.name << "\"" 
             << ", line: " << currentSymbol.line
             << ", column start:" << yycolumnStart 
             << ", column end: " << yycolumnEnd
             << ">\n";
    }

    cout << "\nFim do arquivo.\n\n";


    cout << "=================\n" << "Tabela de síntese\n" << "=================\n";

	for(auto pair: classifiedSymbols) {
		cout << SymbolCategoryToString(pair.first) << ": "<< pair.second << "\n";
	}

	if (!unknownSymbols.empty()) {
		cout << "\n\n";
		cout << "====================\n" << "Tokens desconhecidos\n" << "====================\n";

		for (auto token : unknownSymbols) {
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

symbol* AnalisadorLexico::SymbolAtBack(int index) 
{
    if (validSymbols.empty()) {
        return nullptr;
    }

    auto endIterator = validSymbols.end();
    endIterator--;

    for (int i = 0; i < index; i++) {
        endIterator--;
    }

    return *endIterator;
}

// ------------------------------------------------------------------------------

SymbolCategory AnalisadorLexico::classifySymbols(uint type)
{
    if (type >= (uint)SymbolCategory::RESERVED_WORDS && type < (uint)SymbolCategory::PRIMITIVE_TYPE) {
        return SymbolCategory::RESERVED_WORDS; 
    } 
    else if (type >= (uint)SymbolCategory::PRIMITIVE_TYPE && type < (uint)SymbolCategory::META_ATTRIBUTE) {
        return SymbolCategory::PRIMITIVE_TYPE;
    } 
    else if (type >= (uint)SymbolCategory::META_ATTRIBUTE && type < (uint)SymbolCategory::CLASS_STEREOTYPES) {
        return SymbolCategory::META_ATTRIBUTE;
    }
    else if (type >= (uint)SymbolCategory::CLASS_STEREOTYPES && type < (uint)SymbolCategory::RELATION_STEREOTYPES) {
        return SymbolCategory::CLASS_STEREOTYPES;
    }
    else if (type >= (uint)SymbolCategory::RELATION_STEREOTYPES && type < (uint)SymbolCategory::NUMBER_LITERAL) {
        return SymbolCategory::RELATION_STEREOTYPES;
    } 
    else if (type >= (uint)SymbolCategory::SPECIAL_SYMBOL && type < (uint)SymbolCategory::RELATION_OP) {
        return SymbolCategory::SPECIAL_SYMBOL;
    }
    else if (type >= (uint)SymbolCategory::RELATION_OP && type < (uint)SymbolCategory::ENUM) {
        return SymbolCategory::RELATION_OP;
    }

    return static_cast<SymbolCategory>(type);
}
