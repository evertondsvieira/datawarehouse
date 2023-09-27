DROP DATABASE ADS;

CREATE DATABASE ADS;

USE ADS;

DROP TABLE tb010_clientes_antigos;

DROP TABLE tb016_prd_vestuarios;

DROP TABLE tb011_logins;

DROP TABLE tb015_prd_eletros;

DROP TABLE tb014_prd_alimentos;

DROP TABLE tb005_006_funcionarios_cargos;

DROP TABLE tb006_cargos;

DROP TABLE tb010_012_vendas;

DROP TABLE tb010_clientes;

DROP TABLE tb005_funcionarios;

DROP TABLE tb004_lojas;

DROP TABLE tb999_log;

DROP TABLE tb012_017_compras;

DROP TABLE tb017_fornecedores;

DROP TABLE tb003_enderecos;

DROP TABLE tb002_cidades;

DROP TABLE tb001_uf;

DROP TABLE tb012_produtos;

DROP TABLE tb013_categorias;

CREATE TABLE tb001_uf (
  tb001_sigla_uf VARCHAR(2) NOT NULL,
  tb001_nome_estado VARCHAR(255) NOT NULL,
  CONSTRAINT XPKtb001_uf PRIMARY KEY (tb001_sigla_uf)
);

ALTER TABLE
  tb001_uf
ADD
  CONSTRAINT XPKtb001_uf PRIMARY KEY (tb001_sigla_uf);

CREATE TABLE tb002_cidades (
  tb002_cod_cidade SERIAL PRIMARY KEY,
  tb001_sigla_uf VARCHAR(2) NOT NULL,
  tb002_nome_cidade VARCHAR(255) NOT NULL,
  CONSTRAINT XFKtb002_cidades_tb001_uf FOREIGN KEY (tb001_sigla_uf) REFERENCES tb001_uf (tb001_sigla_uf) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb003_enderecos (
  tb003_cod_endereco SERIAL PRIMARY KEY,
  tb001_sigla_uf VARCHAR(2) NOT NULL,
  tb002_cod_cidade INT NOT NULL,
  tb003_nome_rua VARCHAR(255) NOT NULL,
  tb003_numero_rua VARCHAR(10) NOT NULL,
  tb003_complemento VARCHAR(255),
  tb003_ponto_referencia VARCHAR(255),
  tb003_bairro VARCHAR(255) NOT NULL,
  tb003_CEP VARCHAR(15) NOT NULL,
  CONSTRAINT XFKtb003_enderecos_tb001_uf FOREIGN KEY (tb001_sigla_uf) REFERENCES tb001_uf (tb001_sigla_uf) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XFKtb003_enderecos_tb002_cidades FOREIGN KEY (tb002_cod_cidade) REFERENCES tb002_cidades (tb002_cod_cidade) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb004_lojas (
  tb004_cod_loja SERIAL PRIMARY KEY,
  tb003_cod_endereco INT,
  tb004_matriz INT,
  tb004_cnpj_loja VARCHAR(20) NOT NULL,
  tb004_inscricao_estadual VARCHAR(20),
  CONSTRAINT XFKtb004_lojas_tb003_enderecos FOREIGN KEY (tb003_cod_endereco) REFERENCES tb003_enderecos (tb003_cod_endereco) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb005_006_funcionarios_cargos (
  tb005_matricula INT NOT NULL,
  tb006_cod_cargo SERIAL NOT NULL,
  tb005_006_valor_cargo NUMERIC(10, 2) NOT NULL,
  tb005_006_perc_comissao_cargo NUMERIC(5, 2) NOT NULL,
  tb005_006_data_promocao TIMESTAMP NOT NULL,
  CONSTRAINT XFKtb005_006_funcionarios_cargos_tb005_funcionarios FOREIGN KEY (tb005_matricula) REFERENCES tb005_funcionarios (tb005_matricula) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XFKtb005_006_funcionarios_cargos_tb006_cargos FOREIGN KEY (tb006_cod_cargo) REFERENCES tb006_cargos (tb006_cod_cargo) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XPKtb005_006_funcionarios_cargos PRIMARY KEY (tb005_matricula, tb006_cod_cargo)
);

CREATE TABLE tb005_funcionarios (
  tb005_matricula SERIAL PRIMARY KEY,
  tb004_cod_loja INT NOT NULL,
  tb003_cod_endereco INT NOT NULL,
  tb005_nome_completo VARCHAR(255) NOT NULL,
  tb005_data_nascimento TIMESTAMP NOT NULL,
  tb005_CPF VARCHAR(17) NOT NULL,
  tb005_RG VARCHAR(15) NOT NULL,
  tb005_status VARCHAR(20) NOT NULL,
  tb005_data_contratacao TIMESTAMP NOT NULL,
  tb005_data_demissao TIMESTAMP,
  CONSTRAINT XFKtb005_funcionarios_tb004_lojas FOREIGN KEY (tb004_cod_loja) REFERENCES tb004_lojas (tb004_cod_loja) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XFKtb005_funcionarios_tb003_enderecos FOREIGN KEY (tb003_cod_endereco) REFERENCES tb003_enderecos (tb003_cod_endereco) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb006_cargos (
  tb006_cod_cargo SERIAL PRIMARY KEY,
  tb006_nome_cargo VARCHAR(255) NOT NULL
);

CREATE TABLE tb010_012_vendas (
  tb010_012_cod_venda SERIAL PRIMARY KEY,
  tb010_cpf NUMERIC(15) NOT NULL,
  tb012_cod_produto INT NOT NULL,
  tb005_matricula INT NOT NULL,
  tb010_012_data TIMESTAMP NOT NULL,
  tb010_012_quantidade INT NOT NULL,
  tb010_012_valor_unitario NUMERIC(12, 4) NOT NULL,
  CONSTRAINT XFKtb010_012_vendas_tb010_clientes FOREIGN KEY (tb010_cpf) REFERENCES tb010_clientes (tb010_cpf) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XFKtb010_012_vendas_tb005_funcionarios FOREIGN KEY (tb005_matricula) REFERENCES tb005_funcionarios (tb005_matricula) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XFKtb010_012_vendas_tb012_produtos FOREIGN KEY (tb012_cod_produto) REFERENCES tb012_produtos (tb012_cod_produto) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb010_clientes (
  tb010_cpf NUMERIC(15) PRIMARY KEY,
  tb010_nome VARCHAR(255) NOT NULL,
  tb010_fone_residencial VARCHAR(255) NOT NULL,
  tb010_fone_celular VARCHAR(255)
);

CREATE TABLE tb010_clientes_antigos (
  tb010_cpf NUMERIC(15) PRIMARY KEY,
  tb010_nome VARCHAR(255) NOT NULL
);

CREATE TABLE tb011_logins (
  tb011_logins VARCHAR(255) PRIMARY KEY,
  tb010_cpf NUMERIC(15) NOT NULL,
  tb011_senha VARCHAR(255) NOT NULL,
  tb011_data_cadastro TIMESTAMP,
  CONSTRAINT XFKtb011_logins_tb010_clientes FOREIGN KEY (tb010_cpf) REFERENCES tb010_clientes (tb010_cpf) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb012_017_compras (
  tb012_017_cod_compra SERIAL PRIMARY KEY,
  tb012_cod_produto INT NOT NULL,
  tb017_cod_fornecedor INT NOT NULL,
  tb012_017_data TIMESTAMP,
  tb012_017_quantidade INT,
  tb012_017_valor_unitario NUMERIC(12, 2),
  CONSTRAINT XFKtb012_017_compras_tb012_produtos FOREIGN KEY (tb012_cod_produto) REFERENCES tb012_produtos (tb012_cod_produto) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT XFKtb012_017_compras_tb017_fornecedores FOREIGN KEY (tb017_cod_fornecedor) REFERENCES tb017_fornecedores (tb017_cod_fornecedor) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb012_produtos (
  tb012_cod_produto INT PRIMARY KEY,
  tb013_cod_categoria INT NOT NULL,
  tb012_descricao VARCHAR(255) NOT NULL,
  CONSTRAINT XFKtb012_produtos_tb013_categorias FOREIGN KEY (tb013_cod_categoria) REFERENCES tb013_categorias (tb013_cod_categoria) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb013_categorias (
  tb013_cod_categoria SERIAL PRIMARY KEY,
  tb013_descricao VARCHAR(255) NOT NULL
);

CREATE TABLE tb014_prd_alimentos (
  tb014_cod_prd_alimentos SERIAL PRIMARY KEY,
  tb012_cod_produto INT NOT NULL,
  tb014_detalhamento VARCHAR(255) NOT NULL,
  tb014_unidade_medida VARCHAR(255) NOT NULL,
  tb014_num_lote VARCHAR(255),
  tb014_data_vencimento TIMESTAMP,
  tb014_valor_sugerido NUMERIC(10, 2),
  CONSTRAINT XFKtb014_prd_alimentos_tb012_produtos FOREIGN KEY (tb012_cod_produto) REFERENCES tb012_produtos (tb012_cod_produto) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb015_prd_eletros (
  tb015_cod_prd_eletro SERIAL PRIMARY KEY,
  tb012_cod_produto INT NOT NULL,
  tb015_detalhamento VARCHAR(255) NOT NULL,
  tb015_tensao VARCHAR(255),
  tb015_nivel_consumo_procel CHAR(1),
  tb015_valor_sugerido NUMERIC(10, 2),
  CONSTRAINT XFKtb015_prd_eletros_tb012_produtos FOREIGN KEY (tb012_cod_produto) REFERENCES tb012_produtos (tb012_cod_produto) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb016_prd_vestuarios (
  tb016_cod_prd_vestuario SERIAL PRIMARY KEY,
  tb012_cod_produto INT NOT NULL,
  tb016_detalhamento VARCHAR(255) NOT NULL,
  tb016_sexo CHAR(1) NOT NULL,
  tb016_tamanho VARCHAR(255),
  tb016_numeracao NUMERIC(3),
  tb016_valor_sugerido NUMERIC(10, 2),
  CONSTRAINT XFKtb016_prd_vestuarios_tb012_produtos FOREIGN KEY (tb012_cod_produto) REFERENCES tb012_produtos (tb012_cod_produto) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb017_fornecedores (
  tb017_cod_fornecedor SERIAL PRIMARY KEY,
  tb017_razao_social VARCHAR(255),
  tb017_nome_fantasia VARCHAR(255),
  tb017_fone VARCHAR(15),
  tb003_cod_endereco INT,
  CONSTRAINT XFKtb017_fornecedores_tb003_enderecos FOREIGN KEY (tb003_cod_endereco) REFERENCES tb003_enderecos (tb003_cod_endereco) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tb999_log (
  tb999_cod_log SERIAL PRIMARY KEY,
  tb099_objeto VARCHAR(100) NOT NULL,
  tb999_dml VARCHAR(25) NOT NULL,
  tb999_data TIMESTAMP NOT NULL
);

ALTER TABLE tb001_uf
  ADD CONSTRAINT UQtb001_nome_estado UNIQUE (tb001_nome_estado);

ALTER TABLE tb002_cidades
  ADD CONSTRAINT CONST_UF_CIDADE
  FOREIGN KEY (tb001_sigla_uf)
  REFERENCES tb001_uf(tb001_sigla_uf)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb003_enderecos
  ADD CONSTRAINT CONST_CIDADE_END
  FOREIGN KEY (tb002_cod_cidade, tb001_sigla_uf)
  REFERENCES tb002_cidades(tb002_cod_cidade, tb001_sigla_uf)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb004_lojas
  ADD CONSTRAINT CONST_END_LOJAS
  FOREIGN KEY (tb003_cod_endereco)
  REFERENCES tb003_enderecos(tb003_cod_endereco)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb005_006_funcionarios_cargos
  ADD CONSTRAINT CONST_FUNC_FUNCCARGO
  FOREIGN KEY (tb005_matricula)
  REFERENCES tb005_funcionarios(tb005_matricula)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb005_006_funcionarios_cargos
  ADD CONSTRAINT CONST_CARGO_FUNCCARGO
  FOREIGN KEY (tb006_cod_cargo)
  REFERENCES tb006_cargos(tb006_cod_cargo)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb005_funcionarios
  ADD CONSTRAINT CONST_END_FUNC
  FOREIGN KEY (tb003_cod_endereco)
  REFERENCES tb003_enderecos(tb003_cod_endereco)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb005_funcionarios
  ADD CONSTRAINT CONST_LOJAS_FUNC
  FOREIGN KEY (tb004_cod_loja)
  REFERENCES tb004_lojas(tb004_cod_loja)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb010_012_vendas
  ADD CONSTRAINT CONST_FUNC_VENDAS
  FOREIGN KEY (tb005_matricula)
  REFERENCES tb005_funcionarios(tb005_matricula)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb010_012_vendas
  ADD CONSTRAINT CONST_CLI_VENDAS
  FOREIGN KEY (tb010_cpf)
  REFERENCES tb010_clientes(tb010_cpf)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb010_012_vendas
  ADD CONSTRAINT CONST_PRD_VENDAS
  FOREIGN KEY (tb012_cod_produto)
  REFERENCES tb012_produtos(tb012_cod_produto)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb011_logins
  ADD CONSTRAINT CONST_CLI_LOGIN
  FOREIGN KEY (tb010_cpf)
  REFERENCES tb010_clientes(tb010_cpf)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb012_017_compras
  ADD CONSTRAINT CONST_PRD_COMPRAS
  FOREIGN KEY (tb012_cod_produto)
  REFERENCES tb012_produtos(tb012_cod_produto)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb012_017_compras
  ADD CONSTRAINT CONST_FORN_COMPRAS
  FOREIGN KEY (tb017_cod_fornecedor)
  REFERENCES tb017_fornecedores(tb017_cod_fornecedor)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb012_produtos
  ADD CONSTRAINT CONST_CAT_PRD
  FOREIGN KEY (tb013_cod_categoria)
  REFERENCES tb013_categorias(tb013_cod_categoria)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb014_prd_alimentos
  ADD CONSTRAINT CONST_PRD_ALIM
  FOREIGN KEY (tb012_cod_produto)
  REFERENCES tb012_produtos(tb012_cod_produto)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb015_prd_eletros
  ADD CONSTRAINT CONST_PRD_ELET
  FOREIGN KEY (tb012_cod_produto)
  REFERENCES tb012_produtos(tb012_cod_produto)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb016_prd_vestuarios
  ADD CONSTRAINT CONST_PRD_VEST
  FOREIGN KEY (tb012_cod_produto)
  REFERENCES tb012_produtos(tb012_cod_produto)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE tb017_fornecedores
  ADD CONSTRAINT CONST_END_FORN
  FOREIGN KEY (tb003_cod_endereco)
  REFERENCES tb003_enderecos(tb003_cod_endereco)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;


INSERT INTO
  tb001_uf (tb001_sigla_uf, tb001_nome_estado)
VALUES
  ('AC', 'Acre') ('AL', 'Alagoas'),
  ('AP', 'Amapá'),
  ('AM', 'Amazonas'),
  ('BA', 'Bahia'),
  ('CE', 'Ceará'),
  ('DF', 'Distrito Federal'),
  ('ES', 'Espírito Santo'),
  ('GO', 'Goiás'),
  ('MA', 'Maranhão'),
  ('MT', 'Mato Grosso'),
  ('MS', 'Mato Grosso do Sul'),
  ('MG', 'Minas Gerais'),
  ('PA', 'Pará'),
  ('PB', 'Paraíba'),
  ('PR', 'Paraná'),
  ('PE', 'Pernambuco'),
  ('PI', 'Piauí'),
  ('RR', 'Roraima'),
  ('RO', 'Rondônia'),
  ('RJ', 'Rio de Janeiro'),
  ('RN', 'Rio Grande do Norte'),
  ('RS', 'Rio Grande do Sul'),
  ('SC', 'Santa Catarina'),
  ('SP', 'São Paulo'),
  ('SE', 'Sergipe'),
  ('TO', 'Tocantins');

INSERT INTO
  tb002_cidades (tb001_sigla_uf, tb002_nome_cidade)
VALUES
  ('AC', 'Rio Branco'),
  ('AL', 'Maceio'),
  ('AP', 'Macapá'),
  ('AM', 'Manaus'),
  ('BA', 'Salvador'),
  ('CE', 'Fortaleza'),
  ('DF', 'Brasília'),
  ('ES', 'Vitória'),
  ('GO', 'Goiânia'),
  ('MA', 'São Luís'),
  ('MT', 'Cuiabá'),
  ('MS', 'Campo Grande'),
  ('MG', 'Belo Horizonte'),
  ('PA', 'Belém'),
  ('PB', 'João Pessoa'),
  ('PR', 'Curitiba'),
  ('PE', 'Recife'),
  ('PI', 'Teresina'),
  ('RR', 'Boa Vista'),
  ('RO', 'Porto Velho'),
  ('RJ', 'Rio de Janeiro'),
  ('RN', 'Natal'),
  ('RS', 'Porto Alegre'),
  ('SC', 'Florianópolis'),
  ('SP', 'São Paulo'),
  ('SE', 'Aracaju'),
  ('TO', 'Palmas');

INSERT INTO
  tb006_cargos (tb006_nome_cargo)
VALUES
  ('Diretor'),
  ('Gerente Regional'),
  ('Caixa'),
  ('Auxiliar Administrativo'),
  ('Vendedor Júnior'),
  ('Vendedor Pleno'),
  ('Vendedor Sênior'),
  ('Motorista'),
  ('Recursos Humanos'),
  ('Contador');

INSERT INTO tb003_enderecos 
  (tb001_sigla_uf, tb002_cod_cidade, tb003_nome_rua, tb003_numero_rua, tb003_complemento, tb003_ponto_referencia, tb003_bairro, tb003_CEP)
VALUES
  ('MG', 13, 'Av. Brasil', '1.234', null, null, 'Centro', '80.345-432'),
  ('MG', 13, 'Av. Brasil', '234', null, null, 'Centro', '80.345-533'),
  ('MG', 13, 'Av. Brasil', '43', 'Bl 08 AP 30', null, 'Rebouças', '82.345-434'),
  ('MG', 13, 'Av. 1º de Maio', '34', null, null, 'Pampulha', '81.345-435'),
  ('PR', 16, 'Av. Getúlio Vargas', '4.324', null, null, 'água Verde', '80.345-634'),
  ('PR', 16, 'Rua Brigadeiro Franco', '23', null, null, 'Centro', '80.345-735'),
  ('PR', 16, 'Rua Brigadeiro Franco', '54', 'Casa 02', null, 'Centro', '82.345-435'),
  ('PR', 16, 'Rua Brigadeiro Franco', '345', 'Casa 20', 'Próx. Shopping Curitiba', 'Centro', '81.345-436'),
  ('PR', 16, 'Av. Iguaçú', '11', null, null, 'Rebouças', '80.345-836'),
  ('PR', 16, 'Av. Manoel Ribas', '876', null, null, 'Santa Felicidade', '80.345-937'),
  ('MG', 13, 'Av. Brasil', '467', null, null, 'Centro', '80.345-634'),
  ('MG', 13, 'Av. Brasil', '422', null, null, 'Centro', '80.345-735'),
  ('MG', 13, 'Av. Brasil', '376', 'Bl 08 AP 31', null, 'Rebouças', '82.345-435'),
  ('MG', 13, 'Av. 1º de Maio', '331', null, null, 'Pampulha', '81.345-436'),
  ('PR', 16, 'Av. Getúlio Vargas', '285', null, null, 'água Verde', '80.345-836'),
  ('PR', 16, 'Rua Brigadeiro Franco', '240', null, null, 'Centro', '80.345-937'),
  ('PR', 16, 'Rua Brigadeiro Franco', '194', 'Casa 38', null, 'Centro', '82.345-436'),
  ('PR', 16, 'Rua Brigadeiro Franco', '149', 'Casa 56', 'Próx. Vicente Machado', 'Centro', '81.345-437'),
  ('PR', 16, 'Av. Iguaçú', '103', null, null, 'Rebouças', '80.345-937'),
  ('PR', 16, 'Av. Manoel Ribas', '331', null, null, 'Santa Felicidade', '82.345-436'),
  ('MG', 13, 'Av. Brasil', '285', null, null, 'Centro', '80.345-836'),
  ('MG', 13, 'Av. Brasil', '240', null, null, 'Centro', '80.345-937'),
  ('MG', 13, 'Av. Brasil', '331', 'Bl 08 AP 32', null, 'Rebouças', '82.345-436'),
  ('MG', 13, 'Av. 1º de Maio', '285', null, null, 'Pampulha', '81.345-437'),
  ('PR', 16, 'Av. Getúlio Vargas', '240', null, null, 'água Verde', '80.345-038'),
  ('RS', 23, 'Av. Joaquim Lima', '43', null, null, 'Centro', '80.345-634'),
  ('RS', 23, 'Av. Joaquim Lima', '34', null, null, 'Centro', '80.345-735'),
  ('RS', 23, 'Av. Joaquim Lima', '4.324', null, null, 'Rebouças', '82.345-435'),
  ('RS', 23, 'Av. Joaquim Lima', '23', 'Casa 01', null, 'Rebouças', '81.345-436'),
  ('RS', 23, 'Av. Joaquim Lima', '54', 'Casa 23', null, 'Centro', '80.345-836'),
  ('RS', 23, 'Av. Joaquim Lima', '345', 'Casa 99', null, 'Centro', '80.345-937'),
  ('RS', 23, 'Av. Das Nações', '11', null, null, 'Ladeira', '82.345-436'),
  ('RS', 23, 'Av. Das Nações', '876', null, null, 'Ladeira', '81.345-437'),
  ('RS', 23, 'Av. Das Nações', '467', null, null, 'Ladeira', '80.345-836'),
  ('RS', 23, 'Av. Das Nações', '422', null, null, 'Ladeira', '80.345-937'),
  ('RS', 23, 'Av. Das Nações', '376', null, null, 'Ladeira', '80.345-634'),
  ('RS', 23, 'Av. Das Nações', '331', null, null, 'Ladeira', '80.345-735'),
  ('SP', 25, 'Av. Das Nações', '285', null, null, 'Ladeira', '82.345-436'),
  ('SP', 25, 'Av. Das Nações', '240', null, null, 'Ladeira', '81.345-437'),
  ('SP', 25, 'Av. Das Nações', '34', null, null, 'Ladeira', '80.345-156'),
  ('SP', 25, 'Av. Paulista', '4.324', null, null, 'Centro', '80.345-199'),
  ('SP', 25, 'Av. Washington Luiz', '23', null, null, 'Moema', '82.345-437'),
  ('SP', 25, 'Av. Washington Luiz', '54', null, null, 'Moema', '81.345-438'),
  ('SP', 25, 'Av. Washington Luiz', '345', null, null, 'Moema', '80.345-103'),
  ('SP', 25, 'Av. Washington Luiz', '11', null, null, 'Moema', '80.345-123'),
  ('SP', 25, 'Av. Consolação', '34', null, null, 'Centro', '80.345-836'),
  ('SP', 25, 'Av. Consolação', '4.324', null, null, 'Centro', '80.345-937'),
  ('SP', 25, 'Av. Consolação', '23', null, null, 'Centro', '82.345-437'),
  ('SP', 25, 'Av. Consolação', '54', null, null, 'Centro', '81.345-438'),
  ('SP', 25, 'Av. Consolação', '345', null, null, 'Centro', '80.345-599'),
  ('SP', 25, 'Av. Consolação', '11', null, null, 'Centro', '80.345-836');

INSERT INTO tb004_lojas 
  (tb003_cod_endereco, tb004_matriz, tb004_cnpj_loja, tb004_inscricao_estadual)
VALUES
  (5, null, '99.555.000-0001/01', '234.655.765'),
  (1, 1, '99.555.000-0001/02', '567.655.766'),
  (28, 1, '99.555.000-0001/03', '888.655.767'),
  (41, null, '99.555.000-0001/04', '234.655.768'),
  (10, 1, '99.555.000-0001/05', '234.567.769');

INSERT INTO tb005_funcionarios 
  (tb004_cod_loja, tb003_cod_endereco, tb005_nome_completo, tb005_data_nascimento, tb005_CPF, tb005_RG, tb005_status, tb005_data_contratacao, tb005_data_demissao)
VALUES
  (1, 8, 'Funcionário 01', '1975-01-01', '999.444.555-01', '543.765.234-8', 'Ativo', '2000-01-06', null),
  (2, 2, 'Funcionário 02', '1978-02-03', '999.444.555-02', '543.765.234-9', 'Ativo', '2000-02-06', null),
  (3, 24, 'Funcionário 03', '1982-03-10', '999.444.555-03', '543.765.234-10', 'Ativo', '2000-03-06', null),
  (4, 9, 'Funcionário 04', '1989-04-03', '999.444.555-04', '543.765.234-11', 'Ativo', '2000-04-06', null),
  (5, 8, 'Funcionário 05', '1979-05-01', '999.444.555-05', '543.765.234-12', 'Inativo', '2000-05-06', '2009-01-01'),
  (1, 7, 'Funcionário 06', '1975-01-01', '999.444.555-06', '543.765.234-13', 'Ativo', '2000-06-06', null),
  (2, 4, 'Funcionário 07', '1978-02-03', '999.444.555-07', '543.765.234-14', 'Ativo', '2000-07-06', null),
  (3, 1, 'Funcionário 08', '1982-03-10', '999.444.555-08', '543.765.234-15', 'Ativo', '2000-08-06', null),
  (4, 28, 'Funcionário 09', '1989-04-03', '999.444.555-09', '543.765.234-16', 'Ativo', '2000-09-06', null),
  (5, 9, 'Funcionário 10', '1979-05-01', '999.444.555-10', '543.765.234-17', 'Inativo', '2000-10-06', '2009-02-01'),
  (1, 8, 'Funcionário 11', '1975-01-01', '999.444.555-11', '543.765.234-18', 'Ativo', '2000-11-06', null),
  (2, 5, 'Funcionário 12', '1978-02-03', '999.444.555-12', '543.765.234-19', 'Ativo', '2000-12-06', null),
  (3, 2, 'Funcionário 13', '1982-03-10', '999.444.555-13', '543.765.234-20', 'Ativo', '2000-10-06', null),
  (4, 9, 'Funcionário 14', '1989-04-03', '999.444.555-14', '543.765.234-21', 'Ativo', '2000-11-06', null),
  (5, 10, 'Funcionário 15', '1979-05-01', '999.444.555-15', '543.765.234-22', 'Inativo', '2000-12-06', '2009-03-01'),
  (1, 9, 'Funcionário 16', '1975-01-01', '999.444.555-16', '543.765.234-23', 'Ativo', '2000-12-06', null),
  (1, 15, 'Funcionário 17', '1978-02-03', '999.444.555-17', '543.765.234-24', 'Ativo', '2000-07-06', null),
  (1, 9, 'Funcionário 18', '1982-03-10', '999.444.555-18', '543.765.234-25', 'Ativo', '2000-11-06', null),
  (1, 19, 'Funcionário 19', '1989-04-03', '999.444.555-19', '543.765.234-26', 'Ativo', '2000-10-06', null),
  (1, 7, 'Funcionário 20', '1979-05-01', '999.444.555-20', '543.765.234-27', 'Inativo', '2000-02-06', '2008-04-01'),
  (1, 7, 'Funcionário 21', '1975-01-01', '999.444.555-21', '543.765.234-28', 'Ativo', '2000-02-06', null),
  (2, 5, 'Funcionário 22', '1978-02-03', '999.444.555-22', '543.765.234-29', 'Ativo', '2000-02-06', null),
  (3, 3, 'Funcionário 23', '1982-03-10', '999.444.555-23', '543.765.234-30', 'Ativo', '2000-03-06', null),
  (3, 3, 'Funcionário 24', '1989-04-03', '999.444.555-24', '543.765.234-31', 'Ativo', '2000-04-06', null),
  (3, 4, 'Funcionário 25', '1979-05-01', '999.444.555-25', '543.765.234-32', 'Inativo', '2000-05-06', '2005-05-01'),
  (3, 5, 'Funcionário 26', '1975-01-01', '999.444.555-26', '543.765.234-33', 'Ativo', '2000-02-06', null),
  (3, 6, 'Funcionário 27', '1978-02-03', '999.444.555-27', '543.765.234-34', 'Ativo', '2000-02-06', null),
  (3, 25, 'Funcionário 28', '1982-03-10', '999.444.555-28', '543.765.234-35', 'Ativo', '2000-02-06', null),
  (4, 1, 'Funcionário 29', '1989-04-03', '999.444.555-29', '543.765.234-36', 'Ativo', '2000-01-06', null),
  (5, 1, 'Funcionário 30', '1979-05-01', '999.444.555-30', '543.765.234-37', 'Inativo', '2000-03-06', '2009-06-01'),
  (1, 1, 'Funcionário 31', '1975-01-01', '999.444.555-31', '543.765.234-38', 'Ativo', '2000-01-07', null),
  (5, 2, 'Funcionário 32', '1978-02-03', '999.444.555-32', '543.765.234-39', 'Ativo', '2000-02-07', null),
  (1, 6, 'Funcionário 33', '1982-03-10', '999.444.555-33', '543.765.234-40', 'Ativo', '2000-03-07', null),
  (1, 7, 'Funcionário 34', '1989-04-03', '999.444.555-34', '543.765.234-41', 'Ativo', '2000-04-07', null),
  (1, 8, 'Funcionário 35', '1979-05-01', '999.444.555-35', '543.765.234-42', 'Inativo', '2000-05-07', '2009-07-01'),
  (1, 9, 'Funcionário 36', '1975-01-01', '999.444.555-36', '543.765.234-43', 'Ativo', '2000-06-07', null),
  (1, 30, 'Funcionário 37', '1978-02-03', '999.444.555-37', '543.765.234-44', 'Ativo', '2000-07-07', null),
  (1, 1, 'Funcionário 38', '1982-03-10', '999.444.555-38', '543.765.234-45', 'Ativo', '2000-08-07', null),
  (1, 1, 'Funcionário 39', '1989-04-03', '999.444.555-39', '543.765.234-46', 'Ativo', '2000-09-07', null),
  (1, 4, 'Funcionário 40', '1979-05-01', '999.444.555-40', '543.765.234-47', 'Inativo', '2000-10-07', '2005-08-01');

INSERT INTO
  tb005_006_funcionarios_cargos (
    tb005_matricula,
    tb006_cod_cargo,
    tb005_006_valor_cargo,
    tb005_006_perc_comissao_cargo,
    tb005_006_data_promocao
  )
VALUES
  (1, 1, 30000.00, 0.00, '2008-01-02'),
  (12, 2, 10000.00, 0.00, '2008-03-02'),
  (13, 3, 1000.00, 0.00, '2008-10-03'),
  (14, 4, 500.00, 0.00, '2008-10-03'),
  (14, 5, 800.00, 0.05, '2008-10-03'),
  (16, 6, 1000.00, 0.07, '2008-02-04'),
  (17, 7, 1300.00, 0.10, '2008-02-05'),
  (18, 8, 1050.00, 0.00, '2008-01-02'),
  (19, 9, 1150.00, 0.00, '2008-02-02'),
  (10, 3, 1050.99, 0.00, '2008-10-03'),
  (11, 5, 800.00, 0.06, '2008-10-03'),
  (12, 6, 1000.00, 0.06, '2008-10-03'),
  (13, 7, 1300.00, 0.11, '2008-02-04'),
  (15, 5, 800.00, 0.04, '2008-02-05'),
  (15, 6, 1000.00, 0.09, '2008-01-02'),
  (16, 7, 1300.00, 0.12, '2008-02-02'),
  (17, 5, 800.00, 0.05, '2008-10-03'),
  (18, 6, 1000.00, 0.09, '2008-12-03'),
  (4, 7, 1300.00, 0.12, '2008-10-03'),
  (20, 3, 1000.00, 0.00, '2008-02-04'),
  (11, 3, 1000.00, 0.00, '2008-02-05'),
  (12, 3, 1000.00, 0.00, '2008-01-02'),
  (13, 8, 1050.00, 0.00, '2008-05-02'),
  (14, 8, 1050.00, 0.00, '2008-06-03'),
  (15, 8, 1050.00, 0.00, '2008-07-03'),
  (16, 8, 1050.00, 0.00, '2008-08-03'),
  (17, 2, 10000.00, 0.00, '2008-02-04'),
  (18, 2, 10000.00, 0.00, '2008-02-05'),
  (14, 2, 10000.00, 0.00, '2008-01-02'),
  (10, 5, 800.00, 0.04, '2008-09-02'),
  (11, 6, 1000.00, 0.07, '2008-06-03'),
  (12, 7, 1300.00, 0.12, '2008-07-03'),
  (13, 5, 800.00, 0.04, '2008-12-03'),
  (14, 6, 1000.00, 0.07, '2008-02-04'),
  (15, 7, 1300.00, 0.11, '2008-03-05'),
  (16, 3, 1000.00, 0.00, '2008-01-02'),
  (17, 3, 1000.00, 0.00, '2008-05-02'),
  (18, 7, 1300.00, 0.11, '2008-05-03'),
  (3, 7, 1300.00, 0.11, '2008-05-03'),
  (10, 7, 1300.00, 0.11, '2008-08-03'),
  (13, 6, 1000.00, 0.07, '2009-09-03'),
  (8, 7, 1300.00, 0.10, '2009-02-04'),
  (9, 2, 10000.00, 0.10, '2009-02-05');

INSERT INTO tb010_clientes 
  (tb010_cpf, tb010_nome, tb010_fone_residencial, tb010_fone_celular)
VALUES
  (10000000000, 'NOME Teste 01', '(41); 3333-0001', '(41); 9999-9001'),
  (10000000001, 'NOME Teste 02', '(41); 3333-0002', '(41); 9999-9002'),
  (10000000002, 'NOME Teste 03', '(41); 3333-0003', '(41); 9999-9003'),
  (10000000003, 'NOME Teste 04', '(41); 3333-0004', '(41); 9999-9004'),
  (10000000004, 'NOME Teste 05', '(41); 3333-0005', '(41); 9999-9005'),
  (10000000005, 'NOME Teste 06', '(41); 3333-0006', '(41); 9999-9006'),
  (10000000006, 'NOME Teste 07', '(41); 3333-0007', '(41); 9999-9007'),
  (10000000007, 'NOME Teste 08', '(41); 3333-0008', '(41); 9999-9008'),
  (10000000008, 'NOME Teste 09', '(41); 3333-0009', '(41); 9999-9009'),
  (10000000009, 'NOME Teste 10', '(41); 3333-0010', '(41); 9999-9010'),
  (10000000010, 'NOME Teste 11', '(11); 5333-0011', '(41); 9999-9011'),
  (10000000011, 'NOME Teste 12', '(41); 3333-0012', '(41); 9999-9012'),
  (10000000012, 'NOME Teste 13', '(41); 3333-0013', '(41); 9999-9013'),
  (10000000013, 'NOME Teste 14', '(41); 3333-0014', '(41); 9999-9014'),
  (10000000014, 'NOME Teste 15', '(41); 3333-0015', '(41); 9999-9015'),
  (10000000015, 'NOME Teste 16', '(48); 5333-8989', '(41); 9999-9016'),
  (10000000016, 'NOME Teste 17', '(41); 3333-0017', '(41); 9999-9017'),
  (10000000017, 'NOME Teste 18', '(41); 3333-0018', '(41); 9999-9018'),
  (10000000018, 'NOME Teste 19', '(41); 3333-0019', '(41); 9999-9019'),
  (10000000019, 'NOME Teste 20', '(41); 3333-0020', '(41); 9999-9020'),
  (10000000020, 'NOME Teste 21', '(41); 3333-0021', '(41); 9999-9021'),
  (10000000021, 'NOME Teste 22', '(41); 3333-0022', '(41); 9999-9022'),
  (10000000022, 'NOME Teste 23', '(11); 5333-0099', '(41); 9999-9023'),
  (10000000023, 'NOME Teste 24', '(41); 3333-0024', '(41); 9999-9024'),
  (10000000024, 'NOME Teste 25', '(41); 3333-0025', '(11); 8999-9025'),
  (10000000025, 'NOME Teste 26', '(41); 3333-0026', '(41); 9999-9026'),
  (10000000026, 'NOME Teste 27', '(41); 3333-0027', '(41); 9999-9027'),
  (10000000027, 'NOME Teste 28', '(41); 3333-0028', '(41); 9999-9028'),
  (10000000028, 'NOME Teste 29', '(41); 3333-0029', '(41); 9999-9029'),
  (10000000029, 'NOME Teste 30', '(41); 3333-0030', '(41); 9999-9030'),
  (10000000030, 'NOME Teste 31', '(41); 3333-0031', '(41); 9999-9031'),
  (10000000031, 'NOME Teste 32', '(41); 3333-0032', '(41); 9999-9032'),
  (10000000032, 'NOME Teste 33', '(41); 3333-0033', '(41); 9999-9033'),
  (10000000033, 'NOME Teste 34', '(41); 3333-0034', '(41); 9999-9034'),
  (10000000034, 'NOME Teste 35', '(41); 3333-0035', '(41); 9999-9035'),
  (10000000035, 'NOME Teste 36', '(41); 3333-0036', '(41); 9999-9036'),
  (10000000036, 'NOME Teste 37', '(41); 3333-0037', '(41); 9999-9037'),
  (10000000037, 'NOME Teste 38', '(41); 3333-0038', '(41); 9999-9038'),
  (10000000038, 'NOME Teste 39', '(41); 3333-0039', '(41); 9999-9039'),
  (10000000039, 'NOME Teste 40', '(41); 3333-0040', '(41); 9999-9040'),
  (10000000040, 'NOME Teste 41', '(41); 3333-0041', '(41); 9999-9041'),
  (10000000041, 'NOME Teste 42', '(41); 3333-0042', '(41); 9999-9042'),
  (10000000042, 'NOME Teste 43', '(41); 3333-0043', '(41); 9999-9043'),
  (10000000043, 'NOME Teste 44', '(41); 3333-0044', '(41); 9999-9044'),
  (10000000044, 'NOME Teste 45', '(41); 3333-0045', '(11); 8999-9325'),
  (10000000045, 'NOME Teste 46', '(41); 3333-0046', '(11); 8999-9089'),
  (10000000046, 'NOME Teste 47', '(41); 3333-0047', '(41); 9999-9047'),
  (10000000047, 'NOME Teste 48', '(41); 3333-0048', '(41); 9999-9048'),
  (10000000048, 'NOME Teste 49', '(41); 3333-0049', '(11); 8999-6464'),
  (10000000049, 'NOME Teste 50', '(41); 3333-0050', '(41); 9999-9050'),
  (10000000050, 'NOME Teste 51', '(41); 3333-0051', '(41); 9999-9051');

INSERT INTO
  tb004_lojas (tb004_cod_loja, tb003_cod_endereco, tb004_matriz, tb004_cnpj_loja, tb004_inscricao_estadual)
VALUES
  (
    null,
    5,
    null,
    '99.555.000-0001/01',
    '234.655.765'
  ),
  (null, 1, 1, '99.555.000-0001/02', '567.655.766'),
  (null, 28, 1, '99.555.000-0001/03', '888.655.767'),
  (
    null,
    41,
    null,
    '99.555.000-0001/04',
    '234.655.768'
  ),
  (null, 10, 1, '99.555.000-0001/05', '234.567.769');

INSERT INTO
  tb010_clientes_antigos (tb010_cpf, tb010_nome)
VALUES
  (10000000000, 'NOME Teste 01'),
  (10000000001, 'NOME Teste 02'),
  (10000000002, 'NOME Teste 03'),
  (10000000003, 'NOME Teste 04'),
  (10000000004, 'NOME Teste 05'),
  (10000000005, 'NOME Teste 06'),
  (10000000006, 'NOME Teste 07'),
  (10000000007, 'NOME Teste 08'),
  (10000000008, 'NOME Teste 09'),
  (10000000009, 'NOME Teste 10'),
  (10000000010, 'NOME Teste 11'),
  (10000000011, 'NOME Teste 12');

INSERT INTO tb011_logins (tb011_logins, tb010_cpf, tb011_senha, tb011_data_cadastro)
VALUES
  ('Teste_01', 10000000000, 'Teste_01', '2009-01-01'),
  ('Teste_02', 10000000001, 'Teste_02', '2009-01-01'),
  ('Teste_03', 10000000002, 'Teste_03', '2009-01-01'),
  ('Teste_04', 10000000003, 'Teste_04', '2009-11-01'),
  ('Teste_05', 10000000004, 'Teste_05', '2009-01-01'),
  ('Teste_06', 10000000005, 'Teste_06', '2009-12-01'),
  ('Teste_07', 10000000006, 'Teste_07', '2009-01-01'),
  ('Teste_08', 10000000007, 'Teste_08', '2009-01-01'),
  ('Teste_09', 10000000008, 'Teste_09', '2009-01-08'),
  ('Teste_10', 10000000009, 'Teste_10', '2009-01-01'),
  ('Teste_11', 10000000010, 'Teste_11', '2009-01-01'),
  ('Teste_12', 10000000011, 'Teste_12', '2008-01-01'),
  ('Teste_13', 10000000012, 'Teste_13', '2009-03-01'),
  ('Teste_14', 10000000013, 'Teste_14', '2009-01-01'),
  ('Teste_15', 10000000014, 'Teste_15', '2009-01-01'),
  ('Teste_16', 10000000015, 'Teste_16', '2009-01-02'),
  ('Teste_17', 10000000016, 'Teste_17', '2009-01-01'),
  ('Teste_18', 10000000017, 'Teste_18', '2009-05-01'),
  ('Teste_19', 10000000018, 'Teste_19', '2009-01-01'),
  ('Teste_20', 10000000019, 'Teste_20', '2009-01-01'),
  ('Teste_21', 10000000020, 'Teste_21', '2009-01-01'),
  ('Teste_22', 10000000021, 'Teste_22', '2009-11-01'),
  ('Teste_23', 10000000022, 'Teste_23', '2009-01-01'),
  ('Teste_24', 10000000023, 'Teste_24', '2009-05-01'),
  ('Teste_25', 10000000024, 'Teste_25', '2009-01-01'),
  ('Teste_26', 10000000025, 'Teste_26', '2009-01-01'),
  ('Teste_27', 10000000026, 'Teste_27', '2009-01-08'),
  ('Teste_28', 10000000027, 'Teste_28', '2009-01-01'),
  ('Teste_29', 10000000028, 'Teste_29', '2009-01-01'),
  ('Teste_30', 10000000029, 'Teste_30', '2008-01-01'),
  ('Teste_31', 10000000030, 'Teste_31', '2009-08-01'),
  ('Teste_32', 10000000031, 'Teste_32', '2009-01-01'),
  ('Teste_33', 10000000032, 'Teste_33', '2009-01-01'),
  ('Teste_34', 10000000033, 'Teste_34', '2009-01-02'),
  ('Teste_35', 10000000034, 'Teste_35', '2009-01-01'),
  ('Teste_36', 10000000035, 'Teste_36', '2009-09-01'),
  ('Teste_37', 10000000036, 'Teste_37', '2009-01-01'),
  ('Teste_38', 10000000037, 'Teste_38', '2009-01-01'),
  ('Teste_39', 10000000038, 'Teste_39', '2009-01-01'),
  ('Teste_40', 10000000039, 'Teste_40', '2009-11-01'),
  ('Teste_41', 10000000040, 'Teste_41', '2009-01-01'),
  ('Teste_42', 10000000041, 'Teste_42', '2009-07-01'),
  ('Teste_43', 10000000042, 'Teste_43', '2009-01-01'),
  ('Teste_44', 10000000043, 'Teste_44', '2009-01-01'),
  ('Teste_45', 10000000044, 'Teste_45', '2009-01-08'),
  ('Teste_46', 10000000045, 'Teste_46', '2009-01-01'),
  ('Teste_47', 10000000046, 'Teste_47', '2009-01-01'),
  ('Teste_48', 10000000047, 'Teste_48', '2008-01-01'),
  ('Teste_49', 10000000048, 'Teste_49', '2009-04-01'),
  ('Teste_50', 10000000049, 'Teste_50', '2009-01-01'),
  ('Teste_51', 10000000050, 'Teste_51', '2009-01-01');


INSERT INTO tb013_categorias 
  (tb013_descricao)
VALUES
  ('Alimentos Perecíveis'),
  ('Alimentos Não Perecíveis'),
  ('Eletrodomésticos'),
  ('Eletrônicos'),
  ('CD e DVD'),
  ('Roupas Masculinas'),
  ('Roupas Femininas'),
  ('Roupas Infantis');

INSERT INTO
  tb012_produtos (tb012_cod_produto, tb013_cod_categoria, tb012_descricao)
VALUES
  (10, 1, 'Biscoito Recheado'),
  (11, 1, 'Pão-de-queijo Congelado'),
  (12, 1, 'Iogurte'),
  (13, 1, 'Barra de Chocolate'),
  (14, 1, 'Barra de Cereal'),
  (15, 1, 'Biscoito água e Sal'),
  (16, 1, 'Biscoito Maizena'),
  (17, 1, 'Salgadinho'),
  (18, 1, 'Suco Ades'),
  (19, 1, 'Isotônico'),
  (20, 2, 'Açúcar'),
  (21, 2, 'Arroz'),
  (22, 2, 'Feijão'),
  (23, 2, 'Milho de Pipoca'),
  (30, 3, 'Geladeira'),
  (31, 3, 'Geladeira Duplex'),
  (32, 3, 'Fogão 4 Bocas'),
  (33, 3, 'Fogão 6 Bocas'),
  (34, 3, 'Batedeira'),
  (35, 3, 'Liquidificador'),
  (36, 3, 'Torradeira'),
  (37, 3, 'Sanduicheira'),
  (38, 3, 'Multiprocessador'),
  (39, 3, 'Forno Elétrico'),
  (40, 4, 'TV LCD'),
  (41, 4, 'TV Cubo de Imagens'),
  (42, 4, 'DVD'),
  (43, 4, 'DVD Karaoke'),
  (44, 4, 'Vídeo-Game'),
  (45, 4, 'Aparelho de Som'),
  (46, 4, 'Aparelho de Som Automotivo'),
  (47, 4, 'Auto-Falantes Automotivos'),
  (48, 4, 'Notebook'),
  (49, 4, 'Computador Desktop'),
  (50, 5, 'CD Rock'),
  (51, 5, 'CD POP'),
  (52, 5, 'CD Coletânea'),
  (53, 5, 'CD Caipira'),
  (54, 5, 'CD Virgem'),
  (55, 5, 'DVD Rock'),
  (56, 5, 'DVD POP'),
  (57, 5, 'DVD Coletânea'),
  (58, 5, 'DVD Caipira'),
  (59, 5, 'DVD Virgem'),
  (60, 6, 'Calça Jeans'),
  (61, 6, 'Calça Moleton'),
  (62, 6, 'Camisa Polo'),
  (63, 6, 'Camisa Manga Longa'),
  (64, 6, 'Camisa Manga Curta'),
  (65, 6, 'Camiseta'),
  (66, 6, 'Regata'),
  (67, 6, 'Meias'),
  (68, 6, 'Roupas de Baixo'),
  (69, 6, 'Gravatas'),
  (70, 7, 'Calça Jeans'),
  (71, 7, 'Calça Moleton'),
  (72, 7, 'Top'),
  (73, 7, 'Camisa Manga Longa'),
  (74, 7, 'Camisa Manga Curta'),
  (75, 7, 'Camiseta'),
  (76, 7, 'Regata'),
  (77, 7, 'Meias'),
  (78, 7, 'Roupas de Baixo'),
  (79, 7, 'Bolsas'),
  (80, 8, 'Camiseta'),
  (81, 8, 'Bermuda'),
  (82, 8, 'Tênis'),
  (83, 8, 'Bonûs');

INSERT INTO tb014_prd_alimentos (tb012_cod_produto, tb014_detalhamento, tb014_unidade_medida, tb014_num_lote, tb014_data_vencimento, tb014_valor_sugerido)
VALUES
  (10, 'Trakinas', 'Kilogramas', '8887775456', '2010-02-11', 1.10),
  (10, 'Pica-Pau', 'Kilogramas', '3457684345', '2011-01-02', 0.89),
  (10, 'Gulosos', 'Kilogramas', '8276348762', '2011-12-01', 1.09),
  (11, 'Quijo de Minas', 'Kilogramas', '5473545453', '2010-01-06', 3.99),
  (11, '+ Pão', 'Kilogramas', '5473545453', '2010-01-06', 2.89),
  (12, 'Batavo - Frutas', 'Litros', '5473545453', '2010-01-05', 1.09),
  (12, 'Danone', 'Litros', '9768935983', '2010-01-05', 0.99),
  (13, 'Garoto', 'Kilogramas', '9583495345', '2011-01-05', 3.99),
  (13, 'Nestlé', 'Kilogramas', '5345662345', '2011-01-03', 4.19),
  (13, 'Hersheys', 'Kilogramas', 'FRU4345GDA', '2011-01-04', 2.99),
  (14, 'Nutri', 'Kilogramas', '5433145453', '2011-01-06', 0.79),
  (14, 'Trill', 'Kilogramas', '8757689456', '2011-01-06', 0.69),
  (15, 'Nestlé', 'Kilogramas', '2324345423', '2011-01-04', 2.99),
  (15, 'Todeschini', 'Kilogramas', '7896532736', '2011-05-01', 1.39),
  (15, 'Mabel', 'Kilogramas', '98475934hhg', '2010-12-12', 1.20),
  (16, 'Nestlé', 'Kilogramas', '13468720049', '2010-05-11', 2.10),
  (16, 'Todeschini', 'Kilogramas', '19040907362', '2010-01-12', 1.14),
  (16, 'Mabel', 'Kilogramas', '46575934hhg', '2010-01-12', 1.18),
  (17, 'Elma Chips', 'Kilogramas', '34174845745', '2010-02-06', 1.99),
  (17, 'Tip-Top', 'Kilogramas', '77583275585', '2010-01-08', 1.49),
  (17, 'Pipoteca', 'Kilogramas', '9283478gdy9', '2010-08-10', 0.99),
  (18, 'Del Vale', 'Litros', '12874534549', '2010-02-06', 1.39),
  (18, 'Ades', 'Litros', '120991705w34', '2010-01-05', 1.09),
  (18, 'Minute Maid +', 'Litros', '164400135343frt', '2010-08-10', 2.99),
  (19, 'Isotônico', 'Litros', '9283478gdy10', '2010-10-06', 3.99);

INSERT INTO tb015_prd_eletros (tb012_cod_produto, tb015_detalhamento, tb015_tensao, tb015_nivel_consumo_procel, tb015_valor_sugerido)
VALUES
  (30, 'Consul', '110-220 volts', 'A', 999.00),
  (30, 'Esmaltec', '110-220 volts', 'B', 999.00),
  (31, 'Bosch', '110-220 volts', 'B', 1399.00),
  (31, 'Consul', '110-220 volts', 'B', 1399.00),
  (32, 'Continental', '110-220 volts', 'A', 559.00),
  (32, 'Dako', '110-220 volts', 'A', 699.00),
  (33, 'Bosch', '110-220 volts', 'A', 999.00),
  (33, 'Esmaltec', '110 volts', 'B', 899.00),
  (34, 'Arno', '110 volts', 'A', 49.90),
  (34, 'Arno', '220 volts', 'A', 52.00),
  (35, 'Britânia', '110 volts', 'A', 65.00),
  (35, 'Arno', '110 volts', 'A', 59.99),
  (36, 'Esmaltec', '110 volts', 'A', 38.00),
  (36, 'Arno', '110 volts', 'A', 49.00),
  (37, 'Britânia', '110 volts', 'B', 43.00),
  (37, 'Arno', '110 volts', 'B', 59.99),
  (38, 'Arno', '110-220 volts', 'C', 799.00),
  (39, 'Brastemp', '110-220 volts', 'C', 599.00),
  (40, 'LG 42 Polegadas', '110-220 volts', 'A', 2999.00),
  (40, 'Philco 42 Polegadas', '110-220 volts', 'A', 2850.00),
  (41, 'CCE 29 Polegadas', '110-220 volts', 'B', 899.00),
  (41, 'Samsung 29 Polegadas', '110-220 volts', 'A', 1250.00),
  (42, 'Philips', '110-220 volts', 'A', 299.00),
  (42, 'Philco', '110-220 volts', 'A', 270.00),
  (43, 'Philco', '110-220 volts', 'A', 299.00),
  (43, 'LG', '110-220 volts', 'A', 312.00),
  (44, 'Play Station 2', '110-220 volts', 'A', 499.00),
  (44, 'X Box 360', '110-220 volts', 'A', 650.00),
  (45, 'Sony', '12 volts', NULL, 519.00),
  (45, 'Aiwa', '12 volts', NULL, 430.50),
  (46, 'Sony', '12 volts', NULL, 249.00),
  (46, 'Pioneer', '12 volts', NULL, 310.80),
  (47, 'Booster', '12 volts', NULL, 130.00),
  (47, 'Bravox', '12 volts', NULL, 129.99),
  (48, 'Positivo', '110-220 volts', 'A', 2599.00),
  (48, 'Intelbras', '110-220 volts', 'A', 1400.00),
  (49, 'STI', '110-220 volts', 'A', 999.90),
  (49, 'Positivo', '110-220 volts', 'A', 1235.89),
  (50, 'AC-DC Collection', NULL, NULL, 35.00),
  (50, 'Ultraje a Rigor', NULL, NULL, 21.89),
  (51, 'Shakira', NULL, NULL, 19.99),
  (51, 'Beyonce', NULL, NULL, 1.99),
  (52, 'Melhores 80 Rocks', NULL, NULL, 23.89),
  (52, 'Melhores 90 Rocks', NULL, NULL, 25.99),
  (53, 'Pena Branca e Xavantinho', NULL, NULL, 15.99),
  (53, 'Milhionário e José Rico', NULL, NULL, 26.34),
  (54, 'EMTEC', NULL, NULL, 0.89),
  (54, 'BULK', NULL, NULL, 0.73),
  (55, 'Deep Purple', NULL, NULL, 49.90),
  (55, 'Joe Satriani', NULL, NULL, 72.78),
  (56, 'Shakira', NULL, NULL, 89.34),
  (56, 'Beyonce', NULL, NULL, 1.99),
  (57, 'Melhores 80 Rocks', NULL, NULL, 35.75),
  (57, 'Melhores 90 Rocks', NULL, NULL, 32.58),
  (58, 'Berenice Azambuja', NULL, NULL, 35.76),
  (58, 'Tadeu e Tadando', NULL, NULL, 32.59),
  (59, 'EMTEC', NULL, NULL, 1.23),
  (59, 'BULK', NULL, NULL, 0.99);

INSERT INTO tb016_prd_vestuarios (tb012_cod_produto, tb016_detalhamento, tb016_sexo, tb016_tamanho, tb016_numeracao, tb016_valor_sugerido)
VALUES
  (60, 'Lee', 'M', NULL, 52, 69.99),
  (60, 'Malwe', 'M', NULL, 56, 89.99),
  (61, 'Malwe', 'U', 'Grande', NULL, 22.00),
  (61, 'Hering', 'U', 'Pequena', NULL, 22.00),
  (62, 'Polo', 'M', 'Grande', NULL, 22.00),
  (62, 'Lacoste', 'M', 'Grande', NULL, 35.00),
  (63, 'Polo', 'M', 'Grande', NULL, 27.00),
  (63, 'Lacoste', 'M', 'Grande', NULL, 38.00),
  (64, 'Polo', 'M', 'Grande', NULL, 22.00),
  (64, 'Lacoste', 'M', 'Grande', NULL, 35.00),
  (65, 'Rip Curl', 'U', 'Grande', NULL, 28.09),
  (65, 'Mormai', 'U', 'Grande', NULL, 32.00),
  (66, 'Mormai', 'M', 'Grande', NULL, 10.99),
  (66, 'Mormai', 'M', 'Pequena', NULL, 10.99),
  (67, 'Social', 'M', NULL, 44, 9.90),
  (67, 'Esporte', 'M', NULL, 44, 12.00),
  (68, 'Cueca', 'M', 'Grande', NULL, 15.89),
  (68, 'Samba Canção', 'M', 'Grande', NULL, 15.89),
  (69, 'Armani', 'M', NULL, NULL, 19.99),
  (70, 'Lee', 'F', NULL, 46, 99.99),
  (70, 'Malwe', 'F', NULL, 48, 119.99),
  (71, 'Malwe', 'F', 'Grande', NULL, 35.00),
  (71, 'Hering', 'F', 'Pequena', NULL, 35.00),
  (72, 'Polo', 'F', 'Média', NULL, 37.00),
  (72, 'Meimalha', 'F', 'Média', NULL, 37.00),
  (73, 'Polo', 'F', 'Média', NULL, 27.00),
  (73, 'Meimalha', 'F', 'Média', NULL, 38.00),
  (74, 'Polo', 'F', 'Média', NULL, 22.00),
  (74, 'Meimalha', 'F', 'Média', NULL, 35.00),
  (75, 'Rip Curl', 'F', 'Média', NULL, 28.09),
  (75, 'Mormai', 'F', 'Média', NULL, 32.00),
  (76, 'Mormai', 'F', 'Média', NULL, 10.99),
  (76, 'Mormai', 'F', 'Pequena', NULL, 10.99),
  (77, 'Social', 'F', NULL, 44, 9.90),
  (77, 'Esporte', 'F', NULL, 44, 12.00),
  (78, 'Calcinhas', 'F', 'Pequena', NULL, 19.99),
  (78, 'Soutien', 'F', 'Pequena', NULL, 29.99),
  (79, 'Renner', 'F', NULL, NULL, 139.00),
  (79, 'C & A', 'F', NULL, NULL, 119.00),
  (80, 'Malwe', 'I', 'Pequena', NULL, 19.99),
  (80, 'Tigor T Tigre', 'I', 'Pequena', NULL, 25.99),
  (81, 'Malwe', 'I', 'Pequena', NULL, 19.99),
  (81, 'Tigor T Tigre', 'I', 'Pequena', NULL, 25.99),
  (82, 'Klin', 'I', NULL, 25, 39.99),
  (82, 'Pimpolho', 'I', NULL, 28, 59.99),
  (83, 'Tigor T Tigre', 'I', NULL, NULL, 9.50);

INSERT INTO tb017_fornecedores (tb017_razao_social, tb017_nome_fantasia, tb017_fone, tb003_cod_endereco) VALUES
  ('Empresa 01', 'Nome Fantasia - Empresa 01', '(41) 3343-4545', 7),
  ('Empresa 02', 'Nome Fantasia - Empresa 02', '(41) 3343-4546', 7),
  ('Empresa 03', 'Nome Fantasia - Empresa 03', '(41) 3343-4547', 7),
  ('Empresa 04', 'Nome Fantasia - Empresa 04', '(41) 3343-4548', 7),
  ('Empresa 05', 'Nome Fantasia - Empresa 05', '(41) 3343-4549', 7),
  ('Empresa 06', 'Nome Fantasia - Empresa 06', '(41) 3343-4550', 7),
  ('Empresa 07', 'Nome Fantasia - Empresa 07', '(41) 3343-4551', 7),
  ('Empresa 08', 'Nome Fantasia - Empresa 08', '(41) 3343-4552', 7),
  ('Empresa 09', 'Nome Fantasia - Empresa 09', '(41) 3343-4553', 7),
  ('Empresa 10', 'Nome Fantasia - Empresa 10', '(41) 3343-4554', 7),
  ('Empresa 11', 'Nome Fantasia - Empresa 11', '(41) 3343-4555', 8),
  ('Empresa 12', 'Nome Fantasia - Empresa 12', '(41) 3343-4556', 8),
  ('Empresa 13', 'Nome Fantasia - Empresa 13', '(41) 3343-4557', 8),
  ('Empresa 14', 'Nome Fantasia - Empresa 14', '(41) 3343-4558', 8),
  ('Empresa 15', 'Nome Fantasia - Empresa 15', '(41) 3343-4559', 8),
  ('Empresa 16', 'Nome Fantasia - Empresa 16', '(41) 3343-4560', 8),
  ('Empresa 17', 'Nome Fantasia - Empresa 17', '(41) 3343-4561', 8),
  ('Empresa 18', 'Nome Fantasia - Empresa 18', '(41) 3343-4562', 8),
  ('Empresa 19', 'Nome Fantasia - Empresa 19', '(41) 3343-4563', 8),
  ('Empresa 20', 'Nome Fantasia - Empresa 20', '(41) 3343-4564', 8),
  ('Empresa 21', 'Nome Fantasia - Empresa 21', '(41) 3343-4565', 9),
  ('Empresa 22', 'Nome Fantasia - Empresa 22', '(41) 3343-4566', 9),
  ('Empresa 23', 'Nome Fantasia - Empresa 23', '(41) 3343-4567', 9),
  ('Empresa 24', 'Nome Fantasia - Empresa 24', '(41) 3343-4568', 9),
  ('Empresa 25', 'Nome Fantasia - Empresa 25', '(41) 3343-4569', 9),
  ('Empresa 26', 'Nome Fantasia - Empresa 26', '(41) 3343-4570', 9),
  ('Empresa 27', 'Nome Fantasia - Empresa 27', '(41) 3343-4571', 9),
  ('Empresa 28', 'Nome Fantasia - Empresa 28', '(41) 3343-4572', 9),
  ('Empresa 29', 'Nome Fantasia - Empresa 29', '(41) 3343-4573', 9),
  ('Empresa 30', 'Nome Fantasia - Empresa 30', '(41) 3343-4574', 9),
  ('Empresa 31', 'Nome Fantasia - Empresa 31', '(41) 3343-4575', 10),
  ('Empresa 32', 'Nome Fantasia - Empresa 32', '(41) 3343-4576', 11),
  ('Empresa 33', 'Nome Fantasia - Empresa 33', '(41) 3343-4577', 12);

INSERT INTO tb010_012_vendas (tb010_cpf, tb012_cod_produto, tb005_matricula, tb010_012_data, tb010_012_quantidade, tb010_012_valor_unitario) VALUES
  (10000000000, 10, 4, '2010-03-11', 2, 1.42),
  (10000000001, 10, 2, '2010-03-12', 3, 0.94),
  (10000000002, 10, 3, '2010-03-13', 1, 1.10),
  (10000000003, 11, 5, '2010-03-14', 2, 2.46),
  (10000000004, 11, 5, '2010-03-15', 2, 2.62),
  (10000000005, 11, 6, '2010-03-16', 1, 3.22),
  (10000000006, 12, 8, '2010-03-17', 1, 1.10),
  (10000000007, 12, 7, '2010-03-18', 1, 1.10),
  (10000000008, 12, 7, '2010-03-19', 2, 0.83),
  (10000000009, 13, 9, '2010-03-20', 2, 3.76),
  (10000000010, 13, 10, '2010-03-21', 1, 3.54),
  (10000000011, 13, 11, '2010-03-22', 2, 3.34),
  (10000000012, 14, 13, '2010-03-23', 3, 0.51),
  (10000000013, 14, 12, '2010-03-24', 2, 0.51),
  (10000000014, 14, 13, '2010-03-25', 1, 0.45),
  (10000000015, 15, 14, '2010-03-26', 1, 1.42),
  (10000000016, 15, 15, '2010-03-27', 1, 1.55),
  (10000000017, 15, 16, '2010-03-28', 1, 1.42),
  (10000000018, 16, 17, '2010-03-29', 2, 2.22),
  (10000000019, 16, 18, '2010-03-30', 2, 1.58),
  (10000000020, 16, 19, '2010-03-31', 2, 1.63),
  (10000000021, 17, 20, '2010-01-04', 1, 1.10),
  (10000000022, 17, 21, '2010-02-04', 3, 1.10),
  (10000000023, 17, 22, '2010-03-04', 2, 0.83),
  (10000000024, 18, 23, '2010-04-04', 3, 1.58),
  (10000000025, 18, 24, '2010-05-04', 1, 1.63),
  (10000000026, 18, 25, '2010-06-04', 2, 1.10),
  (10000000027, 19, 26, '2010-07-04', 4, 2.22),
  (10000000028, 30, 1, '2010-08-04', 3, 1152.62),
  (10000000029, 30, 2, '2010-09-04', 2, 1137.58),
  (10000000030, 31, 3, '2010-04-10', 2, 1760.00),
  (10000000031, 31, 4, '2010-04-11', 1, 1600.00),
  (10000000032, 32, 5, '2010-04-12', 1, 574.40),
  (10000000033, 32, 6, '2010-04-13', 1, 577.79),
  (10000000034, 33, 7, '2010-04-14', 1, 894.40),
  (10000000035, 33, 8, '2010-04-15', 1, 737.79),
  (10000000036, 34, 9, '2010-04-16', 1, 24.00),
  (10000000037, 34, 10, '2010-04-17', 1, 27.20),
  (10000000038, 35, 11, '2010-04-18', 1, 35.20),
  (10000000039, 35, 12, '2010-04-19', 2, 49.60),
  (10000000040, 36, 14, '2010-04-20', 2, 43.20),
  (10000000041, 37, 15, '2010-04-21', 1, 52.80),
  (10000000042, 38, 17, '2010-04-22', 1, 43.20),
  (10000000043, 39, 18, '2010-04-23', 1, 52.80),
  (10000000044, 40, 20, '2010-03-16', 1, 1643.31),
  (10000000045, 41, 21, '2010-03-17', 1, 2949.74),
  (10000000046, 42, 24, '2010-03-18', 2, 203.31),
  (10000000047, 43, 25, '2010-03-19', 1, 229.74),
  (10000000048, 44, 28, '2010-03-20', 1, 660.91),
  (10000000049, 45, 29, '2010-03-21', 1, 732.14),
  (10000000050, 46, 32, '2010-03-22', 1, 340.91),
  (10000000015, 47, 33, '2010-03-23', 3, 143.34),
  (10000000016, 48, 36, '2010-03-24', 1, 1968.94),
  (10000000017, 49, 37, '2010-03-25', 2, 980.91),
  (10000000018, 50, 40, '2010-03-26', 1, 18.54),
  (10000000019, 51, 4, '2010-03-27', 1, 17.26),
  (10000000020, 52, 2, '2010-03-28', 4, 18.56),
  (10000000021, 53, 3, '2010-03-29', 1, 17.28),
  (10000000022, 54, 5, '2010-03-30', 3, 18.58),
  (10000000023, 55, 5, '2010-03-31', 1, 17.30),
  (10000000024, 56, 6, '2010-01-04', 2, 18.59),
  (10000000025, 57, 8, '2010-02-04', 1, 17.31),
  (10000000026, 58, 7, '2010-03-04', 1, 18.61),
  (10000000027, 59, 7, '2010-04-04', 2, 0.69),
  (10000000028, 60, 9, '2010-05-04', 2, 95.18),
  (10000000029, 60, 10, '2010-06-04', 1, 122.38),
  (10000000030, 61, 11, '2010-03-16', 2, 29.94),
  (10000000031, 61, 13, '2010-03-17', 1, 29.97),
  (10000000032, 62, 12, '2010-03-18', 2, 29.98),
  (10000000033, 62, 13, '2010-03-19', 1, 47.60),
  (10000000034, 63, 14, '2010-03-20', 2, 36.72),
  (10000000037, 63, 15, '2010-03-21', 1, 51.68),
  (10000000038, 64, 16, '2010-03-22', 2, 29.92),
  (10000000039, 64, 17, '2010-03-23', 1, 47.60),
  (10000000040, 65, 18, '2010-03-24', 2, 38.19),
  (10000000041, 65, 19, '2010-03-25', 1, 43.54),
  (10000000000, 66, 20, '2010-03-26', 1, 14.94),
  (10000000001, 66, 21, '2010-03-27', 2, 14.94),
  (10000000002, 67, 22, '2010-03-28', 1, 13.46),
  (10000000003, 67, 23, '2010-03-29', 2, 16.42),
  (10000000004, 68, 24, '2010-03-30', 1, 21.71),
  (10000000005, 68, 25, '2010-03-31', 3, 21.65),
  (10000000006, 69, 26, '2010-01-04', 1, 27.18),
  (10000000007, 70, 1, '2010-02-04', 3, 135.98),
  (10000000008, 70, 2, '2010-03-04', 1, 163.18),
  (10000000009, 71, 3, '2010-04-04', 1, 47.60),
  (10000000010, 71, 4, '2010-05-04', 2, 47.60),
  (10000000011, 72, 5, '2010-06-04', 1, 50.32),
  (10000000000, 72, 6, '2010-03-16', 1, 50.32),
  (10000000001, 73, 7, '2010-03-17', 2, 36.72),
  (10000000002, 73, 8, '2010-03-18', 1, 51.78),
  (10000000003, 74, 9, '2010-03-19', 1, 30.06),
  (10000000004, 74, 10, '2010-03-20', 1, 47.60),
  (10000000005, 75, 11, '2010-03-21', 1, 38.19),
  (10000000006, 75, 12, '2010-03-22', 2, 43.60),
  (10000000007, 76, 14, '2010-03-23', 1, 14.94),
  (10000000008, 76, 15, '2010-03-24', 2, 14.94),
  (10000000009, 77, 17, '2010-03-25', 1, 13.46),
  (10000000010, 77, 18, '2010-03-26', 1, 16.40),
  (10000000011, 78, 20, '2010-03-27', 1, 27.18),
  (10000000012, 78, 21, '2010-03-28', 3, 38.38),
  (10000000013, 79, 24, '2010-03-29', 1, 189.49),
  (10000000014, 79, 25, '2010-03-30', 1, 161.84),
  (10000000015, 80, 28, '2010-03-31', 2, 27.18),
  (10000000012, 80, 29, '2010-01-04', 1, 35.34),
  (10000000013, 81, 32, '2010-02-04', 1, 27.18),
  (10000000014, 81, 33, '2010-03-04', 1, 35.34),
  (10000000015, 82, 36, '2010-04-04', 2, 54.38),
  (10000000013, 82, 37, '2010-05-04', 1, 81.58),
  (10000000014, 83, 40, '2010-06-04', 1, 14.38),
  (10000000000, 10, 4, '2011-05-11', 2, 17.31),
  (10000000000, 10, 4, '2011-02-11', 2, 38.89);

INSERT INTO
  tb012_017_compras
VALUES
  (null, 10, 2, '2010-01-02', 1, 0.59),
  (null, 10, 3, '2010-01-03', 2, 0.69),
  (null, 10, 4, '2010-01-01', 3, 0.89),
  (null, 10, 4, '2010-02-21', 3, 0.89),
  (null, 10, 4, '2011-02-01', 3, 0.89);
  (null, 11, 5, '2010-01-04', 3, 1.54),
  (null, 11, 5, '2010-01-05', 1, 1.64),
  (null, 11, 6, '2010-01-06', 2, 2.01),
  (null, 12, 8, '2010-01-07', 3, 0.69),
  (null, 12, 7, '2010-01-08', 3, 0.69),
  (null, 12, 7, '2010-01-09', 3, 0.52),
  (null, 13, 9, '2010-01-10', 3, 2.35),
  (null, 13, 10, '2010-01-11', 3, 2.21),
  (null, 13, 11, '2010-01-12', 4, 2.09),
  (null, 14, 13, '2010-01-13', 4, 0.32),
  (null, 14, 12, '2010-01-14', 4, 0.32),
  (null, 14, 13, '2010-01-15', 4, 0.28),
  (null, 15, 14, '2010-01-16', 5, 0.89),
  (null, 15, 15, '2010-01-17', 5, 0.97),
  (null, 15, 16, '2010-01-18', 5, 0.89),
  (null, 16, 17, '2010-02-19', 5, 1.39),
  (null, 16, 18, '2010-02-20', 6, 0.99),
  (null, 16, 19, '2010-02-21', 6, 1.02),
  (null, 17, 20, '2010-02-22', 3, 0.69),
  (null, 17, 21, '2010-02-23', 4, 0.69),
  (null, 17, 22, '2010-02-24', 2, 0.52),
  (null, 18, 23, '2010-02-25', 5, 0.99),
  (null, 18, 24, '2010-02-26', 3, 1.02),
  (null, 18, 25, '2010-02-27', 4, 0.69),
  (null, 19, 26, '2010-02-28', 3, 1.39),
  (null, 30, 1, '2010-02-10', 5, 720.39),
  (null, 30, 2, '2010-02-11', 5, 710.99),
  (null, 31, 3, '2010-02-13', 3, 1100.00),
  (null, 31, 4, '2010-02-14', 2, 1000.00),
  (null, 32, 5, '2010-02-15', 1, 359.00),
  (null, 32, 6, '2010-02-16', 3, 361.12),
  (null, 33, 7, '2010-02-17', 3, 559.00),
  (null, 33, 8, '2010-02-18', 3, 461.12),
  (null, 34, 9, '2010-02-19', 5, 15.00),
  (null, 34, 10, '2010-02-20', 2, 17.00),
  (null, 35, 11, '2010-02-21', 5, 22.00),
  (null, 35, 12, '2010-02-22', 3, 31.00),
  (null, 36, 14, '2010-02-23', 4, 27.00),
  (null, 37, 15, '2010-02-24', 5, 33.00),
  (null, 38, 17, '2010-02-25', 3, 27.00),
  (null, 39, 18, '2010-01-26', 5, 33.00),
  (null, 40, 20, '2010-03-27', 2, 1027.07),
  (null, 41, 21, '2010-03-28', 1, 1843.59),
  (null, 42, 24, '2010-03-16', 5, 127.07),
  (null, 43, 25, '2010-03-17', 6, 143.59),
  (null, 44, 28, '2010-03-18', 4, 413.07),
  (null, 45, 29, '2010-03-19', 3, 457.59),
  (null, 46, 32, '2010-03-20', 6, 213.07),
  (null, 47, 33, '2010-03-16', 6, 89.59),
  (null, 48, 16, '2010-03-17', 6, 1230.59),
  (null, 49, 27, '2010-03-18', 6, 613.07),
  (null, 50, 30, '2010-03-19', 6, 11.59),
  (null, 51, 4, '2010-03-20', 3, 10.79),
  (null, 52, 2, '2010-03-03', 6, 11.60),
  (null, 53, 3, '2010-03-04', 4, 10.80),
  (null, 54, 5, '2010-03-05', 6, 11.61),
  (null, 55, 5, '2010-03-06', 3, 10.81),
  (null, 56, 6, '2010-01-07', 2, 11.62),
  (null, 57, 8, '2010-05-08', 6, 10.82),
  (null, 58, 7, '2010-05-09', 6, 11.63),
  (null, 59, 7, '2010-05-10', 5, 0.43),
  (null, 60, 9, '2010-05-24', 4, 59.49),
  (null, 60, 10, '2010-05-25', 6, 76.49),
  (null, 61, 11, '2010-05-26', 5, 18.71),
  (null, 61, 13, '2010-05-27', 3, 18.73),
  (null, 62, 12, '2010-05-28', 5, 18.74),
  (null, 62, 13, '2010-05-16', 6, 29.75),
  (null, 63, 14, '2010-05-17', 6, 22.95),
  (null, 63, 15, '2010-05-18', 6, 32.30),
  (null, 64, 16, '2010-05-19', 6, 18.70),
  (null, 64, 17, '2010-05-20', 6, 29.75),
  (null, 65, 18, '2010-05-16', 6, 23.87),
  (null, 65, 19, '2010-05-17', 4, 27.21),
  (null, 66, 20, '2010-05-18', 6, 9.34),
  (null, 66, 21, '2010-05-19', 3, 9.34),
  (null, 67, 22, '2010-05-20', 8, 8.41),
  (null, 67, 23, '2010-05-03', 9, 10.26),
  (null, 68, 24, '2010-05-04', 6, 13.57),
  (null, 68, 25, '2010-05-05', 6, 13.53),
  (null, 69, 26, '2010-01-06', 9, 16.99),
  (null, 70, 1, '2010-01-07', 8, 84.99),
  (null, 70, 2, '2010-08-08', 6, 101.99),
  (null, 71, 3, '2010-08-09', 7, 29.75),
  (null, 71, 4, '2010-08-10', 6, 29.75),
  (null, 72, 5, '2010-08-24', 7, 31.45),
  (null, 72, 6, '2010-08-25', 6, 31.45),
  (null, 73, 7, '2010-08-26', 7, 22.95),
  (null, 73, 8, '2010-08-27', 5, 32.36),
  (null, 74, 9, '2010-08-28', 7, 18.79),
  (null, 74, 10, '2010-08-16', 4, 29.75),
  (null, 75, 11, '2010-08-17', 3, 23.87),
  (null, 75, 12, '2010-08-18', 7, 27.25),
  (null, 76, 14, '2010-08-19', 3, 9.34),
  (null, 76, 15, '2010-08-20', 7, 9.34),
  (null, 77, 17, '2010-08-16', 7, 8.41),
  (null, 77, 18, '2010-08-17', 2, 10.25),
  (null, 78, 20, '2010-08-18', 7, 16.99),
  (null, 78, 21, '2010-08-19', 4, 23.99),
  (null, 79, 24, '2010-08-20', 7, 118.43),
  (null, 79, 25, '2010-08-03', 3, 101.15),
  (null, 80, 28, '2010-08-04', 7, 16.99),
  (null, 80, 29, '2010-08-05', 7, 22.09),
  (null, 81, 32, '2010-08-06', 8, 16.99),
  (null, 81, 33, '2010-08-07', 4, 22.09),
  (null, 82, 16, '2010-08-08', 5, 33.99),
  (null, 82, 17, '2010-01-09', 8, 50.99),
  (null, 83, 10, '2010-01-10', 8, 8.99);