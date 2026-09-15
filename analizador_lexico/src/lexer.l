%{
#include "token.h"

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

genset                  return GENSET;
disjoint                return DISJOINT;
complete                return COMPLETE;
general                 return GENERAL;
specifics               return SPECIFICS;
where                   return WHERE;
package                 return PACKAGE;
import                  return IMPORT;
functional-complexes    return FUNCTIONAL_COMPLEXES;

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

event                   return EVENT;
situation               return SITUATION;
process                 return PROCESS;
category                return CATEGORY;
mixin                   return MIXIN;
phaseMixin              return PHASE_MIXIN;
roleMixin               return ROLE_MIXIN;
historicalRole          return HISTORICAL_ROLE;
historicalRoleMixin     return HISTORICAL_ROLE_MIXIN;
kind                    return KIND;
collective              return COLLECTIVE;
quantity                return QUANTITY;
quality                 return QUALITY;
mode                    return MODE;
intrinsic-modes         return INTRINSIC_MODES;
extrinsic-modes         return EXTRINSIC_MODES;
subkind                 return SUBKIND;
phase                   return PHASE;
role                    return ROLE;

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
participation           return PARTICIPATION;
participational         return PARTICIPATIONAL;
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

{number}                return NUMBER_LITERAL;
{symbol}                return SPECIAL_SYMBOL;
{instanceName}          return INSTANCE_NAME;
{newType}               return NEW_TYPE;
{className}             return CLASS_NAME;
{relationName}          return RELATION_NAME;

.                       return UNKNOWN;

%%
