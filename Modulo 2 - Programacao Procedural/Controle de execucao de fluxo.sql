/*===============================================================
CONTROLE DE EXECUÇÃO DE FLUXO - SQL SERVER
===============================================================*/

/*===============================================================
1. Blocos BEGIN...END
===============================================================*/
/*
- Agrupa várias instruções em um bloco
- Facilita organização e leitura do código
*/
BEGIN
    -- Instruções aqui
    PRINT 'Exemplo de BEGIN...END';
END

/*===============================================================
2. Desvio condicional: IF...ELSE
===============================================================*/
/*
- Executa blocos de comandos dependendo de uma condição
- Para múltiplas instruções, utilize BEGIN...END
*/
IF 1 = 1
BEGIN
    PRINT 'Condição verdadeira';
END
ELSE
BEGIN
    PRINT 'Condição falsa';
END

/*===============================================================
3. Encerrando o fluxo: RETURN
===============================================================*/
/*
- Encerra a execução de uma stored procedure ou batch
- Não permite continuidade do script
*/
RETURN;

/*===============================================================
4. Laço de repetição: WHILE
===============================================================*/
/*
- Executa um bloco repetidamente enquanto a condição for verdadeira
- Pode ser usado para inserções, updates ou deletes em lotes
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
- CONTINUE: pula a iteração atual e retorna ao início do loop
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
        CONTINUE; -- pula esta iteração
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
- Permite capturar exceções e tratar erros
- Apenas erros com severidade > 10 são capturados
- TRY e CATCH devem estar juntos, sem comandos entre eles
*/
BEGIN TRY
    -- Simulação de erro: divisão por zero
    SELECT 1/0;
END TRY
BEGIN CATCH
    IF @@ERROR = 8134
        RAISERROR('Ocorreu um erro de divisão por zero', 10, 1);
END CATCH;
