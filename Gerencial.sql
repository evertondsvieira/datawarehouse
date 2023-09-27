CREATE TABLE mes (
  mes integer primary key,
  nome varchar(50) not null
);

CREATE TABLE diasemana (
  diadasemana integer primary key,
  nome varchar(20) not null
);

CREATE TABLE produto (
  cod_prod serial primary key,
  descricao varchar(255) not null
);

CREATE TABLE categoria (
  cod_categoria serial primary key,
  descricao varchar(255) not null
);

CREATE TABLE cliente (
  cpf numeric(15) primary key,
  nome varchar(255) NOT NULL,
  ultima_venda timestamp
);

CREATE TABLE funcionario (
  matricula serial primary key,
  nome varchar(255) NOT NULL
);

CREATE TABLE loja (
  cod serial primary key,
  cnpj varchar(20) NOT NULL
);

CREATE TABLE fatocompras (
  ano integer,
  mes integer,
  cod_prod serial,
  qtde integer,
  valor_total numeric(10, 2) NULL,
  constraint fk_compra2 foreign key(mes) references mes(mes),
  constraint fk_compra3 foreign key(cod_prod) references produto(cod_prod)
);

CREATE TABLE fatolucratividade (
  ano integer,
  mes integer,
  cod_prod serial,
  lucro numeric(10, 2),
  constraint fk_lucro2 foreign key(mes) references mes(mes),
  constraint fk_lucro3 foreign key(cod_prod) references produto(cod_prod)
);

CREATE TABLE fatovendasatendgasto (
  ano integer,
  mes integer,
  dia integer,
  diadasemana integer,
  cod_prod serial,
  cod_categoria serial,
  qtde integer,
  cod_loja serial,
  cpf numeric(15),
  matricula serial,
  valor numeric(10, 2),
  media_gasto numeric(10, 2),
  constraint fk_vf2 foreign key(mes) references mes(mes),
  constraint fk_vf3 foreign key(diadasemana) references diasemana(diadasemana),
  constraint fk_vf4 foreign key(cod_prod) references produto(cod_prod),
  constraint fk_vf5 foreign key(cod_categoria) references categoria(cod_categoria),
  constraint fk_vf6 foreign key(cod_loja) references loja(cod),
  constraint fk_vf7 foreign key(cpf) references cliente(cpf),
  constraint fk_vf8 foreign key(matricula) references funcionario(matricula)
);

-- Views criadas para facilitar as operações no DW
-- Facilita insert em fatolucratividade
CREATE VIEW tempfatolucro AS
SELECT
  p.cod_prod,
  to_char(c.tb012_017_data, 'YYYYMM') AS mesano,
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ) AS ano,
  c.tb012_cod_produto,
  SUM(
    c.tb012_017_quantidade * c.tb012_017_valor_unitario
  ) AS custo,
  SUM(
    v.tb010_012_quantidade * v.tb010_012_valor_unitario
  ) AS receita
FROM
  tb012_017_compras c
  LEFT JOIN tb010_012_vendas v ON c.tb012_cod_produto = v.tb012_cod_produto
GROUP BY
  p.cod_prod,
  mesano,
  ano,
  c.tb012_cod_produto;

-- Fato Ultima compra do cliente
CREATE VIEW fatoultimacompra AS
SELECT
  cpf,
  nome,
  EXTRACT(
    DAY
    FROM
      (CURRENT_DATE - ultima_venda)
  ) AS "Dias da Ultima Venda"
FROM
  cliente;

-- Inserts Iniciais que populam as tabelas sem Fks no DW
INSERT INTO
  produto (descricao)
SELECT
  DISTINCT tb012_descricao
FROM
  tb012_produtos;

INSERT INTO
  categoria (descricao)
SELECT
  DISTINCT tb013_descricao
FROM
  tb013_categorias;

INSERT INTO
  cliente (cpf, nome)
SELECT
  tb010_cpf,
  tb010_nome
FROM
  tb010_clientes;

INSERT INTO
  diasemana (diadasemana, nome)
VALUES
  (0, 'Segunda'),
  (1, 'Terça'),
  (2, 'Quarta'),
  (3, 'Quinta'),
  (4, 'Sexta'),
  (5, 'Sábado'),
  (6, 'Domingo');

INSERT INTO
  mes (mes, nome)
VALUES
  (1, 'Janeiro'),
  (2, 'Fevereiro'),
  (3, 'Março'),
  (4, 'Abril'),
  (5, 'Maio'),
  (6, 'Junho'),
  (7, 'Julho'),
  (8, 'Agosto'),
  (9, 'Setembro'),
  (10, 'Outubro'),
  (11, 'Novembro'),
  (12, 'Dezembro');

INSERT INTO
  funcionario (nome)
SELECT
  DISTINCT tb005_nome_completo
FROM
  tb005_funcionarios;

UPDATE
  cliente
SET
  ultima_venda = (
    SELECT
      MAX(tb010_012_data)
    FROM
      tb010_012_vendas
    WHERE
      tb010_cpf = cliente.cpf
    GROUP BY
      tb010_cpf
  );

INSERT INTO
  loja (cnpj)
SELECT
  DISTINCT tb004_cnpj_loja
FROM
  tb004_lojas;

-- Inserts que populam as tabelas com fks no DW
-- Fato Compra de Produtos
-- Granularidade Total
INSERT INTO
  fatocompras
SELECT
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      c.tb012_017_data
  ) AS mes,
  c.tb012_cod_produto,
  SUM(c.tb012_017_quantidade),
  SUM(
    c.tb012_017_quantidade * c.tb012_017_valor_unitario
  )
FROM
  tb012_017_compras c
GROUP BY
  ano,
  mes,
  c.tb012_cod_produto;

-- Granularidade Ano
INSERT INTO
  fatocompras
SELECT
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ) AS ano,
  NULL AS mes,
  c.tb012_cod_produto,
  SUM(c.tb012_017_quantidade),
  SUM(
    c.tb012_017_quantidade * c.tb012_017_valor_unitario
  )
FROM
  tb012_017_compras c
GROUP BY
  ano,
  c.tb012_cod_produto;

-- Fato Vendas
-- Granularidade Total
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ) AS mes,
  EXTRACT(
    DAY
    FROM
      v.tb010_012_data
  ) AS dia,
  EXTRACT(
    DOW
    FROM
      v.tb010_012_data
  ) AS diadasemana,
  v.tb012_cod_produto,
  p.cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.cod AS cod_loja,
  NULL AS cpf,
  NULL AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON v.tb012_cod_produto = p.cod_prod
  JOIN tb005_funcionarios f ON v.tb005_matricula = f.matricula
  JOIN tb004_lojas l ON f.tb004_cod_loja = l.cod
GROUP BY
  ano,
  mes,
  dia,
  diadasemana,
  v.tb012_cod_produto,
  p.cod_categoria,
  l.cod;

-- Granularidade por dia da Semana de cada mes de cada ano
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ) AS mes,
  NULL AS dia,
  EXTRACT(
    DOW
    FROM
      v.tb010_012_data
  ) AS diadasemana,
  v.tb012_cod_produto,
  p.cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.cod AS cod_loja,
  NULL AS cpf,
  NULL AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON v.tb012_cod_produto = p.cod_prod
  JOIN tb005_funcionarios f ON v.tb005_matricula = f.matricula
  JOIN tb004_lojas l ON f.tb004_cod_loja = l.cod
GROUP BY
  ano,
  mes,
  diadasemana,
  v.tb012_cod_produto,
  p.cod_categoria,
  l.cod;

-- Granularidade por mes
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ) AS mes,
  NULL AS dia,
  NULL AS diadasemana,
  v.tb012_cod_produto,
  p.cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.cod AS cod_loja,
  NULL AS cpf,
  NULL AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON v.tb012_cod_produto = p.cod_prod
  JOIN tb005_funcionarios f ON v.tb005_matricula = f.matricula
  JOIN tb004_lojas l ON f.tb004_cod_loja = l.cod
GROUP BY
  ano,
  mes,
  v.tb012_cod_produto,
  p.cod_categoria,
  l.cod;

-- Granularidade por ano
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ) AS ano,
  NULL AS mes,
  NULL AS dia,
  NULL AS diadasemana,
  v.tb012_cod_produto,
  p.cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.cod AS cod_loja,
  NULL AS cpf,
  NULL AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON v.tb012_cod_produto = p.cod_prod
  JOIN tb005_funcionarios f ON v.tb005_matricula = f.matricula
  JOIN tb004_lojas l ON f.tb004_cod_loja = l.cod
GROUP BY
  ano,
  v.tb012_cod_produto,
  p.cod_categoria,
  l.cod;

-- Fato Gasto Cliente
-- Granularidade Total
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ) AS mes,
  NULL AS dia,
  NULL AS diadasemana,
  NULL AS cod_prod,
  NULL AS cod_categoria,
  SUM(v.tb010_012_quantidade) AS qtde,
  l.cod AS cod_loja,
  v.tb010_cpf AS cpf,
  NULL AS matricula,
  SUM(v.tb010_012_valor_unitario) AS valor,
  (
    SUM(v.tb010_012_valor_unitario) / EXTRACT(
      DAY
      FROM
        LAST_DAY(v.tb010_012_data)
    )
  ) AS media_gasto
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON v.tb012_cod_produto = p.cod_prod
  JOIN tb005_funcionarios f ON v.tb005_matricula = f.matricula
  JOIN tb004_lojas l ON f.tb004_cod_loja = l.cod
GROUP BY
  ano,
  mes,
  l.cod,
  v.tb010_cpf
ORDER BY
  SUM(v.tb010_012_valor_unitario) DESC
LIMIT
  30;

-- Granularidade por ano
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ) AS ano,
  NULL AS mes,
  NULL AS dia,
  NULL AS diadasemana,
  NULL AS cod_prod,
  NULL AS cod_categoria,
  SUM(v.tb010_012_quantidade) AS qtde,
  l.cod AS cod_loja,
  v.tb010_cpf AS cpf,
  NULL AS matricula,
  SUM(v.tb010_012_valor_unitario) AS valor,
  (SUM(v.tb010_012_valor_unitario) / 12) AS media_gasto
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON v.tb012_cod_produto = p.cod_prod
  JOIN tb005_funcionarios f ON v.tb005_matricula = f.matricula
  JOIN tb004_lojas l ON f.tb004_cod_loja = l.cod
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  l.cod,
  v.tb010_cpf
ORDER BY
  SUM(v.tb010_012_valor_unitario) DESC
LIMIT
  30;

-- Fato Atendimentos
-- Granularidade máxima
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      tb010_012_data
  ) AS mes,
  EXTRACT(
    DAY
    FROM
      tb010_012_data
  ) AS dia,
  EXTRACT(
    DOW
    FROM
      tb010_012_data
  ) AS diadasemana,
  NULL AS cod_prod,
  NULL AS cod_categoria,
  COUNT(tb010_012_data) AS qtde,
  NULL AS cod_loja,
  NULL AS cpf,
  tb005_matricula AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas
GROUP BY
  tb005_matricula,
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      tb010_012_data
  ),
  EXTRACT(
    DAY
    FROM
      tb010_012_data
  );

-- Por mês
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  ) AS ano,
  EXTRACT(
    MONTH
    FROM
      tb010_012_data
  ) AS mes,
  NULL AS dia,
  NULL AS diadasemana,
  NULL AS cod_prod,
  NULL AS cod_categoria,
  COUNT(tb010_012_data) AS qtde,
  NULL AS cod_loja,
  NULL AS cpf,
  tb005_matricula AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas
GROUP BY
  tb005_matricula,
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      tb010_012_data
  );

-- Vendas por ano
INSERT INTO
  fatovendasatendgasto
SELECT
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  ) AS ano,
  NULL AS mes,
  NULL AS dia,
  NULL AS diadasemana,
  NULL AS cod_prod,
  NULL AS cod_categoria,
  COUNT(tb010_012_data) AS qtde,
  NULL AS cod_loja,
  NULL AS cpf,
  tb005_matricula AS matricula,
  NULL AS valor,
  NULL AS media_gasto
FROM
  tb010_012_vendas
GROUP BY
  tb005_matricula,
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  );

-- Fato Lucratividade Bruta
-- Granularidade máxima por ano e mes - Lucro por produto no de cada mes de cada ano
-- Lucro por produto por mes de cada ano
INSERT INTO
  fatolucratividade
SELECT
  t.ano,
  t.mesano,
  t.cod_prod,
  (t.receita - t.custo) AS lucro
FROM
  tempfatolucro t;

-- Lucro por produto por ano
INSERT INTO
  fatolucratividade
SELECT
  t.ano,
  NULL AS mes,
  t.cod_prod,
  (SUM(t.receita) - SUM(t.custo)) AS "Lucro Anual"
FROM
  tempfatolucro t
GROUP BY
  t.ano,
  t.cod_prod;