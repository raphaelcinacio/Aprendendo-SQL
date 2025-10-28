-- Transação

/*

Conceitos e propriedades:

Transação:
- Uma única lógica de trabalho.
- Se tudo que está dentro dessa unidade lógica de trabalho for feita com sucesso, os dados
serão persistidos no banco de forma permanente.
- Se algo ocorrer de errado, a unidade lógica de trabalho é inválida, onde todas as 
modificações feitas desde o início do trabalho serão desfeitas.

Toda transação dever ter as quatro propriedades, conhecidas como ACID:

Atomicidade - A transação é indivisível(Concluido com sucesso ou desfeito)
Consistência - A transação deve manter a consistência dos dados
Isolamento - O que ocorre em uma transação não interfere em outra
Durabilidade - Uma vez a transação confirmada, os dados são persistidos e o 
armazenamento é permanente

Log de transação

- Um dos arquivos de banco de dados que registra tudo que ocorrer dentro de uma transação
- As instruções são gravadas sequencialmente para cada instrução
- Se precisar realizar algum procedimento de recuperação, como desfazer uma transação ou 
recuperar o banco no processo de restore, o log da transação é utilizado

select * from sys.master_files where database_id = DB_ID()

*/

/*

Comandos de transação:

BEGIN TRANSACTION
- Marca o início da unidade lógica de trabalho
- Tudo que é realizado na modificação dos dados, é controlado pela transação

COMMIT TRANSACTION
- Confirma que a unidade lógica de trabalho foi concluída com sucesso
- Os dados são persistidos

ROLLBACK TRANSACTION
- Cancela tudo que foi modificado na unidade lógica de trabalho, voltando os dados
ao status antes de iniciar a transação

Boas práticas:
- Toda vez que for mexer com o banco de dados(update ou delete), abra uma transação
- Usar transações curtas - Comandos que não afetam transação(SELECT, declaração de variável)

*/

/*

Controle da quantidade de transações:

@@TRANCOUNT
- Use essa função para controlar se existe transações abertas e quantas transações atualmente 
estão abertas na sessão atual

Dica:
- Antes de realizar um commit ou rollback, verifique se há transações abertas

IF @@TRANCOUNT > 0
	COMMIT

O commit realiza a confirmação apenas da última transação aberta, enquanto o rollback
reverte todas as transações de uma vez

*/

/*

Transações aninhadas:

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

O COMMIT confirma apenas a transação a qual ele pertence, enquanto o ROLLBACK desfaz 
todas as transações

*/

/*

Bloqueio(Locks):

- Quando uma conexão bloqueia recursos durante uma transação e outras conexões não conseguem
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
em um recurso. Isso para garantir a eficiência da transação versus a 
sobrecarga de recursos de hardware e o do SQL Server

Um bloqueio pode ser realizado de diversas formas, que chamamos de 
"Modo de Bloqueio"

Quando é realizado um bloqueio de um recurso qualquer, chamamos esse
bloqueio de exclusivo e é representado pela letra X. A sessão que realiza
o bloqueio detêm o bloqueio do recurso e outra sessão não pode solicitar
o bloqueio do mesmo recurso.

Quando a operação de leitura é realizada, a sessão tenta obter um 
bloqueio compartilhado representado pela letra S. A sessão que realiza o bloqueio
detêm o bloqueio do recurso e outra sessão pode solicitar somente bloqueio compartilhado.

Recursos:

Podemos dizer que os recursos são unidades de alocação de dados que podem
sofrer algum tipo de bloqueio. Abaixo temos a hierarquia do menor até o maior

RID -> Utilizado para bloquear uma única linha dentro de um heap
KEY -> Bloqueio de linha dentro de um indice usado para proteger um intervalo de chaves 
em transações
PAGE -> Uma página de 8 quilobytes(KB) em um banco de dados, com dados ou páginas de indice
EXTENT -> Um grupo de 8 páginas
HoBT -> Um heap ou árvore-B. Um bloqueio protegendo uma árvore-B(índice) ou o heap de páginas 
de dados
TABLE -> A tabela inteira, inclusive todos os dados e índices
FILE -> Um arquivo de banco de dados
APPLICATION -> Um recurso de aplicativo especificado
METADATA -> Bloqueios de metadados
ALLOCATION_UNIT -> Uma unidade de alocação
DATABASE -> O banco de dados inteiro

Um bloqueio parte da granularidade menor para a maior. Em alguns casos, pode ocorrer o que
chamamos de intenção de bloqueio, que pode ser exclusivo(IX) ou compartilhado(IS)

Comando KILL

*/

/*

DEADLOCKS:

- Ocorre quando há uma dependência cíclica entre duas conexões
- Os recursos de duas conexões tem uma dependência entre si. A transação A tem 
dependência com a transação B e vice-versa

Exemplo

BEGIN TRANSACTION -- Transação 1 

UPDATE tCADLivro	-- Recurso 1
SET nPaginas = 617
WHERE iIDLivro = 1

UPDATE tCADCliente	-- Recurso 2
SET mCredito = 1
WHERE iIDCliente = 1

BEGIN TRANSACTION -- Transação 2

UPDATE tCADCliente	-- Recurso 1
SET mCredito = 1
WHERE iIDCliente = 1

UPDATE tCADLivro	-- Recurso 2
SET nPaginas = 617
WHERE iIDLivro = 1

Resultado

A Transação 1 aguarda a liberação para realizar o recurso 2, enquanto Transação 2 
aguarda a liberação para realizar o recurso 2. Como há uma dependência cíclica, uma das
sessões receber o deadlock, enquanto a outra finaliza

Mensagem de erro

Msg 1205, Level 13, State 51, Line 7
Transaction (Process ID 54) was deadlocked on lock resources with another process 
and has been chosen as the deadlock victim. Rerun the transaction.

Como o SQL Server define qual conexão receberá o deadlock?
- As conexões são avaliadas e é elegiada a que consumiu menos
recursos para ser a vítima, pois o custo do rollback será menor

Minimizando a ocorrência de deadlock:

1. Criar códigos com a mesma sequência lógica para atender o processo ou uma 
regra de negócio
2. Sempre utilizar o mesmo objeto de progração para atender um processo,
evitando ter código igual em objetos diferentes
3. Utilize transações curtas, com comandos somente de atualização de 
dados

*/

/*

Configurações de bloqueios e deadlocks:

SET LOCK_TIMEOUT
- Define o tempo de timeout de um bloqueio que a sessão espera.

SET LOCK_TIMEOUT 5000 -- Define um tempo de 5 segundos
SET LOCK_TIMEOUT 0 -- Não define tempo para bloqueio
SET LOCK_TIMEOUT -1 -- Espera indefinidamente

Por padrão, a conexão espera indefinidamente pela liberação do bloqueio. A dica
aqui é usar esse comando de forma pontual, onde existe processos com uma grande 
incidência de bloqueios e que a regra de negócio permita interromper a transação

Com isso, poderíamos recuperar o código de erro e tratar dentro de um TRY-CATCH

SET DEADLOCK_PRIORITY
- Define a prioridade das conexões durante a fase de resolução de um DEADLOCK.
- Quando alteramos a prioridade do dealock, a conexão que tem a prioridade
maior que as outras não será eleita a vítima do deadlock, mesmo que ele tenha 
consumido poucos recursos

-10 -> Prioridade mais baixa
10 -> Prioridade mais alta

NORMAL -> Valor 0(padrão)
HIGH -> Representa o valor 5 e tem prioridade sobre as conexões com valor -10 até 4
LOW -> Tem o valor -5 e será eleita vítima sobre as conexões com valor -4 até 10

*/

/*

Utilizando SEQUENCE em transação:

A numeração gerada pelo SEQUENCE é utilizada em um processo de transação,
independente se a transação foi confirmada ou revertida

Isso significa que, uma vez utilizado o NEXT VALUE FOR, para obter o próximo número, 
ele já foi recuperado, mesmo que não utilize ele

*/