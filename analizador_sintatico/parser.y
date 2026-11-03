%{
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include "symtable.h"
#include "relatorio.h"
#include "../analizador_lexico/AnalisadorLexico.h"

using namespace std;

int yylex();
int yyparse();
void yyerror(const char*);

AnalisadorLexico* AnalisadorLexicoSintatico = new AnalisadorLexico();

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

TipoErro contextoAtual = TipoErro::GENERICO;
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

%token OPEN_BRACES CLOSE_BRACES OPEN_PARENTHESES CLOSE_PARENTHESES COLON COMMA AT DOT

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
    | identifier DOT identifier
;

package_decl:
    PACKAGE package_name {
        string pkgName = $2;
        currentScope->setScopeName("package " + pkgName);

        symbol* smb = AnalisadorLexicoSintatico->SymbolAtBack(0);
        smb->scope = currentScope->getScopeName();

        currentScope->put("package " + pkgName, new symbol(
            smb->type,
            smb->category,
            smb->name,
            smb->line,
            smb->columnStart,
            smb->columnEnd,
            smb->scope
        ));
        cout << "Declaração de pacote: " << pkgName << "\n";
        contextoAtual = TipoErro::PACOTE;

        free($2);
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
    class_decl            { cout << "Declaração de classe\n"; contextoAtual = TipoErro::CLASSE; }
    | data_type_decl      { cout << "Declaração de tipo de dados\n"; contextoAtual = TipoErro::DATA_TYPE; }
    | enum_decl           { cout << "Declaração de enum\n"; contextoAtual = TipoErro::ENUM; }
    | generalization_decl { cout << "Declaração de generalização\n"; contextoAtual = TipoErro::GENSET; }
    | external_rel        { cout << "Declaração de relação externa\n"; contextoAtual = TipoErro::RELACAO; }
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

        symbol* existing = currentScope->getLocal(className);
        if (existing != nullptr && existing->category == SymbolCategory::CLASS_NAME) {
            cerr << "Erro semântico [Linha " << existing->line << ", " 
                 << " Coluna " << existing->columnStart << " a " << existing->columnEnd
                 << "]: Classe '" << className << "' já declarada no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            symbol* classStereotype = AnalisadorLexicoSintatico->SymbolAtBack(3);
            symbol* nameClass = AnalisadorLexicoSintatico->SymbolAtBack(2);

            currentScope->put(className, new symbol(
                classStereotype->type, 
                classStereotype->category, 
                className, 
                nameClass->line,
                nameClass->columnStart,
                nameClass->columnEnd, 
                currentScope->getScopeName()
            ));
        }
        enterScope(className);

        free($2);

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
    | OPEN_BRACES class_elements CLOSE_BRACES
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
            cerr << "Aviso semântico " 
                 << " [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() 
                 << "]: Classe base '" << baseClass << "' referenciada ainda não foi encontrada no escopo.\n";
        }

        free($1);
    }
    | class_list COMMA CLASS_NAME {
        string baseClass = $3;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() 
                 << "]: Classe base '" << baseClass << "' referenciada ainda não foi encontrada no escopo.\n";
        }

        free($3);
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
    attr_name COLON data_type opt_attribute_modifiers {
        contextoAtual = TipoErro::ATRIBUTO;
        string attrName = $1;
        string typeName = ($3 ? $3 : "");

        if (currentScope->getLocal(attrName) != nullptr) {
            cerr << "Erro semântico [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() 
                 << "]: Atributo '" << attrName << "' duplicado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            symbol* atribute = AnalisadorLexicoSintatico->SymbolAtBack(3);
            symbol* typeData = AnalisadorLexicoSintatico->SymbolAtBack(1);

            currentScope->put(attrName, new symbol(
                typeData->type, 
                typeData->category, 
                atribute->name, 
                atribute->line, 
                atribute->columnStart,
                atribute->columnEnd, 
                currentScope->getScopeName()
            ));
        }

        free($1);
        free($3);
    }
;

attr_name:
    RELATION_NAME { $$ = $1; }
    | ATTR_NAME   { $$ = $1; }
    | CLASS_NAME  { $$ = $1; }
;

data_type:
    NUMBER        { $$ = strdup("number"); }
  | STRING        { $$ = strdup("string"); }
  | BOOLEAN       { $$ = strdup("boolean"); }
  | DATE          { $$ = strdup("date"); }
  | TIME          { $$ = strdup("time"); }
  | DATETIME      { $$ = strdup("datetime"); }
  | CLASS_NAME    { $$ = $1; }
  | NEW_TYPE      { $$ = $1; }
  | RELATION_NAME { $$ = $1; }
;

opt_attribute_modifiers:
    %empty
    | opt_attribute_modifiers OPEN_BRACES modifier_list CLOSE_BRACES
;

modifier_list:
    modifier_item
    | modifier_list COMMA modifier_item
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
            cerr << "Erro semântico [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() 
                 << "]: Tipo de dados '" << dtName << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            symbol* newType = AnalisadorLexicoSintatico->SymbolAtBack(0);

            currentScope->put(dtName, new symbol(
                yytokentype::DATA_TYPE, 
                SymbolCategory::DATA_TYPE, 
                dtName, 
                newType->line, 
                newType->columnStart,
                newType->columnEnd, 
                currentScope->getScopeName()
            ));
        }

        enterScope(dtName);

        free($2);
    } OPEN_BRACES opt_datatype_attributes CLOSE_BRACES {
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
            cerr << "Erro semântico [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() << " a " << AnalisadorLexicoSintatico->currentColumnEnd()
                 << "]: Enum '" << enumName << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            symbol* newEnum = AnalisadorLexicoSintatico->SymbolAtBack(0);
            currentScope->put(enumName, new symbol(
                yytokentype::ENUM,
                SymbolCategory::ENUM, 
                enumName, 
                newEnum->line, 
                newEnum->columnStart, 
                newEnum->columnEnd, 
                currentScope->getScopeName()
            ));
        }

        enterScope(enumName);

        free($2);
    } OPEN_BRACES enum_members CLOSE_BRACES {
        exitScope();
    }
;

enum_members:
    enum_member {
        string mem = $1;
        symbol* newEnumMember = AnalisadorLexicoSintatico->SymbolAtBack(0);
        currentScope->put(mem, new symbol(
            yytokentype::CLASS_NAME,
            SymbolCategory::ENUM, 
            mem, 
            newEnumMember->line, 
            newEnumMember->columnStart, 
            newEnumMember->columnEnd,
            currentScope->getScopeName()
        ));

        free($1);
    }
    | enum_members COMMA enum_member {
        string mem = $3;
        symbol* newEnumMember = AnalisadorLexicoSintatico->SymbolAtBack(0);
        currentScope->put(mem, new symbol(
            yytokentype::CLASS_NAME,
            SymbolCategory::ENUM, 
            mem, 
            newEnumMember->line, 
            newEnumMember->columnStart, 
            newEnumMember->columnEnd,
            currentScope->getScopeName()
        ));

        free($3);
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
            cerr << "Erro semântico [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() << " a " << AnalisadorLexicoSintatico->currentColumnEnd() 
                 << "]: Genset '" << gname << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            symbol* newGen = AnalisadorLexicoSintatico->SymbolAtBack(4);
            currentScope->put(gname, new symbol(
                yytokentype::GENSET,
                SymbolCategory::RESERVED_WORDS, 
                gname, 
                newGen->line, 
                newGen->columnStart,
                newGen->columnEnd, 
                currentScope->getScopeName()
            ));
        }

        string baseClass = $7;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << AnalisadorLexicoSintatico->yyline()
                 << "]: Classe geral '" << baseClass << "' do genset ainda não declarada.\n";
        }

        free($3);
        free($7);
    }
    | genset_modifiers GENSET genset_name OPEN_BRACES genset_body CLOSE_BRACES {
        string gname = $3;
        if (currentScope->getLocal(gname) != nullptr) {
            cerr << "Erro semântico [Linha " << AnalisadorLexicoSintatico->yyline()
                 << ", Coluna " << AnalisadorLexicoSintatico->currentColumnStart() << " a " << AnalisadorLexicoSintatico->currentColumnEnd() 
                 << "]: Genset '" << gname << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            symbol* genType = AnalisadorLexicoSintatico->SymbolAtBack(5);
            symbol* newGen = AnalisadorLexicoSintatico->SymbolAtBack(3);
            currentScope->put(gname, new symbol(
                genType->type, 
                SymbolCategory::RESERVED_WORDS, 
                gname, 
                newGen->line, 
                newGen->columnStart,
                newGen->columnEnd, 
                currentScope->getScopeName()
            ));
        }

        free($3);
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
            cerr << "Aviso semântico [Linha " << AnalisadorLexicoSintatico->yyline()
                 << "]: Classe geral '" << baseClass << "' do genset ainda não declarada.\n";
        }

        free($2);
    }
    | SPECIFICS class_list GENERAL CLASS_NAME opt_inner_genset_modifiers {
        string baseClass = $4;
        if (currentScope->get(baseClass) == nullptr) {
            cerr << "Aviso semântico [Linha " << AnalisadorLexicoSintatico->yyline() 
                 << "]: Classe geral '" << baseClass << "' do genset ainda não declarada.\n";
        }

        free($4);
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

            symbol* relationName = AnalisadorLexicoSintatico->SymbolAtBack(3);
            symbol* relationType = AnalisadorLexicoSintatico->SymbolAtBack(5);
            currentScope->put(relName, new symbol(
                relationType->type, 
                relationType->category, 
                relName, 
                relationName->line, 
                relationName->columnStart,
                relationName->columnEnd, 
                currentScope->getScopeName()
            ));
        }

        cout << "Declaração de relação interna\n";
        contextoAtual = TipoErro::RELACAO;

        if ($3 != nullptr) free($3);
        if ($5 != nullptr) free($5);
    }
;

external_rel:
    opt_at_stereotype RELATION_KW domain_class opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        string relName = $3;
        string relType = ($1 != nullptr ? $1 : "relation");

        symbol* relationName = AnalisadorLexicoSintatico->SymbolAtBack(5);
        symbol* relationType = AnalisadorLexicoSintatico->SymbolAtBack(7);

        currentScope->put(relName, new symbol(
            relationType->type,
            relationType->category, 
            relName, 
            relationName->line, 
            relationName->columnStart, 
            relationName->columnEnd, 
            currentScope->getScopeName()
        ));

        cout << "Declaração de relação externa\n";

        if ($3 != nullptr) free($3);
        if ($5 != nullptr) free($5);
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
    | OPEN_PARENTHESES rel_ident CLOSE_PARENTHESES
;

opt_cardinality:
    %empty
    | CARDINALITY
;

opt_at_stereotype:
    %empty { $$ = nullptr; }
    | AT relation_type { $$ = $2; }
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

int main(int argc, char ** argv)
{
    if (argc <= 1 || argc > 2) {
        cerr << "Para usar o parser utilize o comando: ./parser <arquivo.tonto>\n";
    }

    /* se foi passado um nome de arquivo */
    ifstream file(argv[1]);
    if (!file.is_open())
    {
        cout << "Arquivo " << argv[1] << " não encontrado!\n";
        return 1;
    }

    AnalisadorLexicoSintatico->yySwitchStreams(file, cout);
    int parseResult = yyparse();

    delete AnalisadorLexicoSintatico;

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

int yylex() {
    return AnalisadorLexicoSintatico->yylex();
}

void yyerror(const char* mensagem) {

    string sugestao;

    switch (contextoAtual) {
        case TipoErro::PACOTE:
            sugestao = "Verifique a declaração do pacote";
            break;
        case TipoErro::CLASSE:
            sugestao = "Verifique a declaração da classe";
            break;
        case TipoErro::ATRIBUTO:
            sugestao = "Verifique a declaração do atributo";
            break;
        case TipoErro::DATA_TYPE:
            sugestao = "Verifique a declaração do pacote";
            break;
        case TipoErro::ENUM:
            sugestao = "Verifique a declaração do enum";
            break;   
        case TipoErro::GENSET:
            sugestao = "Verifique a declaração do genset";
            break;
        case TipoErro::RELACAO:
            sugestao = "Verifique a declaração da relacao";
            break;
        default:
            sugestao = "Verifique a sintaxe";
            break;
    }
    registrar_erro(
        contextoAtual,
        AnalisadorLexicoSintatico->yyline(),
        AnalisadorLexicoSintatico->currentColumnStart(),
        AnalisadorLexicoSintatico->currentColumnEnd(),
        mensagem,
        sugestao
    );
}
