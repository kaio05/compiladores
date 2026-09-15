#include <FlexLexer.h>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include "token.h"

extern int yycolumn;

int main(int argc, char** argv)
{
	if(argc < 2) {
		std::cerr << "Argumento faltando\n" << "Uso: ./lexer <arquivo.tonto>\n";
		return 1;
	} else if (argc > 2) {
		std::cerr << "Muitos argumentos: " << argc-1 << "\n";
		return 1;
	}

	std::ifstream file(argv[1]);

	if(!file.is_open()) {
		std::cerr << "Error opening file\n";
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
		token t = { (uint)lookahead, lexer.YYText(), lexer.lineno(), yycolumn };
		tokenCountMap[t.type]++;
		std::cout << "<Token: " << tokenTypeNames[t.type] << ", \"" << t.lexeme << "\", lin: " << t.line << ", col:" << t.column << ">\n";
	}

	if (lookahead == -1) {
		std::cerr << "Erro na linha: " << lexer.lineno() << ".\n" << "Coluna: " << yycolumn << ".\n" 
			<< "Caractere não reconhecido: \"" << lexer.YYText() << "\"\n";
	}

	if (lookahead == 0) {
		std::cout << "Fim do arquivo.\n";

		std::cout << "=================\n"
		<< "Tabela de síntese\n"
		<< "=================\n";

		for(auto pair: tokenCountMap) {
			std::cout << tokenTypeNames[pair.first]
				<< ": "
				<< pair.second
				<< std::endl;
		}
	}
}