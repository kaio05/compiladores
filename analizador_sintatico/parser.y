%{
#include <iostream>
#include <cctype>
using namespace std;

int yylex(void);
int yyparse(void);
void yyerror(const char*);
%}   

%token PACKAGE
%token RELATION_NAME


%%

expr: PACKAGE RELATION_NAME {cout << "package declaration\n";}
;

%%

int main()
{
    yyparse();
}

void yyerror(const char* s)
{
    cout << "ERRO: " << s << '\n';
}