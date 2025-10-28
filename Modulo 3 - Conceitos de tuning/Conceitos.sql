-- Conceitos
/*

Todos os dados enviados das aplica��es, s�o gravados em tabelas. Essas, por sua vez,
s�o chamadas de objetos de aloca��o de dados. Esses objetos de aloca��o s�o
gravados dentro dos arquivos de dados(localizados no disco).

Em cada arquivo de dados, temos �reas pr�-definidas, onde os dados s�o gravados. Essas
�reas s�o associadas aos objetos de aloca��o e s�o conhecidas como p�gina de dados.

P�gina de dados:

1. Uma p�gina de dados � a menor aloca��o de dados utilizada pelo SQL Server. Ela
� a unidade fundamental de armazenamento de dados.

2. Uma p�gina de dados tem um tamanho definido de 8Kbytes ou 8192Kbytes, que
s�o divididos entre cabe�alho, �rea de dados e slot de controle

3. Ua p�gina de dados � eclusiva para um objeto de aloca��o e um objeto de aloca��o
pode ter diversas p�ginas de dados.

4. Em uma p�gina de dados somente ser�o armazenados 8060 bytes de dados

CREATE TABLE Teste01
(
	Descricao CHAR(4096),
	Titulo CHAR(4096),
	Observacao CHAR(4096)
)

Creating or altering table 'Teste01' failed because the minimum row size would be 12295, 
including 7 bytes of internal overhead. This exceeds the maximum allowable table row size 
of 8060 bytes.

Ou seja, uma linha n�o pode ter mais que 8060 bytes

CREATE TABLE Teste01
(
	Descricao CHAR(4000),
	Titulo CHAR(4000)
)

INSERT INTO Teste01(Descricao, Titulo)
VALUES('TesteDescricao', 'TesteTitulo')

sp_spaceused 'Teste01' -- Retorna o espa�o usado pela tabela(n�mero de p�ginas)

-- Extent ou Extens�o

- Agrupamentos l�gicos de p�ginas de dados
- Seu objetivo � gerenciar melhor o espa�o alocado dos dados
- Um extent tem exatamente 8 p�ginas de dados e um tamanho de 64 Kbytes

-- Quando h� a formata��o do disco, o ideal � que o tamanho para aloca��o seja
-- definido em 64 Kbytes, para que apenas uma leitura seja feita

-- Tipos de Extent
-- 1. Misto(Mixed Extent): quando as p�ginas de dados s�o de objetos de aloca��es 
-- diferentes
-- 2. Uniforme(Uniform Extent): quando as p�ginas de dados s�o exclusiva de um �nico 
-- objeto de aloca��o

-- Por padr�o, � utilizado o mixed, quando n�o h� como definir o tamanho da tabela

*/

/*

-- Configura��o de mem�ria

Mem�ria:

- Quanto mais, melhor. Mem�ria ser� utilizada para carregar os dados que est�o
em disco para uma �rea do SQL Server conhecida como Buffer Pool.

- Quanto mais dados o SQL Server conseguir manter em mem�ria, melhor. 

Buffer Cache ou Buffer Pool:

- Um buffer � uma �rea de 8Kbytes na mem�ria onde o SQL Server armazena as p�ginas 
de dados lidas dos objetos de aloca��o que est�o no disco

- O dado permanece no buffer at� que o gerenciador de buffer precise de mais �rea para
carregar novas p�ginas de dados. As �reas de buffer mais antigas e com dados
modificados s�o gravados em disco e liberadas para as novas p�ginas

- A �rea de mem�ria onde fica o Buffer Pool � configurada no SQL Server como 
Min Server Memory e Max Server Memory

1. Leitura l�gica: Quando o dado est� no buffer
2. Leitura f�sica: Quando o dado n�o est� no buffer e � necess�rio ler do disco

Configurando a mem�ria no SQL Server

EXECUTE sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE

EXECUTE sp_configure 'min memory per query (KB)'
EXECUTE sp_configure 'max server memory (MB)'

-- Na execu��o acima tem 1024 Kb de mem�ria m�nima e 2147483647 Kb(2 Tb) de mem�ria
m�xima

-- Quando a aloca��o ultrapassa o valor m�nimo, o SQL Server continua a alocar mais mem�ria.
Se, por algum motivo, o Sistema Operacional solicitar mem�ria do SQL Server, o mesmo 
pode liberar a mem�ria, mas at� atingir o limite m�nimo.
-- Min Server Memory: Se refere a mem�ria m�nima que o SQL Server pode liberar
-- Mas Server Memory: A mem�ria m�xima alocada para o servi�o do SQL Server

-- Verificar a mem�ria total e dispon�vel

select 
	  total_physical_memory_kb / 1024.0 as MemoriaTotal,
	  available_physical_memory_kb / 1024.0 as MemoriaDisponivel
from sys.dm_os_sys_memory -- 16270.460937	6516.597656

-- Configurando os valores m�ximo e m�nimo

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

- Cada banco de dados tem no m�nimo dois arquivos
	1. .MDF(Master Data File) -> Arquivo principal
	2. .LDF(Log Data File) -> Registro de log de transa��o

Sintaxe b�sica para cria��o de um banco de dados

- CREATE DATABASE DBTest

SELECT * FROM SYS.DATABASE_FILES
-- Size -> Quantidade de p�ginas para o banco de dados
-- Growth -> Taxa de crescimento do arquivo em p�ginas de dados

No arquivo principal:
- A inicializa��o do banco de dados
- A refer�ncia para outros arquivos de dados do banco de dados
- Metadados de todos os objetos de banco de dados criados pelos desenvolvedores

Todo e qualquer comando que tenha alguma refer�ncia a objetos como tabela, colunas, view, etc.
Sempre consulta os metadados desses objetos no arquivo principal, ou seja, um simples
"SELECT Coluna FROM Tabela", faz com que o SQL Server consulte nos metadados se a coluna e tabela existem.

- Existe um outro tipo de arquiovo que podemos(e devemos) associar ao banco de dados, que � conhecido
como secund�rio de dados. Ele tem a extens�o NDF.

Cada um dos arquivos de dados deve possuir algumas caracter�sticas como:
- Ser agrupado junto com outros arquivos de dados em um grupo l�gico de arquivos chamado
de FILEGROUP(FG). Se n�o especificado o File Group, o arquivo fica no grupo de arquivo PRIMARY
- Deve te um nome l�gico que ser� utilizado em instru��es T-SQL
- Deve ter um nome f�sico onde consta o local e o arquivo no sistema operacional
- Deve ter um tamanho inicial para atender a carga de dados atual e uma previs�o futura
- Deve ter uma taxa de crescimento definida. Ser� utilizada para aumentar o tamanho do arquivo de dados, 
quando o mesmo estiver cheio
- Deve ter um limite m�ximo de crescimento. Isso � importante para evitar que arquivos
cres�am e ocupem todo o espa�o em disco

- Toda vez que um novo banco de dados � criado, as configura��es b�sicas como size e growth, s�o
retiradas no banco de dados model

Exemplo de cria��o de banco de dados:

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
	FILENAME = 'C:\Database\DataBaseFiles\DBDemo_01_Secundario.ndf', -- � poss�vel distribuir a carga em dois discos, para ganho de performance
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
� um agrupamento l�gico de arquivos de dados para distribuir melhor a aloca��o de dados
entre os discos, agrupar dados de acordo com contextos. Al�m de permitir ao DBA uma melhor
forma de administra��o.

USE MASTER
GO

DROP DATABASE IF EXISTS DBDemo_01
GO

CREATE DATABASE DBDemo_01
ON PRIMARY -- Filegroup prim�rio
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

- A vantagem � que os metadados ficam no primary, enquanto os demais dados s�o gravados em outros arquivos
- Vale mencionar que � poss�vel criar um filegroup apenas para os indices, dessa forma
ter�amos ganho de performance, pois os metadados, dados e indices, estariam em arquivos diferentes

sys.filegroups -> Retorna informa��es sobre os filegroups

Para ganho de performance:
1. Distribuir o banco em discos distintos
2. Separar dados dos metadados, atrav�s de filegroup

*/

/*

Tipos de dados e armazenamento:

- Quando criamos uma tabela, temos que definir as colunas e onde os dados ficar�o
armazenados.

- Essas colunas dever ser definidas com um conjunto de caracter�sticas, que permite
armazenar os dados corretos, com o tamanho ideal e com as regras de restri��es.

Dados de tamanho Fixo:
------------------------------------------------------

S�o os tipos de dados que armazenam o tamanho que foi declarado ou definido
para o tipo de dados, sem aumentar ou diminuir o n�mero de bytes
de acordo com o dado inserido

INT 
- Sempre armazena 4 bytes para representar um n�mero inteiro
- Muito utilizada para chave prim�ria
- Evite usar para armazenar valores pequenos, como idade. 
- Utilize para armazenar dados que ser�o utilizados para efetuar algum c�lculo ou opera��o
matem�tica

SMALLINT 
- Sempre armazena 2 bytes
- �til para armazenar informa��es, que n�o ultrapassem de 30.000 linhas

TINYINT
- Sempre armazena 1 byte
- Utilizado para valores pequeno, de 0 a 255

BIGINT
- Sempre armazena 8 bytes

CHAR(n)
- Aceita n caracteres
- O total de bytes declarados no tipo de dados ser� o mesmo para o armazenamento

NCHAR(n)
- Aceita n caracteres
- O total de bytes declarados no tipo de dados ser� o mesmo para o armazenamento
- Utiliza 2 bytes para representar 1 caractere

DATE
- 3 bytes
- Para datas entre 01/01/0001 at� 31/12/9999
- Para data de nascimento, data de fabrica��o, data de previs�o de entrega

DATETIME
- 8 bytes
- Para datas entre 01/01/1753 00:00:00.000 at� 31/12/9999 23:59:59.997
- Data de entrega, data do pedido, data marca��o de ponto

SMALLDATETIME
- 4 bytes
- Para datas entre 01/01/1900 00:00:00 at� 31/12/2079 23:59:00(Os segundos s�o zerados)
- Utilizado para registrar datas com hora e minuto, com restri��o do ano entre 1900 e 2079

DATETIME2(n)
- 6 bytes
- 01/01/0001 00:00:00 at� 31/12/9999 23:59:59.9999999

TIME(n)
- Formato HH:MM:SS.SSSSSSS
- N�o armazena horas acumuladas
- Geralmente utilizado junto de uma data, para informar quando um evento ocorreu
- Se usarmos duas colunas (DATE + TIME), ser� consumido 6 bytes(DATE + TIME(2)),
sendo equivalente a um DATETIME(2)

MONEY
- 8 bytes
- Precis�o de 4 casas decimais
- Valor monet�rio
- Para representar um valor acumulado ou totalizador

SMALLMONEY
- 4 bytes
- Precis�o de 4 casas decimais
- Valor monet�rio
- Para representar valores unit�rios, de desconto ou acr�scimo

DECIMAL(p, s)
- Tipo de dados n�mericos com precis�o decimal. 
- p -> Total de d�gitos, incluindo a escala
- s -> Representa a escala que � o total de d�gitos a direita do ponto decimal
- NUMERIC = DECIMAL
- At� 38 d�gitos de precis�o, temos 17 bytes de armazenamento
- Para valores de at� 10 milh�es e usando duas casas decimais, gastar�amos 5 bytes, sendo um
armazenamento menor que MONEY e permitiria guardar mais valores que o SMALLMONEY

Dados de tamanho Vari�vel:
------------------------------------------------------

VARCHAR(n)
- Aceita n bytes de armazenamento
- O SQL Server utiliza 2 bytes a mais no armazenamento para gravar e recuperar os dados

NVARCHAR(n)
- Aceita n bytes de armazenamento
- O SQL Server utiliza 2 bytes a mais no armazenamento para gravar e recuperar os dados, 
e grava 2 bytes para cada caracter informado

1. C�digos de caracter de 0 a 255 s�o representados com 1 byte
2. C�digos de caracter de 256 a 65554 s�o representados com 2 bytes

Boas pr�ticas:
------------------------------------------------------
1. N�o usar NCHAR ou NVARCHAR(S� quando necess�rio)
2. Utilize INT para chave prim�rio das tabelas
3. Pequenas tabelas para armazenar categorias, grupos ou tipifica��o, verificar a 
possibilidade de usar TINYINT para identifica��o das linhas
4. Utilize BIGINT quando houve real necessidade
5. Utilize VARCHAR somente para colunas com varia��es grandes de dados e com tamanhos grandes
6. Analise o uso de CHAR ou INT para representar n�meros

*/

/*

Design de tabelas:

- Quando uma tabela � criada, deve ser especificado em qual filegroup a mesma ser� criada
- Se n�o informado, a mesma ser� criada no filegroup padr�o, sendo criada na primary

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

-- Filegroup padr�o
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

-- Para avaliar em qual filegroup est� a tabela
SELECT object_name(i.object_id) as [Table], d.name as [FileGroup]
FROM sys.data_spaces d
	INNER JOIN sys.indexes i
	ON d.data_space_id = i.data_space_id
WHERE i.object_id = object_id('tExemplo1')
and i.index_id in (0, 1)

---------------------------------------------------------
No exemplo abaixo, temos 4 tabelas para atender a uma mesma demanda, por�m, 
� poss�vel perceber que o n�mero total de p�ginas de cada tabela e 
tamanho de armazenamento � totalmente diferentes

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
) on DADOS1                                    -- +- 7680 bytes limite m�ximo de aloca��o.
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
   iID           int primary key identity(1,1) ,  -- 4 bytes, incluimos uma PK INT com numera��o autom�tica.
   Codigo        varchar(20),                     -- 20 bytes 
   Titulo        varchar(200),                    -- 200 bytes 
   Descricao     varchar(3500),                   -- 3500 bytes 
   iIDFornecedor int ,                            -- 4 bytes ,considero que os dados de Fornecedor em outra tabela. 
   Preco         money ,                          -- 8 bytes 
   Comissao      numeric(4,2),                    -- 5 bytes, Como a comiss�o � um percentual (99,99)
   ValorComissao money ,                          -- 8 bytes 
   Quantidade    int ,                            -- 4 bytes 
   Frete         money                            -- 8 bytes 
) on DADOS3                                       -- +- 3761 bytes 
go

Create Table tItemModelo04 
(
   iID           smallint primary key identity(1,1), -- 2 bytes , Como a tabela ter� 15.000, smallint 
   Codigo        varchar(20),                        -- 20 bytes 
   Titulo        varchar(200),                       -- 200 bytes 
   Descricao     varchar(3500),                      -- 3500 bytes 
   iIDFornecedor smallint ,                          -- 2 bytes, no m�ximo 5000 fornecedores 
   Preco         smallmoney ,                        -- 4 bytes Preco com valor m�ximo de 200 mil.
   Comissao      numeric(4,2),                       -- 5 bytes 
   ValorComissao as (Preco * Comissao/100) ,         -- 0 bytes, em vez de guardar a comiss�o, calculamos. 
   Quantidade    smallint ,                          -- 2 bytes Armazena ate 32.000 quantidade do Item .
   Frete         smallmoney                          -- 4 bytes Frete com valor m�ximo de 200 mil.
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

-- Quando criar uma tabela, preciso cri�-la de maneira que a mesma ocupe
o menor n�mero de p�ginas dentro do banco de dados

*/

/*

Colunas calculadas:

- Uma coluna calculada � utilizada quando realizamos um c�lculo ou montamos
uma express�o e associamos a uma coluna
- O dado retornado por essa coluna � calculado no momento em que o mesmo 
for solicitado, ou seja, o mesmo n�o ser� persistido em disco, enquanto n�o for
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

-- Recurso do SQL Server para compactar dados pelas linhas ou p�gina de dados

-- A compacta��o tem como objetivo reduzir o espa�o alocado pelo banco de 
dados em disco, como aumentar a performance de acesso aos dados, 
visto que com a compacta��o, � poss�vel alocar mais bytes em uma p�gina de 
dados

-- Pode ser aplicada em uma tabela sem indices(heap table), com �ndices
agrupados (clusterizado)

-- N�o � toda tabela que pode ser compactada ou que realmente teremos 
ganho de armazenamento ou performance

----------------------------------------------------------------------

-- Retorna o espa�o utilizado por uma tabela

sp_spaceused 'NomeTabela'
	- size_with_current_compression_setting(KB) -> Tamanho atual
	- size_with_requested_compression_setting(KB) -> Tamanho estimado com compress�o

-- Retorna o total de p�ginas e se h� alguma compress�o realizada

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('NomeTabela')
	  and au.type = 1
go

----------------------------------------------------------------------

Sobre o page compression

O PAGE compression � uma t�cnica que reduz redund�ncias dentro da mesma p�gina de 
dados (8 KB). O SQL Server faz isso em tr�s etapas sucessivas:

1. Row compression (primeira etapa)
- Remove bytes desnecess�rios, como zeros, espa�os fixos, etc.
- Exemplo: um INT com valor 1 passa a ocupar apenas 1 byte (em vez de 4).

2. Prefix compression
- Identifica prefixos comuns em v�rias colunas ou linhas e armazena o prefixo 
uma �nica vez.

3. Dictionary compression
- Cria um dicion�rio de valores repetidos dentro da p�gina (8KB) e substitui 
as repeti��es por refer�ncias curtas.
- Exemplo, se v�rias linhas cont�m o valor �SP�, o SQL Server o guarda uma vez e 
substitui as ocorr�ncias por um ponteiro.

Vantagens:

1. Grande economia de espa�o

- Pode reduzir o tamanho da tabela ou �ndice em 50% a 80%, dependendo da redund�ncia 
dos dados.

2. Menos I/O (entrada e sa�da)

- Como h� menos bytes a serem lidos e gravados, consultas podem ser mais r�pidas, 
especialmente em leituras intensivas.

3. Melhor uso de cache e mem�ria

- Mais dados cabem no buffer pool, reduzindo leituras em disco.

Desvantagens:

1. Maior uso de CPU

- Cada leitura e escrita exige compress�o e descompress�o em tempo real, 
o que pode afetar sistemas de alta taxa de atualiza��o (INSERT, UPDATE, DELETE).

2. Melhor para dados �est�ticos�

- Ideal para tabelas hist�ricas, de logs, fatos (DW) ou com baixo volume de updates.
- N�o indicado para tabelas com muitos UPDATEs em colunas comprimidas.

----------------------------------------------------------------------

Como aplicar page compression:

ALTER TABLE dbo.NomeTabela
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);

Antes de aplicar, sempre � bom medir o ganho esperado. Para isso, podemos usar
uma procedure pr�pria do SQL Server:

EXEC sp_estimate_data_compression_savings 
    'dbo',              -- Schema
    'Tabela',           -- Tabela
    NULL,               -- �ndice espec�fico ou NULL para todos
    NULL,               -- Parti��o espec�fica ou NULL
    'PAGE';             -- Tipo de compress�o

----------------------------------------------------------------------

Entendendo o I/O no contexto da compress�o

1. Durante a leitura

- Cada p�gina no SQL Server tem 8 KB.
- Quando aplicamos PAGE compression, o SQL Server armazena mais linhas 
dentro da mesma p�gina.
- Isso significa que uma leitura de 8 KB cont�m mais dados �teis.

Resultado:

- Menos p�ginas precisam ser lidas do disco.
- Menos opera��es f�sicas de I/O.
- O buffer pool (cache em mem�ria) consegue armazenar mais linhas por p�gina.

Exemplo:
Se uma tabela ocupa 100 GB antes da compress�o e 40 GB depois, 
qualquer consulta que antes lia 10.000 p�ginas agora pode ler 
apenas 4.000 � menos I/O direto.

2. Durante a escrita

Cada vez que ocorre um INSERT, UPDATE ou DELETE:

- O SQL Server precisa comprimir ou descomprimir a p�gina 
(se estiver em PAGE compression).
- Isso gera trabalho adicional de CPU.

- Opera��es de escrita (principalmente UPDATE) podem exigir mais CPU e 
mais regrava��es de p�ginas.

| Tipo de opera��o     | Efeito no I/O             | Efeito na CPU| Observa��o                             |
| -------------------- | --------------------------| -------------| -------------------------------------- |
|   SELECT (leitura)   | Reduzido                  | Leve aumento | Geralmente positivo                    |
|   INSERT             | Pode aumentar             | M�dio        | Compress�o precisa ser aplicada        |
|   UPDATE             | Pode aumentar bastante    | Alto         | Pode exigir recompacta��o              |
|   DELETE             | Neutro ou ligeiro aumento | Leve         | P�gina pode precisar ser reequilibrada |


*/

