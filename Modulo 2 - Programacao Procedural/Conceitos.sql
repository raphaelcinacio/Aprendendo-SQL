/*===============================================================
REGRAS, CONCEITOS E BOAS PR�TICAS DE SQL SERVER
===============================================================*/

/*===============================================================
Regras de Edgar Codd - Regra 5
===============================================================*/
/*
- Deve existir pelo menos uma linguagem de acesso declarativa (SQL),
  utilizada por programas ou de forma interativa, com suporte a manipula��o e defini��o de dados.

Padr�es:
- ANSI-86
- ISO 9075

SQL no lado da aplica��o:
- Linguagens como Java, Python, C# podem executar instru��es SQL.
- Pode gerar alto volume de idas ao banco para leitura/grava��o.

Programa��o procedural (Stored Procedures, Functions):
- Permite executar rotinas armazenadas no SQL Server.
Vantagens:
  1. Redu��o de tr�fego de rede
  2. Seguran�a refor�ada
  3. Reutiliza��o de c�digo
  4. Manuten��o facilitada
  5. Melhor desempenho
Desvantagens:
  1. Limita��o de acesso
  2. Limita��o de integra��o
  3. Fraca portabilidade
*/

/*===============================================================
Scripts SQL
===============================================================*/
/*
- Arquivo com extens�o .sql que cont�m instru��es SQL/T-SQL
- Uso comum:
  - Cria��o de objetos de banco (tabelas, procedures, views, triggers)
  - Manuten��o de tabelas e dados
*/

/*===============================================================
Coment�rios
===============================================================*/
/*
- Coment�rios explicam e documentam o c�digo
- Tipos:
  -- Coment�rio de linha
  /**/ Coment�rio em bloco
*/

/*===============================================================
Comando USE
===============================================================*/
/*
- Troca de contexto do banco de dados na conex�o atual.
- �til para executar scripts em m�ltiplos bancos.
*/
USE MeuBancoDeDados;
GO

/*===============================================================
Instru��o GO
===============================================================*/
/*
- N�o � T-SQL, mas sim comando do SSMS.
- Finaliza a execu��o de um bloco de comandos.
- Pode ser seguido de n�mero: repete o bloco n vezes.

Exemplo:
*/
SELECT * FROM tRELAutorLivro;
GO 2 -- Executa duas vezes

/*===============================================================
Comando EXECUTE
===============================================================*/
/*
- Executa stored procedures ou instru��es din�micas.

Execu��o de procedure:
*/
EXECUTE sp_helpdb;

/*
Execu��o de instru��o din�mica:
*/
DECLARE @tabela CHAR(20) = 'tRELAutorLivro';
EXECUTE ('SELECT iIdAutorLivro, iIdAutor FROM ' + @tabela)
WITH RESULT SETS
(
    (idAutorLivro INT NOT NULL,
     idAutor INT NOT NULL)
);

/*===============================================================
PRINT e RAISERROR
===============================================================*/
/*
PRINT:
- Usado para debugar ou informar dados
- Ignora valores NULL em concatena��o
- Passa por buffer e n�o exibe imediatamente

RAISERROR:
- Gera erros ou avisos
- WITH NOWAIT exibe a mensagem imediatamente, sem buffer
*/

/*===============================================================
Fun��es @@ROWCOUNT x ROWCOUNT_BIG()
===============================================================*/
/*
@@ROWCOUNT:
- Total de linhas processadas na �ltima instru��o (INT)

ROWCOUNT_BIG():
- Para grandes volumes (> 2 bilh�es de linhas)
- Retorna BIGINT
*/

/*===============================================================
SEQUENCE
===============================================================*/
/*
- Objeto para gerar valores num�ricos sequenciais
- NEXT VALUE FOR: obt�m pr�ximo valor
- Pode ser reinicializado

Exemplo de cria��o e uso:
*/
CREATE SEQUENCE seqIdPessoa
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

CREATE TABLE Pessoa
(
    IdPessoa INT NOT NULL DEFAULT (NEXT VALUE FOR seqIdPessoa) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL
);
GO

INSERT INTO Pessoa (IdPessoa, Nome)
VALUES (NEXT VALUE FOR seqIdPessoa, 'Teste');

-- Consultar sequ�ncias existentes
SELECT * FROM SYS.SEQUENCES
WHERE NAME = 'seqIdPessoa';

/*
IDENTITY() x SEQUENCE:
- IDENTITY: associada a tabela/coluna; pr�xima linha gerada automaticamente.
- SEQUENCE: independente de tabela; precisa de NEXT VALUE FOR; pode reiniciar.
*/

/*===============================================================
Fun��o @@ERROR
===============================================================*/
/*
- Retorna n�mero do erro da �ltima instru��o
- Exemplo de uso:
*/
SELECT 2/0; -- For�a erro
PRINT @@ERROR; -- Retorna c�digo do erro

/*
- @@ERROR � resetado antes da pr�xima instru��o T-SQL
- � recomend�vel capturar e tratar erros para an�lise posterior
*/

/*===============================================================
SET NOCOUNT ON
===============================================================*/
/*
- Evita envio de mensagens de quantidade de linhas afetadas ao cliente
- Reduz tr�fego de rede e melhora performance de procedures com v�rias instru��es
- Afeta apenas a conex�o atual
*/
SET NOCOUNT ON;

