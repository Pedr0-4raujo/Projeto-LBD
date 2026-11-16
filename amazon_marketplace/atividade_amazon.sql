DROP DATABASE IF EXISTS amazon_marketplace;
CREATE DATABASE amazon_marketplace;
USE amazon_marketplace;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE enderecos (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    rua VARCHAR(150) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    principal BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    CHECK (tipo IN ('entrega', 'cobranca'))
);

CREATE TABLE dados_pagamento_padrao (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    cartao_token VARCHAR(255) NOT NULL,
    bandeira VARCHAR(20) NOT NULL,
    final_cartao CHAR(4) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

CREATE TABLE vendedores (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nome_loja VARCHAR(150) NOT NULL,
    cnpj VARCHAR(20) NOT NULL UNIQUE,
    avaliacao_media DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    data_ativacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (avaliacao_media BETWEEN 0 AND 5)
);

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    id_categoria_pai INT NULL,
    FOREIGN KEY (id_categoria_pai) REFERENCES categorias(id_categoria)
);

CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_vendedor INT NOT NULL,
    id_categoria INT NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    CHECK (preco >= 0)
);

CREATE TABLE detalhes_tecnicos (
    id_detalhe INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL UNIQUE,
    peso_kg DECIMAL(5,2),
    dimensoes VARCHAR(50),
    garantia_meses INT DEFAULT 0,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    CHECK (peso_kg IS NULL OR peso_kg >= 0),
    CHECK (garantia_meses >= 0)
);

CREATE TABLE estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    deposito VARCHAR(50) NOT NULL,
    data_ultima_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    UNIQUE (id_produto, deposito),
    CHECK (quantidade >= 0)
);

CREATE TABLE imagens_produto (
    id_imagem INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    url VARCHAR(255) NOT NULL,
    ordem INT NOT NULL DEFAULT 1,
    formato VARCHAR(10) NOT NULL DEFAULT 'jpg',
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    UNIQUE (id_produto, ordem),
    CHECK (ordem > 0)
);

CREATE TABLE carrinhos (
    id_carrinho INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    data_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_origem VARCHAR(45),
    status VARCHAR(20) NOT NULL DEFAULT 'aberto',
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    CHECK (status IN ('aberto', 'finalizado', 'abandonado'))
);

CREATE TABLE itens_carrinho (
    id_item_carrinho INT AUTO_INCREMENT PRIMARY KEY,
    id_carrinho INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (id_carrinho) REFERENCES carrinhos(id_carrinho),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    UNIQUE (id_carrinho, id_produto),
    CHECK (quantidade > 0)
);

CREATE TABLE cupons (
    id_cupom INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    percentual_desc DECIMAL(5,2) NOT NULL,
    validade DATETIME NOT NULL,
    CHECK (percentual_desc BETWEEN 0 AND 100)
);

CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_endereco INT NULL,
    id_cupom INT NULL,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'processando',
    valor_total DECIMAL(10,2) NOT NULL,
    endereco_rua VARCHAR(150) NOT NULL,
    endereco_cidade VARCHAR(100) NOT NULL,
    endereco_estado CHAR(2) NOT NULL,
    endereco_cep VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_endereco) REFERENCES enderecos(id_endereco) ON DELETE SET NULL,
    FOREIGN KEY (id_cupom) REFERENCES cupons(id_cupom),
    CHECK (valor_total >= 0),
    CHECK (status IN ('processando', 'pago', 'enviado', 'entregue', 'cancelado'))
);

CREATE TABLE itens_pedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    UNIQUE (id_pedido, id_produto),
    CHECK (quantidade > 0),
    CHECK (preco_unitario >= 0)
);

CREATE TABLE pagamentos (
    id_pagamento_transacao INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    id_pagamento_padrao INT NULL,
    metodo VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento DATETIME,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_pagamento_padrao) REFERENCES dados_pagamento_padrao(id_pagamento),
    CHECK (metodo IN ('cartao', 'pix', 'boleto')),
    CHECK (valor_pago >= 0),
    CHECK (status IN ('aprovado', 'recusado', 'estornado'))
);

CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    transportadora VARCHAR(100),
    codigo_rastreio VARCHAR(50) UNIQUE,
    data_envio DATETIME,
    data_prevista DATETIME,
    data_entregue DATETIME,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

CREATE TABLE entrega_itens (
    id_entrega_item INT AUTO_INCREMENT PRIMARY KEY,
    id_entrega INT NOT NULL,
    id_item INT NOT NULL,
    FOREIGN KEY (id_entrega) REFERENCES entregas(id_entrega),
    FOREIGN KEY (id_item) REFERENCES itens_pedido(id_item),
    UNIQUE (id_entrega, id_item)
);

CREATE TABLE historico_rastreio (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_entrega INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    local VARCHAR(100),
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_entrega) REFERENCES entregas(id_entrega)
);

CREATE TABLE avaliacoes (
    id_avaliacao INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    id_usuario INT NOT NULL,
    nota TINYINT NOT NULL,
    comentario TEXT,
    data DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    UNIQUE (id_produto, id_usuario),
    CHECK (nota BETWEEN 1 AND 5)
);

CREATE TABLE devolucoes (
    id_devolucao INT AUTO_INCREMENT PRIMARY KEY,
    id_item INT NOT NULL,
    quantidade_devolvida INT NOT NULL,
    motivo VARCHAR(200) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'solicitado',
    data_solicitacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_item) REFERENCES itens_pedido(id_item),
    CHECK (status IN ('solicitado', 'aprovado', 'reembolsado')),
    CHECK (quantidade_devolvida > 0)
);