#include <FlexLexer.h>
#include "token.h"

int main(int argc, char** argv)
{
	yyFlexLexer lexer;
	unsigned int lookahead;

	while ((lookahead = lexer.yylex()) != 0) {
		
	}
}