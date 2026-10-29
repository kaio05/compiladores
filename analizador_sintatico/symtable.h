#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <string>
#include <unordered_map>
#include <iostream>

// ============================================================================
// Estrutura de Símbolo da Linguagem TONTO
// ============================================================================

enum class SymbolCategory {
    PACKAGE,
    CLASS,
    DATATYPE,
    ENUM,
    ATTRIBUTE,
    RELATION,
    GENSET,
    OTHER
};

std::string categoryToString(SymbolCategory cat);

class Symbol {
public:
    std::string name;
    SymbolCategory category;
    std::string type;
    int line;
    int column;
    std::string scope;

    Symbol(const std::string& name, SymbolCategory cat = SymbolCategory::OTHER,
           const std::string& type = "", int line = 0, int column = 0, const std::string& scope = "");
    virtual ~Symbol() = default;

    virtual std::string toString() const;
};

// ============================================================================
// Tabela de Símbolos como Tabela de Dispersão Encadeada (Escopos)
// Implementação baseada no modelo teórico do Prof. Judson Santos Santiago (Slide 16)
// ============================================================================

class SymTable {
private:
    // Tabela de dispersão (std::unordered_map nativa do C++)
    std::unordered_map<std::string, Symbol*> table;

    // Ponteiro para a tabela do bloco/escopo mais externo (Slide 16)
    SymTable* prev;

    // Nome descritivo do escopo
    std::string scopeName;

public:
    SymTable(SymTable* p = nullptr, const std::string& name = "global");
    ~SymTable();

    // Insere símbolo no escopo atual (Slide 16)
    void put(const std::string& s, Symbol* sym);

    // Consulta símbolo encadeado do escopo interno para os externos (Slide 16)
    Symbol* get(const std::string& s);

    // Consulta símbolo apenas no escopo local
    Symbol* getLocal(const std::string& s);

    // Acessores e utilitários
    SymTable* getPrev() const { return prev; }
    const std::string& getScopeName() const { return scopeName; }
    const std::unordered_map<std::string, Symbol*>& getTable() const { return table; }

    void printTable(std::ostream& out = std::cout) const;
};

#endif // SYMTABLE_H
