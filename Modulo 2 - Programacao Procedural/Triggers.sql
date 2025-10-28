-- Triggers

/*

Triggers são objetos de banco de dados que executam automaticamente uma ação quando ocorre um 
determinado evento (como um INSERT, UPDATE ou DELETE) em uma tabela ou visão (view).

As triggers podem ser disparadas por:

INSERT → quando uma nova linha é inserida
UPDATE → quando uma linha é atualizada
DELETE → quando uma linha é excluída

-- Estrutura

CREATE TRIGGER NomeDaTrigger
ON NomeDaTabela
AFTER/INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    -- Ações que serão executadas automaticamente
END;

As triggers são normalmente criadas para responder a três tipos principais de eventos 
em tabelas:

| Evento   | Quando dispara                   | Exemplo de uso                           |
| -------- | -------------------------------- | ---------------------------------------- |
| `INSERT` | Quando uma nova linha é inserida | Registrar logs de inserção               |
| `UPDATE` | Quando uma linha é modificada    | Auditar alterações                       |
| `DELETE` | Quando uma linha é excluída      | Mover dados para uma tabela de histórico |

No SQL Server, há dois tipos principais de triggers quanto ao momento em que são executadas:

AFTER TRIGGER (padrão):

- Executa após a operação (INSERT, UPDATE ou DELETE) ser concluída com sucesso.
- Muito usada para auditoria ou ações dependentes da confirmação da operação.

INSTEAD OF

- Usada quando você quer substituir o comportamento padrão da ação.
- Muito comum em views, já que views normalmente não podem receber 
INSERT ou UPDATE diretamente.

Exemplo:

1. Você tenta fazer um DELETE em uma tabela.
2. Existe uma trigger INSTEAD OF DELETE nessa tabela.
3. A trigger é disparada no lugar do DELETE.
4. A ação de remover a linha não acontece, a menos que você faça explicitamente dentro da trigger.

CREATE TRIGGER trg_InsteadOfDelete
ON tCADCliente
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO tCADClienteLog (IdCliente, Nome, TipoPessoa, Documento)
    SELECT iIdCliente, cNome, nTipoPessoa, cDocumento
    FROM deleted;
END;

Nível de Atuação:

| Nível                             | Descrição                                                                                                                    | Exemplo de uso                                                |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Tabela (DML Triggers)**         | Disparam com base em operações `INSERT`, `UPDATE` ou `DELETE` em uma tabela ou view                                          | Auditoria de alterações em uma tabela                         |
| **Banco de dados (DDL Triggers)** | Disparam com base em eventos de **Data Definition Language (DDL)**, como `CREATE TABLE`, `ALTER TABLE`, `DROP DATABASE` etc. | Impedir exclusão de tabelas ou monitorar alterações de schema |
| **Servidor (Logon Triggers)**     | Disparam em eventos **no nível do servidor**, como `LOGON`                                                                   | Restringir conexões, registrar logins, etc.                   |

Tabelas Virtuais: inserted e deleted

Essas tabelas são automáticas dentro das triggers DML:

| Tabela     | Quando é preenchida    | Contém                                       |
| ---------- | ---------------------- | -------------------------------------------- |
| `inserted` | Em `INSERT` e `UPDATE` | As **novas** linhas inseridas ou atualizadas |
| `deleted`  | Em `DELETE` e `UPDATE` | As **antigas** linhas removidas ou alteradas |

Para eventos de UPDATE, é necessário realizar um JOIN entre as tabelas virtuais

CREATE TRIGGER trg_AfterUpdate
ON Clientes
AFTER UPDATE
AS
BEGIN
    SELECT * FROM deleted;  -- Valores antigos
    SELECT * FROM inserted; -- Valores novos
END;

Boas práticas e cuidados:

- Documente e nomeie bem (trg_Tabela_Evento é um padrão comum).
- Use triggers para auditoria, logs e validações automáticas.

Curiosidade:

- Ao criar triggers de nível de servidor, é possível capturar eventos
DDL(Data Definition Language). Exemplo:

CREATE TRIGGER trg_AlterTable_Server
ON ALL SERVER
FOR ALTER_TABLE
AS
BEGIN
    DECLARE @data XML
    SET @data = EVENTDATA()

    INSERT INTO ServerAuditLog (EventType, DatabaseName, ObjectName, EventTime)
    VALUES (
        @data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'NVARCHAR(100)'),
        @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        GETDATE()
    );
END;


*/
