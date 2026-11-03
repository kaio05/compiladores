
#include "relatorio.h"
#include <iostream>
#include <string>
#include <vector>

static std::vector<ErroSintatico> erros;

// Converte a categoria do erro em texto.
static std::string obter_nome_tipo(TipoErro tipo) {
    switch (tipo) {
        case TipoErro::PACOTE:
            return "PACOTE";

        case TipoErro::CLASSE:
            return "CLASSE";

        case TipoErro::ATRIBUTO:
            return "ATRIBUTO";

        case TipoErro::DATA_TYPE:
            return "DATA_TYPE";

        case TipoErro::ENUM:
            return "ENUM";

        case TipoErro::GENSET:
            return "GENSET";

        case TipoErro::RELACAO:
            return "RELACAO";

        case TipoErro::GENERICO:
            return "GENERICO";

        default:
            return "DESCONHECIDO";
    }
}

// Registra um novo erro.
void registrar_erro(
    TipoErro tipo,
    int linha,
    int coluna,
    int colunaFim,
    const std::string& mensagem,
    const std::string& sugestao
) {
    erros.push_back({
        tipo,
        linha,
        coluna,
        colunaFim,
        mensagem,
        sugestao
    });
}

// Exibe todos os erros registrados.
void gerar_relatorio() {
    std::cout << "\n========== RELATORIO DE ERROS ==========\n";

    if (erros.empty()) {
        std::cout << "\nNenhum erro encontrado.\n";
        return;
    }

    for (size_t i = 0; i < erros.size(); i++) {
        const ErroSintatico& erro = erros[i];

        std::cout << "\nErro " << i + 1 << "\n";

        std::cout << "Categoria: "
                  << obter_nome_tipo(erro.tipo) << "\n";

        std::cout << "Linha: " << erro.linha << "\n";
        std::cout << "Coluna: " << erro.coluna << " a " << erro.colunaFim << "\n";

        std::cout << "Problema: "
                  << erro.mensagem << "\n";

        std::cout << "Sugestao: "
                  << erro.sugestao << "\n";

        std::cout << "----------------------------------------\n";
    }

    std::cout << "\nTotal de erros: " << erros.size() << "\n";
}

// Retorna a quantidade de erros registrados.
int obter_quantidade_erros() {
    return static_cast<int>(erros.size());
}
