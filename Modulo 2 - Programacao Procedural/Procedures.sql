-- Stored Procedures

/*

O que é:

- Stored procedures ou procedimentos armazenados, são objetos de programação
com comandos T-SQL armazenados no banco de dados com um nome.
- Aceitam parâmetros no momento da execução, podendo retornar um status
ou um conjunto de valores.

Motivos para usarmos stored procedures:

- Redução no tráfego de rede
- Segurança 
- Código reutilizável
- Fácil manutenção
- Melhor desempenho

Tipos de stored procedures:

1. Definida pelo usuário
2. Sistema
3. Temporário

Padrão de criação de stored procedures:

O padrão ter por objetivo definir a estrutura para:

1. Nomear stored procedures
2. Comentar o seu código
3. Estruturar e indentar corretamente os comandos

---------------------------------------------------

1. Definição da SP

CREATE PROCEDURE <NomeProcedure>
(
	<Parâmetros>
)
AS
<Código>

Nome da procedure:
1. Qualquer nome com até 128 caracteres que começa com uma letra, _, # ou ##
2. Padronizar: 
   - stp_, usp_
   - CamelCase

---------------------------------------------------
2. Inclusão de cabeçalho

/*
---------------------------------------------------
Tipo de objeto  : Store procedure
Objeto			: stp_NomeProcedure
Objetivo		: Atualizar dados...
Projeto			: ___
Criado em		: 01/10/2025
---------------------------------------------------
Observações:

---------------------------------------------------
Histórico:

Autor			Data			Descrição
--------------- ---------------	---------------------

*/

---------------------------------------------------
3. Estruturação e indentação do código
- É recomendado que todo o código da procedure
fique dentro de um BEGIN/END, para identificação 
do início e fim da procedure

*/

/*

Operações de manutenção de uma stored procedure:

-- Criação da procedure

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

-- Alteração de procedure

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

-- Opção para criar ou alterar(Em caso de alteração, não remove as permissões concedidas)

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

-- Consultar informações da procedure

sys.procedures
sys.objects
sys.dm_sql_referenced_entities -> Informações os objetos utilizados pela procedure

SELECT *
FROM sys.dm_sql_referenced_entities('dbo.stp_AtualizaEstoque', 'OBJECT')

-- Exibir o conteúdo da procedure

1. sp_helptext <NomeProcedure>
2. através da sys.sql_modules
3. SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.stp_Pedidos'))

-- Renomear a procedure
- A vantagem de renomear é não perder as permissões liberadas

sp_rename 'dbo.stp_AtualizaEstoque', 'stp_Pedidos'

-- Executando a procedure

EXECUTE <NomeProcedure>

EXEC <NomeProcedure>

EXECUTE (<NomeProcedure>)

-- Verificar o desempenho de execução

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

- Com uma variável do tipo table

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

-- Utilizando parâmetros

- Utilizamos os parâmetros recebidos pela procedure para flexibilizar
a execução das consultas

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
			RAISERROR('Erro ao tentar atualizar o valor de crédito', 16, 1)

	END CATCH

END

-- Execução

EXECUTE stp_AtualizarCredito 1, 0 -- Sem a definição dos parâmetros
EXECUTE stp_AtualizarCredito @IdCliente=1, @NovoCredito=100 -- Com a definição dos parâmetros

*/

/*

-- Usando valor padrão para os parâmetros

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@NovoCredito MONEY = 20 -- Valor padrão igual a 20
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
			RAISERROR('Erro ao tentar atualizar o valor de crédito', 16, 1)

	END CATCH

END

- Não é obrigatório, mas é possível executar o valor padrão da seguinte forma

EXECUTE stp_AtualizarCredito @IdCliente=1, @NovoCredito=DEFAULT 

- O parâmetro pode assumir um valor padrão ou até mesmo NULL

1. @NovoCredito MONEY = 20
2. @NovoCredito MONEY = NULL

*/

/*

-- Definindo a direção dos parâmetros

Os parâmetros podem assumir dois sentidos, sendo eles:

1. Entrada -> Quando passamos dados para a procedure
2. Saída -> Quando a procedure retorna dados

Por padrão, todo parâmetro será de entrada de dados

-- Para um dado escalar

CREATE OR ALTER PROCEDURE stp_AtualizarCredito
(
	@IdCliente INT,
	@Credito MONEY,
	@NovoCredito SMALLMONEY OUTPUT -- Definição de parâmetro de saída
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
			RAISERROR('Erro ao tentar atualizar o valor de crédito', 16, 1)

	END CATCH

END

DECLARE @NCredito SMALLMONEY;
EXECUTE stp_AtualizarCredito @IdCliente = 1, 
							 @Credito = 100, 
							 @NovoCredito = @NCredito OUTPUT -- Indica a variável que receberá o parâmetro de saída

SELECT @NCredito

*/

/*

-- Como retornar um status

É possível retornar o valor da procedure por um status, o qual
poderá ser retornado com a instrução RETURN

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
			RAISERROR('Erro ao tentar atualizar o valor de crédito', 16, 1)

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
		RAISERROR('Erro ao tentar atualizar o valor de crédito', 16, 1)

	SET @Retorno = -1
	RETURN @Retorno

END

DECLARE @Status INT
EXECUTE @Status = stp_AtualizarCredito 1, -10000 -- Para recuperar o valor de return
SELECT @Status 

*/

/*

-- Segurança de acesso aos dados com procedure

Três cenários
1. Acesso total
2. Acesso parcial
3. Acesso restrito

USE MASTER
GO 

CREATE LOGIN usrTest
	WITH PASSWORD = '@123456',
	DEFAULT_DATABASE = ebook,
	CHECK_EXPIRATION = OFF, -- A conta não expira
	CHECK_POLICY = OFF		-- Não utilizar as políticas de senha do Windows
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
-- Iremos reduzir o acesso, incluindo permissão de leitura, gravação e execução de procedure

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

-- Outras permissões

GRANT EXECUTE ON SCHEMA::dbo TO usrTest
GRANT SELECT ON view_tabela TO usrTest

*/

/*

-- Queries dinâmicas e o risco do SQL Injection

- Query dinâmica é uma instrução SQL que realiza a montagem em tempo de execução

A instrução EXECUTE é utilizada para executar qualquer instrução T-SQL
contida entre aspas simples ou dentro de uma variável char/varchar

CREATE OR ALTER PROCEDURE stp_RecuperarCliente
    @documento NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Construção insegura: concatenação direta de input do usuário em SQL dinâmico
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT * FROM dbo.tCADCliente WHERE cDocumento = ' + @documento + ';';

    -- Execução direta do SQL construído
    EXEC(@sql);
END
GO

EXECUTE stp_RecuperarCliente "1 or 1=1"

*/

/*

-- Criptografia de Procedures

- Possibilidade de criptografar o conteúdo da procedure armazenado no banco de dados

CREATE OR ALTER PROCEDURE stp_RecuperarCliente
    @documento NVARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    -- Construção insegura: concatenação direta de input do usuário em SQL dinâmico
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT * FROM dbo.tCADCliente WHERE cDocumento = ' + @documento + ';';

    -- Execução direta do SQL construído
    EXEC(@sql);
END
GO

Uma vez que a procedure é criada com "WITH ENCRYPTION", é necessário que o código
esteja versionado em algum lugar

*/

/*

-- Passando vários dados em um parâmetro

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

-- Passando um dataset como parâmetro

- É possível utilizar o conceito de table-value parameters, para usar uma tabela como 
parâmetro
- Para parâmetros de valor de tabela, utilizaremos três palavras chaves, sendo elas:
1. Nome do parâmetro
2. O tipo de dado
3. Palavra chave READONLY, obrigatório

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

- Nativamente, o SQL Server não implementa uma solução para retornar
diversos conjunto de dados ao término da execução da procedure

- Para manipular um conjunto de dados é possível utilizar o XML ou JSON

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

-- São procedures criadas pelo SQL Server no momento da instalação de uma instância
-- São criadas no banco de dados MASTER
-- São procedures iniciadas por "sp_" ou "xp_"
	- As iniciadas por "sp_", em sua maioria, está associada a um código T-SQL
		- sp_help, sp_helptext, sp_oacreate
	- As iniciadas por "xp_" tem associado uma DDL
		- xp_cmdshell, xp_fileexist

exec sp_helptext sp_helptext

- A execução da procedure de sistema sempre será baseada no banco de dados
MASTER

SP_HELPINDEX -> Procedure para visualizar índices de uma tabela

1. Procedures de sistemas devem começar com "sp_"
	- Todas as procedures com esse prefixo, são buscadas no banco master
	- Evitar que outrar procedures que não sejam de sistema, utilizem o 
	prefixo sp_, para uma melhora de performance

2. Procedures de sistema devem ser marcadas como procedures de sistema do SQL Server.
Para isso, é necessário usar a procedure sp_ms_marksystemobject

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

-- Stored Procedure de inicialização de sistema

- É possível executar procedures em diversos momentos, sem necessariamente o uso
do EXECUTE, como:
1. Como um app web
2. Serviço
3. Pacote do SSIS
4. Relatório via SSRS

- É uma abordagem interessante, quando desejamos capturar dados no momento 
em que o SQL inicializa.

-- Criar uma tabela temporária global no banco de dados TEMPDB

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

-- Inclusão da procedure como inicialização do SQL Server

EXECUTE sp_procoption @procname = 'stp_InicializacaoSQLServer',
					  @OptionName = 'STARTUP',
					  @OptionValue = 'ON'
GO

SELECT * FROM SYS.PROCEDURES
	WHERE IS_AUTO_EXECUTED = 1

-- Caso seja necessário determinar uma ordem de execução, é possível
-- determinar uma procedure "mestre" que determine a ordem de execução das demais

-- É possível unir WHILE com WAITFOR, para deixar a procedure executando em background

*/

