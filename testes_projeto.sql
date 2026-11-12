/* =====================================================
   ROTEIRO DE TESTES - varejo_de_roupas

   - NAO use Alt+X neste arquivo: alguns testes geram erro
     DE PROPOSITO (marcados com "ERRO ESPERADO").
   - Os testes das partes 5 e 6 usam variaveis (@): rode-os
     na mesma aba, na ordem em que aparecem.
   ===================================================== */

use varejo_de_roupas;


/* =====================================
   PARTE 1 - ESTRUTURA
   ===================================== */

-- 1.1 Esperado: 10 tabelas
show tables;

-- 1.2 Esperado: clientes 10, funcionarios 10, fornecedores 10, categorias 5,
--   forma_de_pagamento 4, produtos 10, vendas 10, itens_venda 14,
--   pagamentos 10, estoque_movimentacao 9
select 'clientes' as tabela, count(*) as total from clientes
union all select 'funcionarios', count(*) from funcionarios
union all select 'fornecedores', count(*) from fornecedores
union all select 'categorias', count(*) from categorias
union all select 'forma_de_pagamento', count(*) from forma_de_pagamento
union all select 'produtos', count(*) from produtos
union all select 'vendas', count(*) from vendas
union all select 'itens_venda', count(*) from itens_venda
union all select 'pagamentos', count(*) from pagamentos
union all select 'estoque_movimentacao', count(*) from estoque_movimentacao;

-- 1.3 Esperado: 3 triggers
--   trg_valida_estoque_venda, trg_baixa_estoque_venda, trg_impede_estoque_negativo
show triggers;


/* =====================================
   PARTE 2 - CONFERENCIA DOS UPDATES
   ===================================== */

-- 2.1 valor_total recalculado (UPDATE 01)
-- Esperado, de idvenda 1 a 10:
--   265.20, 119.90, 139.80, 79.90, 299.40, 94.80, 119.90, 79.90, 159.70, 34.90
select idvenda, valor_total from vendas order by idvenda;

-- 2.2 reajuste de 10% nas jaquetas (UPDATE 02)
-- Esperado: Jaqueta de Couro 164.89 e Casaco de Frio Acolchoado 131.89
select nome, preco
from produtos
where idcategoria = (select idcategoria from categorias where nome_categoria = 'Jaquetas');

-- 2.3 telefone corrigido (UPDATE 03). Esperado: 46999716500
select nome, telefone from clientes where nome = 'Cleiton de Quadros';

-- 2.4 promocao de cargo (UPDATE 04). Esperado: Gerente
select nome, cargo from funcionarios where nome = 'Eduardo de Almeida';

-- 2.5 correcao de estoque (UPDATE 05). Esperado: 42
select nome, estoque_atual from produtos where nome = 'Boné Aba Reta';

-- 2.6 pagamentos iguais ao total da venda (UPDATE EXTRA). Esperado: 0 divergentes
select count(*) as divergentes
from pagamentos p
join vendas v on v.idvenda = p.idvenda
where p.valor <> v.valor_total;


/* =====================================
   PARTE 3 - CONFERENCIA DOS DELETES
   ===================================== */

-- 3.1 Esperado: 0 em todas as quatro linhas (DELETE 01 a 04)
select 'cliente teste' as registro, count(*) as encontrados
from clientes where nome = 'cliente teste cadastro duplicado'
union all
select 'categoria por engano', count(*)
from categorias where nome_categoria = 'calca cargo'
union all
select 'fornecedor cancelado', count(*)
from fornecedores where nome = 'fornecedor cancelado Ltda'
union all
select 'produto descontinuado', count(*)
from produtos where nome = 'produto descontinuado teste';

-- 3.2 DELETE 05. Esperado: 0 (a entrada de 45 do Cinto de Couro foi removida)
select count(*) as movimentacoes_cinto
from estoque_movimentacao
where idproduto = (select idproduto from produtos where nome = 'Cinto de Couro');


/* =====================================
   PARTE 4 - RELATORIOS
   ===================================== */

-- 4.1 RELATORIO 01: estoque baixo (WHERE + ORDER BY)
-- Esperado: 2 linhas, nesta ordem:
--   Casaco de Frio Acolchoado | 10 | 131.89
--   Jaqueta de Couro          | 15 | 164.89
select nome, estoque_atual, preco
from produtos
where estoque_atual < 20
order by estoque_atual asc;

-- 4.2 RELATORIO 02: desempenho geral (funcoes agregadas)
-- Esperado: total_vendas 10 | faturamento 1393.40 | ticket_medio 139.34
--           maior_venda 299.40 | menor_venda 34.90
select
    count(*)         as total_vendas,
    sum(valor_total) as faturamento_total,
    avg(valor_total) as ticket_medio,
    max(valor_total) as maior_venda,
    min(valor_total) as menor_venda
from vendas;

-- 4.3 RELATORIO 03: extrato das vendas (JOIN simples, 3 tabelas)
-- Esperado: 10 linhas, com NOMES (nao numeros).
--   Primeira: venda 1 | Lucas Antonio | Eduardo de Almeida | 2026-01-11 09:15 | 265.20
--   Ultima:   venda 10 | Cleiton de Quadros | Gabriela Noara | 2026-10-08 17:00 | 34.90
select
    v.idvenda,
    c.nome  as cliente,
    f.nome  as vendedor,
    v.data_venda,
    v.valor_total
from vendas v
join clientes c     on c.idcliente = v.idcliente
join funcionarios f on f.idfuncionario = v.idfuncionario
order by v.data_venda;

-- 4.4 RELATORIO 04: vendas por produto (JOIN + LEFT JOIN)
-- Esperado: 10 linhas, em ordem decrescente de unidades:
--   Camiseta Over Sized Premium Preta 8 | Camiseta Casual Preta 7
--   Calça Social 3 | Boné Aba Reta 3 | Cinto de Couro 2
--   Tênis Casual Branco 1 | Chinelo Masculino 1 | Casaco de Frio Acolchoado 1
--   Calça Sarja 0 | Jaqueta de Couro 0
select
    p.nome                          as produto,
    c.nome_categoria                as categoria,
    fo.nome                         as fornecedor,
    coalesce(sum(iv.quantidade), 0) as unidades_vendidas
from produtos p
join categorias c        on c.idcategoria = p.idcategoria
join fornecedores fo     on fo.idfornecedor = p.idfornecedor
left join itens_venda iv on iv.idproduto = p.idproduto
group by p.idproduto, p.nome, c.nome_categoria, fo.nome
order by unidades_vendidas desc;

-- 4.4b DEMONSTRACAO DO LEFT JOIN: mesma consulta trocando LEFT JOIN por JOIN.
-- Esperado: so 8 linhas. Calça Sarja e Jaqueta de Couro SOMEM, porque
-- nunca foram vendidas e o JOIN comum descarta quem nao tem correspondencia.
select
    p.nome                          as produto,
    c.nome_categoria                as categoria,
    fo.nome                         as fornecedor,
    coalesce(sum(iv.quantidade), 0) as unidades_vendidas
from produtos p
join categorias c    on c.idcategoria = p.idcategoria
join fornecedores fo on fo.idfornecedor = p.idfornecedor
join itens_venda iv  on iv.idproduto = p.idproduto
group by p.idproduto, p.nome, c.nome_categoria, fo.nome
order by unidades_vendidas desc;

-- 4.5 RELATORIO 05: vendas acima do ticket medio (subquery no WHERE)
-- Esperado: 4 linhas, nesta ordem:
--   Luiz Sencoski 299.40 | Lucas Antonio 265.20 | Victor Luiz 159.70 | Sofia Gabriele 139.80
select
    v.idvenda,
    c.nome as cliente,
    v.data_venda,
    v.valor_total
from vendas v
join clientes c on c.idcliente = v.idcliente
where v.valor_total > (select avg(valor_total) from vendas)
order by v.valor_total desc;

-- 4.6 RELATORIO 05 (variacao): subquery no SELECT
-- Esperado: diferenca positiva nas vendas 1, 3, 5 e 9 (acima de 139.34)
-- e negativa nas demais. Ex.: venda 1 = 125.86 | venda 5 = 160.06 | venda 10 = -104.44
select idvenda, valor_total,
       valor_total - (select avg(valor_total) from vendas) as diferenca_da_media
from vendas;


/* =====================================
   PARTE 5 - TRIGGERS (demonstracao ao vivo)
   Rode na ordem, na mesma aba.
   ===================================== */

-- ---------- TESTE 1: baixa automatica (trg_baixa_estoque_venda) ----------

-- 5.1 ANTES. Esperado: Calça Sarja com estoque 25
select nome, estoque_atual from produtos where nome = 'Calça Sarja';

-- 5.2 Cria uma venda nova
insert into vendas (idcliente, idfuncionario, data_venda) values
((select idcliente from clientes where nome = 'Lucas Antonio'),
 (select idfuncionario from funcionarios where nome = 'Angelo Hank'),
 '2026-11-11 10:00:00');

-- 5.3 Guarda os IDs em variaveis (necessario por causa do erro 1442:
--     o INSERT nao pode ler produtos enquanto o trigger altera produtos)
set @id_venda = (select idvenda from vendas where data_venda = '2026-11-11 10:00:00');
set @id_prod  = (select idproduto from produtos where nome = 'Calça Sarja');

-- 5.4 Vende 3 calcas sarja: os triggers 1 e 2 disparam aqui
insert into itens_venda (idvenda, idproduto, quantidade, preco_unitario)
values (@id_venda, @id_prod, 3, 69.90);

-- 5.5 DEPOIS. Esperado: estoque 22
select nome, estoque_atual from produtos where nome = 'Calça Sarja';

-- 5.6 Movimentacao criada SOZINHA pelo trigger.
-- Esperado: Calça Sarja | Angelo Hank | saida | 3
select m.idmovimentacao, p.nome as produto, f.nome as funcionario, m.tipo, m.quantidade
from estoque_movimentacao m
join produtos p     on p.idproduto = m.idproduto
join funcionarios f on f.idfuncionario = m.idfuncionario
order by m.idmovimentacao desc
limit 1;

-- ---------- TESTE 2: estoque insuficiente (trg_valida_estoque_venda) ----------

-- 5.7 O Casaco de Frio tem 10 em estoque; tentar vender 11.
-- ERRO ESPERADO: estoque insuficiente para este produto
set @id_prod2 = (select idproduto from produtos where nome = 'Casaco de Frio Acolchoado');

insert into itens_venda (idvenda, idproduto, quantidade, preco_unitario)
values (@id_venda, @id_prod2, 11, 119.90);

-- 5.8 Nada foi gravado. Esperado: estoque do Casaco continua 10
select nome, estoque_atual from produtos where nome = 'Casaco de Frio Acolchoado';

-- 5.9 Esperado: so 1 item na venda nova (a Calça Sarja)
select * from itens_venda where idvenda = @id_venda;

-- ---------- TESTE 3: estoque negativo (trg_impede_estoque_negativo) ----------

-- 5.10 ERRO ESPERADO: estoque nao pode ficar negativo
update produtos set estoque_atual = -5 where nome = 'Boné Aba Reta';

-- 5.11 Esperado: continua 42
select nome, estoque_atual from produtos where nome = 'Boné Aba Reta';


/* =====================================
   PARTE 6 - INTEGRIDADE (perguntas comuns do professor)
   ===================================== */

-- 6.1 Nao da para apagar cliente que ja comprou.
-- ERRO ESPERADO: Cannot delete or update a parent row: a foreign key constraint fails
delete from clientes where nome = 'Lucas Antonio';

-- 6.2 A chave composta impede o mesmo produto duas vezes na mesma venda.
-- ERRO ESPERADO: Duplicate entry ... for key 'PRIMARY'
set @venda1 = (select idvenda from vendas where data_venda = '2026-01-11 09:15:00');
set @bone   = (select idproduto from produtos where nome = 'Boné Aba Reta');

insert into itens_venda (idvenda, idproduto, quantidade, preco_unitario)
values (@venda1, @bone, 1, 34.90);


/* =====================================
   PARTE 7 - LIMPEZA (volta os dados ao estado original)
   Rode depois dos testes e antes de apresentar.
   ===================================== */

delete from itens_venda where idvenda = @id_venda;

delete from vendas where data_venda = '2026-11-11 10:00:00';

delete from estoque_movimentacao where tipo = 'saida';

update produtos set estoque_atual = 25 where nome = 'Calça Sarja';

-- Conferencia final. Esperado: vendas 10, itens_venda 14, estoque_movimentacao 9,
-- Calça Sarja com 25
select
    (select count(*) from vendas)                as vendas,
    (select count(*) from itens_venda)           as itens_venda,
    (select count(*) from estoque_movimentacao)  as estoque_movimentacao,
    (select estoque_atual from produtos where nome = 'Calça Sarja') as estoque_calca_sarja;
