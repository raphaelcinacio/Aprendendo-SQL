/* 
============================================================
VARIÁVEIS NO SQL SERVER
============================================================

Uma variável é um espaço temporário em memória usado para armazenar
dados durante a execução de um script SQL.

É útil para armazenar valores intermediários, parâmetros ou resultados
de cálculos, e pode ser usada em consultas, DML, funções e procedimentos.

============================================================ 
*/

/* 
============================================================
COMO DEFINIR UMA VARIÁVEL
============================================================

- A sintaxe básica é:

  DECLARE @NomeDaVariavel Tipo = Valor

- O valor inicial é opcional. Caso não seja informado, será NULL.
*/

-- Exemplo 1: declarando com valor inicial
DECLARE @Nome VARCHAR(100) = 'Raphael';

-- Exemplo 2: declarando e atribuindo depois
DECLARE @Salario SMALLMONEY;
SET @Salario = 2500.50;

-- Exemplo 3: atribuindo valor através de SELECT
DECLARE @Cidade VARCHAR(100);
SELECT @Cidade = 'São Paulo';

/* 
============================================================
ATRIBUINDO VALORES
============================================================ 
*/

-- Forma 1: com SET
DECLARE @Idade INT;
SET @Idade = 23;

-- Forma 2: com SELECT
DECLARE @Pontuacao INT;
SELECT @Pontuacao = 100;

-- Diferença:
-- SET: usado para atribuições simples.
-- SELECT: permite múltiplas atribuições em uma única consulta.

/* 
============================================================
ATRIBUIÇÃO MÚLTIPLA
============================================================ 
*/

-- Exemplo: atribuindo valores para duas variáveis de uma só vez
DECLARE @Cliente VARCHAR(100);
DECLARE @TotalPedidos INT;

SELECT 
    @Cliente = Nome,
    @TotalPedidos = COUNT(*)
FROM Clientes
JOIN Pedidos ON Clientes.ClienteID = Pedidos.ClienteID
WHERE Clientes.ClienteID = 1
GROUP BY Nome;

SELECT @Cliente AS NomeCliente, @TotalPedidos AS TotalPedidos;

/* 
============================================================
OPERAÇÕES COM VARIÁVEIS
============================================================ 
*/

DECLARE @Saldo DECIMAL(10,2) = 1000.00;
SET @Saldo += 250.00;
SET @Saldo -= 50.00;
SELECT @Saldo AS SaldoFinal;

/* 
============================================================
VARIÁVEIS EM INSTRUÇÕES DML
============================================================ 
*/

-- Recuperando o valor atualizado diretamente no UPDATE
DECLARE @NovoPreco DECIMAL(10,2);

UPDATE ItensPedido
SET @NovoPreco = Preco = Preco * 1.10
WHERE ItemID = 1;

SELECT @NovoPreco AS NovoPreco;

/* 
============================================================
VARIÁVEIS COM TOP E FILTROS DINÂMICOS
============================================================ 
*/

DECLARE @QtdLinhas INT = 2;
SELECT TOP(@QtdLinhas) * FROM Pedidos;

/* 
============================================================
BOAS PRÁTICAS
============================================================

1. Declare todas as variáveis no início do bloco de código.
2. Use nomes claros e coerentes com o propósito.
3. Evite tipos genéricos como NVARCHAR(MAX) ou DECIMAL(38,18) sem necessidade.
4. Sempre documente o propósito das variáveis em comentários.

*/

/* 
============================================================
   ERROS COMUNS
============================================================

-- 1. Usar variável não inicializada (resulta em NULL)
DECLARE @Valor INT;
SELECT @Valor + 10; -- Resultado será NULL

-- 2. Esperar que SELECT atribua múltiplas linhas (atribui só a última)
DECLARE @UltimoPedido INT;
SELECT @UltimoPedido = PedidoID FROM Pedidos; -- Atribui apenas o último PedidoID retornado

SELECT @UltimoPedido AS UltimoPedido;

*/

/* 
============================================================
FORMATO DE SAÍDA EM JSON E XML
============================================================

-- Retorna resultado em JSON
SELECT TOP 1 * FROM Pedidos FOR JSON AUTO;

-- Retorna resultado em XML
SELECT TOP 1 * FROM Pedidos FOR XML AUTO, ELEMENTS;

*/

