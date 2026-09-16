#include <FlexLexer.h>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include "token.h"

extern int yycolumn;

uint classifyTokens(uint type)
{
    if (type >= tokenClass::RESERVED_WORDS && type < tokenClass::PRIMITIVE_TYPE) {
        return tokenClass::RESERVED_WORDS;
   } 
    else if (type >= tokenClass::PRIMITIVE_TYPE && type < tokenClass::META_ATTRIBUTE) {
        return tokenClass::PRIMITIVE_TYPE;
   } 
    else if (type >= tokenClass::META_ATTRIBUTE && type < tokenClass::CLASS_STEREOTYPES) {
        return tokenClass::CLASS_STEREOTYPES;
   }
    else if (type >= tokenClass::CLASS_STEREOTYPES && type < tokenClass::RELATION_STEREOTYPES) {
        return tokenClass::CLASS_STEREOTYPES;
   }
    else if (type >= tokenClass::RELATION_STEREOTYPES && type < tokenClass::NUMBERL) {
        return tokenClass::RELATION_STEREOTYPES;
   }

    return type;
};

int main(int argc, char** argv)
{
	if(argc < 2) {
		std::cerr << "Argumento faltando\n" << "Uso: ./lexer <arquivo.tonto>\n";
		return 1;
	} else if (argc > 2) {
		std::cerr << "Muitos argumentos: " << argc-1 << ". Espera-se apenas 1 argumento: <arquivo.tonto>\n";
		return 1;
	}

	std::ifstream file(argv[1]);
	if(!file.is_open()) {
		std::cerr << "Erro ao abrir o arquivo!\n";
		return 1;
	}

	std::unordered_map<int, int> tokenCountMap;
	yyFlexLexer lexer;
	int lookahead;

	lexer.switch_streams(&file, &std::cout);

	std::cout << "===============\n"
		      << "Visão analítica\n"
		      << "===============\n";

	while ((lookahead = lexer.yylex()) > 0) {
		tokenCountMap[classifyTokens(lookahead)]++;

		std::cout << "<Token: " 
			<< tokenTypeNames[lookahead] << ", \"" 
			<< lexer.YYText() << "\", lin: " << lexer.lineno() << ", col:" << yycolumn << ">\n";
	}

	if (lookahead == 0) {
		std::cout << "Fim do arquivo.\n";

		std::cout << "=================\n"
		<< "Tabela de síntese\n"
		<< "=================\n";

		for(auto pair: tokenCountMap) {
			std::cout << tokenClassNames.at(pair.first) << ": "<< pair.second << std::endl;
		}
	}
}