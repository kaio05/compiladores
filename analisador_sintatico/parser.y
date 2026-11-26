%code requires{
    #include <string>
    #include <vector>
    #include "ast.h"

    using namespace std;

    struct partialSymbol {
        int type;
        char* str;
        int line;
        int start;
        int end;
    };

    struct relationalConector {
        int left;
        partialSymbol* middle;
        int right;
    };
}

%{
#include <fstream>
#include <iostream>
#include <cstring>
#include "symtable.h"
#include "relatorio.h"
#include "../analisador_lexico/AnalisadorLexico.h"

ProgramNode* root = new ProgramNode();
ClassNode* currentClass = nullptr;

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
    vector<string>* list;
    relationalConector* connector;
    char* str;
    int integer;

    ProgramNode* program;
    PackageNode* package;
    ClassNode* classNode;
    GensetNode* genset;
    RelationNode* relation;

    ClassStereotype classStereotype;
    RelationStereotype relationStereotype;

    vector<string>* stringList;
    vector<GensetModifier>* gensetModifiers;
    GensetModifier gensetModifier;
    GensetBody* gensetBody;
}

/* Tokens das palavras reservadas e dos estereótipos. */

/* Estereótipos de classes */
%token EVENT SITUATION PROCESS CATEGORY MIXIN PHASE_MIXIN
%token ROLE_MIXIN HISTORICAL_ROLE HISTORICAL_MIXIN
%token HISTORICAL_ROLE_MIXIN KIND COLLECTIVE QUANTITY
%token QUALITY MODE INTRINSIC_MODES EXTRINSIC_MODES
%token FUNCTIONAL_COMPLEXES SUBKIND PHASE ROLE RELATOR RELATORS 

/* Palavras reservadas */
%token RELATION PACKAGE IMPORT OF DATA_TYPE ENUM SPECIALIZES

/* Generalizações */
%token GENSET DISJOINT COMPLETE OVERLAPPING INCOMPLETE GENERAL SPECIFICS WHERE

/* Tipos primitivos */
%token NUMBER STRING BOOLEAN DATE TIME DATETIME

/* Meta atributos */
%token ORDERED CONST DERIVED SUBSETS REDEFINES

/* Estereótipos de relação */
%token MATERIAL DERIVATION COMPARATIVE MEDIATION
%token CHARACTERIZATION EXTERNAL_DEPENDENCE COMPONENT_OF
%token MEMBER_OF SUB_COLLECTION_OF SUB_QUALITY_OF
%token INSTANTIATION TERMINATION PARTICIPATIONAL PARTICIPATION
%token HISTORICAL_DEPENDENCE CREATION MANIFESTATION
%token BRINGS_ABOUT TRIGGERS COMPOSITION AGGREGATION
%token INHERENCE VALUE FORMAL CONSTITUTION 

/* Operadores relacionais */
%token DASH AGGREGATION_OP COMPOSITION_OP

/* Símbolos especiais */
%token OPEN_BRACES CLOSE_BRACES OPEN_PARENTHESES CLOSE_PARENTHESES COLON COMMA AT DOT

/* Construtors, cardinalidade e números */
%token <symb> NUMBER_LITERAL PACKAGE_NAME INSTANCE_NAME NEW_TYPE ATTRIBUTE_NAME CLASS_NAME RELATION_NAME CARDINALITY

/* IDK */
%token UNKNOWN


/* Regras que retorna um tipo de dado específico */
%type <program> program
%type <package> package_decl

%type <classNode> class_decl class_header
%type <genset> genset_decl
%type <relation> internal_rel external_rel

%type <stringList> opt_specializes class_list
%type <gensetModifiers> genset_modifiers
%type <gensetModifier> genset_modifier
%type <gensetBody> genset_body

%type <symb> datatype_name identifier enum_member opt_cardinality rel_ident opt_rel_alias import_path

%type <integer> relation_operator
%type <connector> rel_connector 

%type <classStereotype> class_stereotype
%type <relationStereotype> relation_type opt_at_stereotype

%type <str> data_type meta_stereotype opt_meta_stereotype

%start program

%%

/* 1. Programa e Pacotes */

program:
    opt_imports package_decl declarations
    {
        root->package = $2;
        $$ = root;
    }
;

/* Importações */

opt_imports:
    %empty
    | opt_imports import_stmt
;

import_stmt:
    IMPORT import_path
    {
        PackageNode* node = new PackageNode();

        node->name = $2->str;
        node->lineStart = $2->line;
        node->lineEnd = $2->line;

        root->imports.emplace_back(node);
    }
;

import_path:
    identifier { $$ = $1; }
    | identifier DOT identifier { $$ = $1; }
;

identifier:
    CLASS_NAME    { $$ = $1; }
    | RELATION_NAME { $$ = $1; }
    | NEW_TYPE    { $$ = $1; }
    | PACKAGE_NAME { $$ = $1; }
;

/* Declaração de pacotes */

package_kw: 
    PACKAGE { contextoAtual = TipoErro::PACOTE; }
;

package_decl:
    package_kw PACKAGE_NAME {
        partialSymbol* pkg = $2;
        string pkgName = pkg->str;

        PackageNode* node = new PackageNode();

        node->name = pkg->str;
        node->lineStart = pkg->line;
        node->lineEnd = pkg->line;

        root->package = node;

        currentScope->setScopeName("package " + pkgName);
        currentScope->put("package " + pkgName, new Symbol(
            pkgName,
            SymbolCategory::PACKAGE,
            "Pacote",
            pkg->line,
            pkg->start,
            pkg->end,
            currentScope->getScopeName()
        ));

        cout << "Declaração de pacote: " << pkg->str << ", linha: " << pkg->line << "\n";

        contextoAtual = TipoErro::PACOTE;

        destroyPartialSymbol(pkg);

        $$ = node;
    }
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
    | genset_decl
    | external_rel
;

/* 2. Declaração de Classes */

class_decl:
    class_header opt_class_body { 
        exitScope(); 

        root->package->classes.emplace_back($1);
        currentClass = nullptr;
        $$ = $1;
    }
;

class_header:
    class_stereotype CLASS_NAME opt_meta_stereotype opt_specializes {
        partialSymbol* className = $2;

        Symbol* existing = currentScope->get(className->str);

        if (existing != nullptr && existing->name == className->str) {

            cerr << "Erro semântico [Linha " << existing->line << ", " 
                 << " Coluna " << existing->columnStart << " a " << existing->columnEnd
                 << "]. Classe: '" << className->str << "' já declarada." 
                 << currentScope->getScopeName() << ".\n";

        } else {
            // Criação do nó da AST
            ClassNode* node = new ClassNode();

            node->name = className->str;
            node->lineStart = className->line;
            node->lineEnd = className->line;
            node->superclasses = move(*$4);
            node->stereotype = $1;

            currentClass = node;

            delete $4;
            $$ = node;
            
            // Inserção na tabela de símbolos
            currentScope->put(string(className->str), new Symbol(
                className->str, 
                SymbolCategory::CLASS, 
                "Classe", 
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
    %empty { $$ = nullptr; }
    | OF meta_stereotype { $$ = $2; }
;

meta_stereotype:
    FUNCTIONAL_COMPLEXES {$$ = (char*)"functionalComplexes";}
    | RELATOR {$$ = (char*)"relator";}
    | RELATORS {$$ = (char*)"relators";}
    | INTRINSIC_MODES {$$ = (char*)"intrinsicModes";}
    | EXTRINSIC_MODES {$$ = (char*)"extrinsicModes";}
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
    %empty { $$ = new vector<string>(); }
    | SPECIALIZES class_list { $$ = $2; }
;

class_list:
    CLASS_NAME {
        partialSymbol* baseClass = $1;

        if (currentScope->get(string(baseClass->str)) == nullptr) {
            cerr << "Aviso semântico " 
                 << " [Linha " << baseClass->line 
                 << ", Coluna " << baseClass->start << " a " << baseClass->end
                 << "]. Classe base: '" << baseClass->str << "' referenciada ainda não foi encontrada no escopo.\n";
        }

        $$ = new vector<string>();
        $$->push_back(baseClass->str);
        destroyPartialSymbol(baseClass);
    }
    | class_list COMMA CLASS_NAME {
        partialSymbol* baseClass = $3;
        if (currentScope->get(string(baseClass->str)) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line 
                 << ", Coluna " << baseClass->start << " a " << baseClass->end
                 << "]. Classe base: '" << baseClass->str << "' referenciada ainda não foi encontrada no escopo.\n";
        }

        $$ = $1;
        $$->push_back(baseClass->str);
        destroyPartialSymbol(baseClass);
    }
;

class_stereotype:
    EVENT                  { $$ = ClassStereotype::EVENT; contextoAtual = TipoErro::CLASSE; }
  | SITUATION              { $$ = ClassStereotype::SITUATION; contextoAtual = TipoErro::CLASSE; }
  | PROCESS                { $$ = ClassStereotype::PROCESS; contextoAtual = TipoErro::CLASSE; }
  | CATEGORY               { $$ = ClassStereotype::CATEGORY; contextoAtual = TipoErro::CLASSE; }
  | MIXIN                  { $$ = ClassStereotype::MIXIN; contextoAtual = TipoErro::CLASSE; }
  | PHASE_MIXIN            { $$ = ClassStereotype::PHASE_MIXIN; contextoAtual = TipoErro::CLASSE; }
  | ROLE_MIXIN             { $$ = ClassStereotype::ROLE_MIXIN; contextoAtual = TipoErro::CLASSE; }
  | HISTORICAL_MIXIN       { $$ = ClassStereotype::HISTORICAL_MIXIN; contextoAtual = TipoErro::CLASSE; }
  | HISTORICAL_ROLE        { $$ = ClassStereotype::HISTORICAL_ROLE; contextoAtual = TipoErro::CLASSE; }
  | HISTORICAL_ROLE_MIXIN  { $$ = ClassStereotype::HISTORICAL_ROLE_MIXIN; contextoAtual = TipoErro::CLASSE; }
  | KIND                   { $$ = ClassStereotype::KIND; contextoAtual = TipoErro::CLASSE; }
  | COLLECTIVE             { $$ = ClassStereotype::COLLECTIVE; contextoAtual = TipoErro::CLASSE; }
  | QUANTITY               { $$ = ClassStereotype::QUANTITY; contextoAtual = TipoErro::CLASSE; }
  | QUALITY                { $$ = ClassStereotype::QUALITY; contextoAtual = TipoErro::CLASSE; }
  | MODE                   { $$ = ClassStereotype::MODE; contextoAtual = TipoErro::CLASSE; }
  | INTRINSIC_MODES        { $$ = ClassStereotype::INTRINSIC_MODES; contextoAtual = TipoErro::CLASSE; }
  | EXTRINSIC_MODES        { $$ = ClassStereotype::EXTRINSIC_MODES; contextoAtual = TipoErro::CLASSE; }
  | SUBKIND                { $$ = ClassStereotype::SUBKIND; contextoAtual = TipoErro::CLASSE; }
  | PHASE                  { $$ = ClassStereotype::PHASE; contextoAtual = TipoErro::CLASSE; }
  | ROLE                   { $$ = ClassStereotype::ROLE; contextoAtual = TipoErro::CLASSE; }
  | RELATOR                { $$ = ClassStereotype::RELATOR; contextoAtual = TipoErro::CLASSE; }
;

/* 2.1. Declaração de Atributos */

attribute:
    ATTRIBUTE_NAME COLON data_type opt_cardinality opt_attribute_modifiers {
        contextoAtual = TipoErro::ATRIBUTO;

        partialSymbol* attrName = $1;
        string typeName = $3;

        if (currentScope->getLocal(string(attrName->str)) != nullptr) {
            cerr << "Erro semântico [Linha " << attrName->line 
                 << ", Coluna " << attrName->start << " a " << attrName->end
                 << "]: Atributo '" << attrName->str << "' duplicado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {

            currentScope->put(string(attrName->str), new Symbol(
                attrName->str, 
                SymbolCategory::ATTRIBUTE, 
                typeName, 
                attrName->line, 
                attrName->start,
                attrName->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de atributo: " << attrName->str << ", linha: " << attrName->line << "\n";
        }

        free($3);
        destroyPartialSymbol($4);
        destroyPartialSymbol(attrName);
    }
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

data_type:
    NUMBER        { $$ = strdup("number"); }
  | STRING        { $$ = strdup("string"); }
  | BOOLEAN       { $$ = strdup("boolean"); }
  | DATE          { $$ = strdup("date"); }
  | TIME          { $$ = strdup("time"); }
  | DATETIME      { $$ = strdup("datetime"); }
  | NEW_TYPE { 
        Symbol* symb = currentScope->get($1->str);

        if (symb == nullptr) {
            cerr << "Erro em: [Linha " << $1->line 
                 << ", Coluna " << $1->start << " a " << $1->end
                 << "]. Tipo: '" << $1->str << "' referenciado não foi declarado.\n";
        } 

        $$ = strdup($1->str);
        destroyPartialSymbol($1); 
    }
;

data_type_kw:
    DATA_TYPE { contextoAtual = TipoErro::DATA_TYPE; }
;

datatype_name:
    NEW_TYPE { $$ = $1; }
;

opt_datatype_attributes:
    %empty 
    | opt_datatype_attributes opt_datatype_attribute opt_attribute_modifiers
;

opt_datatype_attribute:
    ATTRIBUTE_NAME COLON data_type
;

data_type_decl:
     data_type_kw datatype_name {
        partialSymbol* dtName = $2;

        if (currentScope->getLocal(string(dtName->str)) != nullptr) {
            cerr << "Erro semântico [Linha " << dtName->line 
                 << ", Coluna " << dtName->start << " a " << dtName->end
                 << "]. Tipo de dados: '" << dtName->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(string(dtName->str), new Symbol(
                dtName->str, 
                SymbolCategory::DATATYPE, 
                "Novo tipo de dado", 
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
                 << "]. Enum: '" << enumName->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(enumName->str, new Symbol(
                enumName->str, 
                SymbolCategory::ENUM,
                "Enum", 
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

        currentScope->put(member->str, new Symbol(
            member->str, 
            SymbolCategory::CLASS,
            "Membro de enum", 
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

        currentScope->put(member->str, new Symbol(
            member->str, 
            SymbolCategory::CLASS,
            "Membro de enum", 
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
;

/* 5. Conjuntos de Generalizações (Genset) */

genset_modifiers:
    %empty { 
        $$ = new vector<GensetModifier>(); 
        contextoAtual = TipoErro::GENSET;
    }
    | genset_modifiers genset_modifier { 
        $$ = $1;
        $$->push_back($2);
        contextoAtual = TipoErro::GENSET;
    }
;

genset_modifier:
    DISJOINT { $$ = GensetModifier::DISJOINT; }
    | COMPLETE { $$ = GensetModifier::COMPLETE; }
    | OVERLAPPING { $$ = GensetModifier::OVERLAPPING; }
    | INCOMPLETE { $$ = GensetModifier::INCOMPLETE; }
;

genset_decl:
    genset_modifiers GENSET CLASS_NAME WHERE class_list SPECIALIZES CLASS_NAME {

        vector<GensetModifier>* gensetMods = $1;
        partialSymbol* newGenset = $3;
        partialSymbol* baseClass = $7;

        GensetNode* node = new GensetNode();

        node->name = newGenset->str;
        node->modifiers = move(*gensetMods);

        node->general = $3->str;
        node->specifics = $5;

        root->package->gensets.emplace_back(node);

        if (currentScope->get(baseClass->str) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line
                 << "]: Classe geral '" << baseClass->str << "' da generalização ainda não foi declarada.\n";
        }

        if (currentScope->getLocal(newGenset->str) != nullptr) {
            cerr << "Erro semântico [Linha " << newGenset->line 
                 << ", Coluna " << newGenset->start << " a " << newGenset->end
                 << "]: Generalização '" << newGenset->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(newGenset->str, new Symbol(
                newGenset->str, 
                SymbolCategory::GENSET,
                "Generalização", 
                newGenset->line, 
                newGenset->start,
                newGenset->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de genset: " << newGenset->str << ", linha: " << newGenset->line << "\n";
        }

        destroyPartialSymbol(newGenset);
        destroyPartialSymbol(baseClass);

        delete $1;

        $$ = node;
    }
    | genset_modifiers GENSET CLASS_NAME OPEN_BRACES genset_body CLOSE_BRACES {

        vector<GensetModifier>* gensetModifiers = $1;
        partialSymbol* newGenset = $3;

        if (currentScope->getLocal(newGenset->str) != nullptr) {
            cerr << "Erro semântico [Linha " << newGenset->line
                 << ", Coluna " << newGenset->start << " a " << newGenset->end 
                 << "]: Genset '" << newGenset->str << "' já declarado no escopo " 
                 << currentScope->getScopeName() << ".\n";
        } else {
            currentScope->put(newGenset->str, new Symbol(
                newGenset->str, 
                SymbolCategory::GENSET, 
                "Generalização", 
                newGenset->line, 
                newGenset->start,
                newGenset->end, 
                currentScope->getScopeName()
            ));

            cout << "Declaração de genset: " << newGenset->str << ", linha: " << newGenset->line << "\n";
        }

        destroyPartialSymbol(newGenset);
        delete gensetModifiers;
    }
;

genset_body:
    GENERAL CLASS_NAME SPECIFICS class_list {
        partialSymbol* baseClass = $2;

        if (currentScope->get(baseClass->str) == nullptr) {
            cerr << "Aviso semântico [Linha " << baseClass->line
                 << "]: Classe geral '" << baseClass->str << "' do genset ainda não declarada.\n";
        }

        $$ = new GensetBody();

        $$->general = baseClass->str;
        $$->specifics = move(*$4);

        destroyPartialSymbol(baseClass);
        delete $4;
    }
;


/* 6. Relações Internas e Externas */

internal_rel:
    opt_at_stereotype opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        if ($3 != nullptr) {

            RelationNode* relation = new RelationNode();

            relation->stereotype = $1;

            // A classe de origem é a classe que contém a relação
           relation->sourceClass = currentClass->name;

            // A classe de destino é o CLASS_NAME
            relation->targetClass = $5->str;

            // Converter as cardinalidades
            relation->sourceCardinality = $2? $2->str : "";
            relation->targetCardinality = $4? $4->str: "";

            relation->lineStart = currentClass->lineStart;

            currentClass->internalRelations.emplace_back(relation);

            // Tabela de símbolos

            RelationStereotype relType = $1;

            relationalConector* relationC = $3;
            int relationType = relationC->left;

            partialSymbol* className = $5;

            string relName;
            if (relationC->middle == nullptr) {
                relName = "relação sem nome";

                currentScope->put(relName, new Symbol(
                    relName, 
                    SymbolCategory::RELATION, 
                    "Relação interna", 
                    className->line, 
                    className->start,
                    className->end, 
                    currentScope->getScopeName()
                ));
            } else {
                relName = relationC->middle->str;

                currentScope->put(relName, new Symbol(
                    relName, 
                    SymbolCategory::RELATION, 
                    "Relação interna", 
                    relationC->middle->line, 
                    relationC->middle->start,
                    relationC->middle->end, 
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
    opt_at_stereotype RELATION CLASS_NAME opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {

        RelationStereotype relType = $1;

        partialSymbol* className = $3;

        relationalConector* relationC = $5;
        int relationType = relationC->left;
        string relName;

        // Nó da AST
        
        RelationNode* relation = new RelationNode();

        relation->stereotype = relType;

        // A classe de origem é a classe que contém a relação
        relation->sourceClass = className->str;

        // A classe de destino é o CLASS_NAME
        relation->targetClass = $7->str;

        // Converter as cardinalidades
        relation->sourceCardinality = $4->str;
        relation->targetCardinality = $6->str;

        relation->lineStart = className->line;

        root->package->externalRelations.emplace_back(relation);

        // Tabela de símbolos

        if (relationC->middle == nullptr){
            relName = "Relação externa sem nome";

            currentScope->put(relName, new Symbol(
                relName, 
                SymbolCategory::RELATION, 
                "Relação externa",
                className->line, 
                className->start, 
                className->end, 
                currentScope->getScopeName()
            ));
        } else {
            relName = relationC->middle->str;

            currentScope->put(relName, new Symbol(
                relName, 
                SymbolCategory::RELATION, 
                "Relação externa",
                className->line, 
                className->start, 
                className->end, 
                currentScope->getScopeName()
            ));

            destroyPartialSymbol(relationC->middle);
        }

        cout << "Declaração de relação externa: " << relName << ", linha: " << className->line << "\n";

        destroyPartialSymbol(className);
        delete relationC;
    }
    |
    opt_at_stereotype RELATION RELATION_NAME opt_cardinality rel_connector opt_cardinality CLASS_NAME opt_rel_alias {
        RelationStereotype relType = $1;

        partialSymbol* relationName = $3;

        relationalConector* relationC = $5;
        int relationType = relationC->left;
        string relName;

        // Nó da AST
        
        RelationNode* relation = new RelationNode();

        relation->stereotype = relType;

        relation->relationName = relationName->str;

        // A classe de destino é o CLASS_NAME
        relation->targetClass = $7->str;

        // Converter as cardinalidades
        relation->sourceCardinality = $4->str;
        relation->targetCardinality = $6->str;

        relation->lineStart = relationName->line;

        root->package->externalRelations.emplace_back(relation);

        // Tabela de símbolos

        if (relationC->middle == nullptr){
            relName = "Relação externa sem nome";

            currentScope->put(relName, new Symbol(
                relName, 
                SymbolCategory::RELATION, 
                "Relação externa",
                relationName->line, 
                relationName->start, 
                relationName->end, 
                currentScope->getScopeName()
            ));
        } else {
            relName = relationC->middle->str;

            currentScope->put(relName, new Symbol(
                relName, 
                SymbolCategory::RELATION, 
                "Relação externa",
                relationName->line, 
                relationName->start, 
                relationName->end, 
                currentScope->getScopeName()
            ));

            destroyPartialSymbol(relationC->middle);
        }

        cout << "Declaração de relação externa: " << relName << ", linha: " << relationName->line << "\n";

        destroyPartialSymbol(relationName);
        delete relationC;
    }
;


rel_connector:
    relation_operator { 
        $$ = new relationalConector();
        $$->left = $1;
        $$->middle = nullptr;
        $$->right = 0;
    }
    | relation_operator rel_ident relation_operator { 
        $$ = new relationalConector(); 
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
    %empty { $$ = RelationStereotype::DEFAULT; contextoAtual = TipoErro::RELACAO; }
    | AT relation_type { $$ = $2; contextoAtual = TipoErro::RELACAO; }
;

relation_operator:
    DASH { $$ = DASH; }
    | AGGREGATION_OP { $$ = AGGREGATION_OP; }
    | COMPOSITION_OP { $$ = COMPOSITION_OP; }
;

relation_type:
    COMPONENT_OF           { $$ = RelationStereotype::COMPONENT_OF; }
  | MEMBER_OF              { $$ = RelationStereotype::MEMBER_OF; }
  | SUB_COLLECTION_OF      { $$ = RelationStereotype::SUB_COLLECTION_OF; }
  | SUB_QUALITY_OF         { $$ = RelationStereotype::SUB_QUALITY_OF; }
  | MEDIATION              { $$ = RelationStereotype::MEDIATION; }
  | MATERIAL               { $$ = RelationStereotype::MATERIAL; }
  | DERIVATION             { $$ = RelationStereotype::DERIVATION; }
  | COMPARATIVE            { $$ = RelationStereotype::COMPARATIVE; }
  | CHARACTERIZATION       { $$ = RelationStereotype::CHARACTERIZATION; }
  | EXTERNAL_DEPENDENCE    { $$ = RelationStereotype::EXTERNAL_DEPENDENCE; }
  | INSTANTIATION          { $$ = RelationStereotype::INSTANTIATION; }
  | TERMINATION            { $$ = RelationStereotype::TERMINATION; }
  | PARTICIPATIONAL        { $$ = RelationStereotype::PARTICIPATIONAL; }
  | PARTICIPATION          { $$ = RelationStereotype::PARTICIPATION; }
  | HISTORICAL_DEPENDENCE  { $$ = RelationStereotype::HISTORICAL_DEPENDENCE; }
  | CREATION               { $$ = RelationStereotype::CREATION; }
  | MANIFESTATION          { $$ = RelationStereotype::MANIFESTATION; }
  | BRINGS_ABOUT           { $$ = RelationStereotype::BRINGS_ABOUT; }
  | TRIGGERS               { $$ = RelationStereotype::TRIGGERS; }
  | COMPOSITION            { $$ = RelationStereotype::COMPOSITION; }
  | AGGREGATION            { $$ = RelationStereotype::AGGREGATION; }
  | INHERENCE              { $$ = RelationStereotype::INHERENCE; }
  | VALUE                  { $$ = RelationStereotype::VALUE; }
  | FORMAL                 { $$ = RelationStereotype::FORMAL; }
  | CONSTITUTION           { $$ = RelationStereotype::CONSTITUTION; }
;

%%

int main(int argc, char ** argv)
{
    if (argc <= 1 || argc > 3) {
        cerr << "Para usar o parser utilize o comando: ./parser <arquivo.tonto> opcionalmente com a flag: -flex\n";
    }

    /* se foi passado um nome de arquivo */
    ifstream file(argv[1]);
    if (!file.is_open())
    {
        cout << "Arquivo " << argv[1] << " não encontrado!\n";
        return 1;
    }

    if (argc == 3 && string(argv[2]) == "-flex") {
        
        AnalisadorLexico lex(file, cout);
        lex.start();
        return 0;

    } else if (argc == 2) {

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

        showTree(root);

        // Libera memória da AST
        for (ClassNode* c: root->package->classes) {
            delete c;
            c = nullptr;
        }
        for (GensetNode* g: root->package->gensets) {
            delete g;
            g = nullptr;
        }
        for (RelationNode* r: root->package->externalRelations) {
            delete r;
            r = nullptr;
        }
        for (PackageNode* p: root->imports) {
            delete p;
            p = nullptr;
        }
        return parseResult;

    }
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
