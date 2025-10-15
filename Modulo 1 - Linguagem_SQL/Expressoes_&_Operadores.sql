/* 
===========================================================
EXPRESSÕES E OPERADORES NO SQL SERVER
===========================================================

As expressões e operadores são fundamentais para construir consultas dinâmicas e precisas.
Elas permitem manipular valores, realizar cálculos, aplicar filtros e definir condições lógicas.

===========================================================
EXPRESSÕES
===========================================================

Uma expressão é uma combinação de valores, colunas, funções e operadores que o SQL Server
avalia para obter um resultado.

Tipos:
- Expressão simples: utiliza apenas um valor ou uma operação direta.
- Expressão complexa: envolve múltiplos operadores, funções ou colunas.

*/

-- Exemplo de expressão simples
SELECT 10 + 5 AS ResultadoSimples;

-- Exemplo de expressão complexa
SELECT (PrecoUnitario * Quantidade) - Desconto AS ValorFinal
FROM Vendas.ItemPedido;

-- Exemplo prático com função e cálculo de diferença de datas
SELECT 
    PrimeiroNome,
    DataAdmissao,
    GETDATE() - DataAdmissao AS TempoDias
FROM Rh.Empregado;

/*
Explicação:
GETDATE() retorna a data atual.
A subtração entre datas resulta no número de dias entre elas.
Aqui, “TempoDias” mostra há quantos dias o empregado foi admitido.
*/

/* 
===========================================================
CONVERSÕES DE DADOS
===========================================================

O SQL Server realiza conversões implícitas automaticamente quando possível.
Porém, em muitos casos é necessário converter explicitamente usando funções como
CAST e CONVERT, para evitar erros ou garantir o formato desejado.

*/

-- Conversão explícita com CAST
SELECT CAST('2025-10-14' AS DATETIME) AS DataConvertida;

-- Conversão explícita com CONVERT (permite definir formato)
SELECT CONVERT(VARCHAR(10), GETDATE(), 103) AS DataFormatoBR; -- 103 = dd/mm/yyyy

/*
Explicação:
CAST é mais simples e segue o padrão ANSI.
CONVERT é específico do SQL Server e permite formatação de datas e números.
*/

/* 
===========================================================
OPERADORES MATEMÁTICOS
===========================================================

Usados para realizar operações aritméticas com colunas, valores ou expressões.

Operadores:
+ (adição)
- (subtração)
* (multiplicação)
/ (divisão)
% (módulo)

Regras:
Se duas expressões têm o mesmo tipo de dado, o resultado mantém esse tipo.
Em divisões entre inteiros, o resultado também será inteiro (truncado).
*/

-- Exemplo 1: Divisão entre inteiros
SELECT 10 / 3 AS ResultadoInteiro;  -- Retorna 3

-- Exemplo 2: Divisão com decimal
SELECT 10.0 / 3 AS ResultadoDecimal; -- Retorna 3.3333

/* 
===========================================================
TABELA DE PRECEDÊNCIA DE OPERADORES
===========================================================

A precedência define a ordem em que os operadores são avaliados em uma expressão.

Ordem de precedência (do mais alto para o mais baixo):
1. Parênteses: ()
2. Operadores aritméticos de multiplicação/divisão/módulo: (*, /, %)
3. Operadores aritméticos de adição/subtração: (+, -)
4. Operadores de comparação: (=, <>, !=, >, <, >=, <=)
5. Operadores lógicos unários: NOT
6. Operadores lógicos binários: AND
7. Operadores lógicos binários: OR
*/

-- Exemplo prático
SELECT 10 + 5 * 2 AS Resultado;  -- Resultado = 20 (multiplicação ocorre primeiro)
SELECT (10 + 5) * 2 AS Resultado; -- Resultado = 30 (parênteses alteram a ordem)

/*
Explicação:
Os operadores são avaliados de acordo com sua precedência.
O uso de parênteses permite alterar essa ordem e priorizar determinadas operações.
*/

/* 
===========================================================
OPERADORES DE COMPARAÇÃO
===========================================================

Usados para comparar valores em expressões booleanas.

Operadores:
=     Igual
>     Maior que
<     Menor que
>=    Maior ou igual
<=    Menor ou igual
<> ou != Diferente
IS NULL / IS NOT NULL  Verifica valores nulos
*/

-- Exemplo
SELECT *
FROM Rh.Empregado
WHERE Salario > 5000 AND Cargo <> 'Estagiário';

/*
Explicação:
Este exemplo retorna todos os empregados cujo salário é maior que 5000
e que não possuem o cargo de “Estagiário”.
*/

/* 
===========================================================
OPERADORES LÓGICOS
===========================================================

Combinam ou invertem condições booleanas, retornando resultados:
TRUE (verdadeiro), FALSE (falso) ou UNKNOWN (desconhecido, quando há NULLs).

Principais operadores:
AND     → Retorna TRUE se ambas as condições forem verdadeiras.
OR      → Retorna TRUE se ao menos uma condição for verdadeira.
NOT     → Inverte o resultado lógico (TRUE vira FALSE e vice-versa).
IN      → Verifica se o valor está em uma lista.
BETWEEN → Verifica se um valor está dentro de um intervalo.
LIKE    → Compara padrões em strings.
EXISTS  → Verifica se uma subconsulta retorna resultados.
ALL / ANY / SOME → Comparam um valor com o resultado de uma subconsulta.
*/

-- Exemplo: AND e OR
SELECT *
FROM Rh.Empregado
WHERE Salario > 4000 AND Departamento = 'TI';

-- Exemplo: IN
SELECT *
FROM Rh.Empregado
WHERE Departamento IN ('TI', 'RH', 'Financeiro');

-- Exemplo: BETWEEN
SELECT *
FROM Rh.Empregado
WHERE DataAdmissao BETWEEN '2020-01-01' AND '2024-12-31';

-- Exemplo: LIKE (busca textual com padrões)
SELECT *
FROM Rh.Empregado
WHERE PrimeiroNome LIKE 'A%'; -- Começa com A

-- Exemplo: EXISTS
SELECT Nome
FROM Rh.Empregado E
WHERE EXISTS (
    SELECT 1 FROM Vendas.Pedido P WHERE P.iIdEmpregado = E.iIdEmpregado
);

-- Exemplo: ALL e ANY
SELECT *
FROM Vendas.Pedido
WHERE ValorTotal > ALL (SELECT ValorTotal FROM Vendas.Pedido WHERE iIDCliente = 10);

SELECT *
FROM Vendas.Pedido
WHERE ValorTotal > ANY (SELECT ValorTotal FROM Vendas.Pedido WHERE iIDCliente = 10);

/*
Explicação:
- ALL compara o valor com todos os resultados da subconsulta (precisa ser maior que todos).
- ANY compara o valor com pelo menos um dos resultados (basta um ser menor para retornar TRUE).
- EXISTS retorna TRUE se a subconsulta retornar ao menos uma linha.
- LIKE é útil para buscas parciais de texto.
- BETWEEN facilita a filtragem por intervalos, como datas ou valores numéricos. Considera os valores das extremidades para comparação
*/

/* 
===========================================================
COMBINAÇÃO DE AND E OR
===========================================================

O SQL segue uma ordem de precedência lógica:

1. NOT
2. AND
3. OR

Isso significa que o SQL avalia primeiro as condições com AND,
e só depois as com OR — a menos que se use parênteses para definir
explicitamente a prioridade.

Sem parênteses, o resultado pode ser diferente do esperado.
*/

/* Exemplo 1 – Interpretação incorreta */
SELECT *
FROM Vendas.Cliente
WHERE Cidade = 'São Paulo'
   OR Cidade = 'Rio de Janeiro'
   AND Ativo = 1;

/*
A consulta acima é interpretada assim:

WHERE Cidade = 'São Paulo'
   OR (Cidade = 'Rio de Janeiro' AND Ativo = 1)

Resultado:
- Todos os clientes de São Paulo serão retornados,
  mesmo que não estejam ativos.
- Apenas clientes ativos do Rio de Janeiro serão retornados.

Ou seja, a condição "Ativo = 1" só vale para o Rio de Janeiro.
*/

/* Exemplo 2 – Correção com parênteses */
SELECT *
FROM Vendas.Cliente
WHERE (Cidade = 'São Paulo' OR Cidade = 'Rio de Janeiro')
  AND Ativo = 1;

/*
Agora a lógica está correta:
- Apenas clientes de São Paulo ou Rio de Janeiro
  que também estão ativos serão retornados.

Os parênteses garantem a prioridade da comparação entre cidades
antes de aplicar o filtro de "Ativo = 1".
*/

/*
Resumo:
Sempre use parênteses ao combinar AND e OR para evitar resultados
imprevistos e tornar a intenção da consulta mais clara.
*/

/* 
===========================================================
NULL E EXPRESSÕES
===========================================================

NOT NULL / NULL

O que acontece ao usarmos NULL em alguma expressão, por exemplo, de soma ou concatenação?

- Qualquer operação aritmética ou de concatenação envolvendo NULL resulta em NULL.
  Exemplo:
    SELECT 10 + NULL AS ResultadoSoma;        -- Retorna NULL
    SELECT 'ABC' + NULL AS ResultadoConcat;   -- Retorna NULL

- NULL = NULL -> Sempre falso
  Isso ocorre porque o NULL representa "valor desconhecido" e o SQL não pode afirmar
  que dois valores desconhecidos são iguais.

- NULL não pode ser comparado com operadores de comparação (=, <, >, etc.).
  É necessário utilizar:
    IS NULL      → para verificar se o valor é nulo
    IS NOT NULL  → para verificar se o valor não é nulo

  Exemplo:
    SELECT *
    FROM Clientes
    WHERE DataNascimento IS NULL;        -- Busca clientes sem data cadastrada

- O NULL é ignorado nas funções de agregação (exceto COUNT(*))
  Exemplo:
    SELECT
        COUNT(IdCliente) AS TotalComValor,
        COUNT(*) AS TotalLinhas
    FROM Clientes;
  -- COUNT(IdCliente) ignora NULLs
  -- COUNT(*) conta todas as linhas, inclusive com valores NULL

===========================================================
FRASE LÓGICA: "TODAS DE UMA VEZ"
===========================================================

O SQL não processa linha a linha como uma linguagem procedural (ex: Python, C, etc.).
Ele trabalha com **conjuntos de dados** e avalia **todas as expressões de uma fase lógica**
de processamento ao mesmo tempo.

Isso significa que:
- O otimizador do SQL Server pode escolher **a ordem mais eficiente** para avaliar as condições.
- Dentro de uma mesma fase lógica, as expressões **não têm uma ordem garantida** de execução.
- Por isso, não se deve depender da ordem de avaliação de expressões no mesmo nível.

Exemplo:
    SELECT *
    FROM Produtos
    WHERE (Preco / Estoque) > 10 
        AND Estoque > 0;

Se houver linhas com Estoque = 0, o SQL pode gerar erro de divisão por zero,
mesmo que a condição "Preco > 0" pudesse, aparentemente, filtrar esses casos antes.
Isso ocorre porque o SQL pode avaliar ambas as condições simultaneamente.

Forma segura:
    SELECT *
    FROM Produtos
    WHERE Estoque > 0
      AND (Preco / Estoque) > 10;

Dessa forma, garantimos que não há risco de erro, independentemente da ordem de avaliação interna.

===========================================================
BOA PRÁTICA:
===========================================================
- Sempre trate NULLs e condições lógicas de forma explícita.
- Use ISNULL(), COALESCE() ou CASE para evitar resultados inesperados.
- Nunca confie na “ordem de avaliação” dentro de uma mesma fase — o SQL é declarativo,
  e o otimizador decide como executar.

*/

/* 
===========================================================
CURTO-CIRCUITO E AVALIAÇÃO DE EXPRESSÕES LÓGICAS
===========================================================

O T-SQL dá suporte ao conceito de **curto-circuito**, 
mas seu comportamento pode surpreender quem vem de linguagens como C#, Java ou Python.

Em linguagens tradicionais, a avaliação é feita **da esquerda para a direita**,
e se o primeiro predicado já define o resultado da expressão lógica,
o segundo nem chega a ser avaliado.

Exemplo clássico (em linguagens imperativas):

   if (x != 0 && 10 / x > 2)   --> só avalia o segundo se x != 0 for verdadeiro

Porém, no SQL Server a história é diferente.

O otimizador **não garante a ordem de avaliação** dos predicados dentro da mesma fase lógica.
Ele pode escolher avaliar o predicado de **menor custo** primeiro, mesmo que esteja escrito depois.

Isso significa que o conceito de curto-circuito **não é garantido**.

*/

/* Exemplo de comportamento potencialmente perigoso */

SELECT Quantidade,
       PrecoTotal,
       PrecoTotal / Quantidade AS PrecoUnitario
FROM Tabela
WHERE Quantidade / 2 * 2 <> 0
      AND PrecoTotal / Quantidade >= 2.5;

/*
Mesmo com o filtro `Quantidade / 2 * 2 <> 0` antes,
o SQL Server pode decidir avaliar primeiro `PrecoTotal / Quantidade >= 2.5`
por ser uma operação de **menor custo**. Isso pode gerar erro de divisão por zero.

Esse comportamento ocorre porque o SQL Server avalia as expressões com base no **plano de execução**,
e não necessariamente na **ordem textual** do código.

------------------------------------------------------------
SOLUÇÕES SEGURAS
------------------------------------------------------------

1. Usar NULLIF para evitar divisões por zero:
   (substitui 0 por NULL, o que torna a operação segura)

   PrecoTotal / NULLIF(Quantidade, 0)

2. Usar funções que testam validade ou convertem de forma segura:
   - COALESCE(expr1, expr2, ...)     → Retorna o primeiro valor não nulo
   - ISDATE(expr)                    → Verifica se a expressão é uma data válida
   - IIF(condicao, valor_se_verdadeiro, valor_se_falso)
   - TRY_PARSE(expr AS tipo)         → Converte com segurança; retorna NULL se falhar

Exemplo seguro:

SELECT Quantidade,
       PrecoTotal,
       PrecoTotal / NULLIF(Quantidade, 0) AS PrecoUnitario
FROM Tabela
WHERE IIF(Quantidade > 0, PrecoTotal / Quantidade, 0) >= 2.5;

*/

/* 
===========================================================
INSTRUÇÃO CASE
===========================================================

A instrução CASE é uma **expressão condicional**.
Ela permite testar condições dentro de uma consulta SQL e retornar valores diferentes
conforme o resultado dessas condições.

Pode ser utilizada em qualquer parte de uma query:
SELECT, WHERE, ORDER BY, GROUP BY, HAVING, etc.

Funciona como um “IF” dentro do SQL.

------------------------------------------------------------
1. Forma simples (sem expressão inicial)
------------------------------------------------------------

CASE 
    WHEN <condição1> THEN <resultado1>
    WHEN <condição2> THEN <resultado2>
    ELSE <resultado_padrão>
END

Exemplo:
SELECT Nome,
       Salario,
       CASE 
           WHEN Salario >= 10000 THEN 'Alto'
           WHEN Salario BETWEEN 5000 AND 9999 THEN 'Médio'
           ELSE 'Baixo'
       END AS FaixaSalarial
FROM RH.Empregado;

------------------------------------------------------------
2. Forma com expressão inicial
------------------------------------------------------------

CASE <expressão>
    WHEN <valor1> THEN <resultado1>
    WHEN <valor2> THEN <resultado2>
    ELSE <resultado_padrão>
END

Exemplo:
SELECT CASE DATEPART(WEEKDAY, GETDATE())
           WHEN 1 THEN 'Domingo'
           WHEN 2 THEN 'Segunda'
           WHEN 3 THEN 'Terça'
           WHEN 4 THEN 'Quarta'
           WHEN 5 THEN 'Quinta'
           WHEN 6 THEN 'Sexta'
           WHEN 7 THEN 'Sábado'
       END AS DiaDaSemana;

------------------------------------------------------------
3. CASE aninhado
------------------------------------------------------------

Um CASE pode estar dentro de outro, permitindo testes mais complexos:

SELECT Nome,
       Salario,
       CASE 
           WHEN Salario >= 10000 THEN 
                CASE 
                    WHEN Cargo = 'Gerente' THEN 'Alta Gerência'
                    ELSE 'Profissional Sênior'
                END
           ELSE 'Demais Colaboradores'
       END AS Categoria
FROM RH.Empregado;

------------------------------------------------------------
Boas práticas:
- Sempre incluir um ELSE, mesmo que seja para retornar NULL.
- Evite usar CASE para substituir lógica que deveria estar em uma tabela auxiliar.
- Lembre-se: CASE é uma expressão, não um comando de controle de fluxo.

===========================================================
*/



