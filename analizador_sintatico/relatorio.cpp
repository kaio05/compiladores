#include "relatorio.h"
#include <cstdio>

static ErroSintatico erros[MAX_ERROS];
static int quantidade_erros = 0;

void registrar_erro(
    int linha,
    int coluna,
    const char* mensagem,
    const char* sugestao
) {
    if (quantidade_erros >= MAX_ERROS) {
        return;
    }

    ErroSintatico* erro = &erros[quantidade_erros++];

    erro->linha = linha;
    erro->coluna = coluna;

    std::snprintf(
        erro->mensagem,
        sizeof(erro->mensagem),
        "%s",
        mensagem
    );

    std::snprintf(
        erro->sugestao,
        sizeof(erro->sugestao),
        "%s",
        sugestao
    );
}

void gerar_relatorio(void) {
    std::printf("\n=== RELATORIO DE ERROS ===\n");

    for (int i = 0; i < quantidade_erros; i++) {
        const ErroSintatico* erro = &erros[i];

        std::printf(
            "\nErro %d\n"
            "Linha: %d, Coluna: %d\n"
            "Problema: %s\n"
            "Sugestao: %s\n",
            i + 1,
            erro->linha,
            erro->coluna,
            erro->mensagem,
            erro->sugestao
        );
    }

    std::printf(
        "\nTotal de erros: %d\n",
        quantidade_erros
    );
}

int obter_quantidade_erros(void) {
    return quantidade_erros;
}