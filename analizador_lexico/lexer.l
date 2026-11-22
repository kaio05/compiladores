%{
#include "../analizador_sintatico/parser.tab.h"

int yycolumnStart = 1;
int yycolumnEnd = 1;

void updateColumnPos(int leng) {
    yycolumnStart = yycolumnEnd;
    yycolumnEnd += leng;
}

void resetColumn() {
    yycolumnEnd = 1;
    yycolumnStart = 1;
}

#define YY_USER_ACTION updateColumnPos(yyleng);
#define YY_DECL int yyFlexLexer::yylex()

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
packageName         ({letter})+("Package")
newType             ({letter})+("DataType")
className           [A-Z]({letter}|_)*
relationName        [a-z]({letter}|_)*
cardinality         \[([0-9]+|\*|[0-9]+\.\.([0-9]+|\*))\]
/* symbol           ("{"|"}"|"("|")"|"["|"]"|".."|"<>--"|"--<>"|"<o>--"|"--<o>"|\*|\@|\:|"--"|",") */

%%
{ws}                    {/* nenhuma ação e nenhum retorno */}
{newline}               resetColumn();
{comment}               resetColumn();

event                   return EVENT;
situation               return SITUATION;
process                 return PROCESS;
category                return CATEGORY;
mixin                   return MIXIN;
phaseMixin              return PHASE_MIXIN;
roleMixin               return ROLE_MIXIN;
historicalRole          return HISTORICAL_ROLE;
historicalMixin         return HISTORICAL_MIXIN;
historicalRoleMixin     return HISTORICAL_ROLE_MIXIN;
kind                    return KIND;
collective              return COLLECTIVE;
quantity                return QUANTITY;
quality                 return QUALITY;
mode                    return MODE;
intrinsic-modes         return INTRINSIC_MODES;
extrinsic-modes         return EXTRINSIC_MODES;
functional-complexes    return FUNCTIONAL_COMPLEXES;
subkind                 return SUBKIND;
phase                   return PHASE;
role                    return ROLE;
relator                 return RELATOR;
relators                return RELATORS;

relation                return RELATION;
package                 return PACKAGE;
import                  return IMPORT;
of                      return OF;
datatype                return DATA_TYPE;
enum                    return ENUM;
specializes             return SPECIALIZES;

genset                  return GENSET;
disjoint                return DISJOINT;
complete                return COMPLETE;
overlapping             return OVERLAPPING;
incomplete              return INCOMPLETE;
general                 return GENERAL;
specifics               return SPECIFICS;
where                   return WHERE;

number                  return NUMBER;
string                  return STRING;
boolean                 return BOOLEAN;
date                    return DATE;
time                    return TIME;
datetime                return DATETIME;

ordered                 return ORDERED;
const                   return CONST;
derived                 return DERIVED;
subsets                 return SUBSETS;
redefines               return REDEFINES;

material                return MATERIAL;
derivation              return DERIVATION;
comparative             return COMPARATIVE;
mediation               return MEDIATION;
characterizarion        return CHARACTERIZATION;
externalDependence      return EXTERNAL_DEPENDENCE;
componentOf             return COMPONENT_OF;
memberOf                return MEMBER_OF;
subCollectionOf         return SUB_COLLECTION_OF;
subQualityOf            return SUB_QUALITY_OF;
instantiation           return INSTANTIATION;
termination             return TERMINATION;
participational         return PARTICIPATIONAL;
participation           return PARTICIPATION;
historicalDependence    return HISTORICAL_DEPENDENCE;
creation                return CREATION;
manifestation           return MANIFESTATION;
bringsAbout             return BRINGS_ABOUT;
triggers                return TRIGGERS;
composition             return COMPOSITION;
aggregation             return AGGREGATION;
inherence               return INHERENCE;
value                   return VALUE;
formal                  return FORMAL;
constitution            return CONSTITUTION;

"--"                    return DASH;
"<>--"                  return AGGREGATION_OP;
"<o>--"                 return COMPOSITION_OP;

"{"                     return OPEN_BRACES;
"}"                     return CLOSE_BRACES;
"("                     return OPEN_PARENTHESES;
")"                     return CLOSE_PARENTHESES;
":"                     return COLON;
","                     return COMMA;
"@"                     return AT;
"."                     return DOT;

{number}                { yylval.symb = new partialSymbol(NUMBER_LITERAL, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return NUMBER_LITERAL; }
{cardinality}           { yylval.symb = new partialSymbol(CARDINALITY, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return CARDINALITY; }
{instanceName}          { yylval.symb = new partialSymbol(INSTANCE_NAME, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return INSTANCE_NAME; }
{packageName}           { yylval.symb = new partialSymbol(PACKAGE_NAME, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return PACKAGE_NAME; }
{newType}               { yylval.symb = new partialSymbol(NEW_TYPE, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return NEW_TYPE; }
{className}             { yylval.symb = new partialSymbol(CLASS_NAME, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return CLASS_NAME; }
{relationName}          { yylval.symb = new partialSymbol(RELATION_NAME, strdup(yytext), yylineno, yycolumnStart, yycolumnEnd); return RELATION_NAME; }

.                       return UNKNOWN;

%%
