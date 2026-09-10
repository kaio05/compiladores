#include <print>
#include <FlexLexer.h>
#include "token.h"
#include "SymTable.h"

int main(int argc, char** argv)
{
	yyFlexLexer lexer;
	unsigned int lookahead;
	while ((lookahead = lexer.yylex()) != 0) {
		Token t = { lookahead, lexer.lineno(), lexer.YYLeng() };
		SymTable* table = new Symtable();
        table.insert(t);
        
	}
}