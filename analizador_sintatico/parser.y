%{
#include <iostream>
#include <cctype>
#include <FlexLexer.h>

using std::cout;

yyFlexLexer lexer;

int yylex();
void yyerror(const char*);
%}   

/* Tokens das palavras reservadas e dos estereótipos. */
%token GENSET DISJOINT COMPLETE GENERAL SPECIFICS WHERE
%token PACKAGE IMPORT FUNCTIONAL_COMPLEXES

%token NUMBER STRING BOOLEAN DATE TIME DATETIME

%token ORDERED CONST DERIVED SPECIALIZES SUBSETS REDEFINES

%token EVENT SITUATION PROCESS CATEGORY MIXIN PHASE_MIXIN
%token ROLE_MIXIN HISTORICAL_MIXIN HISTORICAL_ROLE
%token HISTORICAL_ROLE_MIXIN KIND COLLECTIVE QUANTITY
%token QUALITY MODE INTRINSIC_MODES EXTRINSIC_MODES
%token SUBKIND PHASE ROLE RELATOR

%token MATERIAL DERIVATION COMPARATIVE MEDIATION
%token CHARACTERIZATION EXTERNAL_DEPENDENCE COMPONENT_OF
%token MEMBER_OF SUB_COLLECTION_OF SUB_QUALITY_OF
%token INSTANTIATION TERMINATION PARTICIPATIONAL PARTICIPATION
%token HISTORICAL_DEPENDENCE CREATION MANIFESTATION
%token BRINGS_ABOUT TRIGGERS COMPOSITION AGGREGATION
%token INHERENCE VALUE FORMAL CONSTITUTION

%token NUMBER_LITERAL DATA_TYPE
%token INSTANCE_NAME NEW_TYPE CLASS_NAME RELATION_NAME UNKNOWN

%token OPEN_BRACES CLOSE_BRACES COLON COMMA AT DOT

%token RELATION_KW CARDINALITY DASH AGGREGATION_OP COMPOSITION_OP

%token ENUM ATTR_NAME


%start program

%%

/* 1. Programa completo */

program:
  imports package_decl declarations
;

imports:
  IMPORT package_name
  | IMPORT package_name DOT NEW_TYPE
;

package_decl:
  PACKAGE package_name {cout << "Declaração de pacote\n";}
;

package_name:
  CLASS_NAME
  | RELATION_NAME
  | ATTR_NAME
;

/* Declarações posteriores ao pacote. */

declarations:
  %empty
  | declarations declaration
;

declaration:
  class_decl {cout << "Declaração de classe\n";}
  | data_type_decl {cout << "Declaração de tipo de dados\n";}
  | enum_decl {cout << "Declaração de enum\n";}
  | generalization_decl {cout << "Declaração de generalização\n";}
  | external_rel {cout << "Declaração de relação\n";}
;

/* 2. Declaração de classes */

class_decl:
    class_stereotype CLASS_NAME opt_class_body opt_specializes
;

opt_class_body:
    %empty
    | OPEN_BRACES attributes internal_rels CLOSE_BRACES
;

opt_specializes:
    %empty
    | SPECIALIZES class_list
;

class_list:
  CLASS_NAME
  | CLASS_NAME COMMA class_list
;

class_stereotype:
    EVENT
  | SITUATION
  | PROCESS
  | CATEGORY
  | MIXIN
  | PHASE_MIXIN
  | ROLE_MIXIN
  | HISTORICAL_MIXIN
  | HISTORICAL_ROLE
  | HISTORICAL_ROLE_MIXIN
  | KIND
  | COLLECTIVE
  | QUANTITY
  | QUALITY
  | MODE
  | INTRINSIC_MODES
  | EXTRINSIC_MODES
  | SUBKIND
  | PHASE
  | ROLE
  | RELATOR
;

/* 3. Declaração de tipos de dados */

data_type_decl:
    DATA_TYPE NEW_TYPE OPEN_BRACES attributes CLOSE_BRACES 
;

/* Lista de atributos: pode estar vazia. */

attributes:
    %empty
  | attribute_list
;

attribute_list:
    attribute
  | attribute_list attribute
;

attribute:
    RELATION_NAME COLON data_type attribute_modifiers
;


data_type:
    NUMBER
  | STRING
  | BOOLEAN
  | DATE
  | TIME
  | DATETIME
  | CLASS_NAME
  | NEW_TYPE
;

/* Meta-atributos opcionais.
   A sintaxe detalhada deles depende da linguagem. */

attribute_modifiers:
    %empty
  | attribute_modifiers OPEN_BRACES attribute_modifier CLOSE_BRACES
;

attribute_modifier:
    ORDERED
  | CONST
  | DERIVED
  | SUBSETS CLASS_NAME
  | REDEFINES CLASS_NAME
;

/* 4. Classes enumeradas */

enum_decl:
    ENUM CLASS_NAME OPEN_BRACES enum_members CLOSE_BRACES 
;

enum_members:
    CLASS_NAME
  | enum_members COMMA CLASS_NAME
;

/* 5. Generalizações */

generalization_decl:
    disjoint_opt complete_opt GENSET CLASS_NAME 
    WHERE specific_classes SPECIALIZES CLASS_NAME 

  | disjoint_opt complete_opt GENSET CLASS_NAME
    OPEN_BRACES GENERAL CLASS_NAME SPECIFICS specific_classes CLOSE_BRACES
;

disjoint_opt:
    %empty
  | DISJOINT
;

complete_opt:
    %empty
  | COMPLETE
;

specific_classes:
    CLASS_NAME
  | specific_classes COMMA CLASS_NAME
;

/* 6. Relações internas */

internal_rels:
    %empty
  | internal_rels relation
;

relation:
    AT relation_type
    cardinality_opt
    relation_operator
    cardinality_opt
    CLASS_NAME
  | AT relation_type
    cardinality_opt
    DASH
    RELATION_NAME
    DASH
    cardinality_opt
    CLASS_NAME
;

cardinality_opt:
  %empty
  | CARDINALITY
;

relation_type:
  COMPONENT_OF
  | MEMBER_OF
  | SUB_COLLECTION_OF
  | SUB_QUALITY_OF
  | MEDIATION
;

/* Relações externas */

external_rel:
    AT MEDIATION RELATION_KW
    relation_name_opt
      CARDINALITY
    relation_operator
      CARDINALITY
    CLASS_NAME
;

relation_name_opt:
    %empty
  | RELATION_NAME
;

relation_operator:
    DASH
  | AGGREGATION_OP
  | COMPOSITION_OP
;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  

int yylex() 
{
  return lexer.yylex();
}

void yyerror(const char* s)
{
  extern int yycolumnStart;
  extern int yycolumnEnd;

  cout << "Erro sintático: símbolo \"" << lexer.YYText() 
  << "\" (linha " << lexer.lineno() << "), " 
  << " (coluna " << yycolumnStart << " a " << yycolumnEnd << ")\n";
}
