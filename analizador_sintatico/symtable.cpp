#include "symtable.h"
#include <sstream>
#include <iomanip>

std::string categoryToString(SymbolCategory cat) {
    switch (cat) {
        case SymbolCategory::PACKAGE:   return "Pacote";
        case SymbolCategory::CLASS:     return "Classe";
        case SymbolCategory::DATATYPE:  return "Tipo de Dados";
        case SymbolCategory::ENUM:      return "Enum";
        case SymbolCategory::ATTRIBUTE: return "Atributo";
        case SymbolCategory::RELATION:  return "Relação";
        case SymbolCategory::GENSET:    return "Genset";
        default:                        return "Outro";
    }
}

// ============================================================================
// Implementação de Symbol
// ============================================================================

Symbol::Symbol(const std::string& name, SymbolCategory cat, const std::string& type,
               int line, int column, const std::string& scope)
    : name(name), category(cat), type(type), line(line), column(column), scope(scope) {}

std::string Symbol::toString() const {
    std::ostringstream ss;
    ss << "[" << categoryToString(category) << "] " << name;
    if (!type.empty()) {
        ss << " : " << type;
    }
    if (line > 0) {
        ss << " (lin: " << line << ", col: " << column << ")";
    }
    return ss.str();
}

// ============================================================================
// Implementação de SymTable (Tabela de Dispersão Encadeada - Slide 16)
// ============================================================================

SymTable::SymTable(SymTable* p, const std::string& name)
    : prev(p), scopeName(name) {}

SymTable::~SymTable() {
    // Libera a memória dos símbolos alocados neste escopo
    for (auto& pair : table) {
        delete pair.second;
    }
    table.clear();
}

void SymTable::put(const std::string& s, Symbol* sym) {
    table[s] = sym;
}

Symbol* SymTable::get(const std::string& s) {
    // Busca encadeada percorrendo do escopo atual para o mais externo (Slide 16)
    for (SymTable* st = this; st != nullptr; st = st->prev) {
        auto it = st->table.find(s);
        if (it != st->table.end()) {
            return it->second;
        }
    }
    return nullptr;
}

Symbol* SymTable::getLocal(const std::string& s) {
    auto it = table.find(s);
    if (it != table.end()) {
        return it->second;
    }
    return nullptr;
}

void SymTable::printTable(std::ostream& out) const {
    out << "--- Tabela de Símbolos [Escopo: " << scopeName << "] ---\n";
    out << "Tamanho: " << table.size() << " entradas (Bucket count: " << table.bucket_count() << ")\n";
    for (const auto& pair : table) {
        out << "  Chave [\"" << pair.first << "\"] => " << (pair.second ? pair.second->toString() : "null") << "\n";
    }
}
