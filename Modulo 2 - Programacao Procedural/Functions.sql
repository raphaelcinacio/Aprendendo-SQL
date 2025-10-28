/*===============================================================
FUNÇÕES (FUNCTIONS) - SQL SERVER
===============================================================*/

/*
Functions são objetos de banco de dados que encapsulam código T-SQL 
e retornam um valor. Elas são reutilizáveis e podem ser usadas em 
consultas SELECT, WHERE, JOIN e outras operações.

Principais características:
- Sempre retornam um valor (scalar ou table)
- Não podem modificar dados diretamente (INSERT, UPDATE, DELETE)
- Executadas no contexto de uma consulta, simplificando lógica repetitiva
*/

/*===============================================================
1. Scalar Function (Função Escalar)
===============================================================*/
/*
- Retorna um único valor (ex: INT, VARCHAR, DATE)
- Pode ser usada em SELECT, WHERE, JOIN, etc.
*/
CREATE FUNCTION dbo.fn_CalcularIdade(@DataNascimento DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Idade INT;
    SET @Idade = DATEDIFF(YEAR, @DataNascimento, GETDATE());
    RETURN @Idade;
END;
GO

-- Exemplo de uso:
SELECT dbo.fn_CalcularIdade('2000-01-01') AS Idade;
GO

/*===============================================================
2. Table-Valued Function (TVF)
===============================================================*/

/*
2.1 Inline Table-Valued Function
- Retorna uma tabela a partir de uma única query
- Melhor performance que Multi-Statement TVF
*/
CREATE FUNCTION dbo.fn_ObterClientesAtivos()
RETURNS TABLE
AS
RETURN
(
    SELECT IdCliente, Nome
    FROM Clientes
    WHERE Ativo = 1
);
GO

-- Exemplo de uso:
SELECT * FROM dbo.fn_ObterClientesAtivos();
GO

/*
2.2 Multi-Statement Table-Valued Function
- Permite várias instruções T-SQL antes de retornar a tabela
*/
CREATE FUNCTION dbo.fn_ObterClientesPorCidade(@Cidade NVARCHAR(100))
RETURNS @Clientes TABLE (
    IdCliente INT,
    Nome NVARCHAR(100)
)
AS
BEGIN
    INSERT INTO @Clientes
    SELECT IdCliente, Nome
    FROM Clientes
    WHERE Cidade = @Cidade;

    RETURN;
END;
GO

-- Exemplo de uso:
SELECT * FROM dbo.fn_ObterClientesPorCidade('São Paulo');
GO

/*===============================================================
3. Quando usar Functions
===============================================================*/
/*
- Quando há lógica reutilizável em várias consultas
- Simplificar consultas complexas, quebrando em blocos lógicos
- Cálculos que podem ser aplicados como colunas derivadas ou filtros
*/

/*===============================================================
4. Boas práticas
===============================================================*/
/*
1. Naming convention: use prefixos como fn_ para identificar funções
2. Evite lógica complexa em scalar functions em consultas grandes
3. Prefira Inline Table-Valued Functions quando possível
4. Documente parâmetros e retorno para melhor entendimento

*/
