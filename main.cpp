#include <iostream>
#include <fstream>
#include "analizador_sintatico/parser.tab.h"
#include "analizador_lexico/AnalisadorLexico.h"
using namespace std;

void lex(ifstream& file);
void parse(ifstream& file);

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
	if(opcao == 1) parse(file);

}

void lex(ifstream& file) {
	AnalisadorLexico lexer(file, cout);
	lexer.start();
}

void parse(ifstream& file) {

	extern AnalisadorLexico AnalisadorLexicoSintatico;
	AnalisadorLexicoSintatico.yySwitchStreams(file, cout);

	yyparse();
}
