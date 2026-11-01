#ifndef RELATORIO_H
#define RELATORIO_H

#define MAX_ERROS 100

typedef struct {
    int linha;
    int coluna;
    char mensagem[256];
    char sugestao[256];
} ErroSintatico;

// Registra um novo erro sintático.
void registrar_erro(
    int linha,
    int coluna,
    const char* mensagem,
    const char* sugestao
);

// Exibe os erros registrados.
void gerar_relatorio(void);

// Retorna a quantidade de erros registrados.
int obter_quantidade_erros(void);

#endif