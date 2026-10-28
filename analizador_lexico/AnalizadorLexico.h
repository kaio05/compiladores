#pragma once

// ------------------------------------------------------------------------------

#include <FlexLexer.h>
#include <string>
#include <map>

// ------------------------------------------------------------------------------

using uint = unsigned int;
using std::string;
using std::map;

// ------------------------------------------------------------------------------

struct token {
    uint type;
    uint classification;
    string lexeme;
    uint line;
    uint column;
    
    token(uint type, uint classification, string lexeme, uint line, uint column) 
    : type(type), classification(classification), lexeme(lexeme), line(line), column(column){};
};

const map<yytokentype, string> tokenTypeNames = {
    { YYEMPTY, "Vazio" },
    { YYEOF, "Fim do arquivo" },
    { YYerror, "YYerror" },
    { YYUNDEF, "Simbolo não definido" },
    { GENSET, "GENSET"  },
    { DISJOINT, "DISJOINT" },
    { COMPLETE, "COMPLETE" },
    { GENERAL, "GENERAL" },
    { SPECIFICS, "SPECIFICS" },
    { WHERE, "WHERE" },
    { PACKAGE, "PACKAGE" },
    { IMPORT, "IMPORT" },
    { FUNCTIONAL_COMPLEXES, "FUNCTIONAL_COMPLEXES" },
    { NUMBER, "NUMBER" },
    { STRING, "STRING" },
    { BOOLEAN, "BOOLEAN" },
    { DATE, "DATE" },
    { TIME, "TIME" },
    { DATETIME, "DATETIME" },
    { ORDERED, "ORDERED" },
    { CONST, "CONST"   },
    { DERIVED, "DERIVED" },
    { SPECIALIZES, "SPECIALIZES" },
    { SUBSETS, "SUBSETS" },
    { REDEFINES, "REDEFINES" },
    { EVENT, "EVENT" },
    { SITUATION, "SITUATION" },
    { PROCESS, "PROCESS" },
    { CATEGORY, "CATEGORY" },
    { MIXIN, "MIXIN" },
    { PHASE_MIXIN, "PHASE_MIXIN" },
    { ROLE_MIXIN, "ROLE_MIXIN" },
    { HISTORICAL_MIXIN, "HISTORICAL_MIXIN" },
    { HISTORICAL_ROLE, "HISTORICAL_ROLE" },
    { HISTORICAL_ROLE_MIXIN, "HISTORICAL_ROLE_MIXIN" },
    { KIND, "KIND" },
    { COLLECTIVE, "COLLECTIVE" },
    { QUANTITY, "QUANTITY" },
    { QUALITY, "QUALITY" },
    { MODE, "MODE" },
    { INTRINSIC_MODES, "INTRINSIC_MODES" },
    { EXTRINSIC_MODES, "EXTRINSIC_MODES" },
    { SUBKIND, "SUBKIND" },
    { PHASE, "PHASE" },
    { ROLE, "ROLE" },
    { RELATOR, "RELATOR" },
    { MATERIAL, "MATERIAL" },
    { DERIVATION, "DERIVATION" },
    { COMPARATIVE, "COMPARATIVE" },
    { MEDIATION, "MEDIATION" },
    { CHARACTERIZATION, "CHARACTERIZATION" },
    { EXTERNAL_DEPENDENCE, "EXTERNAL_DEPENDENCE" },
    { COMPONENT_OF, "COMPONENT_OF"},
    { MEMBER_OF, "MEMBER_OF" },
    { SUB_COLLECTION_OF, "SUB_COLLECTION_OF" },
    { SUB_QUALITY_OF, "SUB_QUALITY_OF" },
    { INSTANTIATION, "INSTANTIATION" },
    { TERMINATION, "TERMINATION" },
    { PARTICIPATIONAL, "PARTICIPATIONAL" },
    { PARTICIPATION, "PARTICIPATION" },
    { HISTORICAL_DEPENDENCE, "HISTORICAL_DEPENDENCE" },
    { CREATION, "CREATION" },
    { MANIFESTATION, "MANIFESTATION" },
    { BRINGS_ABOUT, "BRINGS_ABOUT" },
    { TRIGGERS, "TRIGGERS" },
    { COMPOSITION, "COMPOSITION" },
    { AGGREGATION, "AGGREGATION" },
    { INHERENCE, "INHERENCE" },
    { VALUE, "VALUE" },
    { FORMAL, "FORMAL" },
    { CONSTITUTION, "CONSTITUTION" },
    { NUMBER_LITERAL, "NUMBER_LITERAL" },
    { SPECIAL_SYMBOL, "SPECIAL_SYMBOL" },
    { DATA_TYPE, "DATA_TYPE" },
    { INSTANCE_NAME, "INSTANCE_NAME" },
    { NEW_TYPE, "NEW_TYPE" },
    { CLASS_NAME, "CLASS_NAME" },
    { RELATION_NAME, "RELATION_NAME" },
    { UNKNOWN, "UNKNOWN" },
    { RELATION_KW, "RELATION_KW" },
    { CARDINALITY, "CARDINALITY" },
    { DASH, "DASH" },
    { AGGREGATION_OP, "AGGREGATION_OP" },
    { COMPOSITION_OP, "COMPOSITION_OP" },
    { ENUM, "ENUM" },
    { ATTR_NAME, "ATTR_NAME" }
};

enum class tokenClass {
    RESERVED_WORDS = yytokentype::GENSET,
    PRIMITIVE_TYPE = yytokentype::NUMBER,
    META_ATTRIBUTE = yytokentype::ORDERED,
    CLASS_STEREOTYPES = yytokentype::EVENT,
    RELATION_STEREOTYPES = yytokentype::MATERIAL,
    NUMBER_LITERAL = yytokentype::NUMBER_LITERAL,
    SPECIAL_SYMBOL, 
    DATA_TYPE,
    INSTANCE_NAME, 
    NEW_TYPE, 
    CLASS_NAME, 
    RELATION_NAME, 
    UNKNOWN_SYMBOL,
    RELATION_OP = yytokentype::RELATION_KW,
    ENUM,
    ATTR_NAME
};

const map<tokenClass, string> tokenClassNames = {
    { tokenClass::RESERVED_WORDS, "Palavras reservadas" },
    { tokenClass::PRIMITIVE_TYPE, "Tipos primitivos" },
    { tokenClass::META_ATTRIBUTE, "Meta-atributos" },
    { tokenClass::CLASS_STEREOTYPES, "Estereótipos de classe" },
    { tokenClass::RELATION_STEREOTYPES, "Estereótipos de relação" },
    { tokenClass::NUMBER_LITERAL, "Números" },
    { tokenClass::SPECIAL_SYMBOL, "Símbolos especiais" },
    { tokenClass::NEW_TYPE, "Novos tipos" },
    { tokenClass::INSTANCE_NAME, "Instâncias" },
    { tokenClass::CLASS_NAME, "Classes" },
    { tokenClass::RELATION_NAME, "Relações" },
    { tokenClass::UNKNOWN_SYMBOL, "Símbolos desconhecidos" },
    { tokenClass::RELATION_OP, "Operação de relação" },
    { tokenClass::ENUM, "Enumerador" },
    { tokenClass::ATTR_NAME, "Nome de atributo" }
};
