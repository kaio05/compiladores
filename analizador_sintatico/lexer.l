%{
#include "parser.tab.h"

int column = 1;
int yycolumn = 1;

void updateColumnPos(int leng) {
    yycolumn = column;
    column += leng;
}

void resetColumn() {
    column = 1;
}

#define YY_USER_ACTION updateColumnPos(yyleng);

%}

%option noyywrap
%option yylineno

/* definições regulares */
delim               [ \t\r]
ws                  {delim}+
newline             [\n]
comment             (\/\/.*)
digit               [0-9]
number              {digit}+(\.{digit}+)?(E[+-]?{digit}+)?
letter              [A-Za-z]
instanceName        ({letter})+({digit})+
newType             ({letter})+("DataType")
className           [A-Z]({letter}|_)*
relationName        [a-z]({letter}|_)*
symbol              ("{"|"}"|"("|")"|"["|"]"|".."|"<>--"|"--<>"|"<o>--"|"--<o>"|\*|\@|\:|"--"|",")

%%
{ws}                    {/* nenhuma ação e nenhum retorno */}
{newline}               resetColumn();
{comment}               resetColumn();

package                 return PACKAGE;
{relationName}             return RELATION_NAME;

%%
