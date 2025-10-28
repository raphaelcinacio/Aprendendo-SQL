-- Views
/*

- View ou vis�o, s�o objetos de programa��o que encapsulam uma instru��o SELECT
- Os dados n�o est�o armazenados na view. H� a execu��o de um c�digo SELECT
associado a view

Motivos para usar uma view:

1. Simplificar uma instru��o SELECT complexa, ou seja, para facilitar a 
utiliza��o e reaproveitamento de c�digo
2. Acess�vel por qualquer instru��o DML e, em certo cen�rios,
ser� poss�vel utilizar em instru��es como INSERT, UPDATE e DELETE, para atualizar 
os dados
3. Reduz o tr�nsito de dados pela rede interna
4. Encapsular regras de neg�cio, escondendo os objetos de banco de dados
5. Permite emular tabelas que foram alteradas e compatibilizar com
vers�es antigas de sistemas
6. Maior seguran�a de acesso aos dados, onde podemos conceder acesso a view,
sem a necessidade de conceder permiss�es nas tabelas

Como criar:

CREATE OR ALTER VIEW v_tCADCliente
AS
SELECT iIdCliente as Id,
	   cNome as Nome,
	   mCredito as ValorCredito
FROM tCADCliente
WHERE mCredito < 10

*/

/*

Design de views:

O design para cria��o de views se baseia em:

1. Conhecer os comandos para realizar sua cria��o e manuten��o
2. Ter um padr�o de nomenclatura de objetos
3. Construir o c�digo documentado e organizado

Comandos:

CREATE VIEW <NomeVisao> 
AS 
<C�digo>

DROP VIEW <NomeVisao> 

Recomenda��o:

- Evitar o procedimento de DROP e CREATE. A recomenda��o � utilizar o 
CREATE OR ALTER VIEW
- Se realizar o DROP e CREATE, as permiss�es ser�o perdidas

Procedures de sistema:

-- Mostra estrutura da view(serve para tabelas, procedures, etc)
EXECUTE sp_help <NomeVisao>

-- Mostra o c�digo associado a view(serve para tabelas, procedures, etc)
EXECUTE sp_helptext <NomeVisao>

Todas as views s�o criadas no banco de dados da conex�o atual e armazenadas
nas vis�es de cat�logo:

- sys.views
- sys.sql_expression_dependencies
- sys.sql_modules

SELECT * 
	FROM sys.sql_expression_dependencies ed
	WHERE ed.referencing_id = object_id('vLOGEventos')

Padr�o de nomenclatura e c�digo:

- Trata-se de um processo para definir os nomes dos objetos do banco de dados, que 
permite sua identifica��o e tipo de objeto. O padr�o tamb�m permite que o time
de desenvolvedores possa criar os objetos que todos possam identificar.

Exemplo:

- v_tCADCliente
	v_ -> Indica ser uma view

Construir um c�digo documentado

1. Realize a documenta��o do c�digo, pois o mesmo poder� facilitar em altera��es
futuras
2. Tenha registrado o nome do autor, uma descri��o do que faz, o objeto e, 
de prefer�ncia, mantenha um hist�rico das atualiza��es

*/

/*

Usando SCHEMABINDING

- O SCHEMABINDING � uma op��o que voc� declara no design
da view para realizar uma associa��o entre a view e as 
tabelas utilizadas na consulta. Com isso, modifica��es nas
estruturas das tabelas que comp�es a view, n�o poder�o ser realizadas

- Para usar essa  op��o, as tabelas devem ser declaradas com o
esquema

CREATE TABLE Clientes(
	Id INT NOT NULL,
	Nome VARCHAR(100) NOT NULL,
	PessoaFisica BIT NOT NULL,
	CONSTRAINT PK_Id PRIMARY KEY(Id)
);

CREATE OR ALTER VIEW v_Clientes
WITH SCHEMABINDING
AS 
SELECT Id, Nome, PessoaFisica
FROM dbo.Clientes

ALTER TABLE Clientes
DROP COLUMN PessoaFisica

Mensagem de erro:

Msg 5074, Level 16, State 1, Line 123
The object 'v_Clientes' is dependent on column 'PessoaFisica'.
*/

/*

CHECK OPTION
- � uma op��o declarada na cria��o da view que garante que os dados
continuem vis�veis depois de qualquer altera��o
- Garante a consist�ncia dos dados inseridos ou atualizados atrav�s da view.
- N�o permite que dados "saiam do filtro" da view

Exemplo:

CREATE OR ALTER VIEW v_CadClientes
WITH SCHEMABINDING
AS 
SELECT iIDCliente as Id, cNome as Nome, nTipoPessoa as PessoaFisica
FROM dbo.tCADCliente
WHERE nTipoPessoa = 1
WITH CHECK OPTION;

UPDATE v_CadClientes
SET PessoaFisica = 2
WHERE Id = 3

*/

/*

Atualiza��o de dados

- � poss�vel atualizar uma view e essa altera��o ocorre na tabela de origem

CREATE OR ALTER VIEW v_CadClientes
WITH SCHEMABINDING
AS 
SELECT iIDCliente as Id, cNome as Nome, nTipoPessoa as PessoaFisica
FROM dbo.tCADCliente

UPDATE v_CadClientes
SET PessoaFisica = 1
WHERE Id = 1

SELECT * FROM v_CadClientes
SELECT * FROM tCADCliente

Em alguns casos, se a view for representada por duas ou mais tabelas, 
e houver a tentativa de atualizar colunas de tabelas diferentes, pode
gerar um erro

*/

