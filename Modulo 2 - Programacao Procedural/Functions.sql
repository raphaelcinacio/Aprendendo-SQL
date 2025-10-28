/*===============================================================
FUN��ES (FUNCTIONS) - SQL SERVER
===============================================================*/

/*
Functions s�o objetos de banco de dados que encapsulam c�digo T-SQL 
e retornam um valor. Elas s�o reutiliz�veis e podem ser usadas em 
consultas SELECT, WHERE, JOIN e outras opera��es.

Principais caracter�sticas:
- Sempre retornam um valor (scalar ou table)
- N�o podem modificar dados diretamente (INSERT, UPDATE, DELETE)
- Executadas no contexto de uma consulta, simplificando l�gica repetitiva
*/

/*===============================================================
1. Scalar Function (Fun��o Escalar)
===============================================================*/
/*
- Retorna um �nico valor (ex: INT, VARCHAR, DATE)
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
- Retorna uma tabela a partir de uma �nica query
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
- Permite v�rias instru��es T-SQL antes de retornar a tabela
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
SELECT * FROM dbo.fn_ObterClientesPorCidade('S�o Paulo');
GO

/*===============================================================
3. Quando usar Functions
===============================================================*/
/*
- Quando h� l�gica reutiliz�vel em v�rias consultas
- Simplificar consultas complexas, quebrando em blocos l�gicos
- C�lculos que podem ser aplicados como colunas derivadas ou filtros
*/

/*===============================================================
4. Boas pr�ticas
===============================================================*/
/*
1. Naming convention: use prefixos como fn_ para identificar fun��es
2. Evite l�gica complexa em scalar functions em consultas grandes
3. Prefira Inline Table-Valued Functions quando poss�vel
4. Documente par�metros e retorno para melhor entendimento

*/
