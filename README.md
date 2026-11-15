# \# Projeto-LBD

# 

# Banco de dados relacional de um marketplace online, inspirado no modelo da Amazon, implementado em MySQL. O repositório reúne o modelo lógico (MySQL Workbench) e o script SQL que cria toda a estrutura.

# 

# \## Arquivos

# 

# | Arquivo | Descrição |

# |---|---|

# | `Modelo\_logico\_amazon.mwb` | Modelo lógico (diagrama EER) do MySQL Workbench |

# | `atividade\_amazon.sql` | Script de criação do banco `amazon\_marketplace` e de todas as tabelas |

# | `README.md` | Documentação do projeto |

# 

# \## Como visualizar o modelo lógico

# 

# 1\. Instalar o \[MySQL Workbench](https://www.mysql.com/products/workbench/).

# 2\. Abrir o Workbench e acessar \*\*File > Open Model...\*\*.

# 3\. Selecionar o arquivo `Modelo\_logico\_amazon.mwb`.

# 4\. Na aba \*\*Model\*\*, dar duplo clique em \*\*EER Diagram\*\* para abrir o diagrama com as tabelas e os relacionamentos.

# 

# \## Como executar o script

# 

# Requisito: MySQL 8.0.16 ou superior (necessário para a aplicação das cláusulas `CHECK`).

# 

# \*\*Pelo MySQL Workbench\*\*

# 

# 1\. Conectar a uma instância local do MySQL.

# 2\. Acessar \*\*File > Open SQL Script...\*\* e selecionar `atividade\_amazon.sql`.

# 3\. Executar o script completo (ícone de raio).

# 

# \*\*Pelo terminal\*\*

# 

# ```bash

# mysql -u root -p < atividade\_amazon.sql

# ```

# 

# > Atenção: o script inicia com `DROP DATABASE IF EXISTS amazon\_marketplace;`. Se o banco já existir, todo o conteúdo será apagado e recriado.

# 

# \## Estrutura do banco

# 

# O banco `amazon\_marketplace` possui 20 tabelas, organizadas em módulos.

# 

# \### Usuários e pagamento

# | Tabela | Função |

# |---|---|

# | `usuarios` | Cadastro dos clientes (e-mail único, senha armazenada como hash) |

# | `enderecos` | Endereços de entrega ou cobrança de cada usuário, com indicação de endereço principal |

# | `dados\_pagamento\_padrao` | Cartão padrão do usuário, guardado como token, com bandeira e últimos 4 dígitos |

# 

# \### Catálogo

# | Tabela | Função |

# |---|---|

# | `vendedores` | Lojas parceiras (CNPJ único e avaliação média de 0 a 5) |

# | `categorias` | Categorias de produtos, com hierarquia por auto-relacionamento (`id\_categoria\_pai`) |

# | `produtos` | Produtos à venda, vinculados a um vendedor e a uma categoria |

# | `detalhes\_tecnicos` | Peso, dimensões e garantia (relação 1:1 com produtos) |

# | `estoque` | Quantidade por produto e depósito, com atualização automática da data |

# | `imagens\_produto` | Imagens de cada produto, com ordem de exibição |

# 

# \### Compra

# | Tabela | Função |

# |---|---|

# | `carrinhos` | Carrinhos dos usuários (`aberto`, `finalizado` ou `abandonado`) |

# | `itens\_carrinho` | Produtos e quantidades de cada carrinho |

# | `cupons` | Cupons de desconto percentual com data de validade |

# | `pedidos` | Pedidos realizados, com status e valor total |

# | `itens\_pedido` | Produtos de cada pedido, com o preço unitário no momento da compra |

# | `pagamentos` | Transação de pagamento de cada pedido (`cartao`, `pix` ou `boleto`) |

# 

# \### Entrega e pós-venda

# | Tabela | Função |

# |---|---|

# | `entregas` | Envios de um pedido, com transportadora e código de rastreio |

# | `entrega\_itens` | Associação entre entregas e itens do pedido (permite envios parciais) |

# | `historico\_rastreio` | Eventos de rastreamento de cada entrega |

# | `avaliacoes` | Notas de 1 a 5 e comentários (uma avaliação por usuário e produto) |

# | `devolucoes` | Solicitações de devolução de itens (`solicitado`, `aprovado` ou `reembolsado`) |

# 

# \## Decisões de modelagem

# 

# \- \*\*Histórico de preço:\*\* `itens\_pedido.preco\_unitario` guarda o valor cobrado na data da compra, sem sofrer alteração caso o preço do produto mude depois.

# \- \*\*Cópia do endereço no pedido:\*\* `pedidos` armazena rua, cidade, estado e CEP, além da referência a `enderecos`. Se o endereço for excluído, a chave `id\_endereco` passa a `NULL` (`ON DELETE SET NULL`) e o pedido mantém o local de entrega.

# \- \*\*Entregas parciais:\*\* a tabela `entrega\_itens` permite dividir um pedido em várias entregas.

# \- \*\*Segurança de dados sensíveis:\*\* senhas em hash (`senha\_hash`) e cartão em token (`cartao\_token`), sem armazenamento de dados em texto puro.

# \- \*\*Integridade:\*\* uso de `CHECK` para valores válidos (status, notas, preços e quantidades) e de `UNIQUE` para evitar duplicidades, como produto repetido no mesmo carrinho.

# 

# \## Estado atual

# 

# O script contém a criação do banco e das tabelas. Inserção de dados, índices, consultas, views, triggers e controle de usuários serão adicionados nas próximas versões.

