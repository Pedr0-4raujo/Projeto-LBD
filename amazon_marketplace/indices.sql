-- ÍNDICE PARA CONSULTAR PEDIDOS DE UM CLIENTE POR DATA

USE amazon_marketplace;

CREATE INDEX idx_pedidos_usuario_data
    ON pedidos (id_usuario, data_pedido);

-- Primeiro filtra pelo cliente e depois ordena os pedidos pela data.
SELECT id_pedido, data_pedido, status
FROM pedidos
WHERE id_usuario = 1
  AND data_pedido >= '2026-01-01'
ORDER BY data_pedido DESC;
