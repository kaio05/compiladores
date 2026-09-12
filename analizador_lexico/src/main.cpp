#include <FlexLexer.h>
#include <iostream>
#include "token.h"
using std::cout;

extern int yycolumn;

int main(int argc, char** argv)
{
	yyFlexLexer lexer;
	int lookahead;

	while ((lookahead = lexer.yylex()) > 0) {
		token t = { (uint)lookahead, lexer.YYText(), lexer.lineno(), yycolumn };
		cout << t.type << " " << t.lexeme << " " << t.line << " " << t.column << std::endl;
	}

	if (lookahead == -1) {
		cout << "Erro na linha: " << lexer.lineno() << ".\n" << "Coluna: " << yycolumn << ".\n" 
			<< "Caractere não reconhecido: \"" << lexer.YYText() << "\"\n";
	}
}