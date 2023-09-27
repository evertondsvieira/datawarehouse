DROP EVENT IF EXISTS DW_FILL_MES CASCADE;


DROP FUNCTION IF EXISTS DW_FATOVENDAS_MES();
DROP FUNCTION IF EXISTS DW_FATOCOMPRAS_MES();
DROP FUNCTION IF EXISTS DW_FATOGASTOCLIENTE_MES();
DROP FUNCTION IF EXISTS DW_FATOLUCRO_MES();
DROP FUNCTION IF EXISTS DW_FATOATENDIMENTO_MES();
DROP FUNCTION IF EXISTS DW_TODOSFATOS_ANUAL();


DROP TRIGGER IF EXISTS TG_DW_CLIENTE ON tb010_clientes;
DROP TRIGGER IF EXISTS TG_DW_LOJA ON tb004_lojas;
DROP TRIGGER IF EXISTS TG_DW_ULTIMA_VENDA ON tb010_012_vendas;
DROP TRIGGER IF EXISTS TG_DW_FUNCIONARIO ON tb005_funcionarios;

-- Criar trigger de tabelas sem FK
-- Trigger dá tb010_clientes
CREATE TRIGGER TG_DW_CLIENTE
AFTER
INSERT
  ON tb010_clientes FOR EACH ROW BEGIN
INSERT INTO
  cliente
VALUES
  (NEW.tb010_cpf, NEW.tb010_nome, NULL);

END;

-- Trigger dá tb004_lojas
CREATE TRIGGER TG_DW_LOJA
AFTER
INSERT
  ON tb004_lojas FOR EACH ROW BEGIN
INSERT INTO
  loja
VALUES
  (NEW.tb004_cod_loja, NEW.tb004_cnpj_loja);

END;

-- Trigger dá tb010_012_vendas
CREATE TRIGGER TG_DW_ULTIMA_VENDA
AFTER
INSERT
  ON tb010_012_vendas FOR EACH ROW BEGIN
UPDATE
  cliente
SET
  ultima_venda = NEW.tb010_012_data
WHERE
  cpf = NEW.tb010_cpf;

END;

-- Trigger dá tb005_funcionarios
CREATE TRIGGER TG_DW_FUNCIONARIO
AFTER
INSERT
  ON tb005_funcionarios FOR EACH ROW BEGIN
INSERT INTO
  funcionario
VALUES
  (NEW.tb005_matricula, NEW.tb005_nome_completo);

END;

-- Crie o evento mensal para atualizar os dados do DW
CREATE
OR REPLACE FUNCTION DW_FILL_MES() RETURNS event_trigger LANGUAGE plpgsql BEGIN -- Se for o primeiro mês do ano, atualiza os fatos granulares anuais
IF EXTRACT(
  MONTH
  FROM
    NOW()
) = 1 THEN PERFORM DW_TODOSFATOS_ANUAL();

END IF;

PERFORM DW_FATOVENDAS_MES();

PERFORM DW_FATOCOMPRAS_MES();

PERFORM DW_FATOGASTOCLIENTE_MES();

PERFORM DW_FATOLUCRO_MES();

PERFORM DW_FATOATENDIMENTO_MES();

END;

-- Evento para acontecer mensalmente
CREATE EVENT DW_FILL_MES ON SCHEDULE EVERY 1 MONTH STARTS '2023-01-01 00:00:00' DO BEGIN PERFORM DW_FILL_MES();

END;

-- Criar procedure DW_FATOVENDAS_MES
CREATE
OR REPLACE FUNCTION DW_FATOVENDAS_MES() RETURNS void LANGUAGE plpgsql BEGIN -- Granularity by day of the week, day, month, and year
INSERT INTO
  fatovendas
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    DAY
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    DOW
    FROM
      v.tb010_012_data
  ),
  v.tb012_cod_produto,
  p.tb013_cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.tb004_cod_loja
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON p.tb012_cod_produto = v.tb012_cod_produto
  JOIN tb005_funcionarios f ON f.tb005_matricula = v.tb005_matricula
  JOIN tb004_lojas l ON l.tb004_cod_loja = f.tb004_cod_loja
WHERE
  v.tb010_012_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    DAY
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    DOW
    FROM
      v.tb010_012_data
  ),
  v.tb012_cod_produto,
  l.tb004_cod_loja;

-- Granularidade por dia da semana para cada mês
INSERT INTO
  fatovendas
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  NULL,
  EXTRACT(
    DOW
    FROM
      v.tb010_012_data
  ),
  v.tb012_cod_produto,
  p.tb013_cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.tb004_cod_loja
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON p.tb012_cod_produto = v.tb012_cod_produto
  JOIN tb005_funcionarios f ON f.tb005_matricula = v.tb005_matricula
  JOIN tb004_lojas l ON l.tb004_cod_loja = f.tb004_cod_loja
WHERE
  v.tb010_012_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    DOW
    FROM
      v.tb010_012_data
  ),
  v.tb012_cod_produto,
  l.tb004_cod_loja;

-- Granularidade por mês
INSERT INTO
  fatovendas
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  NULL,
  NULL,
  v.tb012_cod_produto,
  p.tb013_cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.tb004_cod_loja
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON p.tb012_cod_produto = v.tb012_cod_produto
  JOIN tb005_funcionarios f ON f.tb005_matricula = v.tb005_matricula
  JOIN tb004_lojas l ON l.tb004_cod_loja = f.tb004_cod_loja
WHERE
  v.tb010_012_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  v.tb012_cod_produto,
  l.tb004_cod_loja;

END;

-- Criar procedure DW_FATOCOMPRAS_MES
CREATE
OR REPLACE FUNCTION DW_FATOCOMPRAS_MES() RETURNS void LANGUAGE plpgsql BEGIN -- Fato Compra de Produtos
-- Granularidade Total - Compras por mês e ano
INSERT INTO
  fatocompras
SELECT
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ),
  EXTRACT(
    MONTH
    FROM
      c.tb012_017_data
  ),
  c.tb012_cod_produto,
  SUM(c.tb012_017_quantidade),
  SUM(c.tb012_017_valor_unitario)
FROM
  tb012_017_compras c
WHERE
  c.tb012_017_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ),
  EXTRACT(
    MONTH
    FROM
      c.tb012_017_data
  ),
  c.tb012_cod_produto;

END;

-- Criar procedure DW_FATOGASTOCLIENTE_MES
CREATE
OR REPLACE FUNCTION DW_FATOGASTOCLIENTE_MES() RETURNS void LANGUAGE plpgsql BEGIN -- Fato sobre gastos do cliente
-- Não é possível visualizar a forma de pagamento porque não há campo indicando
-- Os gastos do cliente serão calculados por um período de tempo
-- Granularidade total para o mês e ano
INSERT INTO
  fatogastocliente
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  v.tb010_cpf,
  SUM(v.tb010_012_quantidade) AS qtde,
  SUM(v.tb010_012_valor_unitario) AS valor,
  (
    SUM(v.tb010_012_valor_unitario) / EXTRACT(
      DAY
      FROM
        LAST_DAY(v.tb010_012_data)
    )
  ) AS media_por_dia
FROM
  tb010_012_vendas v
WHERE
  v.tb010_012_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  EXTRACT(
    MONTH
    FROM
      v.tb010_012_data
  ),
  v.tb010_cpf
ORDER BY
  SUM(v.tb010_012_valor_unitario) DESC
LIMIT
  20;

END;

-- Criando procedure DW_FATOLUCRO_MES
CREATE
OR REPLACE FUNCTION DW_FATOLUCRO_MES() RETURNS void LANGUAGE plpgsql BEGIN -- Profit per product per month of each year
INSERT INTO
  fatolucratividade
SELECT
  AnoNum,
  mesAno,
  cod_prod,
  (receita - custo)
FROM
  tempFatoLucro
WHERE
  data2 BETWEEN NOW() - INTERVAL '1 month'
  AND NOW();

END;

-- Criando procedure DW_FATOATENDIMENTO_MES
CREATE
OR REPLACE FUNCTION DW_FATOATENDIMENTO_MES() RETURNS void LANGUAGE plpgsql BEGIN -- Atendimentos per day, month, and year
INSERT INTO
  fatoatendimento
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
  tb005_matricula AS matricula,
  COUNT(tb010_012_data) AS qtde
FROM
  tb010_012_vendas
WHERE
  tb010_012_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
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

-- Atendimentos por mês
INSERT INTO
  fatoatendimento
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
  tb005_matricula AS matricula,
  COUNT(tb010_012_data) AS qtde
FROM
  tb010_012_vendas
WHERE
  tb010_012_data BETWEEN NOW() - INTERVAL '1 month'
  AND NOW()
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

END;

-- Criando procedure DW_TODOSFATOS_ANUAL
CREATE
OR REPLACE FUNCTION DW_TODOSFATOS_ANUAL() RETURNS void LANGUAGE plpgsql BEGIN -- Granularity by year - Fact Sales
INSERT INTO
  fatovendas
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  NULL,
  NULL,
  NULL,
  v.tb012_cod_produto,
  p.tb013_cod_categoria,
  SUM(v.tb010_012_quantidade),
  l.tb004_cod_loja
FROM
  tb010_012_vendas v
  JOIN tb012_produtos p ON p.tb012_cod_produto = v.tb012_cod_produto
  JOIN tb005_funcionarios f ON f.tb005_matricula = v.tb005_matricula
  JOIN tb004_lojas l ON l.tb004_cod_loja = f.tb004_cod_loja
WHERE
  v.tb010_012_data BETWEEN NOW() - INTERVAL '1 year'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  v.tb012_cod_produto,
  l.tb004_cod_loja;

-- Granularidade por ano - Fato Vendas
INSERT INTO
  fatocompras
SELECT
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ),
  NULL,
  c.tb012_cod_produto,
  SUM(c.tb012_017_quantidade),
  SUM(c.tb012_017_valor_unitario)
FROM
  tb012_017_compras c
WHERE
  c.tb012_017_data BETWEEN NOW() - INTERVAL '1 year'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      c.tb012_017_data
  ),
  c.tb012_cod_produto;

-- Granularidade por ano - Gasto Cliente
INSERT INTO
  fatogastocliente
SELECT
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  NULL,
  v.tb010_cpf,
  SUM(v.tb010_012_quantidade) AS qtde,
  SUM(v.tb010_012_valor_unitario) AS valor,
  (SUM(v.tb010_012_valor_unitario) / 12) AS media_por_mes
FROM
  tb010_012_vendas v
WHERE
  v.tb010_012_data BETWEEN NOW() - INTERVAL '1 year'
  AND NOW()
GROUP BY
  EXTRACT(
    YEAR
    FROM
      v.tb010_012_data
  ),
  v.tb010_cpf
ORDER BY
  SUM(v.tb010_012_valor_unitario) DESC
LIMIT
  20;

-- Fato lucro por ano - fatolucratividade
INSERT INTO
  fatolucratividade
SELECT
  AnoNum,
  NULL,
  cod_prod,
  (SUM(receita) - SUM(custo)) AS "Lucro Anual"
FROM
  tempFatoLucro
WHERE
  data2 BETWEEN NOW() - INTERVAL '1 year'
  AND NOW()
GROUP BY
  cod_prod,
  AnoNum;

-- Fato atendimento por ano
INSERT INTO
  fatoatendimento
SELECT
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  ) AS ano,
  NULL AS mes,
  NULL AS dia,
  tb005_matricula AS matricula,
  COUNT(tb010_012_data) AS qtde
FROM
  tb010_012_vendas
WHERE
  tb010_012_data BETWEEN NOW() - INTERVAL '1 year'
  AND NOW()
GROUP BY
  tb005_matricula,
  EXTRACT(
    YEAR
    FROM
      tb010_012_data
  );
END;