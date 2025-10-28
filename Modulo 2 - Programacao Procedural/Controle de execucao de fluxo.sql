/*===============================================================
CONTROLE DE EXECU��O DE FLUXO - SQL SERVER
===============================================================*/

/*===============================================================
1. Blocos BEGIN...END
===============================================================*/
/*
- Agrupa v�rias instru��es em um bloco
- Facilita organiza��o e leitura do c�digo
*/
BEGIN
    -- Instru��es aqui
    PRINT 'Exemplo de BEGIN...END';
END

/*===============================================================
2. Desvio condicional: IF...ELSE
===============================================================*/
/*
- Executa blocos de comandos dependendo de uma condi��o
- Para m�ltiplas instru��es, utilize BEGIN...END
*/
IF 1 = 1
BEGIN
    PRINT 'Condi��o verdadeira';
END
ELSE
BEGIN
    PRINT 'Condi��o falsa';
END

/*===============================================================
3. Encerrando o fluxo: RETURN
===============================================================*/
/*
- Encerra a execu��o de uma stored procedure ou batch
- N�o permite continuidade do script
*/
RETURN;

/*===============================================================
4. La�o de repeti��o: WHILE
===============================================================*/
/*
- Executa um bloco repetidamente enquanto a condi��o for verdadeira
- Pode ser usado para inser��es, updates ou deletes em lotes
*/
DROP TABLE IF EXISTS #Numeros;
CREATE TABLE #Numeros (
    Numero INT PRIMARY KEY
);

DECLARE @Contador INT = 0;

WHILE @Contador <= 10
BEGIN
    INSERT INTO #Numeros VALUES (@Contador);
    SET @Contador += 1;
END

SELECT * FROM #Numeros;

/*===============================================================
5. Controle de loop: BREAK e CONTINUE
===============================================================*/
/*
- BREAK: interrompe o loop e sai dele
- CONTINUE: pula a itera��o atual e retorna ao in�cio do loop
*/
DROP TABLE IF EXISTS #Numeros;
CREATE TABLE #Numeros (
    Numero INT PRIMARY KEY
);

DECLARE @Contador2 INT = 0;

WHILE @Contador2 <= 10
BEGIN
    IF @Contador2 = 3
    BEGIN
        SET @Contador2 += 1;
        CONTINUE; -- pula esta itera��o
    END

    IF @Contador2 = 6
        BREAK; -- interrompe o loop

    INSERT INTO #Numeros VALUES (@Contador2);
    SET @Contador2 += 1;
END

SELECT * FROM #Numeros;

/*===============================================================
6. Tratamento de erros: TRY...CATCH
===============================================================*/
/*
- Permite capturar exce��es e tratar erros
- Apenas erros com severidade > 10 s�o capturados
- TRY e CATCH devem estar juntos, sem comandos entre eles
*/
BEGIN TRY
    -- Simula��o de erro: divis�o por zero
    SELECT 1/0;
END TRY
BEGIN CATCH
    IF @@ERROR = 8134
        RAISERROR('Ocorreu um erro de divis�o por zero', 10, 1);
END CATCH;
