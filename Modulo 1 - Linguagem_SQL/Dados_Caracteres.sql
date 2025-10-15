/* 
============================================================
TÓPICO: DADOS DE CARACTERES NO SQL SERVER
============================================================ */

/*
    CHAR vs VARCHAR
    ------------------------------------------------------------
    - Ambos armazenam texto, mas diferem na forma como utilizam espaço.
    - O SQL Server mede o tamanho em bytes, e cada caractere usa 1 byte.
*/

/*
    CHAR:
    - Tamanho fixo: o SQL Server reserva o espaço total definido, mesmo
      que nem todos os caracteres sejam usados.
    - Exemplo: CHAR(10) sempre ocupa 10 bytes, mesmo que o texto tenha 4 letras.
    - Indicado para dados de tamanho fixo, como CEP, UF, códigos de produto etc.
*/

CREATE TABLE Exemplo_Char (
    Codigo CHAR(10)
);

INSERT INTO Exemplo_Char VALUES ('ABC');
SELECT Codigo, 
       LEN(Codigo) AS Tamanho_Len,   -- LEN ignora espaços em branco à direita
       DATALENGTH(Codigo) AS Tamanho_Bytes -- DATALENGTH mostra bytes reais ocupados
FROM Exemplo_Char;

/*
    VARCHAR:
    - Tamanho variável: armazena apenas o número de bytes usados.
    - Mais econômico para dados de tamanho variável (ex: nomes, e-mails).
    - Há um pequeno custo adicional ao expandir ou reduzir o tamanho na gravação.
*/

CREATE TABLE Exemplo_Varchar (
    Nome VARCHAR(50)
);

INSERT INTO Exemplo_Varchar VALUES ('Raphael');
SELECT Nome,
       LEN(Nome) AS Tamanho_Len,
       DATALENGTH(Nome) AS Tamanho_Bytes
FROM Exemplo_Varchar;

/*
    Comparando CHAR x VARCHAR:
    - CHAR é mais rápido na gravação (espaço fixo).
    - VARCHAR é mais eficiente na leitura e ocupa menos espaço em disco.
    - Ambos têm limite de 8000 bytes por coluna (sem o MAX).
    - VARCHAR(MAX) pode armazenar até 2 GB de texto.
*/

DECLARE @Descricao VARCHAR(MAX);
SET @Descricao = REPLICATE('A', 10000);
SELECT LEN(@Descricao) AS Tamanho_Descricao;

/*
    Observação importante:
    - A soma de todas as colunas de uma linha não pode ultrapassar 8060 bytes.
    - Mesmo que uma coluna individual possa ter até 8000 bytes.
*/

/* 
============================================================
DADOS UNICODE x REGULAR
============================================================ */

/*
    REGULAR:
    - Usa 1 byte por caractere (tipos: CHAR, VARCHAR).
    - Armazena apenas caracteres compatíveis com o collation atual (ex: LATIN1).
    - Não suporta todos os caracteres acentuados ou internacionais.
*/

DECLARE @TextoRegular VARCHAR(10) = 'Olá';
SELECT @TextoRegular AS TextoRegular,
       DATALENGTH(@TextoRegular) AS Bytes_Usados; -- 3 bytes (1 por letra)

/*
    UNICODE:
    - Usa 2 bytes por caractere (tipos: NCHAR, NVARCHAR).
    - Representa até 65.536 caracteres diferentes (suporta qualquer idioma).
    - Indicado para sistemas multilíngues ou que armazenam caracteres especiais.
*/

DECLARE @TextoUnicode NVARCHAR(10) = N'Olá';
SELECT @TextoUnicode AS TextoUnicode,
       DATALENGTH(@TextoUnicode) AS Bytes_Usados; -- 6 bytes (2 por letra)

/*
    Diferença prática:
    - Sempre que usar UNICODE, prefixe a string com "N".
    - Exemplo: N'ʐʒʒ' — sem o N, o SQL Server pode perder ou converter incorretamente.
*/

SELECT N'ʐʒʒ' AS Caracteres_Unicode;


/* 
============================================================
OPERADOR LIKE
============================================================ */

/*
    LIKE:
    - Usado para realizar buscas com padrões (textos parciais).
    - Pode conter curingas (% e _).
    - Padrões:
        'A%'   → começa com A
        '%A'   → termina com A
        '%A%'  → contém A
        '_A_'  → A no meio de uma palavra de 3 letras
        '[A-Z]' → qualquer letra entre A e Z
        '[^A]'  → qualquer letra diferente de A
*/

CREATE TABLE Clientes (
    Id INT IDENTITY,
    Nome VARCHAR(100),
    Telefone VARCHAR(20)
);

INSERT INTO Clientes (Nome, Telefone)
VALUES 
('Raphael', '(11)99999-8888'),
('Maria', '(21)98888-7777'),
('Carlos', '(11)97777-6666'),
('Julia', '(41)92222-3333');

-- Exemplo 1: começa com 'R'
SELECT * FROM Clientes WHERE Nome LIKE 'R%';

-- Exemplo 2: termina com 'a'
SELECT * FROM Clientes WHERE Nome LIKE '%a';

-- Exemplo 3: contém 'ar'
SELECT * FROM Clientes WHERE Nome LIKE '%ar%';

-- Exemplo 4: um único caractere substituto
SELECT * FROM Clientes WHERE Nome LIKE 'J_li_'; -- Julia se encaixa

-- Exemplo 5: faixa de caracteres
SELECT * FROM Clientes WHERE Nome LIKE '[A-C]%'; -- Nomes começando com A, B ou C

-- Exemplo 6: negando o padrão
SELECT * FROM Clientes WHERE Nome LIKE '[^R]%'; -- Todos que NÃO começam com R

-- Exemplo 7: usando colchetes para números
SELECT * FROM Clientes WHERE Telefone LIKE '([0-9][0-9])%';


/* 
============================================================
CONCATENAÇÃO E FUNÇÕES DE CARACTER
============================================================ */

/*
    As funções abaixo são muito úteis para manipular texto.
    Elas ajudam em formatações, buscas, remoção de espaços, etc.
*/

-- CONCAT: une valores, mesmo nulos
SELECT CONCAT(Nome, ' - Tel: ', Telefone) AS ContatoCompleto FROM Clientes;

-- UPPER / LOWER: converte para maiúsculo/minúsculo
SELECT Nome, UPPER(Nome) AS Maiusculo, LOWER(Nome) AS Minusculo FROM Clientes;

-- COALESCE: retorna o primeiro valor não nulo
SELECT COALESCE(NULL, NULL, 'Primeiro Valor Não Nulo') AS Resultado;

-- SUBSTRING / LEFT / RIGHT: extrai partes do texto
SELECT Nome,
       SUBSTRING(Nome, 1, 3) AS Primeiros_3,
       LEFT(Nome, 2) AS Esquerda,
       RIGHT(Nome, 2) AS Direita
FROM Clientes;

-- TRIM / LTRIM / RTRIM: remove espaços
DECLARE @TextoEspacado VARCHAR(20) = '   Teste   ';
SELECT 
    '[' + @TextoEspacado + ']' AS Original,
    '[' + TRIM(@TextoEspacado) + ']' AS Trimado,
    '[' + LTRIM(@TextoEspacado) + ']' AS Sem_Espaco_Esquerda,
    '[' + RTRIM(@TextoEspacado) + ']' AS Sem_Espaco_Direita;

-- LEN x DATALENGTH:
-- LEN → conta caracteres (sem espaços à direita)
-- DATALENGTH → conta bytes (inclui espaços e depende do tipo de dado)
SELECT LEN('Olá ') AS TamanhoLEN, DATALENGTH('Olá ') AS TamanhoBytes;

-- CHARINDEX: encontra posição de um texto dentro de outro
SELECT CHARINDEX('p', 'Raphael') AS Posicao_P;

-- REPLACE: substitui partes de uma string
SELECT REPLACE('Raphael Inacio', 'Inacio', 'Coutinho') AS Substituido;

-- REPLICATE: repete um texto várias vezes
SELECT REPLICATE('SQL ', 3) AS Repeticao;

-- STUFF: substitui parte de uma string por outra
SELECT STUFF('Raphael', 2, 3, 'XXX') AS Resultado;

-- CAST / CONVERT: converte tipos de dados (numéricos, datas, textos)
SELECT CAST(123 AS VARCHAR(10)) AS Convertido,
       CONVERT(VARCHAR(10), 123) AS Convertido2;


/* 
============================================================
LIMPEZA
============================================================ */

-- DROP TABLE Exemplo_Char;
-- DROP TABLE Exemplo_Varchar;
-- DROP TABLE Clientes;
