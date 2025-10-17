/* 
============================================================
T�PICO: DADOS DE DATA E HORA
============================================================ */

/*
1. TIPOS DE DADOS DE DATA E HORA

DATETIME       - 8 bytes  - 01/01/1753 at� 31/12/9999, precis�o ~3 milissegundos
SMALLDATETIME  - 4 bytes  - 01/01/1900 at� 06/06/2079, precis�o 1 minuto (n�o armazena segundos)
DATE           - 3 bytes  - 01/01/0001 at� 31/12/9999
TIME(n)        - 3 a 5 bytes - onde n representa a escala em fra��es de segundos
DATETIME2      - 6 a 8 bytes - 01/01/0001 at� 31/12/9999, precis�o em nanossegundos
DATETIMEOFFSET - 8 a 10 bytes - 01/01/1900 at� 31/12/9999, precis�o em nanossegundos e suporte a UTC

- DATETIME e SMALLDATETIME n�o s�o padr�o ANSI
- Se hora n�o for informada, o valor padr�o ser� 00:00:00
- Formato padr�o do SQL Server:
    - Datas completas: 'AAAA-MM-DD HH:MM:SS' ou 'AAAAMMDD HH:MM:SS'
    - Apenas hora: 'HH:MM:SS.NNNNNNN'
*/

-- ============================================================
-- FUN��ES DE DATA E HORA
-- ============================================================

/*
GETDATE()            -> Retorna data e hora atuais no formato DATETIME
CURRENT_TIMESTAMP    -> Padr�o ANSI, equivalente ao GETDATE()
GETUTCDATE()         -> Retorna data e hora atuais em UTC
SYSDATETIME()        -> Retorna data e hora atuais no formato DATETIME2
SYSUTCDATETIME()     -> Retorna data e hora atuais em UTC no formato DATETIME2
SYSDATETIMEOFFSET()  -> Retorna data e hora atuais no formato DATETIMEOFFSET
*/

SELECT 
    GETDATE() AS DataAtual,
    CURRENT_TIMESTAMP AS TimestampAtual,
    GETUTCDATE() AS DataUTC,
    SYSDATETIME() AS DataAltaPrecisao,
    SYSUTCDATETIME() AS DataUTCPrecisao,
    SYSDATETIMEOFFSET() AS DataComFuso;

/* 
============================================================
PARTES DA DATA
============================================================

Parte da Data (English)      Abrevia��es              Descri��o
---------------------------   ----------------------  ------------------------------
ANO (Year)                    yy, yyyy                 Retorna o ano
TRIMESTRE (Quarter)           qq, q                    Retorna o trimestre (1 a 4)
M�S (Month)                   mm, m                    Retorna o m�s (1 a 12)
DIA DO ANO (Day of year)      dy, y                    Retorna o dia dentro do ano (1 a 366)
DIA (Day)                     dd, d                    Retorna o dia do m�s (1 a 31)
SEMANA (Week)                 wk, ww                   Retorna o n�mero da semana no ano
DIA DA SEMANA (Day of week)   dw, w                    Retorna o n�mero do dia da semana (1 = domingo por padr�o)
HORA (Hour)                   hh                        Retorna a hora (0 a 23)
MINUTO (Minute)               mi, n                     Retorna os minutos (0 a 59)
SEGUNDO (Second)              ss, s                     Retorna os segundos (0 a 59)
MILISSEGUNDO (Millisecond)    ms                        Retorna os milissegundos (0 a 999)
MICROSSEGUNDO (Microsecond)   mcs                       Retorna os microssegundos
NANOSSEGUNDO (Nanosecond)     ns                        Retorna os nanossegundos
TZOFFSET (Time zone offset)   tzoffset                  Retorna o deslocamento do fuso hor�rio (datetimeoffset)
*/

-- ============================================================
-- EXEMPLOS DE USO
-- ============================================================

/*
1. DATEADD

- Adiciona ou subtrai um intervalo de tempo a uma data
- Valores positivos -> adiciona
- Valores negativos -> subtrai
- Sintaxe: DATEADD(<parte_da_data>, <quantidade>, <data>)

Exemplos:
*/

SELECT 
    GETDATE() AS Hoje,
    DATEADD(DAY, 7, GETDATE()) AS Daqui_7_Dias,        -- Adiciona 7 dias
    DATEADD(DAY, -7, GETDATE()) AS Ha_7_Dias,          -- Subtrai 7 dias
    DATEADD(MONTH, 1, GETDATE()) AS MesQueVem,         -- Adiciona 1 m�s
    DATEADD(YEAR, -5, GETDATE()) AS CincoAnosAtras;    -- Subtrai 5 anos

/*
2. DATEDIFF

- Retorna a diferen�a entre duas datas em unidades especificadas
- Sintaxe: DATEDIFF(<parte_da_data>, <data_inicial>, <data_final>)
- Observa��o: A ordem importa, resultado ser� positivo se data_final > data_inicial
*/

SELECT 
    GETDATE() AS Hoje,
    DATEDIFF(DAY, '2025-01-01', GETDATE()) AS DiasDesdeJaneiro,
    DATEDIFF(MONTH, '2024-10-01', GETDATE()) AS MesesDesdeOutubro,
    DATEDIFF(YEAR, '2000-10-15', GETDATE()) AS AnosDesde2000;

/*
3. DATEPART

- Retorna o valor num�rico de uma parte espec�fica da data
- Sintaxe: DATEPART(<parte_da_data>, <data>)

Exemplos:
*/

SELECT 
    GETDATE() AS DataAtual,
    DATEPART(YEAR, GETDATE()) AS Ano,
    DATEPART(QUARTER, GETDATE()) AS Trimestre,
    DATEPART(MONTH, GETDATE()) AS Mes,
    DATEPART(DAYOFYEAR, GETDATE()) AS DiaDoAno,
    DATEPART(DAY, GETDATE()) AS Dia,
    DATEPART(WEEK, GETDATE()) AS Semana,
    DATEPART(WEEKDAY, GETDATE()) AS DiaDaSemana,
    DATEPART(HOUR, GETDATE()) AS Hora,
    DATEPART(MINUTE, GETDATE()) AS Minuto,
    DATEPART(SECOND, GETDATE()) AS Segundo,
    DATEPART(MILLISECOND, GETDATE()) AS Milissegundo;

/*
4. DATENAME

- Retorna o valor textual da parte da data (nome do dia da semana, m�s etc.)
- Sintaxe: DATENAME(<parte_da_data>, <data>)
*/

SELECT 
    GETDATE() AS DataAtual,
    DATENAME(WEEKDAY, GETDATE()) AS NomeDiaSemana,
    DATENAME(MONTH, GETDATE()) AS NomeMes;

/*
5. EOMONTH

- Retorna o �ltimo dia do m�s da data informada
- Poss�vel adicionar ou subtrair meses com o segundo par�metro opcional
- Sintaxe: EOMONTH(<data>, [<meses_adicionais>])
*/

SELECT 
    GETDATE() AS Hoje,
    EOMONTH(GETDATE()) AS UltimoDiaMesAtual,
    EOMONTH(GETDATE(), 1) AS UltimoDiaProximoMes,
    EOMONTH(GETDATE(), -1) AS UltimoDiaMesAnterior;
/*
============================================================
CONCLUS�O
============================================================

- Conhecer os tipos de dados de data e hora � essencial para escolher o tipo
  mais adequado ao sistema.
- Fun��es de data e hora permitem extrair, calcular e formatar datas.
- DATEPART e DATENAME s�o �teis para relat�rios, filtros e agrupamentos.
- DATEADD e DATEDIFF auxiliam no c�lculo de intervalos e datas relativas.
- EOMONTH simplifica a obten��o do �ltimo dia do m�s e permite c�lculos relativos a meses
- SYSDATETIMEOFFSET e TZOFFSET ajudam a lidar com fusos hor�rios.
*/

/* 
============================================================
CONVERS�O DE DATA E HORA
============================================================ 
*/

/*
1. CAST e CONVERT

- CAST(expr AS tipo) -> converte uma express�o para outro tipo de dado
- CONVERT(tipo, expr, estilo) -> converte com formata��o opcional (estilo) 
  para data/hora ou strings

Exemplos:
*/

-- Converte uma data para inteiro (ex.: 20251016)
SELECT CAST(GETDATE() AS INT) AS DataInteiro;

-- Converte uma data para decimal (ex.: 20251016.123456)
SELECT CAST(GETDATE() AS DECIMAL(18,6)) AS DataDecimal;

-- Converter TIME para DECIMAL
-- Passo 1: TIME -> DATETIME
-- Passo 2: DATETIME -> DECIMAL
SELECT CAST(CAST(GETDATE() AS DATETIME) AS DECIMAL(18,6)) AS TimeDecimal;

/*
2. ISDATE()

- Verifica se uma express�o � uma data v�lida
- Retorna 1 (verdadeiro) ou 0 (falso)
*/

SELECT ISDATE('2025-10-16') AS EhDataValida;
SELECT ISDATE('texto qualquer') AS EhDataValida;

/* 
============================================================
RECUPERA��O DE DATAS DIN�MICAS
============================================================ 
*/

/*
3. �ltima semana

- Recupera o domingo da semana passada
- Recupera o domingo da semana atual
*/

-- Dia da semana atual
SELECT DATEPART(dw, GETDATE()) AS DiaDaSemana;

-- Domingo da semana passada (corrigido para considerar semana inteira)
SELECT DATEADD(d, -6, DATEADD(d, -DATEPART(dw, GETDATE()), GETDATE())) AS DomingoSemanaPassada;

-- Domingo da semana atual
SELECT DATEADD(d, 1 - DATEPART(dw, GETDATE()), GETDATE()) AS DomingoSemanaAtual;

/*
4. M�s atual

- Recupera in�cio e fim do m�s atual
*/

-- �ltimo dia do m�s
SELECT EOMONTH(GETDATE()) AS UltimoDiaMesAtual;

-- Primeiro dia do m�s
SELECT DATEADD(d, 1, EOMONTH(GETDATE(), -1)) AS PrimeiroDiaMesAtual;

/* 
============================================================
OBSERVA��ES

- CAST � ANSI, CONVERT � T-SQL e possui estilos para formata��o
- DATEPART e DATEADD permitem calcular datas relativas dinamicamente
- ISDATE � �til para validar entradas de usu�rios ou strings de data
- EOMONTH facilita c�lculos com meses
=========================================================== 
*/

