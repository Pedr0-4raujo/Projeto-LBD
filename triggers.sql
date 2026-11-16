-- TRIGGERS (2): um BEFORE e um AFTER

USE amazon_marketplace;

-- TRIGGERS: um BEFORE e um AFTER

DROP TRIGGER IF EXISTS trg_before_insert_itens_pedido;
DROP TRIGGER IF EXISTS trg_after_insert_itens_pedido;

DELIMITER $$

-- Trigger BEFORE INSERT
CREATE TRIGGER trg_before_insert_itens_pedido
BEFORE INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    DECLARE v_ativo BOOLEAN;
    DECLARE v_maior_estoque INT;

    SELECT ativo INTO v_ativo
    FROM produtos
    WHERE id_produto = NEW.id_produto;

    IF v_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto inativo: nao pode ser adicionado ao pedido';
    END IF;

    SELECT COALESCE(MAX(quantidade), 0) INTO v_maior_estoque
    FROM estoque
    WHERE id_produto = NEW.id_produto;

    IF v_maior_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente para a quantidade solicitada';
    END IF;
END$$

-- Trigger AFTER INSERT
CREATE TRIGGER trg_after_insert_itens_pedido
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE estoque
    SET quantidade = quantidade - NEW.quantidade
    WHERE id_produto = NEW.id_produto
      AND quantidade >= NEW.quantidade
    ORDER BY quantidade DESC
    LIMIT 1;
END$$

DELIMITER ;

-- Teste dos triggers dentro de uma transação (ROLLBACK desfaz tudo ao final)
START TRANSACTION;

SELECT id_produto, deposito, quantidade AS estoque_antes
FROM estoque
WHERE id_produto = 1;

INSERT INTO pedidos (id_usuario, id_endereco, id_cupom, status, valor_total,
                     endereco_rua, endereco_cidade, endereco_estado, endereco_cep)
SELECT 1, id_endereco, NULL, 'processando', 2999.80, rua, cidade, estado, cep
FROM enderecos
WHERE id_endereco = 1;

SET @pedido_teste = LAST_INSERT_ID();

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
VALUES (@pedido_teste, 1, 2, 1499.90);

SELECT id_produto, deposito, quantidade AS estoque_depois
FROM estoque
WHERE id_produto = 1;

ROLLBACK;