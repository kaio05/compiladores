#include <FlexLexer.h>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include "analizador_sintatico/parser.tab.h"
#include "analizador_lexico/AnalizadorLexico.h"
using namespace std;

extern int yycolumnStart;

void lex(ifstream& file);
void parse();
uint classifyTokens(tokenClass type);


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

	if(opcao == 0) lex(file);
	if(opcao == 1) parse();

}

void lex(ifstream& file)
{
	unordered_map<int, int> tokenCountMap;
	vector<token> tokensDesconhecidos;

	yyFlexLexer lexer;
	lexer.switch_streams(&file, &cout);

	cout << "===============\n" << "Visão analítica\n" << "===============\n";

	int lookahead;
	while ((lookahead = lexer.yylex()) > 0) 
	{
		tokenCountMap[classifyTokens((tokenClass)lookahead)]++;

		if (lookahead == UNKNOWN) {
			tokensDesconhecidos.push_back(token(lookahead, lookahead, lexer.YYText(), lexer.lineno(), yycolumnStart));
		}

		cout << "<Token: " 
			 << tokenTypeNames.at(static_cast<yytokentype>(lookahead)) << ", \"" 
			 << lexer.YYText() << "\", lin: " << lexer.lineno() << ", col:" << yycolumnStart << ">\n";
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


void parse()
{
	yyparse();
}

uint classifyTokens(tokenClass type)
{
    if (type >= tokenClass::RESERVED_WORDS && type < tokenClass::PRIMITIVE_TYPE) {
        return (uint)tokenClass::RESERVED_WORDS; 
   } 
    else if (type >= tokenClass::PRIMITIVE_TYPE && type < tokenClass::META_ATTRIBUTE) {
        return (uint)tokenClass::PRIMITIVE_TYPE;
   } 
    else if (type >= tokenClass::META_ATTRIBUTE && type < tokenClass::CLASS_STEREOTYPES) {
        return (uint)tokenClass::CLASS_STEREOTYPES;
   }
    else if (type >= tokenClass::CLASS_STEREOTYPES && type < tokenClass::RELATION_STEREOTYPES) {
        return (uint)tokenClass::CLASS_STEREOTYPES;
   }
    else if (type >= tokenClass::RELATION_STEREOTYPES && type < tokenClass::NUMBER_LITERAL) {
        return (uint)tokenClass::RELATION_STEREOTYPES;
   }

    return (uint)type;
}
