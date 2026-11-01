#include "AnalisadorLexico.h"
#include <iostream>

// ------------------------------------------------------------------------------

using std::cout;

// ------------------------------------------------------------------------------

const map<yytokentype, string> AnalisadorLexico::tokenTypeNames = {
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
    { DATA_TYPE, "DATA_TYPE" },
    { INSTANCE_NAME, "INSTANCE_NAME" },
    { NEW_TYPE, "NEW_TYPE" },
    { CLASS_NAME, "CLASS_NAME" },
    { RELATION_NAME, "RELATION_NAME" },
    { UNKNOWN, "UNKNOWN" },
    { OPEN_BRACES, "{" },
    { CLOSE_BRACES, "}" },
    { COLON, ":" },
    { COMMA, "," },
    { AT, "@" },
    { DOT, "." },
    { RELATION_KW, "RELATION_KW" },
    { CARDINALITY, "CARDINALITY" },
    { DASH, "DASH" },
    { AGGREGATION_OP, "AGGREGATION_OP" },
    { COMPOSITION_OP, "COMPOSITION_OP" },
    { ENUM, "ENUM" },
    { ATTR_NAME, "ATTR_NAME" }
};

const map<tokenClass, string> AnalisadorLexico::tokenClassNames  = {
    { tokenClass::RESERVED_WORDS, "Palavra reservada" },
    { tokenClass::PRIMITIVE_TYPE, "Tipo primitivo" },
    { tokenClass::META_ATTRIBUTE, "Meta-atributo" },
    { tokenClass::CLASS_STEREOTYPES, "Estereótipo de classe" },
    { tokenClass::RELATION_STEREOTYPES, "Estereótipo de relação" },
    { tokenClass::NUMBER_LITERAL, "Número" },
    { tokenClass::NEW_TYPE, "Novo tipo" },
    { tokenClass::INSTANCE_NAME, "Instância" },
    { tokenClass::CLASS_NAME, "Classe" },
    { tokenClass::RELATION_NAME, "Relação" },
    { tokenClass::UNKNOWN_SYMBOL, "Símbolo desconhecido" },
    { tokenClass::SPECIAL_SYMBOL, "Símbolo especial" },
    { tokenClass::RELATION_OP, "Operação de relação" },
    { tokenClass::ENUM, "Enumerador" },
    { tokenClass::ATTR_NAME, "Nome de atributo" }
};

// ------------------------------------------------------------------------------

AnalisadorLexico::AnalisadorLexico()
{

}

// ------------------------------------------------------------------------------

AnalisadorLexico::AnalisadorLexico(ifstream& instream, ostream& outstream)
{
    lexer.switch_streams(instream, outstream);
}

// ------------------------------------------------------------------------------

int AnalisadorLexico::yylex() 
{
    int readToken = lexer.yylex();

    if (readToken <= 0) {
        return readToken;
    }

    uint classifytoken = (uint)classifyTokens(readToken);

    currentToken = token(
        readToken, 
        classifytoken, 
        lexer.YYText(),
        lexer.lineno(),
        yyColumnStart,
        yyColumnEnd
    );

    classificatedToken[classifytoken]++;

    if (readToken == UNKNOWN) {
        unknownToken.push_back(currentToken);
    }

    return readToken;
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::yySwitchStreams(ifstream& instream, ostream& outstream)
{
    lexer.switch_streams(instream, outstream);
}

// ------------------------------------------------------------------------------

void AnalisadorLexico::start()
{
    cout << "===============\n" << "Visão analítica\n" << "===============\n";

    int readToken;

    while(readToken = this->yylex() > 0) {
        cout << "<Token: " 
             << tokenTypeNames.at(static_cast<yytokentype>(currentToken.type)) << ", " 
             << tokenClassNames.at(static_cast<tokenClass>(currentToken.classification)) << ", \""
             << currentToken.lexeme << "\"" 
             << ", line: " << currentToken.line
             << ", column start:" << yycolumnStart 
             << ", column end: " << yycolumnEnd
             << ">\n";
    }

    cout << "\nFim do arquivo.\n\n";


    cout << "=================\n" << "Tabela de síntese\n" << "=================\n";

	for(auto pair: classificatedToken) {
		tokenClass tc = (tokenClass)pair.first;
		cout << tokenClassNames.at(tc) << ": "<< pair.second << "\n";
	}

	if (!unknownToken.empty()) {
		cout << "\n\n";
		cout << "====================\n" << "Tokens desconhecidos\n" << "====================\n";

		for (auto token : unknownToken) {
            cout << "Caractere: \"" 
            << token.lexeme << "\" desconhecido." 
            << " Linha: " << token.line 
            << ". Colunas: " << token.columnStart
            << " a " << token.columnEnd << "."
            << "\n";
		}
	}
}

// ------------------------------------------------------------------------------

tokenClass AnalisadorLexico::classifyTokens(uint type)
{
    if (type >= (uint)tokenClass::RESERVED_WORDS && type < (uint)tokenClass::PRIMITIVE_TYPE) {
        return tokenClass::RESERVED_WORDS; 
    } 
    else if (type >= (uint)tokenClass::PRIMITIVE_TYPE && type < (uint)tokenClass::META_ATTRIBUTE) {
        return tokenClass::PRIMITIVE_TYPE;
    } 
    else if (type >= (uint)tokenClass::META_ATTRIBUTE && type < (uint)tokenClass::CLASS_STEREOTYPES) {
        return tokenClass::META_ATTRIBUTE;
    }
    else if (type >= (uint)tokenClass::CLASS_STEREOTYPES && type < (uint)tokenClass::RELATION_STEREOTYPES) {
        return tokenClass::CLASS_STEREOTYPES;
    }
    else if (type >= (uint)tokenClass::RELATION_STEREOTYPES && type < (uint)tokenClass::NUMBER_LITERAL) {
        return tokenClass::RELATION_STEREOTYPES;
    } 
    else if (type >= (uint)tokenClass::SPECIAL_SYMBOL && type < (uint)tokenClass::RELATION_OP) {
        return tokenClass::SPECIAL_SYMBOL;
    }
    else if (type >= (uint)tokenClass::RELATION_OP && type < (uint)tokenClass::ENUM) {
        return tokenClass::RELATION_OP;
    }

    return static_cast<tokenClass>(type);
}

// ------------------------------------------------------------------------------
