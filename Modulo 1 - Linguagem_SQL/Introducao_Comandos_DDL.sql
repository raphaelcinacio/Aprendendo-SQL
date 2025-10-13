/*===============================================================
CRIAÇÃO DE TABELAS NO SQL SERVER
Este script reúne exemplos práticos e comentados sobre:
- Criação de tabelas
- Tipos de dados
- Restrições (Primary Key, Unique, Foreign Key, Check, Default)
- Sequências e Identity
===============================================================*/

/** Sintaxe básica do CREATE TABLE **/
/*
CREATE TABLE <NomeDaTabela> (
    Coluna1 Tipo Restrição,
    Coluna2 Tipo Restrição,
    ...
)
*/

/** Tipos de dados mais comuns **/
/*
INT      → Números inteiros (BIGINT, INT, TINYINT)
VARCHAR  → Texto variável (VARCHAR, CHAR)
DATE     → Armazena uma data válida
MONEY    → Valores monetários
*/

--===============================================================
-- EXEMPLO BÁSICO DE CRIAÇÃO DE TABELA
--===============================================================
DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL,
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL
);
GO

/** ALTER TABLE → adicionar e remover colunas **/
ALTER TABLE dbo.Empregado 
ADD Departamento VARCHAR(40) NOT NULL;

ALTER TABLE dbo.Empregado
DROP COLUMN CPF;
GO

/** sp_help → exibe informações da tabela **/
EXEC sp_help Empregado;
GO

/*===============================================================
CHAVE PRIMÁRIA (PRIMARY KEY)
Garante unicidade de registros em uma ou mais colunas.
===============================================================*/

-- Primeira forma de criar (inline)
DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL PRIMARY KEY,
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL
);
GO

-- Segunda forma (definida via CONSTRAINT)
DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL,
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado)
);
GO

/** Também é possível adicionar depois com ALTER TABLE **/
ALTER TABLE dbo.Empregado
ADD CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado);
GO

/*===============================================================
SEQUÊNCIAS (SEQUENCE)
Gera valores automáticos e únicos que podem ser usados como PK.
===============================================================*/

CREATE SEQUENCE SeqIdEmpregado START WITH 1 INCREMENT BY 1;

DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL DEFAULT(NEXT VALUE FOR SeqIdEmpregado),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado)
);
GO

/*===============================================================
IDENTITY
Gera valores sequenciais automáticos para colunas inteiras.
===============================================================*/

DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado)
);
GO

/*===============================================================
UNIQUE CONSTRAINT
Garante que os valores em uma coluna (ou conjunto de colunas)
sejam únicos em toda a tabela.
===============================================================*/

DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL UNIQUE,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado)
);
GO

-- Nomeando explicitamente a constraint UNIQUE
DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado),
	CONSTRAINT UnCPF UNIQUE(CPF)
);
GO

ALTER TABLE dbo.Empregado
ADD CONSTRAINT UnCPF UNIQUE(CPF);
GO

/*===============================================================
CHAVE ESTRANGEIRA (FOREIGN KEY)
Garante a integridade referencial entre tabelas relacionadas.
===============================================================*/

DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado),
	CONSTRAINT UnCPF UNIQUE(CPF)
);
GO

DROP TABLE IF EXISTS dbo.Pedido;

CREATE TABLE dbo.Pedido(
	IdPedido INT NOT NULL IDENTITY(1,1),
	IdEmpregado INT NOT NULL,
	Cliente VARCHAR(50) NOT NULL,
	Criado DATETIME NOT NULL,
	CONSTRAINT PKPedido PRIMARY KEY(IdPedido),
	CONSTRAINT FKEmpregado FOREIGN KEY (IdEmpregado)
		REFERENCES dbo.Empregado(IdEmpregado)
);
GO

ALTER TABLE dbo.Pedido
ADD CONSTRAINT FKEmpregado
FOREIGN KEY (IdEmpregado)
REFERENCES dbo.Empregado(IdEmpregado);
GO

/*===============================================================
CHECK CONSTRAINT
Restringe os valores aceitos em uma coluna (validação).
===============================================================*/

DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL CHECK(Salario > 0),
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado),
	CONSTRAINT UnCPF UNIQUE(CPF)
);
GO

-- Forma com constraint nomeada
DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL,
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado),
	CONSTRAINT UnCPF UNIQUE(CPF),
	CONSTRAINT CKSalario CHECK(Salario > 0)
);
GO

ALTER TABLE dbo.Empregado
ADD CONSTRAINT CKSalario CHECK(Salario > 0);
GO

/*===============================================================
DEFAULT CONSTRAINT
Define valores padrão para colunas quando nenhum valor é informado.
===============================================================*/

DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado),
	CONSTRAINT UnCPF UNIQUE(CPF),
	CONSTRAINT CKSalario CHECK(Salario > 0)
);
GO

-- Forma com nome da constraint DEFAULT explícito
DROP TABLE IF EXISTS dbo.Empregado;

CREATE TABLE dbo.Empregado (
	IdEmpregado INT NOT NULL IDENTITY(1,1),
	PrimeiroNome VARCHAR(50) NOT NULL,
	UltimoNome VARCHAR(50) NOT NULL,
	Admissao DATE NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	CPF VARCHAR(11) NOT NULL,
	Salario MONEY NOT NULL,
	CONSTRAINT PKEmpregado PRIMARY KEY(IdEmpregado),
	CONSTRAINT UnCPF UNIQUE(CPF),
	CONSTRAINT CKSalario CHECK(Salario > 0),
	CONSTRAINT DfAdmissao DEFAULT(CURRENT_TIMESTAMP) FOR Admissao
);
GO

ALTER TABLE dbo.Empregado
ADD CONSTRAINT DfAdmissao
DEFAULT(CURRENT_TIMESTAMP) FOR Admissao;
GO