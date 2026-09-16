#pragma once

#include <string>
#include <map>
using std::map;
using std::string;
using uint = unsigned int;

enum tokenTypes {
    //Palavras reservadas
    GENSET = 1, DISJOINT, COMPLETE, GENERAL, SPECIFICS, WHERE, PACKAGE, IMPORT, FUNCTIONAL_COMPLEXES, 
    
    // Tipos 
    NUMBER, STRING, BOOLEAN, DATE, TIME, DATETIME,

    // Meta atributo
    ORDERED, CONST, DERIVED, SUBSETS, REDEFINES,

    // Estereotipos de classe
    EVENT, SITUATION, PROCESS, CATEGORY, MIXIN, PHASE_MIXIN, ROLE_MIXIN, HISTORICAL_MIXIN, 
    HISTORICAL_ROLE, HISTORICAL_ROLE_MIXIN, KIND, COLLECTIVE, QUANTITY, QUALITY, MODE, 
    INTRINSIC_MODES, EXTRINSIC_MODES, SUBKIND, PHASE, ROLE, 
    
    // Estereotipos de relação
    MATERIAL, DERIVATION, COMPARATIVE, MEDIATION, CHARACTERIZATION, EXTERNAL_DEPENDENCE, 
    COMPONENT_OF, MEMBER_OF, SUB_COLLECTION_OF, SUB_QUALITY_OF, INSTANTIATION, TERMINATION, PARTICIPATIONAL, 
    PARTICIPATION, HISTORICAL_DEPENDENCE, CREATION, MANIFESTATION, BRINGS_ABOUT, TRIGGERS, COMPOSITION, 
    AGGREGATION, INHERENCE, VALUE, FORMAL, CONSTITUTION, 

    NUMBER_LITERAL, SPECIAL_SYMBOL, NEW_TYPE, INSTANCE_NAME, CLASS_NAME, RELATION_NAME,

    UNKNOWN
};

const string tokenTypeNames[] = {
    "EOF",

    "GENSET", "DISJOINT", "COMPLETE", "GENERAL", "SPECIFICS", "WHERE", "PACKAGE", "IMPORT", "FUNCTIONAL_COMPLEXES", 

    "NUMBER", "STRING", "BOOLEAN", "DATE", "TIME", "DATETIME",

    "ORDERED", "CONST", "DERIVED", "SUBSETS", "REDEFINES",

    "EVENT", "SITUATION", "PROCESS", "CATEGORY", "MIXIN", "PHASE_MIXIN", "ROLE_MIXIN", "HISTORICAL_MIXIN", 
    "HISTORICAL_ROLE", "HISTORICAL_ROLE_MIXIN", "KIND", "COLLECTIVE", "QUANTITY", "QUALITY", "MODE", 
    "INTRINSIC_MODES", "EXTRINSIC_MODES", "SUBKIND", "PHASE", "ROLE", 
    
    "MATERIAL", "DERIVATION", "COMPARATIVE", "MEDIATION", "CHARACTERIZATION", "EXTERNAL_DEPENDENCE", 
    "COMPONENT_OF", "MEMBER_OF", "SUB_COLLECTION_OF", "SUB_QUALITY_OF", "INSTANTIATION", "TERMINATION", "PARTICIPATIONAL", 
    "PARTICIPATION", "HISTORICAL_DEPENDENCE", "CREATION", "MANIFESTATION", "BRINGS_ABOUT", "TRIGGERS", "COMPOSITION", 
    "AGGREGATION", "INHERENCE", "VALUE", "FORMAL", "CONSTITUTION", 

    "NUMBER_LITERAL", "SPECIAL_SYMBOL", "NEW_TYPE", "INSTANCE_NAME", "CLASS_NAME", "RELATION_NAME",

    "UNKNOWN"
};

enum tokenClass {
    // Inicio das palavras reservadas.
    RESERVED_WORDS = tokenTypes::GENSET,

    // Fim das palavras reservadas, inicio dos tipos.
    PRIMITIVE_TYPE = tokenTypes::NUMBER,

    // Fim dos tipos, inicio de meta atributos.
    META_ATTRIBUTE = tokenTypes::ORDERED,

    // Fim dos meta atributos, inicio dos estereotipos de classe.
    CLASS_STEREOTYPES = tokenTypes::EVENT,

    // Fim dos estereotipos de classe, inicio dos estereotipos de relação.
    RELATION_STEREOTYPES = tokenTypes::MATERIAL,

    // Fim dos estereotipos de relação, inicio dos tipos de token unicos.
    NUMBERL = tokenTypes::NUMBER_LITERAL,

    SPECIALSYMBOL, NEWTYPE, INSTANCE, CLASS, RELATION, 

    UNKNOWNSYMBOL
};

const map<tokenClass, string> tokenClassNames = {
    { RESERVED_WORDS, "Palavra reservada" },
    { PRIMITIVE_TYPE, "Tipo primitivo" },
    { META_ATTRIBUTE, "Meta atributo" },
    { CLASS_STEREOTYPES, "Estereótipos de classe" },
    { RELATION_STEREOTYPES, "Estereótipos de relação" },
    { NUMBERL, "Número" },
    { SPECIALSYMBOL, "Símbolo especial" },
    { NEWTYPE, "Novo tipo" },
    { INSTANCE, "Instância" },
    { CLASS, "Classe" },
    { RELATION, "Relação" },
    { UNKNOWNSYMBOL, "Símbolo desconhecido" }
};

struct token {
    uint type;
    uint classification;
    string lexeme;
    uint line;
    uint column;

    token(uint type, uint classification, string lexeme, uint line, uint column) 
    : type(type), classification(classification), lexeme(lexeme), line(line), column(column){};
};
