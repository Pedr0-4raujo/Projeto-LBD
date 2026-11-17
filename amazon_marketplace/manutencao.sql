-- EXEMPLOS DE MANUTENÇÃO

USE amazon_marketplace;

-- ALTER: aumenta o espaço disponível para o código do cupom.
ALTER TABLE cupons
MODIFY COLUMN codigo VARCHAR(40) NOT NULL;

-- UPDATE: muda o preço do produto 1.
SELECT id_produto, nome, preco
FROM produtos
WHERE id_produto = 1;

START TRANSACTION;
UPDATE produtos
SET preco = 1500.00
WHERE id_produto = 1;
SELECT id_produto, nome, preco
FROM produtos
WHERE id_produto = 1;
ROLLBACK;

-- DELETE: apaga o item 1 do carrinho.
SELECT id_item_carrinho, id_carrinho, id_produto
FROM itens_carrinho
WHERE id_item_carrinho = 1;

START TRANSACTION;
DELETE FROM itens_carrinho
WHERE id_item_carrinho = 1;
SELECT id_item_carrinho, id_carrinho, id_produto
FROM itens_carrinho
WHERE id_item_carrinho = 1;
ROLLBACK;

-- DROP: tabela temporária usada apenas neste exemplo.
DROP TEMPORARY TABLE IF EXISTS tabela_exemplo;
CREATE TEMPORARY TABLE tabela_exemplo (
    id INT
);
DROP TEMPORARY TABLE tabela_exemplo;
