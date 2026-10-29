%{
#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>
using namespace std;

int yylex(void);
int yyparse(void);
void yyerror(const char*);

extern int yylineno;
extern int yycolumn;
%}

/* Tokens das palavras reservadas e dos estereótipos. */
%token GENSET DISJOINT COMPLETE OVERLAPPING INCOMPLETE GENERAL SPECIFICS WHERE
%token PACKAGE IMPORT OF FUNCTIONAL_COMPLEXES RELATORS

%token NUMBER STRING BOOLEAN DATE TIME DATETIME

%token ORDERED CONST DERIVED SUBSETS REDEFINES

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

%token NUMBER_LITERAL SPECIAL_SYMBOL DATA_TYPE
%token INSTANCE_NAME NEW_TYPE CLASS_NAME RELATION_NAME ATTR_NAME UNKNOWN

%token RELATION_KW CARDINALITY DASH AGGREGATION_OP COMPOSITION_OP
%token ENUM SPECIALIZES

%start program

%%

/* 1. Programa e Pacotes */

program:
    package_units
;

package_units:
    package_unit
    | package_units package_unit
;

package_unit:
    opt_imports package_decl declarations
;

opt_imports:
    %empty
    | opt_imports import_stmt
;

import_stmt:
    IMPORT import_path
;

import_path:
    identifier
    | identifier '.' identifier
;

package_decl:
    PACKAGE package_name { cout << "Declaração de pacote\n"; }
;

package_name:
    CLASS_NAME
    | RELATION_NAME
    | ATTR_NAME
;

identifier:
    CLASS_NAME
    | RELATION_NAME
    | ATTR_NAME
    | NEW_TYPE
;

/* Declarações posteriores ao pacote */

declarations:
    %empty
    | declarations declaration
;

declaration:
    class_decl            { cout << "Declaração de classe\n"; }
    | data_type_decl      { cout << "Declaração de tipo de dados\n"; }
    | enum_decl           { cout << "Declaração de enum\n"; }
    | generalization_decl { cout << "Declaração de generalização\n"; }
    | external_rel        { cout << "Declaração de relação externa\n"; }
;

/* 2. Declaração de Classes */

class_decl:
    class_header opt_class_body
;

class_header:
    class_stereotype CLASS_NAME opt_meta_stereotype opt_specializes
;

opt_meta_stereotype:
    %empty
    | OF meta_stereotype
;

meta_stereotype:
    FUNCTIONAL_COMPLEXES
    | RELATOR
    | RELATORS
    | INTRINSIC_MODES
    | EXTRINSIC_MODES
    | CLASS_NAME
    | RELATION_NAME
;

opt_class_body:
    %empty
    | '{' class_elements '}'
;

class_elements:
    %empty
    | class_elements class_element
;

class_element:
    attribute
    | internal_rel { cout << "Declaração de relação interna\n"; }
;

opt_specializes:
    %empty
    | SPECIALIZES class_list
;

class_list:
    CLASS_NAME
    | class_list ',' CLASS_NAME
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

/* 3. Declaração de Atributos */

attribute:
    attr_name ':' data_type opt_attribute_modifiers
;

attr_name:
    RELATION_NAME
    | ATTR_NAME
    | CLASS_NAME
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
  | RELATION_NAME
;

opt_attribute_modifiers:
    %empty
    | opt_attribute_modifiers '{' modifier_list '}'
;

modifier_list:
    modifier_item
    | modifier_list ',' modifier_item
;

modifier_item:
    ORDERED
    | CONST
    | DERIVED
    | SUBSETS CLASS_NAME
    | REDEFINES CLASS_NAME
;

/* 4. Tipos de Dados Complexos (Datatype) */

data_type_decl:
    DATA_TYPE datatype_name '{' opt_datatype_attributes '}'
;

datatype_name:
    NEW_TYPE
    | CLASS_NAME
    | RELATION_NAME
;

opt_datatype_attributes:
    %empty
    | opt_datatype_attributes attribute
;

/* 5. Classes Enumeradas (Enum) */

enum_decl:
    ENUM CLASS_NAME '{' enum_members '}'
;

enum_members:
    enum_member
    | enum_members ',' enum_member
;

enum_member:
    CLASS_NAME
    | RELATION_NAME
    | INSTANCE_NAME
    | NUMBER_LITERAL
;

/* 6. Conjuntos de Generalizações (Genset) */

generalization_decl:
    genset_modifiers GENSET genset_name WHERE class_list SPECIALIZES CLASS_NAME
    | genset_modifiers GENSET genset_name '{' genset_body '}'
;

genset_name:
    CLASS_NAME
    | RELATION_NAME
;

genset_modifiers:
    %empty
    | genset_modifiers genset_modifier
;

genset_modifier:
    DISJOINT
    | COMPLETE
    | OVERLAPPING
    | INCOMPLETE
;

genset_body:
    GENERAL CLASS_NAME SPECIFICS class_list opt_inner_genset_modifiers
    | SPECIFICS class_list GENERAL CLASS_NAME opt_inner_genset_modifiers
;

opt_inner_genset_modifiers:
    %empty
    | opt_inner_genset_modifiers genset_modifier
;

/* 7. Relações Internas e Externas */

internal_rel:
    opt_at_stereotype opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias
;

external_rel:
    opt_at_stereotype RELATION_KW domain_class opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias
;

domain_class:
    CLASS_NAME
    | RELATION_NAME
;

rel_connector:
    relation_operator
    | relation_operator rel_ident relation_operator
;

rel_ident:
    RELATION_NAME
    | CLASS_NAME
;

opt_rel_alias:
    %empty
    | '(' rel_ident ')'
;

opt_cardinality:
    %empty
    | CARDINALITY
;

opt_at_stereotype:
    %empty
    | '@' relation_type
;

relation_operator:
    DASH
    | AGGREGATION_OP
    | COMPOSITION_OP
;

relation_type:
    COMPONENT_OF
  | MEMBER_OF
  | SUB_COLLECTION_OF
  | SUB_QUALITY_OF
  | MEDIATION
  | MATERIAL
  | DERIVATION
  | COMPARATIVE
  | CHARACTERIZATION
  | EXTERNAL_DEPENDENCE
  | INSTANTIATION
  | TERMINATION
  | PARTICIPATIONAL
  | PARTICIPATION
  | HISTORICAL_DEPENDENCE
  | CREATION
  | MANIFESTATION
  | BRINGS_ABOUT
  | TRIGGERS
  | COMPOSITION
  | AGGREGATION
  | INHERENCE
  | VALUE
  | FORMAL
  | CONSTITUTION
;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  

int main(int argc, char ** argv)
{
    /* se foi passado um nome de arquivo */
    if (argc > 1)
    {
        FILE * file = fopen(argv[1], "r");
        if (!file)
        {
            cout << "Arquivo " << argv[1] << " não encontrado!\n";
            return 1;
        }
        yyin = file;
    }

    yyparse();
    return 0;
}

void yyerror(const char* s)
{
    extern int yylineno;    
    extern int yycolumn;
    extern char * yytext;   

    cout << "Erro sintático: símbolo \"" << yytext << "\" (linha " << yylineno << ", coluna " << yycolumn << ")\n";
}