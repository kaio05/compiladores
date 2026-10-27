#include <FlexLexer.h>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include "analizador_lexico/AnalizadorLexico.h"
#include "analizador_sintatico/parser.tab.h"
using namespace std;

extern int yycolumn;

uint classifyTokens(uint type);

int main(int argc, char** argv) {
	int opcao;
	cout << "Selecione uma visualização:\n" << "-- Analise lexica[0]\n-- Analise sintatica[1]\n";
	cin >> opcao;
	if(opcao < 0 || opcao > 1) return -1;

	ifstream file(argv[1]);
	if(!file.is_open()) {
		cerr << "Erro ao abrir o arquivo!\n";
		return 1;
	}

	if(opcao == 0) lex();
	if(opcao == 1) parse();

}

int lex()
{
	unordered_map<int, int> tokenCountMap;
	vector<token> tokensDesconhecidos;

	yyFlexLexer lexer;
	lexer.switch_streams(&file, &cout);

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
		cout << tokenClassNames.at(tc) << ": "<< pair.second << endl;
	}

	if (!tokensDesconhecidos.empty()) {
		cout << "\n\n";
		cout << "====================\n" << "Tokens desconhecidos\n" << "====================\n";

		for (auto token : tokensDesconhecidos) {
			cout << "Caractere: \"" << token.lexeme << "\" desconhecido." 
			<< " Linha: " << token.line << ". Coluna: " << token.column << endl;
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

int parse()
{
	yyparse();
}