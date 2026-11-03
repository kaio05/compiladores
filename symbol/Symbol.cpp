#include "Symbol.h"
#include <sstream>

// ------------------------------------------------------------------------------

string symbol::toString() const
{
    std::ostringstream ss;
    
    ss << "[" << SymbolCategoryToString(category) << "] " << name
    << " (line: " << line << ", column: " << columnStart << " a " << columnEnd << ")";

    return ss.str();
}

// ------------------------------------------------------------------------------

string SymbolTypeToString(yytokentype token) 
{
    switch (token) {
        case YYEMPTY: return "Vazio";
        case YYEOF: return "Fim do arquivo";
        case YYerror: return "YYerror";
        case YYUNDEF: return "Simbolo não definido";

        case GENSET: return "GENSET";
        case DISJOINT: return "DISJOINT";
        case COMPLETE: return "COMPLETE";
        case GENERAL: return "GENERAL";
        case SPECIFICS: return "SPECIFICS";
        case WHERE: return "WHERE";
        case PACKAGE: return "PACKAGE";
        case IMPORT: return "IMPORT";
        case FUNCTIONAL_COMPLEXES: return "FUNCTIONAL_COMPLEXES";

        case NUMBER: return "NUMBER";
        case STRING: return "STRING";
        case BOOLEAN: return "BOOLEAN";
        case DATE: return "DATE";
        case TIME: return "TIME";
        case DATETIME: return "DATETIME";

        case ORDERED: return "ORDERED";
        case CONST: return "CONST";
        case DERIVED: return "DERIVED";
        case SPECIALIZES: return "SPECIALIZES";
        case SUBSETS: return "SUBSETS";
        case REDEFINES: return "REDEFINES";

        case EVENT: return "EVENT";
        case SITUATION: return "SITUATION";
        case PROCESS: return "PROCESS";
        case CATEGORY: return "CATEGORY";
        case MIXIN: return "MIXIN";
        case PHASE_MIXIN: return "PHASE_MIXIN";
        case ROLE_MIXIN: return "ROLE_MIXIN";
        case HISTORICAL_MIXIN: return "HISTORICAL_MIXIN";
        case HISTORICAL_ROLE: return "HISTORICAL_ROLE";
        case HISTORICAL_ROLE_MIXIN: return "HISTORICAL_ROLE_MIXIN";

        case KIND: return "KIND";
        case COLLECTIVE: return "COLLECTIVE";
        case QUANTITY: return "QUANTITY";
        case QUALITY: return "QUALITY";
        case MODE: return "MODE";
        case INTRINSIC_MODES: return "INTRINSIC_MODES";
        case EXTRINSIC_MODES: return "EXTRINSIC_MODES";

        case SUBKIND: return "SUBKIND";
        case PHASE: return "PHASE";
        case ROLE: return "ROLE";
        case RELATOR: return "RELATOR";

        case MATERIAL: return "MATERIAL";
        case DERIVATION: return "DERIVATION";
        case COMPARATIVE: return "COMPARATIVE";
        case MEDIATION: return "MEDIATION";
        case CHARACTERIZATION: return "CHARACTERIZATION";
        case EXTERNAL_DEPENDENCE: return "EXTERNAL_DEPENDENCE";

        case COMPONENT_OF: return "COMPONENT_OF";
        case MEMBER_OF: return "MEMBER_OF";
        case SUB_COLLECTION_OF: return "SUB_COLLECTION_OF";
        case SUB_QUALITY_OF: return "SUB_QUALITY_OF";
        case INSTANTIATION: return "INSTANTIATION";
        case TERMINATION: return "TERMINATION";
        case PARTICIPATIONAL: return "PARTICIPATIONAL";
        case PARTICIPATION: return "PARTICIPATION";
        case HISTORICAL_DEPENDENCE: return "HISTORICAL_DEPENDENCE";

        case CREATION: return "CREATION";
        case MANIFESTATION: return "MANIFESTATION";
        case BRINGS_ABOUT: return "BRINGS_ABOUT";
        case TRIGGERS: return "TRIGGERS";
        case COMPOSITION: return "COMPOSITION";
        case AGGREGATION: return "AGGREGATION";
        case INHERENCE: return "INHERENCE";

        case VALUE: return "VALUE";
        case FORMAL: return "FORMAL";
        case CONSTITUTION: return "CONSTITUTION";

        case NUMBER_LITERAL: return "NUMBER_LITERAL";
        case DATA_TYPE: return "DATA_TYPE";
        case INSTANCE_NAME: return "INSTANCE_NAME";
        case NEW_TYPE: return "NEW_TYPE";
        case CLASS_NAME: return "CLASS_NAME";
        case RELATION_NAME: return "RELATION_NAME";
        case UNKNOWN: return "UNKNOWN";

        case OPEN_BRACES: return "{";
        case CLOSE_BRACES: return "}";
        case COLON: return ":";
        case COMMA: return ",";
        case AT: return "@";
        case DOT: return ".";

        case RELATION_KW: return "RELATION_KW";
        case CARDINALITY: return "CARDINALITY";
        case DASH: return "DASH";
        case AGGREGATION_OP: return "AGGREGATION_OP";
        case COMPOSITION_OP: return "COMPOSITION_OP";
        case ENUM: return "ENUM";
        case ATTR_NAME: return "ATTR_NAME";

        default: return "Token desconhecido";
    }
}

// ------------------------------------------------------------------------------

string SymbolCategoryToString(SymbolCategory category) 
{
    switch (category) {
        case SymbolCategory::RESERVED_WORDS: return "Palavra reservada";
        case SymbolCategory::PRIMITIVE_TYPE: return "Tipo primitivo";
        case SymbolCategory::META_ATTRIBUTE: return "Meta-atributo";
        case SymbolCategory::CLASS_STEREOTYPES: return "Estereótipo de classe";
        case SymbolCategory::RELATION_STEREOTYPES: return "Estereótipo de relação";
        case SymbolCategory::NUMBER_LITERAL: return "Número";
        case SymbolCategory::NEW_TYPE: return "Novo tipo";
        case SymbolCategory::INSTANCE_NAME: return "Instância";
        case SymbolCategory::CLASS_NAME: return "Classe";
        case SymbolCategory::RELATION_NAME: return "Relação";
        case SymbolCategory::UNKNOWN_SYMBOL: return "Símbolo desconhecido";
        case SymbolCategory::SPECIAL_SYMBOL: return "Símbolo especial";
        case SymbolCategory::RELATION_OP: return "Operação de relação";
        case SymbolCategory::ENUM: return "Enumerador";
        case SymbolCategory::ATTR_NAME: return "Nome de atributo";

        default: return "Categoria desconhecida";
    }
}
