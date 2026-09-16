# Analisador Léxico para a Linguagem TONTO

## 🧩 Fase 1 — Análise Léxica (Lexer)

Projeto da disciplina de Compiladores (UFERSA) para a criação de um analisador léxico em C++ e Flex para a "Textual Ontology Language" (TONTO).

## 📖 Sobre o Projeto

**TONTO** (Textual Ontology Language) é uma linguagem textual para a especificação de ontologias computacionais. Este projeto implementa a primeira fase de um compilador para a linguagem, o **analisador léxico**, responsável por ler o código-fonte `.tonto` e convertê-lo em uma sequência de tokens (as menores unidades lógicas da linguagem).

O analisador foi construído em C++ utilizando a ferramenta [Flex (Fast Lexical Analyzer Generator)](https://github.com/westes/flex).

## ✨ Funcionalidades

*   **Reconhecimento Completo**: Identifica todos os estereótipos (de classe e relação), palavras-chave, meta-atributos e símbolos especiais da linguagem TONTO.
*   **Identificadores Complexos**: Classifica corretamente os diferentes tipos de identificadores através de expressões regulares:
    *   `CLASS_NAME` (Ex: `Person`, `Car`)
    *   `INSTANCE_NAME` (Ex: `planet01`)
    *   `RELATION_NAME` (Ex: `involvesOwner`)
    *   `NEW_TYPE` (Ex: `CPFDataType`)
*   **Dupla Visualização de Saída**:
    *   **Visão Analítica**: Uma lista detalhada de cada token encontrado, exibindo seu tipo, lexema (valor original), linha e coluna exata no código-fonte.
    *   **Tabela de Síntese**: Um resumo quantitativo com a contagem total de cada categoria de token (ex: Palavra reservada, Classe, Relação) ao final da análise.
*   **Relatório de Erros**: Captura caracteres ilegais e informa a linha e coluna onde o erro léxico (marcado como `UNKNOWN`) ocorreu.

## 🛠️ Tecnologias Utilizadas

*   C++20 (compilador g++)
*   Flex (Fast Lexical Analyzer)
*   GNU Make

## 📁 Estrutura de Pastas

A estrutura do projeto está organizada da seguinte forma:

    seu-projeto/
    ├── analizador_lexico/
    │   ├── makefile             (Script de automação de compilação)
    │   ├── src/
    │   │   ├── lexer.l          (Regras léxicas e regex em Flex)
    │   │   ├── main.cpp         (Lógica principal e geração de relatórios)
    │   │   └── token.h          (Dicionário de tokens e categorias)
    │   └── tests/               (Arquivos .tonto para validação)
    │       ├── TDAH.tonto
    │       ├── alergiaalimentar.tonto
    │       ├── car.tonto
    │       └── university.tonto
    └── README.md                (Este arquivo)

## 🚀 Como Compilar e Rodar

### 1. Dependências Necessárias
*   **Linux**: `sudo apt install g++ flex make`
*   **Windows (MSYS2)**: `pacman -S gcc flex make`

> **Nota para Windows (MSYS2):** Certifique-se de que as pastas `\msys64\usr\bin` e `\msys64\ucrt64\bin` estejam no PATH do sistema. O arquivo de cabeçalho `FlexLexer.h` (encontrado em `\msys64\usr\include`) deve estar acessível pelo compilador (você pode copiá-lo para `\msys64\ucrt64\include` ou para a pasta `src/` do projeto).

### 2. Compilação
Abra o terminal, navegue até a pasta `analizador_lexico/` e execute o utilitário Make:

```bash
cd analizador_lexico
make