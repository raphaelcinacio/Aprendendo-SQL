USE Vendas;
GO

-- =====================================================
-- SELECT: Consulta de dados
-- =====================================================

-- Seleciona os 10 primeiros registros da tabela Cliente
SELECT TOP 10 * 
FROM Vendas.Cliente;

-- Seleciona os 10 primeiros registros, renomeando colunas
SELECT TOP 10
    RazaoSocial AS Empresa, 
    Endereco AS Local, 
    CEP AS CodigoPostal
FROM Vendas.Cliente
ORDER BY Empresa DESC; -- Ordena pelo nome da empresa em ordem decrescente

-- Filtra registros por condi��o espec�fica
SELECT TOP 10
    RazaoSocial AS Empresa, 
    Endereco AS Local, 
    CEP AS CodigoPostal
FROM Vendas.Cliente
WHERE CEP = 10092;

-- Dicas sobre SELECT:
-- - TOP <n>: limita o n�mero de linhas retornadas
-- - AS: renomeia colunas para melhor visualiza��o
-- - ORDER BY: define a ordena��o dos resultados
-- - WHERE: aplica filtros nas linhas retornadas
-- - SELECT *: retorna todas as colunas da tabela (geralmente usado apenas para estudo)

---------------------------------------------------------

USE Agenda;
GO

-- =====================================================
-- INSERT: Inser��o de dados
-- =====================================================

/*
Sintaxe b�sica:
INSERT INTO <tabela>(colunas)
VALUES(valores);

Insert com Select:
INSERT INTO tabela_destino (coluna1, coluna2, coluna3)
SELECT colunaA, colunaB, colunaC
FROM tabela_origem
WHERE condi��o;
*/

INSERT INTO Contato 
VALUES(1, 'Teste', '(11) 2222-9999', '1990-10-01', 'M');

-- Visualizar registros ap�s inser��o
SELECT * FROM Contato;

---------------------------------------------------------

-- =====================================================
-- UPDATE: Atualiza��o de dados
-- =====================================================

/*
Sintaxe b�sica:
UPDATE <tabela>
SET <coluna>=<novo valor>
WHERE <condicao>;

Update com Join:
UPDATE t1
SET t1.coluna = t2.novo_valor
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.chave = t2.chave
WHERE t2.condi��o = 'valor';
*/

UPDATE Contato
SET Nome = 'Teste2'
WHERE Numero = 1;

-- Visualizar registros ap�s atualiza��o
SELECT * FROM Contato;

---------------------------------------------------------

-- =====================================================
-- DELETE: Exclus�o de dados
-- =====================================================

/*
Sintaxe b�sica:
DELETE FROM <tabela>
WHERE <condicao>;

Delete com Join:
DELETE t1
FROM tabela1 t1
INNER JOIN tabela2 t2 ON t1.chave = t2.chave
WHERE t2.condi��o = 'valor';
*/

DELETE FROM Contato
WHERE Numero = 1;

-- Verifica se o registro foi deletado
SELECT * FROM Contato;
