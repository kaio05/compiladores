# Analisador Léxico para a Linguagem TONTO

## Fase 2 — Análise Sintática

Projeto da disciplina de Compiladores (UFERSA) para a criação de um compilador em C++, utilizando Flex e Bison para a "Textual Ontology Language" (TONTO).

## Sobre o Projeto

**TONTO** (Textual Ontology Language) é uma linguagem textual para a especificação de ontologias computacionais. Este projeto pretende implementar um compilador para a linguagem, o **analisador léxico**, **analisador sintático** e um **analisador semântico**. O primeiro é responsável por ler o código-fonte `.tonto` e convertê-lo em uma sequência de tokens (as menores unidades lógicas da linguagem). Já o segundo utiliza os tokens obtidos pela fase anterior e verifica se elas seguem as regras gramaticais do TONTO. Por fim, o analisador semântico ainda está em fase de construção.

O analisador léxico foi construído em C++ utilizando a ferramenta [Flex (Fast Lexical Analyzer Generator)](https://github.com/westes/flex).
O analisador sintático também foi construído em C++ em conjunto com o [Bison](https://www.gnu.org/software/bison/).

## Funcionalidades do analisador léxico

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

## Funcionalidades e limitações do analisador sintático

* **Verificação de corretude**: O analisador sintático construído consegue analisar um único arquivo .tonto e verificar se a declaração de `Pacotes`, `Classes`, `Tipos de dados`, `Enumeradores`, `Generalizações` e `Relações` segue o padrão da linguagem TONTO.
* **Tabela de símbolos**: Consegue gerar e exibir uma tabela de símbolos com divisão de escopos corretamente.
* **Relatório de erros**: Caso o analisador encontre algum erro ele irá exibir imediatamente o erro encontrado, informando a linha, coluna e o problema encontrado, bem como uma sugestão do que deve ser feito para solucionar o erro.

## Tecnologias Utilizadas

*   C++20 (compilador g++)
*   Flex (Fast Lexical Analyzer)
*   Bison
*   GNU Make

## Estrutura de Pastas

A estrutura do projeto está organizada da seguinte forma:

    compiladores/
    ├── analizador_lexico/
    │   ├── lexer.l                 (Regras léxicas e regex em Flex)
    │   ├── AnalisadorLexico.cpp        (Classe personalizada para acessar funcionalidades do analisador)
    │   ├── AnalisadorLexico.h          (Arquivo de cabeçalho para o analisador léxico)
    │   └── tests/                  (Arquivos .tonto para validação, ocultados para melhorar a visualização)
    │
    ├── analizador_sintativo/
    │   ├── testes/             (Arquivos .tonto para validação, ocultados para melhorar a visualização)
    │   ├── makefile            (script de automação de build)
    │   ├── parser.y            (Regras gramaticais e função main)
    │   ├── relatorio.cpp       (Implementação das funções e estrutras relacionadas à saída de erros do parser)
    │   ├── relatorio.h         (Definição de funções e estruturas relacionadas ao relatório de erros)
    │   ├── symtamble.cpp       (Implementação da tabela de símbolos)
    │   └── symtable.h          (Definição da tabela de símbolos)
    │
    ├──symbol/
    │   ├── Symbol.cpp          (Implementação da estrutura de simbolo utilizada)
    │   └── Symbol.h            (Definição de um símbolo do compilador)
    │
    └── README.md                (Este arquivo)

## Como Compilar e Rodar

### 1. Dependências Necessárias
*   **Linux**: `sudo apt install g++ flex make`
*   **Windows (MSYS2)**: `pacman -S gcc flex make`

> **Nota para Windows (MSYS2):** Certifique-se de que as pastas `\msys64\usr\bin` e `\msys64\ucrt64\bin` estejam no PATH do sistema. O arquivo de cabeçalho `FlexLexer.h` (encontrado em `\msys64\usr\include`) deve estar acessível pelo compilador (você pode copiá-lo para `\msys64\ucrt64\include` ou para a pasta `src/` do projeto).

### 2. Compilação
Abra o terminal, navegue até a pasta `analizador_sintatico/` e execute o utilitário Make:

```bash
cd analizador_lexico
make
```

Isso executará o arquivo de automação make, gerando os arquivos necessários para gerar a o arquivo parser.

### 3. Execução
Execute o programa passando o caminho de um arquivo `.tonto` como argumento:

**No Linux:**
```bash
./parser tests/car.tonto
```

**No Windows:**
```bash
.\parser.exe tests\car.tonto
```

#### 3.1 Flag opcional
Passe a flag opcional `-flex` logo após o caminho do arquivo para alternar a saída do parser, exibindo a saída do analisador léxico.

## Exemplo de Saída do analisador léxico

Ao analisar um arquivo com a flag `-flex`, a saída no terminal seguirá exatamente este formato:

```text
===============
Visão analítica
===============
<Token: PACKAGE, Palavra reservada, "package", line: 1, column start:1, column end: 8>
<Token: CLASS_NAME, Classe, "CarOwnership", line: 1, column start:9, column end: 21>
<Token: KIND, Estereótipo de classe, "kind", line: 3, column start:1, column end: 5>
<Token: CLASS_NAME, Classe, "Organization", line: 3, column start:6, column end: 18>
<Token: SUBKIND, Estereótipo de classe, "subkind", line: 4, column start:1, column end: 8>
...
<Token: DASH, Operação de relação, "--", line: 12, column start:25, column end: 27>
<Token: CARDINALITY, Operação de relação, "[1]", line: 12, column start:28, column end: 31>
<Token: CLASS_NAME, Classe, "Car", line: 12, column start:32, column end: 35>
<Token: }, Símbolo especial, "}", line: 13, column start:1, column end: 2>

Fim do arquivo.

=================
Tabela de síntese
=================
Operação de relação: 6
Estereótipo de relação: 2
Símbolo especial: 4
Categoria desconhecida: 1
Relação: 2
Estereótipo de classe: 4
Classe: 8
Palavra reservada: 1
```

## Exemplo de saída do analisador sintático
Análise padrão de um arquivo.tonto, A saída seguirá esse formato:
```text
=======================================================
Análise do parser
=======================================================
Declaração de pacote: CarOwnership, linha: 1
Declaração de classe: Organization, linha: 3
Declaração de classe: CarAgency, linha: 4
Declaração de classe: Car, linha: 5
Declaração de classe: CarOwnership, linha: 7
Declaração de relação interna: involvesOwner, linha: 9
Declaração de relação interna: involvesProperty, linha: 12

=======================================================
TABELAS DE SÍMBOLOS GERADAS (POR ESCOPO)
=======================================================
--- Tabela de Símbolos [Escopo: package CarOwnership] ---
Tamanho: 5 entradas (Bucket count: 13)
  Chave ["CarOwnership"] => [Categoria: Class, Tipo: CLASS_NAME] CarOwnership (linha: 7, coluna: 9 a 21)
  Chave ["CarAgency"] => [Categoria: Class, Tipo: CLASS_NAME] CarAgency (linha: 4, coluna: 9 a 18)
  Chave ["Car"] => [Categoria: Class, Tipo: CLASS_NAME] Car (linha: 5, coluna: 6 a 9)
  Chave ["Organization"] => [Categoria: Class, Tipo: CLASS_NAME] Organization (linha: 3, coluna: 6 a 18)
  Chave ["package CarOwnership"] => [Categoria: package, Tipo: CLASS_NAME] CarOwnership (linha: 1, coluna: 9 a 21)

--- Tabela de Símbolos [Escopo: CarOwnership] ---
Tamanho: 2 entradas (Bucket count: 13)
  Chave ["involvesProperty"] => [Categoria: Internal relation, Tipo: DASH] involvesProperty (linha: 12, coluna: 32 a 35)
  Chave ["involvesOwner"] => [Categoria: Internal relation, Tipo: DASH] involvesOwner (linha: 9, coluna: 29 a 38)


========== ERRO ENCONTRADO ==========

Nenhum erro encontrado.
```