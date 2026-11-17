-- CONSULTAS

USE amazon_marketplace;

-- INNER JOIN: pedidos com nome do cliente.
SELECT
    pedidos.id_pedido,
    usuarios.nome AS cliente,
    pedidos.status,
    pedidos.valor_total
FROM pedidos
INNER JOIN usuarios
    ON pedidos.id_usuario = usuarios.id_usuario
ORDER BY pedidos.data_pedido DESC;

-- LEFT JOIN: produtos e seus estoques, se houver.
SELECT
    produtos.id_produto,
    produtos.nome AS produto,
    COALESCE(estoque.quantidade, 0) AS quantidade
FROM produtos
LEFT JOIN estoque
    ON produtos.id_produto = estoque.id_produto
ORDER BY produtos.nome ASC;

-- RIGHT JOIN: mostra todos os usuários, mesmo sem pedidos.
SELECT
    usuarios.id_usuario,
    usuarios.nome AS cliente,
    COUNT(pedidos.id_pedido) AS total_pedidos
FROM pedidos
RIGHT JOIN usuarios
    ON pedidos.id_usuario = usuarios.id_usuario
GROUP BY usuarios.id_usuario, usuarios.nome
ORDER BY total_pedidos DESC, usuarios.nome ASC;

-- GROUP BY e HAVING: vendas por vendedor, sem contar pedidos cancelados.
SELECT
    vendedores.id_vendedor,
    vendedores.nome_loja,
    COUNT(DISTINCT pedidos.id_pedido) AS total_pedidos,
    SUM(itens_pedido.quantidade) AS unidades_vendidas,
    SUM(itens_pedido.quantidade * itens_pedido.preco_unitario) AS faturamento
FROM vendedores
INNER JOIN produtos
    ON vendedores.id_vendedor = produtos.id_vendedor
INNER JOIN itens_pedido
    ON produtos.id_produto = itens_pedido.id_produto
INNER JOIN pedidos
    ON itens_pedido.id_pedido = pedidos.id_pedido
WHERE pedidos.status <> 'cancelado'
GROUP BY vendedores.id_vendedor, vendedores.nome_loja
HAVING SUM(itens_pedido.quantidade * itens_pedido.preco_unitario) > 0
ORDER BY faturamento DESC;
