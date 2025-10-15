/*
===========================================================
ORDEM DE PROCESSAMENTO LÓGICO DAS INSTRUÇÕES SQL
===========================================================

De acordo com o padrão ANSI, as instruções SQL não são processadas
na ordem em que as escrevemos, mas sim em uma sequência lógica interna.
Entender essa ordem ajuda a compreender como o banco interpreta e executa
cada parte da consulta, evita erros e auxilia na otimização das queries.

Ordem lógica de processamento padrão:
1. FROM       → Define de onde os dados virão (tabelas, views, etc.)
2. WHERE      → Filtra linhas do conjunto inicial
3. GROUP BY   → Agrupa as linhas em conjuntos menores
4. HAVING     → Filtra os grupos criados
5. SELECT     → Escolhe quais colunas ou expressões serão exibidas
6. ORDER BY   → Organiza o resultado final
7. TOP        → Limita o número de linhas retornadas

Considerando a instrução completa, para o SQL Server 2022, a ordem seria:
1. FROM
2. ON
3. JOIN
4. WHERE
5. GROUP BY
6. WITH CUBE | WITH ROLLUP
7. HAVING
8. SELECT
9. DISTINCT
10. ORDER BY
11. TOP | OFFSET FETCH

Por que isso é importante?
- Saber a ordem ajuda a evitar erros, otimizar consultas e entender 
como filtros, agrupamentos e projeções interagem no processamento.
*/

/* ===========================================================
Exemplo prático com indicação das fases
=========================================================== */
SELECT 
    iIdEmpregado,                        -- FASE 5: seleção final de colunas
    YEAR(DataPedido) AS AnoPedido,
    COUNT(*) AS QuantidadePedido
FROM Vendas.Pedido                       -- FASE 1: fonte de dados
WHERE iIDCliente = 71                    -- FASE 2: filtra as linhas
GROUP BY iIdEmpregado, YEAR(DataPedido)  -- FASE 3: agrupa os resultados
HAVING COUNT(*) > 1                      -- FASE 4: filtra os grupos
ORDER BY iIdEmpregado;                   -- FASE 6: ordena o resultado

/* ===========================================================
FASE FROM
===========================================================

A cláusula FROM define de onde os dados serão obtidos.
Pode receber:
- Tabela física
- View
- Expressão de tabela comum (CTE)
- Subconsulta (tabela derivada)
- Função que retorna tabela
- Construtor de valor de tabela
*/
SELECT *
FROM Vendas.Pedido;

/* ===========================================================
FASE WHERE
===========================================================

Filtra as linhas individuais antes de qualquer agrupamento.

Estrutura comum:
1. Coluna operador Valor
2. Valor operador Coluna

Valores lógicos:
- Verdadeiro → a linha atende ao predicado
- Falso → a linha não atende
- Desconhecido → ocorre quando há valores NULL
*/
SELECT *
FROM Vendas.Pedido
WHERE iIDCliente = 71;

/* ===========================================================
FASE GROUP BY
===========================================================

Agrupa os registros com base em uma ou mais colunas.

Regras:
- Apenas colunas do GROUP BY ou funções de agregação podem aparecer no SELECT
- Internamente, o GROUP BY realiza uma ordenação

Funções de agregação comuns:
- COUNT()
- SUM()
- AVG()
- MAX()
- MIN()

Diferença entre COUNT(*) e COUNT(coluna):
- COUNT(*) → conta todas as linhas
- COUNT(coluna) → ignora valores NULL
*/
SELECT iIdEmpregado, COUNT(*) AS Quantidade
FROM Vendas.Pedido
WHERE iIDCliente = 71
GROUP BY iIdEmpregado;

/* ===========================================================
FASE HAVING
===========================================================

O HAVING é um filtro aplicado após o agrupamento.
Enquanto o WHERE filtra linhas individuais, o HAVING filtra grupos.

O HAVING só faz sentido quando há um GROUP BY.

Exemplo:
Selecionar apenas empregados com mais de 1 pedido no ano
*/
SELECT iIdEmpregado, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
GROUP BY iIdEmpregado
HAVING COUNT(*) > 1;

/* Diferença prática entre WHERE e HAVING */
-- Filtro de ano no HAVING (menos eficiente)
SELECT YEAR(DataPedido) AS AnoPedido, iIdEmpregado, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE iIDCliente = 71
GROUP BY YEAR(DataPedido), iIdEmpregado
HAVING YEAR(DataPedido) >= 2007;

-- Filtro de ano no WHERE (mais eficiente)
SELECT YEAR(DataPedido) AS AnoPedido, iIdEmpregado, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE iIDCliente = 71 AND YEAR(DataPedido) >= 2007
GROUP BY YEAR(DataPedido), iIdEmpregado;

/* ===========================================================
FASE SELECT
===========================================================

- Permite funções de transformação (UPPER, LOWER)
- Concatenação de colunas
- Expressões calculadas
- Uso de aliases (AS nome_coluna)

Observações:
- Aliases no SELECT não podem ser usados em fases anteriores
- DISTINCT remove duplicatas, mas não afeta colunas únicas (PK/Unique)
*/

/* ===========================================================
FASE ORDER BY
===========================================================

A cláusula ORDER BY define a ordem em que os resultados serão apresentados.

- ASC → Ordenação crescente (do menor para o maior)
- DESC → Ordenação decrescente (do maior para o menor)
- É possível ordenar por múltiplas colunas, definindo a prioridade de cada coluna
- Sempre utilize o nome da coluna ou alias, não a posição, para evitar confusão
*/

/* Exemplo 1: Ordenação crescente (ASC) por iIdEmpregado */
SELECT iIdEmpregado, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE iIDCliente = 71
GROUP BY iIdEmpregado
ORDER BY iIdEmpregado ASC;

/*
Explicação:
- O resultado será exibido do menor IdEmpregado para o maior.
- ASC é opcional, pois é a ordem padrão.
- Útil para identificar rapidamente os registros iniciais de forma crescente.
*/

/* Exemplo 2: Ordenação decrescente (DESC) por TotalPedidos */
SELECT iIdEmpregado, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE iIDCliente = 71
GROUP BY iIdEmpregado
ORDER BY TotalPedidos DESC;

/*
Explicação:
- Aqui ordenamos pelo número de pedidos em ordem decrescente.
- O maior número de pedidos aparece primeiro.
- Útil para identificar os "empregados com mais pedidos" rapidamente.
*/

/* Exemplo 3: Ordenação por múltiplas colunas
   Primeiro por AnoPedido em ordem decrescente, depois por iIdEmpregado em ordem crescente */
SELECT iIdEmpregado, YEAR(DataPedido) AS AnoPedido, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE iIDCliente = 71
GROUP BY YEAR(DataPedido), iIdEmpregado
ORDER BY AnoPedido DESC, iIdEmpregado ASC;

/*
Explicação:
- Primeiro critério: Ano do pedido (AnoPedido) do mais recente para o mais antigo.
- Segundo critério: iIdEmpregado em ordem crescente, apenas quando houver empate no ano.
- Múltiplas colunas permitem ordenar hierarquicamente, aplicando prioridades.
- Essencial quando precisamos organizar os resultados por mais de um atributo.
*/

/* Exemplo 4: Combinação prática com ASC e DESC em diferentes colunas */
SELECT iIdEmpregado, YEAR(DataPedido) AS AnoPedido, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE iIDCliente = 71
GROUP BY YEAR(DataPedido), iIdEmpregado
ORDER BY TotalPedidos DESC, AnoPedido ASC;

/*
Explicação:
- Primeiro critério: TotalPedidos decrescente (quem tem mais pedidos aparece primeiro)
- Segundo critério: AnoPedido crescente (para desempates, começa do ano mais antigo)
- Demonstra como podemos misturar ASC e DESC para organizar os dados conforme a necessidade do negócio.
*/

/* ===========================================================
FASE TOP
===========================================================

A cláusula TOP é uma extensão do T-SQL (SQL Server) utilizada para limitar a quantidade de linhas retornadas por uma consulta.

Ordem de avaliação:
- O TOP é aplicado **após o ORDER BY**, ou seja, o SQL Server primeiro ordena os dados e depois retorna apenas o número especificado.

Principais formas de uso:
1. TOP (N) → Retorna as N primeiras linhas.
2. TOP (N) PERCENT → Retorna N% do total de linhas.
3. TOP (N) WITH TIES → Retorna N linhas, mas inclui empates no valor da última linha (baseado no ORDER BY).

*/

/* Exemplo 1: Retornar as 10 linhas mais recentes (TOP N) */
SELECT TOP 10 *
FROM Vendas.Pedido
ORDER BY DataPedido DESC;

/*
Explicação:
- Retorna os 10 pedidos mais recentes (DataPedido em ordem decrescente).
- O ORDER BY garante que os registros sejam organizados antes da limitação.
- Sem o ORDER BY, o TOP retorna linhas aleatórias, pois o SQL não garante ordem implícita.
*/

/* Exemplo 2: Retornar 20% dos pedidos (TOP N PERCENT) */
SELECT TOP 20 PERCENT *
FROM Vendas.Pedido
ORDER BY DataPedido DESC;

/*
Explicação:
- Retorna 20% das linhas totais da tabela Vendas.Pedido.
- O percentual é calculado sobre o total de registros disponíveis.
- Útil quando o número total de linhas pode variar, e se deseja uma amostra proporcional.
*/

/* Exemplo 3: Retornar os 5 pedidos com maior valor total, incluindo empates (TOP WITH TIES) */
SELECT TOP 5 WITH TIES iIDPedido, iIDCliente, Frete
FROM Vendas.Pedido
ORDER BY Frete DESC;

/*
Explicação:
- Retorna os 5 pedidos com maior ValorTotal.
- Caso o 5º e o 6º pedido tenham o mesmo valor (empate), ambos serão retornados.
- A cláusula WITH TIES garante que todos os registros com o mesmo valor de ordenação sejam incluídos.
- Fundamental quando não se quer “cortar” resultados empatados no limite.
*/

/* Exemplo 4: Combinação prática com filtros e ordenação múltipla */
SELECT TOP 3 WITH TIES iIdEmpregado, COUNT(*) AS TotalPedidos
FROM Vendas.Pedido
WHERE YEAR(DataPedido) = 2008
GROUP BY iIdEmpregado
ORDER BY TotalPedidos DESC, iIdEmpregado ASC;

/*
Explicação:
- Retorna os 3 empregados com mais pedidos no ano de 2008.
- Caso haja empate no TotalPedidos do 3º lugar, todos empatados serão incluídos.
- A segunda ordenação (iIdEmpregado ASC) define o desempate visual, mas não interfere no WITH TIES.
*/
