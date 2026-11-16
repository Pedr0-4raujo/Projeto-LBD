-- PERMISSÕES

USE amazon_marketplace;

GRANT SELECT ON amazon_marketplace.* TO 'usuario_leitura'@'localhost';

GRANT SELECT, INSERT, UPDATE ON amazon_marketplace.* TO 'usuario_operador'@'localhost';

GRANT ALL PRIVILEGES ON amazon_marketplace.* TO 'usuario_admin'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'usuario_leitura'@'localhost';
SHOW GRANTS FOR 'usuario_operador'@'localhost';
SHOW GRANTS FOR 'usuario_admin'@'localhost';

REVOKE UPDATE ON amazon_marketplace.* FROM 'usuario_operador'@'localhost';

REVOKE DROP ON amazon_marketplace.* FROM 'usuario_admin'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'usuario_operador'@'localhost';
SHOW GRANTS FOR 'usuario_admin'@'localhost';

DROP USER 'usuario_leitura'@'localhost';

SELECT user, host
FROM mysql.user
WHERE user LIKE 'usuario\_%';
