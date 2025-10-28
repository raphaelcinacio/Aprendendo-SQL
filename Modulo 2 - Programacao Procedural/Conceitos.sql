/*===============================================================
REGRAS, CONCEITOS E BOAS PRÁTICAS DE SQL SERVER
===============================================================*/

/*===============================================================
Regras de Edgar Codd - Regra 5
===============================================================*/
/*
- Deve existir pelo menos uma linguagem de acesso declarativa (SQL),
  utilizada por programas ou de forma interativa, com suporte a manipulação e definição de dados.

Padrões:
- ANSI-86
- ISO 9075

SQL no lado da aplicação:
- Linguagens como Java, Python, C# podem executar instruções SQL.
- Pode gerar alto volume de idas ao banco para leitura/gravação.

Programação procedural (Stored Procedures, Functions):
- Permite executar rotinas armazenadas no SQL Server.
Vantagens:
  1. Redução de tráfego de rede
  2. Segurança reforçada
  3. Reutilização de código
  4. Manutenção facilitada
  5. Melhor desempenho
Desvantagens:
  1. Limitação de acesso
  2. Limitação de integração
  3. Fraca portabilidade
*/

/*===============================================================
Scripts SQL
===============================================================*/
/*
- Arquivo com extensão .sql que contém instruções SQL/T-SQL
- Uso comum:
  - Criação de objetos de banco (tabelas, procedures, views, triggers)
  - Manutenção de tabelas e dados
*/

/*===============================================================
Comentários
===============================================================*/
/*
- Comentários explicam e documentam o código
- Tipos:
  -- Comentário de linha
  /**/ Comentário em bloco
*/

/*===============================================================
Comando USE
===============================================================*/
/*
- Troca de contexto do banco de dados na conexão atual.
- Útil para executar scripts em múltiplos bancos.
*/
USE MeuBancoDeDados;
GO

/*===============================================================
Instrução GO
===============================================================*/
/*
- Não é T-SQL, mas sim comando do SSMS.
- Finaliza a execução de um bloco de comandos.
- Pode ser seguido de número: repete o bloco n vezes.

Exemplo:
*/
SELECT * FROM tRELAutorLivro;
GO 2 -- Executa duas vezes

/*===============================================================
Comando EXECUTE
===============================================================*/
/*
- Executa stored procedures ou instruções dinâmicas.

Execução de procedure:
*/
EXECUTE sp_helpdb;

/*
Execução de instrução dinâmica:
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
- Ignora valores NULL em concatenação
- Passa por buffer e não exibe imediatamente

RAISERROR:
- Gera erros ou avisos
- WITH NOWAIT exibe a mensagem imediatamente, sem buffer
*/

/*===============================================================
Funções @@ROWCOUNT x ROWCOUNT_BIG()
===============================================================*/
/*
@@ROWCOUNT:
- Total de linhas processadas na última instrução (INT)

ROWCOUNT_BIG():
- Para grandes volumes (> 2 bilhões de linhas)
- Retorna BIGINT
*/

/*===============================================================
SEQUENCE
===============================================================*/
/*
- Objeto para gerar valores numéricos sequenciais
- NEXT VALUE FOR: obtém próximo valor
- Pode ser reinicializado

Exemplo de criação e uso:
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

-- Consultar sequências existentes
SELECT * FROM SYS.SEQUENCES
WHERE NAME = 'seqIdPessoa';

/*
IDENTITY() x SEQUENCE:
- IDENTITY: associada a tabela/coluna; próxima linha gerada automaticamente.
- SEQUENCE: independente de tabela; precisa de NEXT VALUE FOR; pode reiniciar.
*/

/*===============================================================
Função @@ERROR
===============================================================*/
/*
- Retorna número do erro da última instrução
- Exemplo de uso:
*/
SELECT 2/0; -- Força erro
PRINT @@ERROR; -- Retorna código do erro

/*
- @@ERROR é resetado antes da próxima instrução T-SQL
- É recomendável capturar e tratar erros para análise posterior
*/

/*===============================================================
SET NOCOUNT ON
===============================================================*/
/*
- Evita envio de mensagens de quantidade de linhas afetadas ao cliente
- Reduz tráfego de rede e melhora performance de procedures com várias instruções
- Afeta apenas a conexão atual
*/
SET NOCOUNT ON;

