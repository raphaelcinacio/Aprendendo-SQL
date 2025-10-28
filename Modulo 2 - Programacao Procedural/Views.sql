-- Views
/*

- View ou visão, são objetos de programação que encapsulam uma instrução SELECT
- Os dados não estão armazenados na view. Há a execução de um código SELECT
associado a view

Motivos para usar uma view:

1. Simplificar uma instrução SELECT complexa, ou seja, para facilitar a 
utilização e reaproveitamento de código
2. Acessível por qualquer instrução DML e, em certo cenários,
será possível utilizar em instruções como INSERT, UPDATE e DELETE, para atualizar 
os dados
3. Reduz o trânsito de dados pela rede interna
4. Encapsular regras de negócio, escondendo os objetos de banco de dados
5. Permite emular tabelas que foram alteradas e compatibilizar com
versões antigas de sistemas
6. Maior segurança de acesso aos dados, onde podemos conceder acesso a view,
sem a necessidade de conceder permissões nas tabelas

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

O design para criação de views se baseia em:

1. Conhecer os comandos para realizar sua criação e manutenção
2. Ter um padrão de nomenclatura de objetos
3. Construir o código documentado e organizado

Comandos:

CREATE VIEW <NomeVisao> 
AS 
<Código>

DROP VIEW <NomeVisao> 

Recomendação:

- Evitar o procedimento de DROP e CREATE. A recomendação é utilizar o 
CREATE OR ALTER VIEW
- Se realizar o DROP e CREATE, as permissões serão perdidas

Procedures de sistema:

-- Mostra estrutura da view(serve para tabelas, procedures, etc)
EXECUTE sp_help <NomeVisao>

-- Mostra o código associado a view(serve para tabelas, procedures, etc)
EXECUTE sp_helptext <NomeVisao>

Todas as views são criadas no banco de dados da conexão atual e armazenadas
nas visões de catálogo:

- sys.views
- sys.sql_expression_dependencies
- sys.sql_modules

SELECT * 
	FROM sys.sql_expression_dependencies ed
	WHERE ed.referencing_id = object_id('vLOGEventos')

Padrão de nomenclatura e código:

- Trata-se de um processo para definir os nomes dos objetos do banco de dados, que 
permite sua identificação e tipo de objeto. O padrão também permite que o time
de desenvolvedores possa criar os objetos que todos possam identificar.

Exemplo:

- v_tCADCliente
	v_ -> Indica ser uma view

Construir um código documentado

1. Realize a documentação do código, pois o mesmo poderá facilitar em alterações
futuras
2. Tenha registrado o nome do autor, uma descrição do que faz, o objeto e, 
de preferência, mantenha um histórico das atualizações

*/

/*

Usando SCHEMABINDING

- O SCHEMABINDING é uma opção que você declara no design
da view para realizar uma associação entre a view e as 
tabelas utilizadas na consulta. Com isso, modificações nas
estruturas das tabelas que compões a view, não poderão ser realizadas

- Para usar essa  opção, as tabelas devem ser declaradas com o
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
- É uma opção declarada na criação da view que garante que os dados
continuem visíveis depois de qualquer alteração
- Garante a consistência dos dados inseridos ou atualizados através da view.
- Não permite que dados "saiam do filtro" da view

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

Atualização de dados

- É possível atualizar uma view e essa alteração ocorre na tabela de origem

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

