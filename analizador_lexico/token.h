#pragma once

enum Tokens {
    GENSET=1, DISJOINT, COMPLETE, GENERAL, SPECIFICS, WHERE, PACKAGE, IMPORT, FUNCTIONAL_COMPLEXES
};

struct Token {
    uint token;
    int line;
    int column;
};