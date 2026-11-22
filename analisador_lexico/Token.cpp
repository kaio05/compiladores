#include "Token.h"
#include <sstream>

// ------------------------------------------------------------------------------

string token::toString() const
{
    std::ostringstream ss;
    
    ss << "[Categoria: " << TokenCategoryToString(category)
    << ", Tipo: " << TokenTypeToString(type) << "] " << name
    << " (linha: " << line << ", coluna: " << columnStart << " a " << columnEnd << ")";

    return ss.str();
}

// ------------------------------------------------------------------------------

string TokenTypeToString(yytokentype token) 
{
    switch (token) {
        case YYEMPTY: return "Vazio";
        case YYEOF: return "Fim do arquivo";
        case YYerror: return "YYerror";
        case YYUNDEF: return "Simbolo não definido";

        case EVENT: return "EVENT";
        case SITUATION: return "SITUATION";
        case PROCESS: return "PROCESS";
        case CATEGORY: return "CATEGORY";
        case MIXIN: return "MIXIN";
        case PHASE_MIXIN: return "PHASE_MIXIN";
        case ROLE_MIXIN: return "ROLE_MIXIN";
        case HISTORICAL_ROLE: return "HISTORICAL_ROLE";
        case HISTORICAL_MIXIN: return "HISTORICAL_MIXIN";
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
        case RELATORS: return "RELATORS";

        case RELATION: return "RELATION";
        case PACKAGE: return "PACKAGE";
        case IMPORT: return "IMPORT";
        case OF: return "OF";
        case FUNCTIONAL_COMPLEXES: return "FUNCTIONAL_COMPLEXES";
        case DATA_TYPE: return "DATA_TYPE";
        case ENUM: return "ENUM";
        case SPECIALIZES: return "SPECIALIZES";

        case GENSET: return "GENSET";
        case DISJOINT: return "DISJOINT";
        case COMPLETE: return "COMPLETE";
        case GENERAL: return "GENERAL";
        case SPECIFICS: return "SPECIFICS";
        case WHERE: return "WHERE";

        case NUMBER: return "NUMBER";
        case STRING: return "STRING";
        case BOOLEAN: return "BOOLEAN";
        case DATE: return "DATE";
        case TIME: return "TIME";
        case DATETIME: return "DATETIME";

        case ORDERED: return "ORDERED";
        case CONST: return "CONST";
        case DERIVED: return "DERIVED";
        case SUBSETS: return "SUBSETS";
        case REDEFINES: return "REDEFINES";

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

        case DASH: return "DASH";
        case AGGREGATION_OP: return "AGGREGATION_OP";
        case COMPOSITION_OP: return "COMPOSITION_OP";

        case OPEN_BRACES: return "{";
        case CLOSE_BRACES: return "}";
        case COLON: return ":";
        case COMMA: return ",";
        case AT: return "@";
        case DOT: return ".";

        case NUMBER_LITERAL: return "NUMBER_LITERAL";
        case CARDINALITY: return "CARDINALITY";
        case INSTANCE_NAME: return "INSTANCE_NAME";
        case NEW_TYPE: return "NEW_TYPE";
        case CLASS_NAME: return "CLASS_NAME";
        case RELATION_NAME: return "RELATION_NAME";
        case PACKAGE_NAME: return "Package name";

        case UNKNOWN: return "UNKNOWN";

        default: return "Token desconhecido";
    }
}

// ------------------------------------------------------------------------------

string TokenCategoryToString(yyTokenCategory category) 
{
    switch (category) {
        case yyTokenCategory::CLASS_STEREOTYPES: return "Estereótipo de classe";
        case yyTokenCategory::RESERVED_WORDS: return "Palavra reservada";
        case yyTokenCategory::GENERALIZATION: return "Generalização";
        case yyTokenCategory::PRIMITIVE_TYPE: return "Tipo primitivo";
        case yyTokenCategory::META_ATTRIBUTE: return "Meta atributo";
        case yyTokenCategory::RELATION_STEREOTYPES: return "Estereótipo de relação";
        case yyTokenCategory::RELATION_OP: return "Operador de ralação";
        case yyTokenCategory::SPECIAL_SYMBOL: return "Símbolo especial";
        case yyTokenCategory::NUMBER_LITERAL: return "Número literal";
        case yyTokenCategory::CARDINALITY: return "Cardinalidade";
        case yyTokenCategory::INSTANCE_NAME: return "Nome de instância";
        case yyTokenCategory::NEW_TYPE: return "Novo tipo";
        case yyTokenCategory::CLASS_NAME: return "Nome de classe";
        case yyTokenCategory::RELATION_NAME: return "Nome de relação";
        case yyTokenCategory::PACKAGE_NAME: return "Nome de pacote";
        case yyTokenCategory::UNKNOWN_TOKEN: return "Token desconhecido";

        default: return "Categoria desconhecida";
    }
}
