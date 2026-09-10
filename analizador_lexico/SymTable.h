#include <unordered_map>
#include "Token.h"
using std::unordered_map;

class SymTable{
private:
    unordered_map<int, Token> table;

public: 
    void insert(Token t){
        table.insert(t.token, t);
    }
};


