-- Tratamento de erros:

/*

O que é um erro?

- Os eventos de erro ou exceções, gerados pelo engine do SQL Server, geram
um conjunto de informações sobre o erro.

Existe duas de ter um erro no SQL Server:

1. As que são geradas pelo próprio engine do SQL Server
2. As geradas por programação pela função RAISERROR()

Em ambas as formas, o erro gerado pode conter informações que vão além do
código de erro que há na função @ERROR:

- Número do erro
	- SQL Server gera erros com numeração de até 49.999
	- É possível criar as próprias mensagems de erro, com números a partir de 50.000

- Mensagem de erro
	- Mensagem com informações sobre o erro e, em alguns casos, contém informações 
	sobre objetos, colunas, valores, etc.

- Severidade
	- Indica a gravidade do erro

- Estado
	- Como uma mensagem de erro pode ser tratada de várias formas, o estado
	pode indicar, por exemplo, como o erro pode ser corrigido

- Procedimento
	- Nome do objeto de programação onde ocorreu o erro. Pode ser uma procedure
	ou trigger.

- Linha
	- Indica a linha dentro do procedimento onde ocorreu o erro. Em caso de 
	execução de lote, a linha dentro do lote.

Exemplo:

SELECT 1 / 0

Msg 8134, Level 16, State 1, Line 41
Divide by zero error encountered.

Onde as mensagens ficam armazenadas

SELECT * FROM
	SYS.MESSAGES m
	INNER JOIN SYS.SYSLANGUAGES l on m.language_id = l.lcid
	WHERE alias = 'Brazilian'
	AND message_id = 8134

*/

/*

Severidade do erro:

- Indica o nível do erro, indicando uma simples mensagem ou um erro crítico

1. Severidade entre 0 e 18, indicam informações, avisos, erros de transação, segurança
e comando T-SQL
2. Erros entre 0 e 9, são avisos de informações ou alertas
3. Erros com nível acima de 10 são capturados pelo bloco CTACH
4. Severidade 11 até 16 indicam erros que devem ser corrigidos pelo desenvolvedor
5. Entre 17 e 19 são erros que somente o DBA pode corrigir
6. Entre 20 e 25 são erros críticos. Os erros fatais encerram a conexão com o cliente. 
Esses erros não são capturados pelo bloco CATCH

*/

/*

Para análise dos erros:

Management > SQL Server Logs > Contém informações de erros que ocorreram

-- Procedures internas

execute sp_readerrorlog 0 -- Retorna as informações de hoje
execute sp_readerrorlog 1 -- Leitura do arquivo anterior

*/

/*

Função RAISERROR()

- Se o RAISERROR() estiver dentro de um bloco TRY, o fluxo será desviado
automaticamente para o bloco CATCH(A severidade precisa ser maior que 10)

RAISERROR()
A função aceita alguns parâmetros, sendo eles:

1. Cadeia de caracteres com a mensagem do erro
2. Código da severidade
3. Código do status entre 1 e 255. Fora desses valores o SQL
Server converte para a faixa entre 1 e 255
4. A partir do quarto parâmetro, é possível informar diversos valores, para serem
usados como placeholder

BEGIN

	SET NOCOUNT ON
	BEGIN TRY
		SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'Teste'
		IF @@ROWCOUNT = 0
			RAISERROR('Tabela não encontrada', 11, 1)
	END TRY
	BEGIN CATCH
		RAISERROR('Tratamento de erros', 10, 1)
	END CATCH

END

Para códigos com severidade acima de 19, precisam ser criados por administradores(sysadmin)
e deve usar o parâmetro WITH LOG. Com isso, os eventos do RAISERROR()
serão gravados no arquivo de log de erros do SQL Server

RAISERROR('Teste', 19, 0) WITH LOG

Montar em tempo de execução com a função RAISERROR()

DECLARE @IdCliente INT = 10;
RAISERROR('Código do cliente %d não foi encontrado', 16, 1, @IdCliente);

%d -> Para valores inteiros
%s -> Para strings

*/

/*

Coletando informações do erro:

As seguintes funções devem ser usadas na área do bloco CATCH

ERROR_NUMBER() - Número do erro
ERROR_MESSAGE() - Mensagem do erro
ERROR_SEVERITY() - Severidade do erro
ERROR_STATE() - O estado do erro
ERROR_PROCEDURE() - A procedure/trigger que gerou o erro
ERROR_LINE() - A linha em que ocorreu o erro

BEGIN TRY
	SELECT 1 / 0
END TRY
BEGIN CATCH
	PRINT ERROR_NUMBER()
	PRINT ERROR_MESSAGE()
	PRINT ERROR_SEVERITY()
	PRINT ERROR_STATE()
	PRINT ERROR_PROCEDURE()
	PRINT ERROR_LINE()
END CATCH

Diferença entre @@ERROR e ERROR_NUMBER()

- O @@ERROR precisa ser capturado logo após a execução do comando, caso contrário o
valor será 0
- A função ERROR_NUMBER() mantém o código do erro, durante toda a execução do bloco
CATCH

FORMATMESSAGE() -> Permite formatar uma mensagem, com uso de placeholder

*/

/*

Armazenando informações do erro:

- Capturar o erro corretamente
- Dar o devido tratamento
- Gravar o erro em tabela, arquivo ou log para posterior análise
- Não expor a mensagem de erro original para a aplicação

Podemos armazenar os dados em:

- Tabela 
- SQL Server Log
- Windows Event Viewer

1. Em tabela

CREATE SEQUENCE SeqIdEvento AS INT START WITH 1 INCREMENT BY 1

CREATE TABLE LogEventos
(
	IdEvento INT NOT NULL DEFAULT(NEXT VALUE FOR SeqIdEvento),
	DataHora DATETIME NOT NULL DEFAULT GETDATE(),
	Mensagem VARCHAR(512) NOT NULL CHECK(Mensagem <> ''),
	CONSTRAINT PkEvento_LogEventos PRIMARY KEY(IdEvento)
)
GO

BEGIN

	SET NOCOUNT ON

	DECLARE @Nome VARCHAR(100)
	DECLARE	@Credito SMALLMONEY
	DECLARE @IdCliente INT,
		    @Retorno INT = 0

	SET @IdCliente = 33612

	BEGIN TRY
		
		SELECT 
			@Nome = cNome,
			@Credito = mCredito
		FROM tCADCliente
		WHERE iIdCliente = @IdCliente

		IF @Credito < 20
			
			UPDATE tCADCliente
			SET cNome = @Nome, -- Pode gerar um erro de dados truncados
				mCredito = 0 -- Violação da restrição CHECK
			WHERE iIdCliente = @IdCliente

	END TRY
	BEGIN CATCH

		DECLARE @ErrorNumber INT = ERROR_NUMBER(),
				@ErrorLine INT = ERROR_LINE()

		DECLARE @ErrorSeverity TINYINT = ERROR_SEVERITY(),
				@ErrorState TINYINT = ERROR_STATE()

		DECLARE @Mensagem VARCHAR(512),
				@ErrorMessage VARCHAR(200) = ERROR_MESSAGE(),
				@ErrorProcedure VARCHAR(128) = ERROR_PROCEDURE()

		SET @Mensagem = FORMATMESSAGE('Message Id %d. %s Severidade %d. Status %d. Procedure %s. Linha %d', @ErrorNumber, @ErrorMessage, @ErrorSeverity,
		@ErrorState, @ErrorProcedure, @ErrorLine)

		INSERT INTO LogEventos(Mensagem)
		VALUES(@Mensagem)

		SET @Retorno = -1

	END CATCH

END

2. SQL Server Log e Event Viewer

Utilizaremos uma procedure de sistema que registra uma mensagem no SQL Server Log
e no Windows Event Viewer

Procedure: XP_LOGEVENT - Extended Stored Procedure
Parâmetros:
	1 - Código da mensagem(deve ser um valor maior que 50.000)
	2 - Mensagem que deve ser logada
	3 - Severidade da mensagem(opcional) 
		Possíveis valores: INFORMATIONAL, WARNING OU ERROR

Faz sentido incluir no Event Viewer, pois conseguimos usar ferramentas de monitoramento

ALTER SEQUENCE SeqIdEvento RESTART WITH 50001
GO

BEGIN

	SET NOCOUNT ON

	DECLARE @Nome VARCHAR(100)
	DECLARE	@Credito SMALLMONEY
	DECLARE @IdCliente INT,
		    @Retorno INT = 0

	SET @IdCliente = 33612

	BEGIN TRY
		
		SELECT 
			@Nome = cNome,
			@Credito = mCredito
		FROM tCADCliente
		WHERE iIdCliente = @IdCliente

		IF @Credito < 20
			
			UPDATE tCADCliente
			SET cNome = @Nome, -- Pode gerar um erro de dados truncados
				mCredito = 0 -- Violação da restrição CHECK
			WHERE iIdCliente = @IdCliente

	END TRY
	BEGIN CATCH

		DECLARE @ErrorNumber INT = ERROR_NUMBER(),
				@ErrorLine INT = ERROR_LINE(),
				@IdError INT

		DECLARE @ErrorSeverity TINYINT = ERROR_SEVERITY(),
				@ErrorState TINYINT = ERROR_STATE()

		DECLARE @Mensagem VARCHAR(512),
				@ErrorMessage VARCHAR(200) = ERROR_MESSAGE(),
				@ErrorProcedure VARCHAR(128) = ERROR_PROCEDURE()

		SET @Mensagem = FORMATMESSAGE('Message Id %d. %s Severidade %d. Status %d. Procedure %s. Linha %d', @ErrorNumber, @ErrorMessage, @ErrorSeverity,
		@ErrorState, @ErrorProcedure, @ErrorLine)

		SET @IdError = NEXT VALUE FOR SeqIdEvento

		EXECUTE xp_logevent @IdError, @Mensagem, ERROR

		SET @Retorno = -1

	END CATCH

END

Informações úteis, para casos de análise:
1. A mensagem de erro ocorreu em qual banco de dados?
2. Qual a conta de logon no momento do erro?
3. Qual a data e hora de logon?
4. O nome da aplicação?
5. O IP e o nome do computador do cliente?

SELECT 
	connect_time,
	client_net_address,
	host_name,
	program_name,
	login_name
FROM sys.dm_exec_connections as conn
	 INNER JOIN sys.dm_exec_sessions as sess
	 ON conn.session_id = sess.session_id
WHERE conn.session_id = @@spid

*/

/*

Tratamento de erros na transação

- Quando implementamos o tratamento de erro em uma solução ou regra de negócio, 
devemos também sempre nós ater ao processo de transação.

1. Se não ocorreu erro na transação, deve confirmar
2. Se ocorreu um erro, temos duas opções

	2.1. Reverter a transação, registrar o evento de erro e retornar o 
	código de registro do evento de erro.
	2.2. Reverter a transação, avaliar qual o tipo de erro e, dependendo
	do tipo de erro, reiniciar o processo novamente. Deve-se atentar a quantidade
	de vezes que devemos executar esse procedimento

Exemplo: Avaliar qual o tipo do erro e reiniciar o processo

DECLARE @Contagem TINYINT = 3

BEGIN
	SET LOCK_TIMEOUT 5000

	WHILE @Contagem > 0
	BEGIN 
		BEGIN TRY
			BEGIN TRANSACTION
	
			COMMIT
			SET @Contagem = 0
		END TRY

		BEGIN CATCH
			DECLARE @ErrorNumber INT = ERROR_NUMBER()
			IF @@TRANCOUNT > 0
				ROLLBACK

			IF @ErrorNumber IN (1222)
			BEGIN
				WAITFOR DELAY '00:00:07'
				SET @Contagem -= 1
			END

			<Comandos>
			<Comandos>
			<Comandos>

			IF @Contagem = 0
				RETURN <Código de registro>

		END CATCH
	END
END


*/



