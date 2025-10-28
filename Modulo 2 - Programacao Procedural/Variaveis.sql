/* 
============================================================
VARI�VEIS NO SQL SERVER
============================================================

Uma vari�vel � um espa�o tempor�rio em mem�ria usado para armazenar
dados durante a execu��o de um script SQL.

� �til para armazenar valores intermedi�rios, par�metros ou resultados
de c�lculos, e pode ser usada em consultas, DML, fun��es e procedimentos.

============================================================ 
*/

/* 
============================================================
COMO DEFINIR UMA VARI�VEL
============================================================

- A sintaxe b�sica �:

  DECLARE @NomeDaVariavel Tipo = Valor

- O valor inicial � opcional. Caso n�o seja informado, ser� NULL.
*/

-- Exemplo 1: declarando com valor inicial
DECLARE @Nome VARCHAR(100) = 'Raphael';

-- Exemplo 2: declarando e atribuindo depois
DECLARE @Salario SMALLMONEY;
SET @Salario = 2500.50;

-- Exemplo 3: atribuindo valor atrav�s de SELECT
DECLARE @Cidade VARCHAR(100);
SELECT @Cidade = 'S�o Paulo';

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

-- Diferen�a:
-- SET: usado para atribui��es simples.
-- SELECT: permite m�ltiplas atribui��es em uma �nica consulta.

/* 
============================================================
ATRIBUI��O M�LTIPLA
============================================================ 
*/

-- Exemplo: atribuindo valores para duas vari�veis de uma s� vez
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
OPERA��ES COM VARI�VEIS
============================================================ 
*/

DECLARE @Saldo DECIMAL(10,2) = 1000.00;
SET @Saldo += 250.00;
SET @Saldo -= 50.00;
SELECT @Saldo AS SaldoFinal;

/* 
============================================================
VARI�VEIS EM INSTRU��ES DML
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
VARI�VEIS COM TOP E FILTROS DIN�MICOS
============================================================ 
*/

DECLARE @QtdLinhas INT = 2;
SELECT TOP(@QtdLinhas) * FROM Pedidos;

/* 
============================================================
BOAS PR�TICAS
============================================================

1. Declare todas as vari�veis no in�cio do bloco de c�digo.
2. Use nomes claros e coerentes com o prop�sito.
3. Evite tipos gen�ricos como NVARCHAR(MAX) ou DECIMAL(38,18) sem necessidade.
4. Sempre documente o prop�sito das vari�veis em coment�rios.

*/

/* 
============================================================
   ERROS COMUNS
============================================================

-- 1. Usar vari�vel n�o inicializada (resulta em NULL)
DECLARE @Valor INT;
SELECT @Valor + 10; -- Resultado ser� NULL

-- 2. Esperar que SELECT atribua m�ltiplas linhas (atribui s� a �ltima)
DECLARE @UltimoPedido INT;
SELECT @UltimoPedido = PedidoID FROM Pedidos; -- Atribui apenas o �ltimo PedidoID retornado

SELECT @UltimoPedido AS UltimoPedido;

*/

/* 
============================================================
FORMATO DE SA�DA EM JSON E XML
============================================================

-- Retorna resultado em JSON
SELECT TOP 1 * FROM Pedidos FOR JSON AUTO;

-- Retorna resultado em XML
SELECT TOP 1 * FROM Pedidos FOR XML AUTO, ELEMENTS;

*/

