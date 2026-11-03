#include "symtable.h"
#include <sstream>
#include <iomanip>

// ============================================================================
// Implementação de SymTable (Tabela de Dispersão Encadeada
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

void SymTable::put(const std::string& s, symbol* sym) {
    table[s] = sym;
}

symbol* SymTable::get(const std::string& s) {
    // Busca encadeada percorrendo do escopo atual para o mais externo
    for (SymTable* st = this; st != nullptr; st = st->prev) {
        auto it = st->table.find(s);
        if (it != st->table.end()) {
            return it->second;
        }
    }
    return nullptr;
}

symbol* SymTable::getLocal(const std::string& s) {
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
