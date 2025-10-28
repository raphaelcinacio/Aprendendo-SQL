-- Conceitos
/*

Todos os dados enviados das aplicações, são gravados em tabelas. Essas, por sua vez,
são chamadas de objetos de alocação de dados. Esses objetos de alocação são
gravados dentro dos arquivos de dados(localizados no disco).

Em cada arquivo de dados, temos áreas pré-definidas, onde os dados são gravados. Essas
áreas são associadas aos objetos de alocação e são conhecidas como página de dados.

Página de dados:

1. Uma página de dados é a menor alocação de dados utilizada pelo SQL Server. Ela
é a unidade fundamental de armazenamento de dados.

2. Uma página de dados tem um tamanho definido de 8Kbytes ou 8192Kbytes, que
são divididos entre cabeçalho, área de dados e slot de controle

3. Ua página de dados é eclusiva para um objeto de alocação e um objeto de alocação
pode ter diversas páginas de dados.

4. Em uma página de dados somente serão armazenados 8060 bytes de dados

CREATE TABLE Teste01
(
	Descricao CHAR(4096),
	Titulo CHAR(4096),
	Observacao CHAR(4096)
)

Creating or altering table 'Teste01' failed because the minimum row size would be 12295, 
including 7 bytes of internal overhead. This exceeds the maximum allowable table row size 
of 8060 bytes.

Ou seja, uma linha não pode ter mais que 8060 bytes

CREATE TABLE Teste01
(
	Descricao CHAR(4000),
	Titulo CHAR(4000)
)

INSERT INTO Teste01(Descricao, Titulo)
VALUES('TesteDescricao', 'TesteTitulo')

sp_spaceused 'Teste01' -- Retorna o espaço usado pela tabela(número de páginas)

-- Extent ou Extensão

- Agrupamentos lógicos de páginas de dados
- Seu objetivo é gerenciar melhor o espaço alocado dos dados
- Um extent tem exatamente 8 páginas de dados e um tamanho de 64 Kbytes

-- Quando há a formatação do disco, o ideal é que o tamanho para alocação seja
-- definido em 64 Kbytes, para que apenas uma leitura seja feita

-- Tipos de Extent
-- 1. Misto(Mixed Extent): quando as páginas de dados são de objetos de alocações 
-- diferentes
-- 2. Uniforme(Uniform Extent): quando as páginas de dados são exclusiva de um único 
-- objeto de alocação

-- Por padrão, é utilizado o mixed, quando não há como definir o tamanho da tabela

*/

/*

-- Configuração de memória

Memória:

- Quanto mais, melhor. Memória será utilizada para carregar os dados que estão
em disco para uma área do SQL Server conhecida como Buffer Pool.

- Quanto mais dados o SQL Server conseguir manter em memória, melhor. 

Buffer Cache ou Buffer Pool:

- Um buffer é uma área de 8Kbytes na memória onde o SQL Server armazena as páginas 
de dados lidas dos objetos de alocação que estão no disco

- O dado permanece no buffer até que o gerenciador de buffer precise de mais área para
carregar novas páginas de dados. As áreas de buffer mais antigas e com dados
modificados são gravados em disco e liberadas para as novas páginas

- A área de memória onde fica o Buffer Pool é configurada no SQL Server como 
Min Server Memory e Max Server Memory

1. Leitura lógica: Quando o dado está no buffer
2. Leitura física: Quando o dado não está no buffer e é necessário ler do disco

Configurando a memória no SQL Server

EXECUTE sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE

EXECUTE sp_configure 'min memory per query (KB)'
EXECUTE sp_configure 'max server memory (MB)'

-- Na execução acima tem 1024 Kb de memória mínima e 2147483647 Kb(2 Tb) de memória
máxima

-- Quando a alocação ultrapassa o valor mínimo, o SQL Server continua a alocar mais memória.
Se, por algum motivo, o Sistema Operacional solicitar memória do SQL Server, o mesmo 
pode liberar a memória, mas até atingir o limite mínimo.
-- Min Server Memory: Se refere a memória mínima que o SQL Server pode liberar
-- Mas Server Memory: A memória máxima alocada para o serviço do SQL Server

-- Verificar a memória total e disponível

select 
	  total_physical_memory_kb / 1024.0 as MemoriaTotal,
	  available_physical_memory_kb / 1024.0 as MemoriaDisponivel
from sys.dm_os_sys_memory -- 16270.460937	6516.597656

-- Configurando os valores máximo e mínimo

EXECUTE sp_configure 'min server memory (MB)', 512
GO 
RECONFIGURE WITH OVERRIDE

EXECUTE sp_configure 'max server memory (MB)', 2147483647
GO 
RECONFIGURE WITH OVERRIDE

select * from sys.dm_os_buffer_descriptors

select 
	db_name(database_id) as Banco,
	(count(1) * 8192) / 1024 / 1024 as QtdPaginas -- Em MB
from sys.dm_os_buffer_descriptors
group by db_name(database_id)

*/

/*

Design de banco de dados

- Cada banco de dados tem no mínimo dois arquivos
	1. .MDF(Master Data File) -> Arquivo principal
	2. .LDF(Log Data File) -> Registro de log de transação

Sintaxe básica para criação de um banco de dados

- CREATE DATABASE DBTest

SELECT * FROM SYS.DATABASE_FILES
-- Size -> Quantidade de páginas para o banco de dados
-- Growth -> Taxa de crescimento do arquivo em páginas de dados

No arquivo principal:
- A inicialização do banco de dados
- A referência para outros arquivos de dados do banco de dados
- Metadados de todos os objetos de banco de dados criados pelos desenvolvedores

Todo e qualquer comando que tenha alguma referência a objetos como tabela, colunas, view, etc.
Sempre consulta os metadados desses objetos no arquivo principal, ou seja, um simples
"SELECT Coluna FROM Tabela", faz com que o SQL Server consulte nos metadados se a coluna e tabela existem.

- Existe um outro tipo de arquiovo que podemos(e devemos) associar ao banco de dados, que é conhecido
como secundário de dados. Ele tem a extensão NDF.

Cada um dos arquivos de dados deve possuir algumas características como:
- Ser agrupado junto com outros arquivos de dados em um grupo lógico de arquivos chamado
de FILEGROUP(FG). Se não especificado o File Group, o arquivo fica no grupo de arquivo PRIMARY
- Deve te um nome lógico que será utilizado em instruções T-SQL
- Deve ter um nome físico onde consta o local e o arquivo no sistema operacional
- Deve ter um tamanho inicial para atender a carga de dados atual e uma previsão futura
- Deve ter uma taxa de crescimento definida. Será utilizada para aumentar o tamanho do arquivo de dados, 
quando o mesmo estiver cheio
- Deve ter um limite máximo de crescimento. Isso é importante para evitar que arquivos
cresçam e ocupem todo o espaço em disco

- Toda vez que um novo banco de dados é criado, as configurações básicas como size e growth, são
retiradas no banco de dados model

Exemplo de criação de banco de dados:

DROP DATABASE IF EXISTS DBDemo_01
GO

CREATE DATABASE DBDemo_01
ON PRIMARY
(
	NAME = 'Primario',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Primario.mdf',
	SIZE = 256MB,
	FILEGROWTH = 64MB
)
LOG ON
(
	NAME = 'Log',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Log.ldf',
	SIZE = 12MB,
	FILEGROWTH = 8MB
)
GO

USE DBDemo_01
GO

SELECT (Size * 8192) / 1024 as Size, (Growth * 8192) / 1024 as Growth, * 
	FROM SYS.DATABASE_FILES

-- Criando com 2 arquivos de dados

DROP DATABASE IF EXISTS DBDemo_01
GO

CREATE DATABASE DBDemo_01
ON PRIMARY
(
	NAME = 'Primario',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Primario.mdf',
	SIZE = 256MB,
	FILEGROWTH = 64MB
),
(	-- Segundo arquivo de dados, no mesmo file group
	NAME = 'Secundario',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Secundario.ndf', -- É possível distribuir a carga em dois discos, para ganho de performance
	SIZE = 256MB,
	FILEGROWTH = 64MB
)
LOG ON
(
	NAME = 'Log',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Log.ldf',
	SIZE = 12MB,
	FILEGROWTH = 8MB
)
GO

USE DBDemo_01
GO

SELECT (Size * 8192) / 1024 as Size, (Growth * 8192) / 1024 as Growth, * 
	FROM SYS.DATABASE_FILES

FILEGROUP
-------------------------------------------------
É um agrupamento lógico de arquivos de dados para distribuir melhor a alocação de dados
entre os discos, agrupar dados de acordo com contextos. Além de permitir ao DBA uma melhor
forma de administração.

USE MASTER
GO

DROP DATABASE IF EXISTS DBDemo_01
GO

CREATE DATABASE DBDemo_01
ON PRIMARY -- Filegroup primário
(
	NAME = 'Primario',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Primario.mdf',
	SIZE = 64MB,
	FILEGROWTH = 8MB
),
FILEGROUP DADOS -- Filegroup com o nome de dados
(
	NAME = 'DadosTransacional1',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Transacional1.ndf', 
	SIZE = 1024MB,
	FILEGROWTH = 102464MB
),
(
	NAME = 'DadosTransacional2',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Transacional2.ndf', 
	SIZE = 1024MB,
	FILEGROWTH = 1024MB
)
LOG ON
(
	NAME = 'Log',
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Log.ldf',
	SIZE = 512MB,
	FILEGROWTH = 64MB
)
GO

-- Para indicar onde os dados devem ser registrados
ALTER DATABASE DBDemo_01 MODIFY FILEGROUP [DADOS] DEFAULT

- A vantagem é que os metadados ficam no primary, enquanto os demais dados são gravados em outros arquivos
- Vale mencionar que é possível criar um filegroup apenas para os indices, dessa forma
teríamos ganho de performance, pois os metadados, dados e indices, estariam em arquivos diferentes

sys.filegroups -> Retorna informações sobre os filegroups

Para ganho de performance:
1. Distribuir o banco em discos distintos
2. Separar dados dos metadados, através de filegroup

*/

/*

Tipos de dados e armazenamento:

- Quando criamos uma tabela, temos que definir as colunas e onde os dados ficarão
armazenados.

- Essas colunas dever ser definidas com um conjunto de características, que permite
armazenar os dados corretos, com o tamanho ideal e com as regras de restrições.

Dados de tamanho Fixo:
------------------------------------------------------

São os tipos de dados que armazenam o tamanho que foi declarado ou definido
para o tipo de dados, sem aumentar ou diminuir o número de bytes
de acordo com o dado inserido

INT 
- Sempre armazena 4 bytes para representar um número inteiro
- Muito utilizada para chave primária
- Evite usar para armazenar valores pequenos, como idade. 
- Utilize para armazenar dados que serão utilizados para efetuar algum cálculo ou operação
matemática

SMALLINT 
- Sempre armazena 2 bytes
- Útil para armazenar informações, que não ultrapassem de 30.000 linhas

TINYINT
- Sempre armazena 1 byte
- Utilizado para valores pequeno, de 0 a 255

BIGINT
- Sempre armazena 8 bytes

CHAR(n)
- Aceita n caracteres
- O total de bytes declarados no tipo de dados será o mesmo para o armazenamento

NCHAR(n)
- Aceita n caracteres
- O total de bytes declarados no tipo de dados será o mesmo para o armazenamento
- Utiliza 2 bytes para representar 1 caractere

DATE
- 3 bytes
- Para datas entre 01/01/0001 até 31/12/9999
- Para data de nascimento, data de fabricação, data de previsão de entrega

DATETIME
- 8 bytes
- Para datas entre 01/01/1753 00:00:00.000 até 31/12/9999 23:59:59.997
- Data de entrega, data do pedido, data marcação de ponto

SMALLDATETIME
- 4 bytes
- Para datas entre 01/01/1900 00:00:00 até 31/12/2079 23:59:00(Os segundos são zerados)
- Utilizado para registrar datas com hora e minuto, com restrição do ano entre 1900 e 2079

DATETIME2(n)
- 6 bytes
- 01/01/0001 00:00:00 até 31/12/9999 23:59:59.9999999

TIME(n)
- Formato HH:MM:SS.SSSSSSS
- Não armazena horas acumuladas
- Geralmente utilizado junto de uma data, para informar quando um evento ocorreu
- Se usarmos duas colunas (DATE + TIME), será consumido 6 bytes(DATE + TIME(2)),
sendo equivalente a um DATETIME(2)

MONEY
- 8 bytes
- Precisão de 4 casas decimais
- Valor monetário
- Para representar um valor acumulado ou totalizador

SMALLMONEY
- 4 bytes
- Precisão de 4 casas decimais
- Valor monetário
- Para representar valores unitários, de desconto ou acréscimo

DECIMAL(p, s)
- Tipo de dados númericos com precisão decimal. 
- p -> Total de dígitos, incluindo a escala
- s -> Representa a escala que é o total de dígitos a direita do ponto decimal
- NUMERIC = DECIMAL
- Até 38 dígitos de precisão, temos 17 bytes de armazenamento
- Para valores de até 10 milhões e usando duas casas decimais, gastaríamos 5 bytes, sendo um
armazenamento menor que MONEY e permitiria guardar mais valores que o SMALLMONEY

Dados de tamanho Variável:
------------------------------------------------------

VARCHAR(n)
- Aceita n bytes de armazenamento
- O SQL Server utiliza 2 bytes a mais no armazenamento para gravar e recuperar os dados

NVARCHAR(n)
- Aceita n bytes de armazenamento
- O SQL Server utiliza 2 bytes a mais no armazenamento para gravar e recuperar os dados, 
e grava 2 bytes para cada caracter informado

1. Códigos de caracter de 0 a 255 são representados com 1 byte
2. Códigos de caracter de 256 a 65554 são representados com 2 bytes

Boas práticas:
------------------------------------------------------
1. Não usar NCHAR ou NVARCHAR(Só quando necessário)
2. Utilize INT para chave primário das tabelas
3. Pequenas tabelas para armazenar categorias, grupos ou tipificação, verificar a 
possibilidade de usar TINYINT para identificação das linhas
4. Utilize BIGINT quando houve real necessidade
5. Utilize VARCHAR somente para colunas com variações grandes de dados e com tamanhos grandes
6. Analise o uso de CHAR ou INT para representar números

*/

/*

Design de tabelas:

- Quando uma tabela é criada, deve ser especificado em qual filegroup a mesma será criada
- Se não informado, a mesma será criada no filegroup padrão, sendo criada na primary

USE MASTER
GO

DROP DATABASE IF EXISTS DBDemoTable
GO

CREATE DATABASE DBDemoTable
ON PRIMARY			(NAME = 'Primario', FILENAME = 'C:\Database\DataBaseFiles\DBDemoTable.mdf'),
FILEGROUP DADOS1	(NAME = 'Dados1', FILENAME = 'C:\Database\DataBaseFiles\DBDemoTable1.ndf'),
FILEGROUP DADOS2	(NAME = 'Dados2', FILENAME = 'C:\Database\DataBaseFiles\DBDemoTable2.ndf'),
FILEGROUP DADOS3	(NAME = 'Dados3', FILENAME = 'C:\Database\DataBaseFiles\DBDemoTable3.ndf'),
FILEGROUP DADOS4	(NAME = 'Dados4', FILENAME = 'C:\Database\DataBaseFiles\DBDemoTable4.ndf')
LOG ON				(NAME = 'Log', FILENAME = 'C:\Database\DataBaseFiles\DBDemoTableLog.ldf')
GO

-- Alterando o file group default
ALTER DATABASE DBDemoTable MODIFY FILEGROUP DADOS1 DEFAULT
GO

USE DBDemoTable
GO

-- Filegroup padrão
CREATE TABLE tExemplo1
(
	Id INT,
	Nome CHAR(10)
)

-- Especificando um Filegroup
CREATE TABLE tExemplo2
(
	Id INT,
	Nome CHAR(10)
) ON DADOS2

-- Para avaliar em qual filegroup está a tabela
SELECT object_name(i.object_id) as [Table], d.name as [FileGroup]
FROM sys.data_spaces d
	INNER JOIN sys.indexes i
	ON d.data_space_id = i.data_space_id
WHERE i.object_id = object_id('tExemplo1')
and i.index_id in (0, 1)

---------------------------------------------------------
No exemplo abaixo, temos 4 tabelas para atender a uma mesma demanda, porém, 
é possível perceber que o número total de páginas de cada tabela e 
tamanho de armazenamento é totalmente diferentes

drop table if exists tItemModelo01 
go
drop table if exists tItemModelo02
go
drop table if exists tItemModelo03 
go
drop table if exists tItemModelo04 
go


Create Table tItemModelo01 
(
   Codigo        nchar(20) primary key ,       -- 40 bytes 
   Titulo        nvarchar(200),                -- 400 bytes 
   Descricao     nvarchar(3500),               -- 7000 bytes 
   Fornecedor    nvarchar(100),                -- 200 bytes 
   Preco         money ,                       -- 8 bytes 
   Comissao      money ,                       -- 8 bytes 
   ValorComissao money ,                       -- 8 bytes 
   Quantidade    int ,                         -- 8 bytes 
   Frete         money                         -- 8 bytes 
) on DADOS1                                    -- +- 7680 bytes limite máximo de alocação.
go 


Create Table tItemModelo02 
(
   Codigo        char(20) primary key ,  -- 20 bytes,  Troca de NCHAR para CHAR 
   Titulo        varchar(200),           -- 200 bytes Troca de NVARCHAR para VARCHAR 
   Descricao     varchar(3500),          -- 3500 bytes 
   Fornecedor    varchar(100),           -- 100 bytes 
   Preco         money ,                 -- 8 bytes 
   Comissao      money ,                 -- 8 bytes 
   ValorComissao money ,                 -- 8 bytes 
   Quantidade    int ,                   -- 4 bytes 
   Frete         money                   -- 8 bytes 
) on DADOS2                              -- +- 3856 bytes 
go 

Create Table tItemModelo03
(
   iID           int primary key identity(1,1) ,  -- 4 bytes, incluimos uma PK INT com numeração automática.
   Codigo        varchar(20),                     -- 20 bytes 
   Titulo        varchar(200),                    -- 200 bytes 
   Descricao     varchar(3500),                   -- 3500 bytes 
   iIDFornecedor int ,                            -- 4 bytes ,considero que os dados de Fornecedor em outra tabela. 
   Preco         money ,                          -- 8 bytes 
   Comissao      numeric(4,2),                    -- 5 bytes, Como a comissão é um percentual (99,99)
   ValorComissao money ,                          -- 8 bytes 
   Quantidade    int ,                            -- 4 bytes 
   Frete         money                            -- 8 bytes 
) on DADOS3                                       -- +- 3761 bytes 
go

Create Table tItemModelo04 
(
   iID           smallint primary key identity(1,1), -- 2 bytes , Como a tabela terá 15.000, smallint 
   Codigo        varchar(20),                        -- 20 bytes 
   Titulo        varchar(200),                       -- 200 bytes 
   Descricao     varchar(3500),                      -- 3500 bytes 
   iIDFornecedor smallint ,                          -- 2 bytes, no máximo 5000 fornecedores 
   Preco         smallmoney ,                        -- 4 bytes Preco com valor máximo de 200 mil.
   Comissao      numeric(4,2),                       -- 5 bytes 
   ValorComissao as (Preco * Comissao/100) ,         -- 0 bytes, em vez de guardar a comissão, calculamos. 
   Quantidade    smallint ,                          -- 2 bytes Armazena ate 32.000 quantidade do Item .
   Frete         smallmoney                          -- 4 bytes Frete com valor máximo de 200 mil.
) on DADOS4                                          -- +- 3739 
go

set nocount on
go


declare @cCodigo varchar(20) = substring(cast(newid() as varchar(36)),1,20)
declare @cDescricao varchar(3500) = replicate('A', rand()*3500)

insert into tItemModelo01 
       (Codigo  ,Titulo   ,Descricao  , Fornecedor      ,Preco,Comissao, ValorComissao, Quantidade,Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,'FORNECEDOR AAAA', 100 ,     100,           100,        100,  100) 

insert into tItemModelo02 (Codigo,Titulo,Descricao, Fornecedor,Preco,Comissao, ValorComissao, Quantidade , Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,'FORNECEDOR AAAA', 100, 100, 100, 100,100) 

insert into tItemModelo03 (Codigo,Titulo,Descricao, iIDFornecedor,Preco,Comissao, ValorComissao, Quantidade , Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,RAND()*10000, 100, 50, 100, 100,100) 

insert into tItemModelo04 (Codigo,Titulo,Descricao, iIDFornecedor,Preco,Comissao,Quantidade,Frete)
values (@cCodigo,'AAAAAAA',@cDescricao,RAND()*10000, 100, 50, 100, 100) 

GO 15000


select fg.name ,
       su.total_page_count  as  nTotalPaginas , 
       su.allocated_extent_page_count  as nPaginasUsada, 
       su.unallocated_extent_page_count   as nPaginasLivre, 
	   -------
       su.total_page_count * 8192 / 1024.0 as nTamanhoKb, 
       su.allocated_extent_page_count * 8 / 1024.0 nUsadoKB, 
       su.unallocated_extent_page_count  * 8 / 1024.0 nLivreKB
  from sys.dm_db_file_space_usage su 
  join sys.filegroups fg 
    on su.filegroup_id = fg.data_space_id

-- Quando criar uma tabela, preciso criá-la de maneira que a mesma ocupe
o menor número de páginas dentro do banco de dados

*/

/*

Colunas calculadas:

- Uma coluna calculada é utilizada quando realizamos um cálculo ou montamos
uma expressão e associamos a uma coluna
- O dado retornado por essa coluna é calculado no momento em que o mesmo 
for solicitado, ou seja, o mesmo não será persistido em disco, enquanto não for
utilizada a palavra reservada PERSISTED

Create Table tItemModelo04 
(
   iID           smallint primary key identity(1,1),  
   Codigo        varchar(20),                         
   Titulo        varchar(200),                       
   Descricao     varchar(3500),                       
   iIDFornecedor smallint ,                           
   Preco         smallmoney ,                        
   Comissao      numeric(4,2),                       
   ValorComissao as cast((Preco * Comissao/100) as smallmoney) PERSISTED, -- Coluna calculada persistida     
   Quantidade    smallint ,                          
   Frete         smallmoney                          
)

*/

/*

Compactando tabelas:

-- Recurso do SQL Server para compactar dados pelas linhas ou página de dados

-- A compactação tem como objetivo reduzir o espaço alocado pelo banco de 
dados em disco, como aumentar a performance de acesso aos dados, 
visto que com a compactação, é possível alocar mais bytes em uma página de 
dados

-- Pode ser aplicada em uma tabela sem indices(heap table), com índices
agrupados (clusterizado)

-- Não é toda tabela que pode ser compactada ou que realmente teremos 
ganho de armazenamento ou performance

----------------------------------------------------------------------

-- Retorna o espaço utilizado por uma tabela

sp_spaceused 'NomeTabela'
	- size_with_current_compression_setting(KB) -> Tamanho atual
	- size_with_requested_compression_setting(KB) -> Tamanho estimado com compressão

-- Retorna o total de páginas e se há alguma compressão realizada

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('NomeTabela')
	  and au.type = 1
go

----------------------------------------------------------------------

Sobre o page compression

O PAGE compression é uma técnica que reduz redundâncias dentro da mesma página de 
dados (8 KB). O SQL Server faz isso em três etapas sucessivas:

1. Row compression (primeira etapa)
- Remove bytes desnecessários, como zeros, espaços fixos, etc.
- Exemplo: um INT com valor 1 passa a ocupar apenas 1 byte (em vez de 4).

2. Prefix compression
- Identifica prefixos comuns em várias colunas ou linhas e armazena o prefixo 
uma única vez.

3. Dictionary compression
- Cria um dicionário de valores repetidos dentro da página (8KB) e substitui 
as repetições por referências curtas.
- Exemplo, se várias linhas contêm o valor “SP”, o SQL Server o guarda uma vez e 
substitui as ocorrências por um ponteiro.

Vantagens:

1. Grande economia de espaço

- Pode reduzir o tamanho da tabela ou índice em 50% a 80%, dependendo da redundância 
dos dados.

2. Menos I/O (entrada e saída)

- Como há menos bytes a serem lidos e gravados, consultas podem ser mais rápidas, 
especialmente em leituras intensivas.

3. Melhor uso de cache e memória

- Mais dados cabem no buffer pool, reduzindo leituras em disco.

Desvantagens:

1. Maior uso de CPU

- Cada leitura e escrita exige compressão e descompressão em tempo real, 
o que pode afetar sistemas de alta taxa de atualização (INSERT, UPDATE, DELETE).

2. Melhor para dados “estáticos”

- Ideal para tabelas históricas, de logs, fatos (DW) ou com baixo volume de updates.
- Não indicado para tabelas com muitos UPDATEs em colunas comprimidas.

----------------------------------------------------------------------

Como aplicar page compression:

ALTER TABLE dbo.NomeTabela
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);

Antes de aplicar, sempre é bom medir o ganho esperado. Para isso, podemos usar
uma procedure própria do SQL Server:

EXEC sp_estimate_data_compression_savings 
    'dbo',              -- Schema
    'Tabela',           -- Tabela
    NULL,               -- Índice específico ou NULL para todos
    NULL,               -- Partição específica ou NULL
    'PAGE';             -- Tipo de compressão

----------------------------------------------------------------------

Entendendo o I/O no contexto da compressão

1. Durante a leitura

- Cada página no SQL Server tem 8 KB.
- Quando aplicamos PAGE compression, o SQL Server armazena mais linhas 
dentro da mesma página.
- Isso significa que uma leitura de 8 KB contém mais dados úteis.

Resultado:

- Menos páginas precisam ser lidas do disco.
- Menos operações físicas de I/O.
- O buffer pool (cache em memória) consegue armazenar mais linhas por página.

Exemplo:
Se uma tabela ocupa 100 GB antes da compressão e 40 GB depois, 
qualquer consulta que antes lia 10.000 páginas agora pode ler 
apenas 4.000 — menos I/O direto.

2. Durante a escrita

Cada vez que ocorre um INSERT, UPDATE ou DELETE:

- O SQL Server precisa comprimir ou descomprimir a página 
(se estiver em PAGE compression).
- Isso gera trabalho adicional de CPU.

- Operações de escrita (principalmente UPDATE) podem exigir mais CPU e 
mais regravações de páginas.

| Tipo de operação     | Efeito no I/O             | Efeito na CPU| Observação                             |
| -------------------- | --------------------------| -------------| -------------------------------------- |
|   SELECT (leitura)   | Reduzido                  | Leve aumento | Geralmente positivo                    |
|   INSERT             | Pode aumentar             | Médio        | Compressão precisa ser aplicada        |
|   UPDATE             | Pode aumentar bastante    | Alto         | Pode exigir recompactação              |
|   DELETE             | Neutro ou ligeiro aumento | Leve         | Página pode precisar ser reequilibrada |


*/

