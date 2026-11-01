%{
#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include "symtable.h"
#include "relatorio.h"

using namespace std;

int yylex(void);
int yyparse(void);
void yyerror(const char*);

extern int yylineno;
extern int yycolumn;

// Gerenciamento de Escopos da Tabela de Símbolos
SymTable* globalScope = new SymTable(nullptr, "global");
SymTable* currentScope = globalScope;
vector<SymTable*> allScopes = { globalScope };

void enterScope(const string& scopeName) {
    currentScope = new SymTable(currentScope, scopeName);
    allScopes.push_back(currentScope);
}

void exitScope() {
    if (currentScope->getPrev() != nullptr) {
        currentScope = currentScope->getPrev();
    }
}
%}

%define parse.error detailed
%define parse.lac full
%locations

%union {
    char* str;
}

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

%token <str> NUMBER_LITERAL SPECIAL_SYMBOL DATA_TYPE
%token <str> INSTANCE_NAME NEW_TYPE CLASS_NAME RELATION_NAME ATTR_NAME UNKNOWN

%token RELATION_KW <str> CARDINALITY DASH AGGREGATION_OP COMPOSITION_OP
%token ENUM SPECIALIZES

%type <str> identifier package_name datatype_name genset_name enum_member attr_name
%type <str> data_type class_stereotype relation_type opt_at_stereotype rel_connector rel_ident domain_class

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
    PACKAGE package_name {
        string pkgName = $2;
        currentScope->setScopeName("package " + pkgName);
        currentScope->put("package " + pkgName, new Symbol(pkgName, SymbolCategory::PACKAGE, "package", yylineno, yycolumn, currentScope->getScopeName()));
        cout << "Declaração de pacote: " << pkgName << "\n";
    }
;

package_name:
    CLASS_NAME    { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
    | ATTR_NAME   { $$ = $1; }
;

identifier:
    CLASS_NAME    { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
    | ATTR_NAME   { $$ = $1; }
    | NEW_TYPE    { $$ = $1; }
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
    class_header opt_class_body {
        exitScope();
    }
;

class_header:
    class_stereotype CLASS_NAME opt_meta_stereotype opt_specializes {
        string className = $2;
        string stereotype = ($1 ? $1 : "");

        Symbol* existing = currentScope->getLocal(className);
        if (existing != nullptr && existing->category == SymbolCategory::CLASS) {
            cerr << "Erro semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Classe '" << className << "' já declarada no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(className, new Symbol(className, SymbolCategory::CLASS, stereotype, yylineno, yycolumn, currentScope->getScopeName()));
        }

        enterScope(className);
    }
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
    CLASS_NAME {
        string baseClass = $1;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Classe base '" << baseClass << "' referenciada ainda não foi encontrada no escopo.\n";
        }
    }
    | class_list ',' CLASS_NAME {
        string baseClass = $3;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Classe base '" << baseClass << "' referenciada ainda não foi encontrada no escopo.\n";
        }
    }
;

class_stereotype:
    EVENT                  { $$ = (char*)"event"; }
  | SITUATION              { $$ = (char*)"situation"; }
  | PROCESS                { $$ = (char*)"process"; }
  | CATEGORY               { $$ = (char*)"category"; }
  | MIXIN                  { $$ = (char*)"mixin"; }
  | PHASE_MIXIN            { $$ = (char*)"phaseMixin"; }
  | ROLE_MIXIN             { $$ = (char*)"roleMixin"; }
  | HISTORICAL_MIXIN       { $$ = (char*)"historicalMixin"; }
  | HISTORICAL_ROLE        { $$ = (char*)"historicalRole"; }
  | HISTORICAL_ROLE_MIXIN  { $$ = (char*)"historicalRoleMixin"; }
  | KIND                   { $$ = (char*)"kind"; }
  | COLLECTIVE             { $$ = (char*)"collective"; }
  | QUANTITY               { $$ = (char*)"quantity"; }
  | QUALITY                { $$ = (char*)"quality"; }
  | MODE                   { $$ = (char*)"mode"; }
  | INTRINSIC_MODES        { $$ = (char*)"intrinsic-modes"; }
  | EXTRINSIC_MODES        { $$ = (char*)"extrinsic-modes"; }
  | SUBKIND                { $$ = (char*)"subkind"; }
  | PHASE                  { $$ = (char*)"phase"; }
  | ROLE                   { $$ = (char*)"role"; }
  | RELATOR                { $$ = (char*)"relator"; }
;

/* 3. Declaração de Atributos */

attribute:
    attr_name ':' data_type opt_attribute_modifiers {
        string attrName = $1;
        string typeName = ($3 ? $3 : "");

        if (currentScope->getLocal(attrName) != nullptr) {
            cerr << "Erro semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Atributo '" << attrName << "' duplicado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(attrName, new Symbol(attrName, SymbolCategory::ATTRIBUTE, typeName, yylineno, yycolumn, currentScope->getScopeName()));
        }
    }
;

attr_name:
    RELATION_NAME { $$ = $1; }
    | ATTR_NAME   { $$ = $1; }
    | CLASS_NAME  { $$ = $1; }
;

data_type:
    NUMBER        { $$ = (char*)"number"; }
  | STRING        { $$ = (char*)"string"; }
  | BOOLEAN       { $$ = (char*)"boolean"; }
  | DATE          { $$ = (char*)"date"; }
  | TIME          { $$ = (char*)"time"; }
  | DATETIME      { $$ = (char*)"datetime"; }
  | CLASS_NAME    { $$ = $1; }
  | NEW_TYPE      { $$ = $1; }
  | RELATION_NAME { $$ = $1; }
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
    DATA_TYPE datatype_name {
        string dtName = $2;
        if (currentScope->getLocal(dtName) != nullptr) {
            cerr << "Erro semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Tipo de dados '" << dtName << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(dtName, new Symbol(dtName, SymbolCategory::DATATYPE, "datatype", yylineno, yycolumn, currentScope->getScopeName()));
        }
        enterScope(dtName);
    } '{' opt_datatype_attributes '}' {
        exitScope();
    }
;

datatype_name:
    NEW_TYPE      { $$ = $1; }
    | CLASS_NAME  { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
;

opt_datatype_attributes:
    %empty
    | opt_datatype_attributes attribute
;

/* 5. Classes Enumeradas (Enum) */

enum_decl:
    ENUM CLASS_NAME {
        string enumName = $2;
        if (currentScope->getLocal(enumName) != nullptr) {
            cerr << "Erro semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Enum '" << enumName << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(enumName, new Symbol(enumName, SymbolCategory::ENUM, "enum", yylineno, yycolumn, currentScope->getScopeName()));
        }
        enterScope(enumName);
    } '{' enum_members '}' {
        exitScope();
    }
;

enum_members:
    enum_member {
        string mem = $1;
        currentScope->put(mem, new Symbol(mem, SymbolCategory::ENUM, currentScope->getScopeName(), yylineno, yycolumn, currentScope->getScopeName()));
    }
    | enum_members ',' enum_member {
        string mem = $3;
        currentScope->put(mem, new Symbol(mem, SymbolCategory::ENUM, currentScope->getScopeName(), yylineno, yycolumn, currentScope->getScopeName()));
    }
;

enum_member:
    CLASS_NAME     { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
    | INSTANCE_NAME { $$ = $1; }
    | NUMBER_LITERAL { $$ = $1; }
;

/* 6. Conjuntos de Generalizações (Genset) */

generalization_decl:
    genset_modifiers GENSET genset_name WHERE class_list SPECIALIZES CLASS_NAME {
        string gname = $3;
        if (currentScope->getLocal(gname) != nullptr) {
            cerr << "Erro semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Genset '" << gname << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(gname, new Symbol(gname, SymbolCategory::GENSET, "genset", yylineno, yycolumn, currentScope->getScopeName()));
        }
        string baseClass = $7;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << yylineno << "]: Classe geral '" << baseClass << "' do genset ainda não declarada.\n";
        }
    }
    | genset_modifiers GENSET genset_name '{' genset_body '}' {
        string gname = $3;
        if (currentScope->getLocal(gname) != nullptr) {
            cerr << "Erro semântico [Linha " << yylineno << ", Coluna " << yycolumn 
                 << "]: Genset '" << gname << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(gname, new Symbol(gname, SymbolCategory::GENSET, "genset", yylineno, yycolumn, currentScope->getScopeName()));
        }
    }
;

genset_name:
    CLASS_NAME    { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
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
    GENERAL CLASS_NAME SPECIFICS class_list opt_inner_genset_modifiers {
        string baseClass = $2;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << yylineno << "]: Classe geral '" << baseClass << "' do genset ainda não declarada.\n";
        }
    }
    | SPECIFICS class_list GENERAL CLASS_NAME opt_inner_genset_modifiers {
        string baseClass = $4;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << yylineno << "]: Classe geral '" << baseClass << "' do genset ainda não declarada.\n";
        }
    }
;

opt_inner_genset_modifiers:
    %empty
    | opt_inner_genset_modifiers genset_modifier
;

/* 7. Relações Internas e Externas */

internal_rel:
    opt_at_stereotype opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        if ($3 != nullptr) {
            string relName = $3;
            string relType = ($1 != nullptr ? $1 : "relation");
            currentScope->put(relName, new Symbol(relName, SymbolCategory::RELATION, relType, yylineno, yycolumn, currentScope->getScopeName()));
        }
        cout << "Declaração de relação interna\n";
    }
;

external_rel:
    opt_at_stereotype RELATION_KW domain_class opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        string relName = $3;
        string relType = ($1 != nullptr ? $1 : "relation");
        currentScope->put(relName, new Symbol(relName, SymbolCategory::RELATION, relType, yylineno, yycolumn, currentScope->getScopeName()));
        cout << "Declaração de relação externa\n";
    }
;

domain_class:
    CLASS_NAME    { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
;

rel_connector:
    relation_operator { $$ = nullptr; }
    | relation_operator rel_ident relation_operator { $$ = $2; }
;

rel_ident:
    RELATION_NAME { $$ = $1; }
    | CLASS_NAME  { $$ = $1; }
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
    %empty { $$ = nullptr; }
    | '@' relation_type { $$ = $2; }
;

relation_operator:
    DASH
    | AGGREGATION_OP
    | COMPOSITION_OP
;

relation_type:
    COMPONENT_OF           { $$ = (char*)"componentOf"; }
  | MEMBER_OF              { $$ = (char*)"memberOf"; }
  | SUB_COLLECTION_OF      { $$ = (char*)"subCollectionOf"; }
  | SUB_QUALITY_OF         { $$ = (char*)"subQualityOf"; }
  | MEDIATION              { $$ = (char*)"mediation"; }
  | MATERIAL               { $$ = (char*)"material"; }
  | DERIVATION             { $$ = (char*)"derivation"; }
  | COMPARATIVE            { $$ = (char*)"comparative"; }
  | CHARACTERIZATION       { $$ = (char*)"characterization"; }
  | EXTERNAL_DEPENDENCE    { $$ = (char*)"externalDependence"; }
  | INSTANTIATION          { $$ = (char*)"instantiation"; }
  | TERMINATION            { $$ = (char*)"termination"; }
  | PARTICIPATIONAL        { $$ = (char*)"participational"; }
  | PARTICIPATION          { $$ = (char*)"participation"; }
  | HISTORICAL_DEPENDENCE  { $$ = (char*)"historicalDependence"; }
  | CREATION               { $$ = (char*)"creation"; }
  | MANIFESTATION          { $$ = (char*)"manifestation"; }
  | BRINGS_ABOUT           { $$ = (char*)"bringsAbout"; }
  | TRIGGERS               { $$ = (char*)"triggers"; }
  | COMPOSITION            { $$ = (char*)"composition"; }
  | AGGREGATION            { $$ = (char*)"aggregation"; }
  | INHERENCE              { $$ = (char*)"inherence"; }
  | VALUE                  { $$ = (char*)"value"; }
  | FORMAL                 { $$ = (char*)"formal"; }
  | CONSTITUTION           { $$ = (char*)"constitution"; }
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

    int parseResult = yyparse();

    if (parseResult == 0)
    {
        cout << "\n=======================================================\n";
        cout << "TABELAS DE SÍMBOLOS GERADAS (POR ESCOPO)\n";
        cout << "=======================================================\n";
        for (SymTable* table : allScopes)
        {
            if (!table->getTable().empty())
            {
                table->printTable(cout);
                cout << "\n";
            }
        }
    }

    // Liberação de memória dos escopos
    for (SymTable* table : allScopes)
    {
        delete table;
    }
    allScopes.clear();

    gerar_relatorio();

    return parseResult;
}

void yyerror(const char* mensagem) {
    registrar_erro(
        yylloc.first_line,
        yylloc.first_column,
        mensagem,
        "Verifique a sintaxe e os tokens esperados."
    );
}