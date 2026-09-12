#pragma once
using uint = unsigned int;

enum tokens {
    GENSET=1, DISJOINT, COMPLETE, GENERAL, SPECIFICS, WHERE, PACKAGE, IMPORT, FUNCTIONAL_COMPLEXES
};

struct Token {
    uint token;
    int linha;
    int coluna;
};