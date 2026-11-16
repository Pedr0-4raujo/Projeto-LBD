-- USUÁRIOS

USE amazon_marketplace;

-- Garante que o bloco possa ser executado mais de uma vez
DROP USER IF EXISTS 'usuario_leitura'@'localhost';
DROP USER IF EXISTS 'usuario_operador'@'localhost';
DROP USER IF EXISTS 'usuario_admin'@'localhost';

-- Criação de três usuários
CREATE USER 'usuario_leitura'@'localhost' IDENTIFIED BY 'Leitura@2026';
CREATE USER 'usuario_operador'@'localhost' IDENTIFIED BY 'Operador@2026';
CREATE USER 'usuario_admin'@'localhost' IDENTIFIED BY 'Admin@2026';