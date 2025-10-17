/*
============================================================
JOIN - CONCEITO E ORDEM DE PROCESSAMENTO
============================================================

A ordem de execução lógica de uma consulta SQL é:

1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY

JOIN é um operador de tabela utilizado no FROM para unir dados de duas ou mais tabelas
realizando uma junção.

O operador ON é utilizado para informar quais linhas de cada tabela possuem um relacionamento.

============================================================
TABELAS DE EXEMPLO PARA PRÁTICA DE JOINS
============================================================
*/

-- 1. TABELA CLIENTES
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nome NVARCHAR(50),
    Cidade NVARCHAR(50)
);

INSERT INTO Clientes (ClienteID, Nome, Cidade) VALUES
(1, 'Ana Silva', 'São Paulo'),
(2, 'Bruno Souza', 'Rio de Janeiro'),
(3, 'Carlos Pereira', 'Belo Horizonte'),
(4, 'Daniela Lima', 'Curitiba');

-- 2. TABELA PRODUTOS
CREATE TABLE Produtos (
    ProdutoID INT PRIMARY KEY,
    NomeProduto NVARCHAR(50),
    Categoria NVARCHAR(50),
    Preco DECIMAL(10,2)
);

INSERT INTO Produtos (ProdutoID, NomeProduto, Categoria, Preco) VALUES
(201, 'Notebook', 'Eletrônicos', 2500.00),
(202, 'Mouse', 'Eletrônicos', 80.00),
(203, 'Cadeira', 'Móveis', 350.00),
(204, 'Mesa', 'Móveis', 500.00);

-- 3. TABELA PEDIDOS
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    ClienteID INT,
    DataPedido DATE,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

INSERT INTO Pedidos (PedidoID, ClienteID, DataPedido) VALUES
(101, 1, '2025-10-01'),
(102, 1, '2025-10-10'),
(103, 2, '2025-10-05'),
(104, 3, '2025-10-12');

-- 4. TABELA ITENS DE PEDIDO
CREATE TABLE ItensPedido (
    ItemID INT PRIMARY KEY,
    PedidoID INT,
    ProdutoID INT,
    Quantidade INT,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID)
);

INSERT INTO ItensPedido (ItemID, PedidoID, ProdutoID, Quantidade) VALUES
(1, 101, 201, 1),
(2, 101, 202, 2),
(3, 102, 203, 1),
(4, 103, 202, 3),
(5, 104, 204, 1);

/*
============================================================
Fases de processamento lógico do JOIN
============================================================

CROSS JOIN → Não utiliza ON e retorna o produto cartesiano.

1. FROM
2. CROSS JOIN
3. WHERE
4. GROUP BY
5. HAVING
6. SELECT
7. ORDER BY

INNER JOIN → Utiliza ON e retorna apenas as linhas com correspondência.

1. FROM
2. INNER JOIN → Produto cartesiano
3. ON → Filtra as linhas com correspondência
4. WHERE
5. GROUP BY
6. HAVING
7. SELECT
8. ORDER BY

OUTER JOIN → Utiliza ON e adiciona as linhas sem correspondência.

1. FROM
2. OUTER JOIN → Produto cartesiano
3. ON → Filtro de correspondência
4. <Adição de linhas sem correspondência>
5. WHERE
6. GROUP BY
7. HAVING
8. SELECT
9. ORDER BY
*/

------------------------------------------------------------
-- CROSS JOIN
------------------------------------------------------------
/*
CROSS JOIN:
- Realiza o produto cartesiano entre duas tabelas.
- Cada linha da tabela da esquerda é combinada com todas as linhas da direita.
- A quantidade de linhas resultantes = LinhasTabelaA * LinhasTabelaB.

Sintaxe ANSI-92:
SELECT * FROM Clientes CROSS JOIN Pedidos;

Sintaxe ANSI-89:
SELECT * FROM Clientes, Pedidos;

Quando usar:
- Para gerar combinações entre todos os registros de duas tabelas.
- Usado raramente em produção, mas útil em testes, matrizes de comparação ou combinações.
*/

SELECT c.Nome AS Cliente, p.PedidoID
FROM Clientes c
CROSS JOIN Pedidos p;

------------------------------------------------------------
-- INNER JOIN
------------------------------------------------------------
/*
INNER JOIN (Junção Interna):
- Retorna apenas as linhas que possuem correspondência entre as tabelas.
- Realiza a junção vertical.
- Duas fases:
  1. Produto cartesiano
  2. Filtro das linhas que atendem ao predicado ON.

- INNER JOIN e JOIN são equivalentes.

Quando usar:
- Quando você deseja retornar apenas dados que tenham relação entre ambas as tabelas.
*/

SELECT 
    c.Nome AS Cliente,
    p.PedidoID,
    p.DataPedido
FROM Clientes c
INNER JOIN Pedidos p
    ON c.ClienteID = p.ClienteID;

------------------------------------------------------------
-- COMPOSITE JOIN
------------------------------------------------------------
/*
Composite Join:
- Mantém as características do INNER JOIN.
- Ocorre quando o predicado possui duas ou mais condições (usando AND ou OR).
*/

-- Exemplo (AND)
SELECT * 
FROM Clientes c
JOIN Pedidos p
    ON c.ClienteID = p.ClienteID
   AND p.DataPedido >= '2025-10-01';

------------------------------------------------------------
-- NON-EQUI JOIN
------------------------------------------------------------
/*
Non-Equi Join:
- Junção onde o operador do ON não é de igualdade.
- Utiliza operadores como >, <, BETWEEN, etc.
*/

SELECT 
    c.Nome AS Cliente,
    p.PedidoID,
    p.DataPedido
FROM Clientes c
JOIN Pedidos p
    ON p.DataPedido > '2025-10-05';

------------------------------------------------------------
-- MULTI-TABLE JOIN
------------------------------------------------------------
/*
Multi-table Join:
- Quando é necessário unir três ou mais tabelas.
- O resultado de uma junção é utilizado como entrada para a próxima.

Etapas:
1. Produto cartesiano entre Tabela1 e Tabela2.
2. Filtro entre Tabela1 e Tabela2 (gerando tabela virtual V1).
3. Produto cartesiano entre V1 e Tabela3.
4. Filtro entre V1 e Tabela3.
*/

SELECT 
    c.Nome AS Cliente,
    p.PedidoID,
    pr.NomeProduto,
    i.Quantidade,
    (i.Quantidade * pr.Preco) AS TotalItem
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
JOIN ItensPedido i ON p.PedidoID = i.PedidoID
JOIN Produtos pr ON i.ProdutoID = pr.ProdutoID;

------------------------------------------------------------
-- LEFT JOIN
------------------------------------------------------------
/*
LEFT JOIN ou LEFT OUTER JOIN (Junção Externa à Esquerda):
- Retorna todas as linhas da tabela da esquerda.
- Se não houver correspondência na direita, retorna NULL.
*/

SELECT 
    c.Nome AS Cliente,
    p.PedidoID,
    p.DataPedido
FROM Clientes c
LEFT JOIN Pedidos p
    ON c.ClienteID = p.ClienteID;

------------------------------------------------------------
-- RIGHT JOIN
------------------------------------------------------------
/*
RIGHT JOIN ou RIGHT OUTER JOIN (Junção Externa à Direita):
- Retorna todas as linhas da tabela da direita.
- Se não houver correspondência na esquerda, retorna NULL.
*/

SELECT 
    c.Nome AS Cliente,
    p.PedidoID,
    p.DataPedido
FROM Pedidos p 
RIGHT JOIN Clientes c
    ON c.ClienteID = p.ClienteID;

------------------------------------------------------------
-- FULL JOIN
------------------------------------------------------------
/*
FULL JOIN ou FULL OUTER JOIN (Junção Externa Completa):
- Retorna todas as linhas de ambas as tabelas.
- Onde não há correspondência, aparecem valores NULL.

Quando usar:
- Para identificar registros sem correspondência em ambos os lados.
*/

SELECT 
    c.Nome AS Cliente,
    p.PedidoID,
    p.DataPedido
FROM Clientes c
FULL JOIN Pedidos p
    ON c.ClienteID = p.ClienteID;

------------------------------------------------------------
-- SELF JOIN
------------------------------------------------------------
/*
SELF JOIN:
- Junção de uma tabela com ela mesma.
- Útil para comparar registros dentro da mesma entidade.
*/

SELECT 
    c1.Nome AS Cliente1,
    c2.Nome AS Cliente2,
    c1.Cidade
FROM Clientes c1
JOIN Clientes c2 
    ON c1.Cidade = c2.Cidade
WHERE c1.ClienteID <> c2.ClienteID;

------------------------------------------------------------
/*
Tabelas Virtuais
------------------------------------------------------------

- O resultado intermediário de uma junção (por exemplo, entre Clientes e Pedidos)
pode ser tratado como uma tabela virtual, usada em uma próxima junção.
*/

/* 
===========================================================
CROSS APPLY
===========================================================

- CROSS APPLY é usado para aplicar uma expressão ou subquery a cada linha de uma tabela.
- Ele funciona como um INNER JOIN para tabelas derivadas ou funções.
- Se a expressão não retornar resultados, a linha da tabela da esquerda não aparece.
- Serve para quando você quer calcular algo “linha a linha”.

Quando usar:
- Quando você precisa de dados derivados de cada linha da tabela principal.
- Útil com funções que retornam tabelas (table-valued functions) ou subqueries correlacionadas.

Exemplo:

SELECT 
    *
FROM Pedidos p
CROSS APPLY (
    SELECT TOP 2 i.ProdutoID
    FROM ItensPedido i
    WHERE i.PedidoID = p.PedidoID
    ORDER BY i.ProdutoID DESC
) AS pr;
*/

/* 
===========================================================
OUTER APPLY
===========================================================

- OUTER APPLY é parecido com CROSS APPLY, mas retorna todas as linhas da tabela da esquerda.
- Se a expressão à direita não retornar resultados, os valores virão como NULL.
- Funciona como LEFT JOIN para tabelas derivadas ou funções.

Quando usar:
- Quando você quer manter todas as linhas da tabela principal, mesmo que não haja correspondência na subquery.

Exemplo:

-- Para cada pedido, listar os dois produtos mais caros, incluindo pedidos sem produtos
SELECT 
    p.PedidoID,
    pr.NomeProduto,
    pr.Preco
FROM Pedidos p
OUTER APPLY (
    SELECT TOP 2 i.ProdutoID, i.Preco
    FROM ItensPedido i
    WHERE i.PedidoID = p.PedidoID
    ORDER BY i.Preco DESC
) AS pr;
*/

/* 
===========================================================
UNION
===========================================================

- UNION combina os resultados de duas ou mais consultas SELECT.
- Remove linhas duplicadas automaticamente.
- Cada SELECT deve ter o mesmo número de colunas e tipos compatíveis.

Quando usar:
- Quando você quer juntar resultados de tabelas ou consultas diferentes, mas não quer duplicatas.

Exemplo:

-- Listar todos os nomes de clientes e fornecedores (sem repetição)
SELECT Nome FROM Clientes
UNION
SELECT Nome FROM Fornecedores;
*/

/* 
===========================================================
UNION ALL
===========================================================

- UNION ALL também combina resultados de SELECTs.
- Diferente do UNION, ele **não remove duplicatas**.
- Mais rápido que UNION, porque não precisa fazer checagem de duplicidade.

Quando usar:
- Quando você quer combinar resultados e não se importa com duplicatas.
- Útil para manter contagem exata de registros.

Exemplo:

-- Listar todos os nomes de clientes e fornecedores (mantendo possíveis duplicatas)
SELECT Nome FROM Clientes
UNION ALL
SELECT Nome FROM Fornecedores;
*/
