#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <string>
#include <unordered_map>
#include <iostream>
#include "../symbol/Symbol.h"

// ============================================================================
// Tabela de Símbolos como Tabela de Dispersão Encadeada (Escopos)
// ============================================================================

class SymTable {
private:
    // Tabela de dispersão
    std::unordered_map<std::string, symbol*> table;

    // Ponteiro para a tabela do bloco/escopo mais externo
    SymTable* prev;

    // Nome descritivo do escopo
    std::string scopeName;

public:
    SymTable(SymTable* p = nullptr, const std::string& name = "global");
    ~SymTable();

    // Insere símbolo no escopo atual
    void put(const std::string& s, symbol* sym);

    // Consulta símbolo encadeado do escopo interno para os externos
    symbol* get(const std::string& s);

    // Consulta símbolo apenas no escopo local
    symbol* getLocal(const std::string& s);

    // Acessores e utilitários
    SymTable* getPrev() const { return prev; }
    const std::string& getScopeName() const { return scopeName; }
    void setScopeName(const std::string& name) { scopeName = name; }
    const std::unordered_map<std::string, symbol*>& getTable() const { return table; }

    void printTable(std::ostream& out = std::cout) const;
};

#endif // SYMTABLE_H
