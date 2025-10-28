-- Stored Procedures

/*

O que �:

- Stored procedures ou procedimentos armazenados, s�o objetos de programa��o
com comandos T-SQL armazenados no banco de dados com um nome.
- Aceitam par�metros no momento da execu��o, podendo retornar um status
ou um conjunto de valores.

Motivos para usarmos stored procedures:

- Redu��o no tr�fego de rede
- Seguran�a 
- C�digo reutiliz�vel
- F�cil manuten��o
- Melhor desempenho

Tipos de stored procedures:

1. Definida pelo usu�rio
2. Sistema
3. Tempor�rio

Padr�o de cria��o de stored procedures:

O padr�o ter por objetivo definir a estrutura para:

1. Nomear stored procedures
2. Comentar o seu c�digo
3. Estruturar e indentar corretamente os comandos

---------------------------------------------------

1. Defini��o da SP

CREATE PROCEDURE <NomeProcedure>
(
	<Par�metros>
)
AS
<C�digo>

Nome da procedure:
1. Qualquer nome com at� 128 caracteres que come�a com uma letra, _, # ou ##
2. Padronizar: 
   - stp_, usp_
   - CamelCase

---------------------------------------------------
2. Inclus�o de cabe�alho

/*
---------------------------------------------------
Tipo de objeto  : Store procedure
Objeto			: stp_NomeProcedure
Objetivo		: Atualizar dados...
Projeto			: ___
Criado em		: 01/10/2025
---------------------------------------------------
Observa��es:

---------------------------------------------------
Hist�rico:

Autor			Data			Descri��o
--------------- ---------------	---------------------

*/

---------------------------------------------------
3. Estrutura��o e indenta��o do c�digo
- � recomendado que todo o c�digo da procedure
fique dentro de um BEGIN/END, para identifica��o 
do in�cio e fim da procedure

*/

/*

Opera��es de manuten��o de uma stored procedure:

-- Cria��o da procedure

CREATE PROCEDURE stp_AtualizaEstoque(
	@Id INT,
	@IdLoja INT,
	@Quantidade INT
) AS
BEGIN
	SET NOCOUNT ON

	UPDATE tRELEstoque
	SET nQuantidade = @Quantidade
	WHERE iIdLivro = @Id 
	AND iIdLoja = @IdLoja
END

-- Altera��o de procedure

ALTER PROCEDURE stp_AtualizaEstoque(
	@Id INT,
	@IdLoja INT,
	@Quantidade INT
) AS
BEGIN
	SET NOCOUNT ON

	UPDATE tRELEstoque
	SET nQuantidade = @Quantidade
	WHERE iIdLivro = @Id 
	AND iIdLoja = @IdLoja
END

-- Op��o para criar ou alterar(Em caso de altera��o, n�o remove as permiss�es concedidas)

CREATE OR ALTER PROCEDURE stp_AtualizaEstoque(
	@Id INT,
	@IdLoja INT,
	@Quantidade INT
) AS
BEGIN
	SET NOCOUNT ON

	UPDATE tRELEstoque
	SET nQuantidade = @Quantidade
	WHERE iIdLivro = @Id 
	AND iIdLoja = @IdLoja
END

-- Para excluir a procedure
DROP PROCEDURE stp_AtualizaEstoque
DROP PROCEDURE IF EXISTS stp_AtualizaEstoque

-- Consultar informa��es da procedure

sys.procedures
sys.objects
sys.dm_sql_referenced_entities -> Informa��es os objetos utilizados pela procedure

SELECT *
FROM sys.dm_sql_referenced_entities('dbo.stp_AtualizaEstoque', 'OBJECT')

-- Exibir o conte�do da procedure

1. sp_helptext <NomeProcedure>
2. atrav�s da sys.sql_modules
3. SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.stp_Pedidos'))

-- Renomear a procedure
- A vantagem de renomear � n�o perder as permiss�es liberadas

sp_rename 'dbo.stp_AtualizaEstoque', 'stp_Pedidos'

-- Executando a procedure

EXECUTE <NomeProcedure>

EXEC <NomeProcedure>

EXECUTE (<NomeProcedure>)

-- Verificar o desempenho de execu��o

SELECT * FROM sys.dm_exec_procedure_stats

*/



/*

-- Retornando um dataset

A procedure pode ser utilizada para retornar um conjunto
de dados no formato de um dataset

CREATE PROCEDURE stp_MovimentoDoDia  
AS  
BEGIN  
     
   SELECT Cliente.cNome as cCliente,  
          Pedido.nNumero as nNumeroPedido,  
          Cast(Pedido.dPedido as date) as dDataPedido ,   
          Sum((Item.nQuantidade*Item.mValorUnitario)-Item.mDesconto)-MAX(Pedido.mDesconto) as mValorPedido ,  
          Count(*) as nQtdItem   
     FROM dbo.tMOVPedido Pedido  
          Join dbo.tCADCliente Cliente   
            on Pedido.iIDCliente = Cliente.iIDCliente  
          Join dbo.tMOVPedidoItem as Item   
            on Pedido.iIDPedido = Item.iidPedido   
    WHERE Pedido.dCancelado is null  
      and Pedido.dPedido between '2010-07-05' and '2010-07-06'  
    GROUP BY Cliente.cNome,         
             Pedido.nNumero,  
             Pedido.dPedido   
END   

-- Insert a partir de uma procedure

- Para uma tabela

SELECT * FROM tTMPMovimentoDoDia

INSERT INTO tTMPMovimentoDoDia EXECUTE stp_MovimentoDoDia

- Com uma vari�vel do tipo table

DECLARE @tTMPMovimentoDoDia TABLE (
	Cliente			VARCHAR(50) NOT NULL,
	NumeroPedido	INT NOT NULL,
	DataPedido		DATE NOT NULL,
	ValorPedido		SMALLMONEY NOT NULL,
	QtdItem			INT NOT NULL
)

INSERT INTO @tTMPMovimentoDoDia EXECUTE stp_MovimentoDoDia

SELECT * FROM @tTMPMovimentoDoDia

*/

/*

-- Utilizando par�metros

- Utilizamos os par�metros recebidos pela procedure para flexibilizar
a execu��o das consultas

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@NovoCredito MONEY
)
AS  
BEGIN 
	
	BEGIN TRY

		UPDATE tCADCliente
		SET mCredito = @NovoCredito
		WHERE iIDCliente = @IdCliente

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		IF ERROR_NUMBER() = 547
			RAISERROR('Erro ao tentar atualizar o valor de cr�dito', 16, 1)

	END CATCH

END

-- Execu��o

EXECUTE stp_AtualizarCredito 1, 0 -- Sem a defini��o dos par�metros
EXECUTE stp_AtualizarCredito @IdCliente=1, @NovoCredito=100 -- Com a defini��o dos par�metros

*/

/*

-- Usando valor padr�o para os par�metros

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@NovoCredito MONEY = 20 -- Valor padr�o igual a 20
)
AS  
BEGIN 
	
	BEGIN TRY

		UPDATE tCADCliente
		SET mCredito = @NovoCredito
		WHERE iIDCliente = @IdCliente

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		IF ERROR_NUMBER() = 547
			RAISERROR('Erro ao tentar atualizar o valor de cr�dito', 16, 1)

	END CATCH

END

- N�o � obrigat�rio, mas � poss�vel executar o valor padr�o da seguinte forma

EXECUTE stp_AtualizarCredito @IdCliente=1, @NovoCredito=DEFAULT 

- O par�metro pode assumir um valor padr�o ou at� mesmo NULL

1. @NovoCredito MONEY = 20
2. @NovoCredito MONEY = NULL

*/

/*

-- Definindo a dire��o dos par�metros

Os par�metros podem assumir dois sentidos, sendo eles:

1. Entrada -> Quando passamos dados para a procedure
2. Sa�da -> Quando a procedure retorna dados

Por padr�o, todo par�metro ser� de entrada de dados

-- Para um dado escalar

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@Credito MONEY,
	@NovoCredito SMALLMONEY OUTPUT -- Defini��o de par�metro de sa�da
)
AS  
BEGIN 
	
	BEGIN TRY

		UPDATE tCADCliente
		SET @NovoCredito = mCredito += @Credito
		WHERE iIDCliente = @IdCliente

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		IF ERROR_NUMBER() = 547
			RAISERROR('Erro ao tentar atualizar o valor de cr�dito', 16, 1)

	END CATCH

END

DECLARE @NCredito SMALLMONEY;
EXECUTE stp_AtualizarCredito @IdCliente = 1, 
							 @Credito = 100, 
							 @NovoCredito = @NCredito OUTPUT -- Indica a vari�vel que receber� o par�metro de sa�da

SELECT @NCredito

*/

/*

-- Como retornar um status

� poss�vel retornar o valor da procedure por um status, o qual
poder� ser retornado com a instru��o RETURN

RETURN <int>

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@Credito MONEY 
)
AS  
BEGIN 

	SET NOCOUNT ON

	DECLARE @Retorno INT = 0 -- Assume 0 como um Status OK
	
	BEGIN TRY
	
		BEGIN TRANSACTION;

		UPDATE tCADCliente
		SET mCredito += @Credito
		WHERE iIDCliente = @IdCliente

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		IF ERROR_NUMBER() = 547
			RAISERROR('Erro ao tentar atualizar o valor de cr�dito', 16, 1)

		SET @Retorno = -1
		RETURN @Retorno

	END CATCH

END

DECLARE @Status INT
EXECUTE @Status = stp_AtualizarCredito 1, -10000 -- Para recuperar o valor de return
SELECT @Status 

*/

/*

-- Criando uma procedure para tratar erros

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@Credito MONEY 
)
AS  
BEGIN 

	SET NOCOUNT ON

	DECLARE @Retorno INT = 0 -- Assume 0 como um Status OK
	
	BEGIN TRY
	
		BEGIN TRANSACTION;

		UPDATE tCADCliente
		SET mCredito += @Credito
		WHERE iIDCliente = @IdCliente

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		EXECUTE @Retorno = stp_ManipularErros

	END CATCH
	
	RETURN @Retorno

END

CREATE OR ALTER PROCEDURE stp_ManipularErros
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @Retorno INT = 0
	DECLARE @ErrorNumber INT = ERROR_NUMBER()

	IF @ErrorNumber = 547
		RAISERROR('Erro ao tentar atualizar o valor de cr�dito', 16, 1)

	SET @Retorno = -1
	RETURN @Retorno

END

DECLARE @Status INT
EXECUTE @Status = stp_AtualizarCredito 1, -10000 -- Para recuperar o valor de return
SELECT @Status 

*/

/*

-- Seguran�a de acesso aos dados com procedure

Tr�s cen�rios
1. Acesso total
2. Acesso parcial
3. Acesso restrito

USE MASTER
GO 

CREATE LOGIN usrTest
	WITH PASSWORD = '@123456',
	DEFAULT_DATABASE = ebook,
	CHECK_EXPIRATION = OFF, -- A conta n�o expira
	CHECK_POLICY = OFF		-- N�o utilizar as pol�ticas de senha do Windows
GO

USE EBOOK
GO

CREATE USER usrTest
	FOR LOGIN usrTest
	WITH DEFAULT_SCHEMA = dbo
GO

-- Acesso total
-- Concedemos acesso de db_owner

ALTER ROLE db_owner ADD MEMBER usrTest
GO

-- Acesso parcial
-- Iremos reduzir o acesso, incluindo permiss�o de leitura, grava��o e execu��o de procedure

ALTER ROLE db_owner DROP MEMBER usrTest
GO

ALTER ROLE db_datareader 
	ADD MEMBER usrTest
GO
ALTER ROLE db_datawriter 
	ADD MEMBER usrTest
GO

GRANT EXECUTE
	ON dbo.stp_AtualizarCredito
	TO usrTest
GO

GRANT VIEW DEFINITION
	ON dbo.stp_AtualizarCredito
	TO usrTest
GO

GRANT ALTER
	ON dbo.stp_AtualizarCredito
	TO usrTest
GO

-- Acesso restrito

ALTER ROLE db_datareader
	DROP MEMBER usrTest

ALTER ROLE db_datawriter
	DROP MEMBER usrTest

REVOKE EXECUTE
	ON dbo.stp_AtualizarCredito
	TO usrTest
GO

DENY VIEW DEFINITION
	ON dbo.stp_AtualizarCredito
	TO usrTest
GO

REVOKE ALTER
	ON dbo.stp_AtualizarCredito
	TO usrTest
GO

-- Outras permiss�es

GRANT EXECUTE ON SCHEMA::dbo TO usrTest
GRANT SELECT ON view_tabela TO usrTest

*/

/*

-- Queries din�micas e o risco do SQL Injection

- Query din�mica � uma instru��o SQL que realiza a montagem em tempo de execu��o

A instru��o EXECUTE � utilizada para executar qualquer instru��o T-SQL
contida entre aspas simples ou dentro de uma vari�vel char/varchar

CREATE OR ALTER PROCEDURE stp_RecuperarCliente
    @documento NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Constru��o insegura: concatena��o direta de input do usu�rio em SQL din�mico
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT * FROM dbo.tCADCliente WHERE cDocumento = ' + @documento + ';';

    -- Execu��o direta do SQL constru�do
    EXEC(@sql);
END
GO

EXECUTE stp_RecuperarCliente "1 or 1=1"

*/

/*

-- Criptografia de Procedures

- Possibilidade de criptografar o conte�do da procedure armazenado no banco de dados

CREATE OR ALTER PROCEDURE stp_RecuperarCliente
    @documento NVARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    -- Constru��o insegura: concatena��o direta de input do usu�rio em SQL din�mico
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT * FROM dbo.tCADCliente WHERE cDocumento = ' + @documento + ';';

    -- Execu��o direta do SQL constru�do
    EXEC(@sql);
END
GO

Uma vez que a procedure � criada com "WITH ENCRYPTION", � necess�rio que o c�digo
esteja versionado em algum lugar

*/

/*

-- Passando v�rios dados em um par�metro

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente VARCHAR(50),
	@Credito MONEY 
)
AS  
BEGIN 

	SET NOCOUNT ON

	DECLARE @Retorno INT = 0 -- Assume 0 como um Status OK
	
	BEGIN TRY
	
		BEGIN TRANSACTION;

		UPDATE tCADCliente
		SET mCredito += @Credito
		WHERE iIDCliente IN (SELECT * FROM STRING_SPLIT(@IdCliente, ','))

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		EXECUTE @Retorno = stp_ManipularErros

	END CATCH
	
	RETURN @Retorno

END

*/

/*

-- Passando um dataset como par�metro

- � poss�vel utilizar o conceito de table-value parameters, para usar uma tabela como 
par�metro
- Para par�metros de valor de tabela, utilizaremos tr�s palavras chaves, sendo elas:
1. Nome do par�metro
2. O tipo de dado
3. Palavra chave READONLY, obrigat�rio

CREATE TYPE TabelaAtualizaEstoque
AS TABLE
(
	IdLivro INT NOT NULL,
	Quantidade INT NOT NULL,
	Valor SMALLMONEY NOT NULL
)
GO

CREATE OR ALTER PROCEDURE stp_AtualizarEstoque(
	@IdLoja INT,
	@AtualizaEstoque TabelaAtualizaEstoque READONLY
)
AS 
BEGIN
	
	SET NOCOUNT ON

	UPDATE tRELEstoque
	SET nQuantidade += AtualizaEstoque.Quantidade,
		mValor = AtualizaEstoque.Valor
	FROM tRELEstoque 
		INNER JOIN @AtualizaEstoque AS AtualizaEstoque
		ON tRELEstoque.iIDLivro = AtualizaEstoque.IdLivro
	WHERE tRELEstoque.iIDLoja = @IdLoja

END

DECLARE @ItensEnviados TabelaAtualizaEstoque

INSERT INTO @ItensEnviados(IdLivro, Quantidade, Valor)
SELECT iIDLivro, nQuantidade, mValor FROM tTMPAtualizaEstoque

EXECUTE stp_AtualizarEstoque @IdLoja = 20, 
							 @AtualizaEstoque = @ItensEnviados

*/

/*

Retornando datasets:

- Nativamente, o SQL Server n�o implementa uma solu��o para retornar
diversos conjunto de dados ao t�rmino da execu��o da procedure

- Para manipular um conjunto de dados � poss�vel utilizar o XML ou JSON

-- Gerando dados no formato XML e JSON 
SELECT * 
	FROM tCADCliente
	FOR XML AUTO

SELECT * 
	FROM tCADCliente
	FOR JSON AUTO

-- Lendo dados JSON
DECLARE @TextoJson VARCHAR(MAX)

SET @TextoJson = (SELECT * 
	FROM tCADCliente
	FOR JSON AUTO)

SELECT *
	FROM OPENJSON (@TextoJson)
	WITH (
		IdCliente INT '$.iIDCliente',
		Nome VARCHAR(100) '$.cNome',
		DataAniversario DATETIME '$.dAniversario'
	)
GO

CREATE OR ALTER PROCEDURE stp_AtualizarProdutosEstoque
(
	@IdLoja INT,
	@IdLivro INT,
	@EstoqueAtualizado VARCHAR(MAX) OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON

	UPDATE tRELEstoque
	SET nQuantidade += 10
	WHERE iIdLivro = @IdLivro 
	AND iIdLoja = @IdLoja

	SET @EstoqueAtualizado = (SELECT iIDEstoque, iIDLoja, iIDLivro 
								FROM tRELEstoque WHERE iIdLivro = @IdLivro 
								AND iIdLoja = @IdLoja 
								FOR JSON AUTO
							  )

END

DECLARE @TextoJson VARCHAR(MAX) = ''

EXECUTE stp_AtualizarProdutosEstoque 9, 106, @EstoqueAtualizado = @TextoJson OUTPUT

SELECT @TextoJson

SELECT *
	FROM OPENJSON (@TextoJson)
	WITH (
		IdEstoque INT '$.iIDEstoque',
		IdLoja INT '$.iIDLoja',
		IdLoja INT '$.iIDLivro'
	)

*/

/*

-- Criando procedures de sistema

-- S�o procedures criadas pelo SQL Server no momento da instala��o de uma inst�ncia
-- S�o criadas no banco de dados MASTER
-- S�o procedures iniciadas por "sp_" ou "xp_"
	- As iniciadas por "sp_", em sua maioria, est� associada a um c�digo T-SQL
		- sp_help, sp_helptext, sp_oacreate
	- As iniciadas por "xp_" tem associado uma DDL
		- xp_cmdshell, xp_fileexist

exec sp_helptext sp_helptext

- A execu��o da procedure de sistema sempre ser� baseada no banco de dados
MASTER

SP_HELPINDEX -> Procedure para visualizar �ndices de uma tabela

1. Procedures de sistemas devem come�ar com "sp_"
	- Todas as procedures com esse prefixo, s�o buscadas no banco master
	- Evitar que outrar procedures que n�o sejam de sistema, utilizem o 
	prefixo sp_, para uma melhora de performance

2. Procedures de sistema devem ser marcadas como procedures de sistema do SQL Server.
Para isso, � necess�rio usar a procedure sp_ms_marksystemobject

USE MASTER
GO

CREATE PROCEDURE sp_helptable
(
	@Table SYSNAME
)
AS
BEGIN
	SELECT Name, Object_Id, Create_Date
		FROM SYS.TABLES
		WHERE NAME = @Table
END

EXECUTE sp_ms_marksystemobject 'sp_helptable'
EXECUTE sp_helptable 'tCADCliente'

*/
 
/*

-- Stored Procedure de inicializa��o de sistema

- � poss�vel executar procedures em diversos momentos, sem necessariamente o uso
do EXECUTE, como:
1. Como um app web
2. Servi�o
3. Pacote do SSIS
4. Relat�rio via SSRS

- � uma abordagem interessante, quando desejamos capturar dados no momento 
em que o SQL inicializa.

-- Criar uma tabela tempor�ria global no banco de dados TEMPDB

USE MASTER
GO

CREATE PROCEDURE stp_InicializacaoSQLServer
AS
BEGIN
	
	CREATE TABLE ##TempTransferenciaCliente
	(
		IdCliente INT NOT NULL,
		Dados VARCHAR(MAX) NOT NULL,
		DataOcorrencia DATETIME NOT NULL DEFAULT GETDATE()
	)

END

-- Inclus�o da procedure como inicializa��o do SQL Server

EXECUTE sp_procoption @procname = 'stp_InicializacaoSQLServer',
					  @OptionName = 'STARTUP',
					  @OptionValue = 'ON'
GO

SELECT * FROM SYS.PROCEDURES
	WHERE IS_AUTO_EXECUTED = 1

-- Caso seja necess�rio determinar uma ordem de execu��o, � poss�vel
-- determinar uma procedure "mestre" que determine a ordem de execu��o das demais

-- � poss�vel unir WHILE com WAITFOR, para deixar a procedure executando em background

*/

