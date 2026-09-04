%{
#include <iostream>
using std::cout; 
%}

%option noyywrap
%option yylineno

/* definições regulares */
delim               [ \t\n]
ws                  {delim}+
digit               [0-9]
/* number              {digit}+(\.{digit}+)?(E[+-]?{digit}+)? */
letter              [A-Za-z]
instanceName        ({letter})+({digit})+
newType             ({letter})+("DataType")
className           [A-Z]({letter}|_)*
relationName        [a-z]({letter}|_)*
symbol             ("{"|"}"|"("|")"|"["|"]"|".."|"<>--"|"--<>"|\*|\@|\:)

%%
{ws}      {/* nenhuma ação e nenhum retorno */}
genset                  cout << "GENSET\n";
disjoint                cout << "DISJOINT\n";
complete                cout << "COMPLETE\n";
general                 cout << "GENERAL\n";
specifics               cout << "SPECIFICS\n";
where                   cout << "WHERE\n";
package                 cout << "PACKAGE\n";
import                  cout << "IMPORT\n";
functional-complexes    cout << "FUNCTIONAL_COMPLEXES\n";

number                  cout << "NUMBER\n";
string                  cout << "STRING\n";
boolean                 cout << "BOOLEAN\n";
date                    cout << "DATE\n";
time                    cout << "TIME\n";
datetime                cout << "DATETIME\n";

ordered                 cout << "ORDERED\n";
const                   cout << "CONST\n";
derived                 cout << "DERIVED\n";
subsets                 cout << "SUBSETS\n";
redefines               cout << "REDEFINES\n";

event                   cout << "EVENT\n";
situation               cout << "SITUATION\n";
process                 cout << "PROCESS\n";
category                cout << "CATEGORY\n";
mixin                   cout << "MIXIN\n";
phaseMixin              cout << "PHASE_MIXIN\n";
roleMixin               cout << "ROLE_MIXIN\n";
historicalRole          cout << "HISTORICAL_ROLE\n";
historicalRoleMixin     cout << "HISTORICAL_ROLE_MIXIN\n";
kind                    cout << "KIND\n";
collective              cout << "COLLECTIVE\n";
quantity                cout << "QUANTITY\n";
quality                 cout << "QUALITY\n";
mode                    cout << "MODE\n";
intrinsicMode           cout << "INTRINSIC_MODE\n";
extrinsicMode           cout << "EXTRINSIC_MODE\n";
subkind                 cout << "SUBKIND\n";
phase                   cout << "PHASE\n";
role                    cout << "ROLE\n";

material                cout << "MATERIAL\n";
derivation              cout << "DERIVATION\n";
comparative             cout << "COMPARATIVE\n";
mediation               cout << "MEDIATION\n";
characterizarion        cout << "CHARACTERIZATION\n";
externalDependence      cout << "EXTERNAL_DEPENDENCE\n";
componentOf             cout << "COMPONENT_OF\n";
memberOf                cout << "MEMBER_OF\n";
subCollectionOf         cout << "SUB_COLLECTION_OF\n";
subQualityOf            cout << "SUB_QUALITY_OF\n";
instantiation           cout << "INSTANTIATION\n";
termination             cout << "TERMINATION\n";
participation           cout << "PARTICIPATION\n";
participational         cout << "PARTICIPATIONAL\n";
historicalDependence    cout << "HISTORICAL_DEPENDENCE\n";
creation                cout << "CREATION\n";
manifestation           cout << "MANIFESTATION\n";
bringsAbout             cout << "BRINGS_ABOUT\n";
triggers                cout << "TRIGGERS\n";
composition             cout << "COMPOSITION\n";
aggregation             cout << "AGGREGATION\n";
inherence               cout << "INHERENCE\n";
value                   cout << "VALUE\n";
formal                  cout << "FORMAL\n";
constitution            cout << "CONSTITUTION\n";

{instanceName}          cout << "INSTANCE_NAME\n";
{newType}               cout << "NEW_TYPE\n";
{className}             cout << "CLASS_NAME\n";
{relationName}          cout << "RELATION_NAME\n";

{symbol}                cout << "SYMBOL\n";

.|\n                    cout << "Desconhecido na linha: " << lineno() << "\n";
%%

int main()
{
	yyFlexLexer lexer;
	lexer.yylex();
}
