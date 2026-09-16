#include <FlexLexer.h>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include "token.h"
using std::cout;
using std::cerr;

extern int yycolumn;

uint classifyTokens(uint type);


int main(int argc, char** argv)
{
	if(argc < 2) {
		cerr << "Argumento faltando. Uso: ./lexer <arquivo.tonto>\n";
		return 1;
	} else if (argc > 2) {
		cerr << "Muitos argumentos: " << argc-1 << ". Espera-se apenas 1 argumento: <arquivo.tonto>\n";
		return 1;
	}

	std::ifstream file(argv[1]);
	if(!file.is_open()) {
		std::cerr << "Erro ao abrir o arquivo!\n";
		return 1;
	}

	std::unordered_map<int, int> tokenCountMap;
	std::vector<token> tokensDesconhecidos;

	yyFlexLexer lexer;
	lexer.switch_streams(&file, &std::cout);

	cout << "===============\n" << "Visão analítica\n" << "===============\n";

	int lookahead;
	while ((lookahead = lexer.yylex()) > 0) 
	{
		tokenCountMap[classifyTokens(lookahead)]++;

		if (lookahead == UNKNOWN) {
			tokensDesconhecidos.push_back(token(lookahead, lookahead, lexer.YYText(), lexer.lineno(), yycolumn));
		}

		cout << "<Token: " 
			 << tokenTypeNames[lookahead] << ", \"" 
			 << lexer.YYText() << "\", lin: " << lexer.lineno() << ", col:" << yycolumn << ">\n";
	}


	cout << "\nFim do arquivo.\n\n";


	cout << "=================\n" << "Tabela de síntese\n" << "=================\n";

	for(auto pair: tokenCountMap) {
		tokenClass tc = (tokenClass)pair.first;
		cout << tokenClassNames.at(tc) << ": "<< pair.second << std::endl;
	}

	if (!tokensDesconhecidos.empty()) {
		cout << "\n\n";
		cout << "====================\n" << "Tokens desconhecidos\n" << "====================\n";

		for (auto token : tokensDesconhecidos) {
			cout << "Caractere: \"" << token.lexeme << "\" desconhecido." 
			<< " Linha: " << token.line << ". Coluna: " << token.column << std::endl;
		}
	}
}


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