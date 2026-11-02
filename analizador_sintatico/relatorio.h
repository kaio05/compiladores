#ifndef RELATORIO_H
#define RELATORIO_H

#include <string>
#include <vector>

enum class TipoErro {
    PACOTE,
    CLASSE,
    ATRIBUTO,
    DATA_TYPE,
    ENUM,
    GENSET,
    RELACAO,
    GENERICO
};

struct ErroSintatico {
    TipoErro tipo;
    int linha;
    int coluna;
    std::string mensagem;
    std::string sugestao;
};

void registrar_erro(
    TipoErro tipo,
    int linha,
    int coluna,
    const std::string& mensagem,
    const std::string& sugestao
);

void gerar_relatorio();

#endif