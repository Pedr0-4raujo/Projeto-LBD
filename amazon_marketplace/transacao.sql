-- TRANSAÇÕES: COMMIT e ROLLBACK

USE amazon_marketplace;

-- COMMIT: confirma a reposição de estoque de um produto
START TRANSACTION;

SELECT id_produto, deposito, quantidade AS estoque_antes
FROM estoque
WHERE id_produto = 2;

UPDATE estoque
SET quantidade = quantidade + 50
WHERE id_produto = 2;

COMMIT;

SELECT id_produto, deposito, quantidade AS estoque_depois_do_commit
FROM estoque
WHERE id_produto = 2;

-- ROLLBACK: desfaz uma alteração feita por engano
START TRANSACTION;

UPDATE produtos
SET preco = 0.00
WHERE id_categoria = 9;

SELECT id_produto, nome, preco AS preco_com_erro
FROM produtos
WHERE id_categoria = 9;

ROLLBACK;

SELECT id_produto, nome, preco AS preco_apos_rollback
FROM produtos
WHERE id_categoria = 9;

-- ROLLBACK parcial com SAVEPOINT
START TRANSACTION;

UPDATE cupons
SET percentual_desc = 10.00
WHERE id_cupom = 1;

SAVEPOINT apos_cupom_1;

UPDATE cupons
SET percentual_desc = 99.00
WHERE id_cupom = 2;

-- Desfaz somente a alteração do cupom 2 e mantém a do cupom 1
ROLLBACK TO SAVEPOINT apos_cupom_1;

COMMIT;

SELECT id_cupom, codigo, percentual_desc
FROM cupons
WHERE id_cupom IN (1, 2);
