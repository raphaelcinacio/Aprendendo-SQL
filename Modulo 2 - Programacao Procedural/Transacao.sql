-- Transa��o

/*

Conceitos e propriedades:

Transa��o:
- Uma �nica l�gica de trabalho.
- Se tudo que est� dentro dessa unidade l�gica de trabalho for feita com sucesso, os dados
ser�o persistidos no banco de forma permanente.
- Se algo ocorrer de errado, a unidade l�gica de trabalho � inv�lida, onde todas as 
modifica��es feitas desde o in�cio do trabalho ser�o desfeitas.

Toda transa��o dever ter as quatro propriedades, conhecidas como ACID:

Atomicidade - A transa��o � indivis�vel(Concluido com sucesso ou desfeito)
Consist�ncia - A transa��o deve manter a consist�ncia dos dados
Isolamento - O que ocorre em uma transa��o n�o interfere em outra
Durabilidade - Uma vez a transa��o confirmada, os dados s�o persistidos e o 
armazenamento � permanente

Log de transa��o

- Um dos arquivos de banco de dados que registra tudo que ocorrer dentro de uma transa��o
- As instru��es s�o gravadas sequencialmente para cada instru��o
- Se precisar realizar algum procedimento de recupera��o, como desfazer uma transa��o ou 
recuperar o banco no processo de restore, o log da transa��o � utilizado

select * from sys.master_files where database_id = DB_ID()

*/

/*

Comandos de transa��o:

BEGIN TRANSACTION
- Marca o in�cio da unidade l�gica de trabalho
- Tudo que � realizado na modifica��o dos dados, � controlado pela transa��o

COMMIT TRANSACTION
- Confirma que a unidade l�gica de trabalho foi conclu�da com sucesso
- Os dados s�o persistidos

ROLLBACK TRANSACTION
- Cancela tudo que foi modificado na unidade l�gica de trabalho, voltando os dados
ao status antes de iniciar a transa��o

Boas pr�ticas:
- Toda vez que for mexer com o banco de dados(update ou delete), abra uma transa��o
- Usar transa��es curtas - Comandos que n�o afetam transa��o(SELECT, declara��o de vari�vel)

*/

/*

Controle da quantidade de transa��es:

@@TRANCOUNT
- Use essa fun��o para controlar se existe transa��es abertas e quantas transa��es atualmente 
est�o abertas na sess�o atual

Dica:
- Antes de realizar um commit ou rollback, verifique se h� transa��es abertas

IF @@TRANCOUNT > 0
	COMMIT

O commit realiza a confirma��o apenas da �ltima transa��o aberta, enquanto o rollback
reverte todas as transa��es de uma vez

*/

/*

Transa��es aninhadas:

SELECT @@TRANCOUNT
BEGIN
	BEGIN TRANSACTION
		BEGIN TRANSACTION
			BEGIN TRANSACTION

			COMMIT
		COMMIT
	COMMIT
END

IF @@TRANCOUNT > 0
	COMMIT

SELECT @@TRANCOUNT

O COMMIT confirma apenas a transa��o a qual ele pertence, enquanto o ROLLBACK desfaz 
todas as transa��es

*/

/*

Bloqueio(Locks):

- Quando uma conex�o bloqueia recursos durante uma transa��o e outras conex�es n�o conseguem
acessar o mesmo recurso.

Como usar o sys.dm_tran_locks

SELECT resource_associated_entity_id, 
	   case when resource_type = 'OBJECT'
		then object_name(resource_associated_entity_id) 
	   end as object, 
	   * 
FROM sys.dm_tran_locks WHERE request_session_id = 59

Bloqueio e recursos:

- O engine do SQL Server decide a melhor forma de realizar um bloqueio
em um recurso. Isso para garantir a efici�ncia da transa��o versus a 
sobrecarga de recursos de hardware e o do SQL Server

Um bloqueio pode ser realizado de diversas formas, que chamamos de 
"Modo de Bloqueio"

Quando � realizado um bloqueio de um recurso qualquer, chamamos esse
bloqueio de exclusivo e � representado pela letra X. A sess�o que realiza
o bloqueio det�m o bloqueio do recurso e outra sess�o n�o pode solicitar
o bloqueio do mesmo recurso.

Quando a opera��o de leitura � realizada, a sess�o tenta obter um 
bloqueio compartilhado representado pela letra S. A sess�o que realiza o bloqueio
det�m o bloqueio do recurso e outra sess�o pode solicitar somente bloqueio compartilhado.

Recursos:

Podemos dizer que os recursos s�o unidades de aloca��o de dados que podem
sofrer algum tipo de bloqueio. Abaixo temos a hierarquia do menor at� o maior

RID -> Utilizado para bloquear uma �nica linha dentro de um heap
KEY -> Bloqueio de linha dentro de um indice usado para proteger um intervalo de chaves 
em transa��es
PAGE -> Uma p�gina de 8 quilobytes(KB) em um banco de dados, com dados ou p�ginas de indice
EXTENT -> Um grupo de 8 p�ginas
HoBT -> Um heap ou �rvore-B. Um bloqueio protegendo uma �rvore-B(�ndice) ou o heap de p�ginas 
de dados
TABLE -> A tabela inteira, inclusive todos os dados e �ndices
FILE -> Um arquivo de banco de dados
APPLICATION -> Um recurso de aplicativo especificado
METADATA -> Bloqueios de metadados
ALLOCATION_UNIT -> Uma unidade de aloca��o
DATABASE -> O banco de dados inteiro

Um bloqueio parte da granularidade menor para a maior. Em alguns casos, pode ocorrer o que
chamamos de inten��o de bloqueio, que pode ser exclusivo(IX) ou compartilhado(IS)

Comando KILL

*/

/*

DEADLOCKS:

- Ocorre quando h� uma depend�ncia c�clica entre duas conex�es
- Os recursos de duas conex�es tem uma depend�ncia entre si. A transa��o A tem 
depend�ncia com a transa��o B e vice-versa

Exemplo

BEGIN TRANSACTION -- Transa��o 1 

UPDATE tCADLivro	-- Recurso 1
SET nPaginas = 617
WHERE iIDLivro = 1

UPDATE tCADCliente	-- Recurso 2
SET mCredito = 1
WHERE iIDCliente = 1

BEGIN TRANSACTION -- Transa��o 2

UPDATE tCADCliente	-- Recurso 1
SET mCredito = 1
WHERE iIDCliente = 1

UPDATE tCADLivro	-- Recurso 2
SET nPaginas = 617
WHERE iIDLivro = 1

Resultado

A Transa��o 1 aguarda a libera��o para realizar o recurso 2, enquanto Transa��o 2 
aguarda a libera��o para realizar o recurso 2. Como h� uma depend�ncia c�clica, uma das
sess�es receber o deadlock, enquanto a outra finaliza

Mensagem de erro

Msg 1205, Level 13, State 51, Line 7
Transaction (Process ID 54) was deadlocked on lock resources with another process 
and has been chosen as the deadlock victim. Rerun the transaction.

Como o SQL Server define qual conex�o receber� o deadlock?
- As conex�es s�o avaliadas e � elegiada a que consumiu menos
recursos para ser a v�tima, pois o custo do rollback ser� menor

Minimizando a ocorr�ncia de deadlock:

1. Criar c�digos com a mesma sequ�ncia l�gica para atender o processo ou uma 
regra de neg�cio
2. Sempre utilizar o mesmo objeto de progra��o para atender um processo,
evitando ter c�digo igual em objetos diferentes
3. Utilize transa��es curtas, com comandos somente de atualiza��o de 
dados

*/

/*

Configura��es de bloqueios e deadlocks:

SET LOCK_TIMEOUT
- Define o tempo de timeout de um bloqueio que a sess�o espera.

SET LOCK_TIMEOUT 5000 -- Define um tempo de 5 segundos
SET LOCK_TIMEOUT 0 -- N�o define tempo para bloqueio
SET LOCK_TIMEOUT -1 -- Espera indefinidamente

Por padr�o, a conex�o espera indefinidamente pela libera��o do bloqueio. A dica
aqui � usar esse comando de forma pontual, onde existe processos com uma grande 
incid�ncia de bloqueios e que a regra de neg�cio permita interromper a transa��o

Com isso, poder�amos recuperar o c�digo de erro e tratar dentro de um TRY-CATCH

SET DEADLOCK_PRIORITY
- Define a prioridade das conex�es durante a fase de resolu��o de um DEADLOCK.
- Quando alteramos a prioridade do dealock, a conex�o que tem a prioridade
maior que as outras n�o ser� eleita a v�tima do deadlock, mesmo que ele tenha 
consumido poucos recursos

-10 -> Prioridade mais baixa
10 -> Prioridade mais alta

NORMAL -> Valor 0(padr�o)
HIGH -> Representa o valor 5 e tem prioridade sobre as conex�es com valor -10 at� 4
LOW -> Tem o valor -5 e ser� eleita v�tima sobre as conex�es com valor -4 at� 10

*/

/*

Utilizando SEQUENCE em transa��o:

A numera��o gerada pelo SEQUENCE � utilizada em um processo de transa��o,
independente se a transa��o foi confirmada ou revertida

Isso significa que, uma vez utilizado o NEXT VALUE FOR, para obter o pr�ximo n�mero, 
ele j� foi recuperado, mesmo que n�o utilize ele

*/