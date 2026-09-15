#include <FlexLexer.h>
#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <unordered_map>
#include "token.h"
#include "TokenTypeNames.h"
using std::cout;

extern int yycolumn;

int main(int argc, char** argv)
{
	if(argc != 2) {
		std::cerr << "Missing argument\n";
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

	cout << "===============\n"
		 << "Visão analítica\n"
		 << "===============\n";

	while ((lookahead = lexer.yylex()) > 0) {
		token t = { (uint)lookahead, lexer.YYText(), lexer.lineno(), yycolumn };
		tokenCountMap[t.type]++;
		cout << "<Token: " << TokenTypeNames[t.type] << ", \"" << t.lexeme << "\", lin: " << t.line << ", col:" << t.column << ">\n";
	}

	if (lookahead == -1) {
		cout << "Erro na linha: " << lexer.lineno() << ".\n" << "Coluna: " << yycolumn << ".\n" 
			<< "Caractere não reconhecido: \"" << lexer.YYText() << "\"\n";
		cout << "=================\n"
			 << "Tabela de síntese\n"
			 << "=================\n";
		for(auto pair: tokenCountMap) {
			cout << TokenTypeNames[pair.first]
				<< ": "
				<< pair.second
				<< std::endl;
		}
	}
}