#include <FlexLexer.h>
#include <print>
#include "token.h"

int main(int argc, char** argv)
{
	yyFlexLexer lexer;
	unsigned int lookahead;

	while ((lookahead = lexer.yylex()) != 0) {
		Token s = { lookahead, lexer.lineno(), lexer.YYLeng() };
		std::println("Token: {}; linha: {}; coluna: {}", s.token, s.linha, s.coluna);
	}
}