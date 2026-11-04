%code requires{
    #include <string>
    #include <vector>

    using namespace std;

    struct partialSymbol {
        int type;
        char* str;
        int line;
        int start;
        int end;
    };

    struct relationalConectors {
        int left;
        partialSymbol* middle;
        int right;
    };
}

%{
#include <fstream>
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include "symtable.h"
#include "relatorio.h"
#include "../analizador_lexico/AnalisadorLexico.h"

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

void destroyPartialSymbol(partialSymbol* sym) {
    if (sym != nullptr) {
        free(sym->str);
        delete sym;
    }
};

TipoErro contextoAtual = TipoErro::GENERICO;
%}

%define parse.error detailed
%define parse.lac full
%locations

%union {
    partialSymbol* symb;
    char* str;
    vector<string>* gensetMods;
    relationalConectors* connectors;
    int integer;
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

%token <symb> NUMBER_LITERAL 
%token SPECIAL_SYMBOL DATA_TYPE
%token <symb> INSTANCE_NAME NEW_TYPE CLASS_NAME RELATION_NAME ATTR_NAME 

%token UNKNOWN

%token OPEN_BRACES CLOSE_BRACES OPEN_PARENTHESES CLOSE_PARENTHESES COLON COMMA AT DOT

%token RELATION_KW 
%token <symb> CARDINALITY 
%token DASH AGGREGATION_OP COMPOSITION_OP
%token ENUM SPECIALIZES

%type <str> class_stereotype relation_type opt_at_stereotype genset_modifier data_type 

%type <integer> relation_operator

%type <connectors> rel_connector 

%type <gensetMods> genset_modifiers opt_inner_genset_modifiers

%type <symb> datatype_name identifier package_name genset_name enum_member attr_name opt_cardinality
%type <symb> domain_class rel_ident opt_rel_alias


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

package_kw: 
    PACKAGE { contextoAtual = TipoErro::PACOTE; }
;

package_decl:
    package_kw package_name {
        partialSymbol* pkgName = $2;
        string name = pkgName->str;

        currentScope->setScopeName("package " + name);
        currentScope->put("package " + name, new symbol(
            (yytokentype)pkgName->type,
            "package",
            pkgName->str,
            pkgName->line,
            pkgName->start,
            pkgName->end,
            currentScope->getScopeName()
        ));

        cout << "Declaração de pacote: " << pkgName->str << ", linha: " << pkgName->line << "\n";

        contextoAtual = TipoErro::PACOTE;

        destroyPartialSymbol(pkgName);
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
    class_decl           
    | data_type_decl     
    | enum_decl          
    | generalization_decl
    | external_rel       
;

/* 2. Declaração de Classes */

class_decl:
    class_header opt_class_body {
        exitScope();
    }
;

class_header:
    class_stereotype CLASS_NAME opt_meta_stereotype opt_specializes {
        partialSymbol* className = $2;
        string stereotype = ($1 ? $1 : "");

        symbol* existing = currentScope->getLocal(className->str);
        if (existing != nullptr && existing->name == className->str) {
            cerr << "Erro semântico [Linha " << existing->line << ", " 
                 << " Coluna " << existing->columnStart << " a " << existing->columnEnd
                 << "]: Classe '" << className << "' já declarada no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {

            currentScope->put(string(className->str), new symbol(
                (yytokentype)className->type, 
                "Class", 
                className->str, 
                className->line,
                className->start,
                className->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de classe: " << className->str << ", linha: " << className->line << "\n";
        }

        enterScope(className->str);

        destroyPartialSymbol(className);
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
    | internal_rel
;

opt_specializes:
    %empty
    | SPECIALIZES class_list
;

class_list:
    CLASS_NAME {
        partialSymbol* baseClass = $1;
        if (currentScope->get(string(baseClass->str)) == nullptr) {
            cerr << "Aviso semântico " 
                 << " [Linha " << baseClass->line 
                 << ", Coluna " << baseClass->start << " a " << baseClass->end
                 << "]: Classe base '" << baseClass->str << "' referenciada ainda não foi encontrada no escopo.\n";
        }

        destroyPartialSymbol(baseClass);
    }
    | class_list COMMA CLASS_NAME {
        partialSymbol* baseClass = $3;
        if (currentScope->get(string(baseClass->str)) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line 
                 << ", Coluna " << baseClass->start << " a " << baseClass->end
                 << "]: Classe base '" << baseClass->str << "' referenciada ainda não foi encontrada no escopo.\n";
        }

        destroyPartialSymbol(baseClass);
    }
;

class_stereotype:
    EVENT                  { $$ = (char*)"event"; contextoAtual = TipoErro::CLASSE; }
  | SITUATION              { $$ = (char*)"situation"; contextoAtual = TipoErro::CLASSE; }
  | PROCESS                { $$ = (char*)"process"; contextoAtual = TipoErro::CLASSE; }
  | CATEGORY               { $$ = (char*)"category"; contextoAtual = TipoErro::CLASSE; }
  | MIXIN                  { $$ = (char*)"mixin"; contextoAtual = TipoErro::CLASSE; }
  | PHASE_MIXIN            { $$ = (char*)"phaseMixin"; contextoAtual = TipoErro::CLASSE; }
  | ROLE_MIXIN             { $$ = (char*)"roleMixin"; contextoAtual = TipoErro::CLASSE; }
  | HISTORICAL_MIXIN       { $$ = (char*)"historicalMixin"; contextoAtual = TipoErro::CLASSE; }
  | HISTORICAL_ROLE        { $$ = (char*)"historicalRole"; contextoAtual = TipoErro::CLASSE; }
  | HISTORICAL_ROLE_MIXIN  { $$ = (char*)"historicalRoleMixin"; contextoAtual = TipoErro::CLASSE; }
  | KIND                   { $$ = (char*)"kind"; contextoAtual = TipoErro::CLASSE; }
  | COLLECTIVE             { $$ = (char*)"collective"; contextoAtual = TipoErro::CLASSE; }
  | QUANTITY               { $$ = (char*)"quantity"; contextoAtual = TipoErro::CLASSE; }
  | QUALITY                { $$ = (char*)"quality"; contextoAtual = TipoErro::CLASSE; }
  | MODE                   { $$ = (char*)"mode"; contextoAtual = TipoErro::CLASSE; }
  | INTRINSIC_MODES        { $$ = (char*)"intrinsic-modes"; contextoAtual = TipoErro::CLASSE; }
  | EXTRINSIC_MODES        { $$ = (char*)"extrinsic-modes"; contextoAtual = TipoErro::CLASSE; }
  | SUBKIND                { $$ = (char*)"subkind"; contextoAtual = TipoErro::CLASSE; }
  | PHASE                  { $$ = (char*)"phase"; contextoAtual = TipoErro::CLASSE; }
  | ROLE                   { $$ = (char*)"role"; contextoAtual = TipoErro::CLASSE; }
  | RELATOR                { $$ = (char*)"relator"; contextoAtual = TipoErro::CLASSE; }
;

/* 2.1. Declaração de Atributos */

attribute:
    attr_name COLON data_type opt_attribute_modifiers {
        contextoAtual = TipoErro::ATRIBUTO;

        partialSymbol* attrName = $1;
        string typeName = ($3 ? $3 : "");

        if (currentScope->getLocal(string(attrName->str)) != nullptr) {
            cerr << "Erro semântico [Linha " << attrName->line 
                 << ", Coluna " << attrName->start << " a " << attrName->end
                 << "]: Atributo '" << attrName->str << "' duplicado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {

            currentScope->put(string(attrName->str), new symbol(
                (yytokentype)attrName->type, 
                "Attribute", 
                typeName, 
                attrName->line, 
                attrName->start,
                attrName->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de atributo: " << attrName->str << ", linha: " << attrName->line << "\n";
        }

        free($3);
        destroyPartialSymbol(attrName);
    }
;

attr_name:
    INSTANCE_NAME   { $$ = $1; }
;

data_type:
    NUMBER        { $$ = strdup("number"); }
  | STRING        { $$ = strdup("string"); }
  | BOOLEAN       { $$ = strdup("boolean"); }
  | DATE          { $$ = strdup("date"); }
  | TIME          { $$ = strdup("time"); }
  | DATETIME      { $$ = strdup("datetime"); }
  | NEW_TYPE      { $$ = strdup($1->str); destroyPartialSymbol($1); }
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

/* 3. Tipos de Dados Complexos (Datatype) */

data_type_kw:
    DATA_TYPE { contextoAtual = TipoErro::DATA_TYPE; }
;

data_type_decl:
     data_type_kw datatype_name {
        partialSymbol* dtName = $2;

        if (currentScope->getLocal(string(dtName->str)) != nullptr) {
            cerr << "Erro semântico [Linha " << dtName->line 
                 << ", Coluna " << dtName->start << " a " << dtName->end
                 << "]: Tipo de dados '" << dtName->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(string(dtName->str), new symbol(
                (yytokentype)dtName->type, 
                "Data type", 
                dtName->str, 
                dtName->line, 
                dtName->start,
                dtName->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de tipo: " << dtName->str << ", linha: " << dtName->line << "\n";
        }

        enterScope(dtName->str);
        destroyPartialSymbol(dtName);

    } OPEN_BRACES opt_datatype_attributes CLOSE_BRACES {
        exitScope();
    }
;

datatype_name:
    NEW_TYPE      { $$ = $1; }
;

opt_datatype_attributes:
    %empty 
    | opt_datatype_attributes attribute opt_attribute_modifiers
;

/* 4. Classes Enumeradas (Enum) */

enum_kw:
    ENUM { contextoAtual = TipoErro::ENUM; }
;

enum_decl:
    enum_kw CLASS_NAME {
        partialSymbol* enumName = $2;

        if (currentScope->getLocal(enumName->str) != nullptr) {
            cerr << "Erro semântico [Linha " << enumName->line 
                 << ", Coluna " << enumName->start << " a " << enumName->end
                 << "]: Enum '" << enumName->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(enumName->str, new symbol(
                (yytokentype)enumName->type,
                "Enum", 
                enumName->str, 
                enumName->line, 
                enumName->start, 
                enumName->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de Enum: " << enumName->str << ", linha: " << enumName->line << "\n";
        }


        enterScope(enumName->str);

        destroyPartialSymbol(enumName);
        
    } OPEN_BRACES enum_members CLOSE_BRACES {
        exitScope();
    }
;

enum_members:
    enum_member {
        partialSymbol* member = $1;

        currentScope->put(member->str, new symbol(
            (yytokentype)member->type,
            "Enum_member", 
            member->str, 
            member->line, 
            member->start, 
            member->end,
            currentScope->getScopeName()
        ));

        cout << "Membro do Enum: " << currentScope->getScopeName() << "[" << member->str << "], linha: " << member->line << "\n";

        destroyPartialSymbol(member);
    }
    | enum_members COMMA enum_member {
        partialSymbol* member = $3;

        currentScope->put(member->str, new symbol(
            (yytokentype)member->type,
            "Enum_member", 
            member->str, 
            member->line, 
            member->start, 
            member->end,
            currentScope->getScopeName()
        ));

        cout << "Membro do Enum: " << currentScope->getScopeName() << "[" << member->str << "], linha: " << member->line << "\n";

        destroyPartialSymbol(member);
    }
;

enum_member:
    CLASS_NAME     { $$ = $1; }
    /* Somente nome de classes */
;

/* 5. Conjuntos de Generalizações (Genset) */

generalization_decl:
    genset_modifiers GENSET genset_name WHERE class_list SPECIALIZES CLASS_NAME {
        vector<string>* gensetMods = $1;

        string mods = "";
        if (!gensetMods->empty()){
            for (auto& mod : *gensetMods){
                mods += mod + " ";
            }
        } else {
            mods = "genset";
        }

        partialSymbol* gname = $3;
        partialSymbol* baseClass = $7;

        if (currentScope->getLocal(gname->str) != nullptr) {
            cerr << "Erro semântico [Linha " << gname->line 
                 << ", Coluna " << gname->start << " a " << gname->end
                 << "]: Genset '" << gname->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(gname->str, new symbol(
                (yytokentype)gname->type,
                mods, 
                gname->str, 
                gname->line, 
                gname->start,
                gname->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de genset: " << gname->str << ", linha: " << gname->line << "\n";
        }

        if (currentScope->get(baseClass->str) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line
                 << "]: Classe geral '" << baseClass->str << "' do genset ainda não declarada.\n";
        }

        destroyPartialSymbol(gname);
        destroyPartialSymbol(baseClass);
    }
    | genset_modifiers GENSET genset_name OPEN_BRACES genset_body CLOSE_BRACES {
        vector<string>* gensetMods = $1;

        string mods = "";
        if (!gensetMods->empty()){
            for (auto& mod : *gensetMods){
                mods += mod + " ";
            }
        } else {
            mods = "genset";
        }

        partialSymbol* genName = $3;

        if (currentScope->getLocal(genName->str) != nullptr) {
            cerr << "Erro semântico [Linha " << genName->line
                 << ", Coluna " << genName->start
                 << " a " << genName->end 
                 << "]: Genset '" << genName->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(genName->str, new symbol(
                (yytokentype)genName->type, 
                mods, 
                genName->str, 
                genName->line, 
                genName->start,
                genName->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de genset: " << genName->str << ", linha: " << genName->line << "\n";
        }

        destroyPartialSymbol(genName);
        delete gensetMods;
    }
;

genset_name:
    CLASS_NAME    { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
;

genset_modifiers:
    %empty { 
        $$ = new vector<string>(); 
        contextoAtual = TipoErro::GENSET;
    }
    | genset_modifiers genset_modifier { 
        $$ = $1;
        $$->push_back($2);
        free($2);
        contextoAtual = TipoErro::GENSET;
    }
;

genset_modifier:
    DISJOINT { $$ = strdup("disjoint"); }
    | COMPLETE { $$ = strdup("complete"); }
    | OVERLAPPING { $$ = strdup("overlapping"); }
    | INCOMPLETE { $$ = strdup("incomplete"); }
;

genset_body:
    GENERAL CLASS_NAME SPECIFICS class_list opt_inner_genset_modifiers {
        partialSymbol* baseClass = $2;

        if (currentScope->get(baseClass->str) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line
                 << "]: Classe geral '" << baseClass->str << "' do genset ainda não declarada.\n";
        }

        destroyPartialSymbol(baseClass);
    }
    | SPECIFICS class_list GENERAL CLASS_NAME opt_inner_genset_modifiers {
        partialSymbol* baseClass = $4;

        if (currentScope->get(baseClass->str) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line 
                 << "]: Classe geral '" << baseClass->str << "' do genset ainda não declarada.\n";
        }

        destroyPartialSymbol(baseClass);
        if ($5 != nullptr) delete $5;
    }
;

opt_inner_genset_modifiers:
    %empty { 
        $$ = new vector<string>(); 
    }
    | opt_inner_genset_modifiers genset_modifier {
        $$ = $1; 
        $$->push_back($2);
        free($2);
    }
;

/* 6. Relações Internas e Externas */

internal_rel:
    opt_at_stereotype opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        if ($3 != nullptr) {
            string relType = ($1 != nullptr ? $1 : "relation");

            relationalConectors* relationC = $3;
            int relationType = relationC->left;

            partialSymbol* className = $5;

            string relName;
            if (relationC->middle == nullptr) {
                relName = "relação sem nome";

                currentScope->put(relName, new symbol(
                    (yytokentype)relationType, 
                    "Internal relation", 
                    relName, 
                    className->line, 
                    className->start,
                    className->end, 
                    currentScope->getScopeName()
                ));
            } else {
                relName = relationC->middle->str;

                currentScope->put(relName, new symbol(
                    (yytokentype)relationType, 
                    "Internal relation", 
                    relName, 
                    className->line, 
                    className->start,
                    className->end, 
                    currentScope->getScopeName()
                ));

                destroyPartialSymbol(relationC->middle);
            }
            
            cout << "Declaração de relação interna: " << relName << ", linha: " << className->line << "\n";

            delete relationC;
            destroyPartialSymbol(className);
        }

        contextoAtual = TipoErro::RELACAO;
    }
;

external_rel:
    opt_at_stereotype RELATION_KW domain_class opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        string relType = ($1 != nullptr ? $1 : "relation");

        partialSymbol* className = $3;

        relationalConectors* relationC = $5;
        int relationType = relationC->left;
        string relName;

        if (relationC->middle == nullptr){
            relName = "Relação externa sem nome";

            currentScope->put(relName, new symbol(
                (yytokentype)relationType, 
                "External relation",
                relName, 
                className->line, 
                className->start, 
                className->end, 
                currentScope->getScopeName()
            ));
        } else {
            relName = relationC->middle->str;

            currentScope->put(relName, new symbol(
                (yytokentype)relationType, 
                "External relation",
                relName, 
                className->line, 
                className->start, 
                className->end, 
                currentScope->getScopeName()
            ));

            destroyPartialSymbol(relationC->middle);
        }

        cout << "Declaração de relação externa: " << relName << ", linha: " << className->line << "\n";

        if ($1 != nullptr) free($1);
        destroyPartialSymbol(className);
        delete relationC;
    }
;

domain_class:
    CLASS_NAME { $$ = $1; }
;

rel_connector:
    relation_operator { 
        $$ = new relationalConectors();
        $$->left = $1;
        $$->middle = nullptr;
        $$->right = 0;
    }
    | relation_operator rel_ident relation_operator { 
        $$ = new relationalConectors(); 
        $$->left = $1;
        $$->middle = $2;
        $$->right = $3;
    }
;

rel_ident:
    RELATION_NAME { $$ = $1; }
;

opt_rel_alias:
    %empty { $$ = nullptr; }
    | OPEN_PARENTHESES rel_ident CLOSE_PARENTHESES { $$ = $2; }
;

opt_cardinality:
    %empty { $$ = nullptr; }
    | CARDINALITY { $$ = $1; }
;

opt_at_stereotype:
    %empty { $$ = nullptr; contextoAtual = TipoErro::RELACAO; }
    | AT relation_type { $$ = $2; contextoAtual = TipoErro::RELACAO; }
;

relation_operator:
    DASH { $$ = DASH; }
    | AGGREGATION_OP { $$ = AGGREGATION_OP; }
    | COMPOSITION_OP { $$ = COMPOSITION_OP; }
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

    cout << "\n=======================================================\n";
    cout << "Análise do parser\n";
    cout << "=======================================================\n";

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
