-- VIEWS

USE amazon_marketplace;

CREATE OR REPLACE VIEW vw_pedidos_detalhados AS
SELECT
    p.id_pedido,
    p.data_pedido,
    u.nome AS cliente,
    u.email,
    p.status,
    p.valor_total,
    c.codigo AS cupom_aplicado,
    c.percentual_desc
FROM pedidos p
INNER JOIN usuarios u ON u.id_usuario = p.id_usuario
LEFT JOIN cupons c ON c.id_cupom = p.id_cupom;

CREATE OR REPLACE VIEW vw_catalogo_estoque AS
SELECT
    pr.id_produto,
    pr.nome AS produto,
    v.nome_loja AS vendedor,
    ca.nome AS categoria,
    pr.preco,
    pr.ativo,
    e.deposito,
    e.quantidade AS quantidade_em_estoque
FROM produtos pr
INNER JOIN vendedores v ON v.id_vendedor = pr.id_vendedor
INNER JOIN categorias ca ON ca.id_categoria = pr.id_categoria
INNER JOIN estoque e ON e.id_produto = pr.id_produto;

CREATE OR REPLACE VIEW vw_vendas_por_vendedor AS
SELECT
    v.id_vendedor,
    v.nome_loja,
    COUNT(DISTINCT ip.id_pedido) AS total_pedidos,
    SUM(ip.quantidade) AS unidades_vendidas,
    SUM(ip.quantidade * ip.preco_unitario) AS faturamento_bruto
FROM vendedores v
INNER JOIN produtos pr ON pr.id_vendedor = v.id_vendedor
INNER JOIN itens_pedido ip ON ip.id_produto = pr.id_produto
INNER JOIN pedidos p ON p.id_pedido = ip.id_pedido
WHERE p.status <> 'cancelado'
GROUP BY v.id_vendedor, v.nome_loja;

-- Exemplos de uso das views
SELECT * FROM vw_pedidos_detalhados
WHERE status = 'entregue' AND cupom_aplicado IS NOT NULL
ORDER BY valor_total DESC;

SELECT produto, vendedor, quantidade_em_estoque
FROM vw_catalogo_estoque
WHERE ativo = TRUE AND quantidade_em_estoque < 100
ORDER BY quantidade_em_estoque;

SELECT nome_loja, total_pedidos, unidades_vendidas, faturamento_bruto
FROM vw_vendas_por_vendedor
ORDER BY faturamento_bruto DESC
LIMIT 10;
