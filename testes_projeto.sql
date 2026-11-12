Demonstracao  SQL
/* =====================================================
   DEMONSTRACAO AO VIVO - varejo_de_roupas
 
   ANTES DE APRESENTAR
   - Abra este arquivo na MESMA conexao (localhost).
   - Rode UM comando por vez: clique na linha e aperte Ctrl+Enter.
   - NAO use Alt+X aqui (o passo 7 gera um erro de proposito).
   - Os passos 7.1 a 7.4 usam variaveis (@): mesma aba, na ordem.
   ===================================================== */
use varejo_de_roupas;
-- =====================================================
-- 1. TABELAS E REGISTROS
--    Mostre o DER primeiro. Depois, a tabela associativa do N:N.
--    "itens_venda liga vendas e produtos; a chave e composta"
-- =====================================================
select * from itens_venda;
 
 
-- =====================================================
-- 2. SELECT COM FILTRO E ORDENACAO (Relatorio 1)
--    "o gerente quer saber o que esta acabando para repor"
--    Esperado: Casaco de Frio (10) e Jaqueta de Couro (15)
-- =====================================================
select nome, estoque_atual, preco
from produtos
where estoque_atual < 20
order by estoque_atual asc;
 
 
-- =====================================================
-- 3. FUNCAO AGREGADA (Relatorio 2)
--    Esperado: 10 vendas | 1393.40 | 139.34 | 299.40 | 34.90
-- =====================================================
select
    count(*)         as total_vendas,
    sum(valor_total) as faturamento_total,
    avg(valor_total) as ticket_medio,
    max(valor_total) as maior_venda,
    min(valor_total) as menor_venda
from vendas;
 
 
-- =====================================================
-- 4. JOIN (Relatorio 3)
--    "cada JOIN liga a chave estrangeira a chave primaria"
--    Esperado: 10 linhas, com nomes de cliente e vendedor
-- =====================================================
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
 
 
-- =====================================================
-- 5. JOIN + LEFT JOIN (Relatorio 4)
--    Esperado: 10 linhas; Calça Sarja e Jaqueta de Couro com 0
-- =====================================================
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
 
-- 5b. Mesma consulta com JOIN comum no lugar do LEFT JOIN
--     Esperado: so 8 linhas; os produtos sem venda SOMEM
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
 
 
-- =====================================================
-- 6. SUBQUERY (Relatorio 5)
--    "a subquery calcula a media; a consulta de fora compara"
--    Esperado: 4 vendas (299.40, 265.20, 159.70, 139.80)
-- =====================================================
select
    v.idvenda,
    c.nome as cliente,
    v.data_venda,
    v.valor_total
from vendas v
join clientes c on c.idcliente = v.idcliente
where v.valor_total > (select avg(valor_total) from vendas)
order by v.valor_total desc;
 
 
-- =====================================================
-- 7. TRIGGERS
--  mostrar o codigo dos triggers enquanto explica.
-- =====================================================
 
-- 7.1 ANTES: estoque da Calça Sarja. Esperado: 25
select nome, estoque_atual from produtos where nome = 'Calça Sarja';
 
-- 7.2 Cria uma venda nova
insert into vendas (idcliente, idfuncionario, data_venda) values
((select idcliente from clientes where nome = 'Lucas Antonio'),
 (select idfuncionario from funcionarios where nome = 'Angelo Hank'),
 '2026-11-11 10:00:00');
 
-- 7.3 Guarda os IDs e vende 3 calcas sarja (os triggers disparam aqui)
set @id_venda = (select idvenda from vendas where data_venda = '2026-11-11 10:00:00');
set @id_prod  = (select idproduto from produtos where nome = 'Calça Sarja');
 
insert into itens_venda (idvenda, idproduto, quantidade, preco_unitario)
values (@id_venda, @id_prod, 3, 69.90);
 
-- 7.4 DEPOIS: estoque caiu sozinho. Esperado: 22
select nome, estoque_atual from produtos where nome = 'Calça Sarja';
 
-- 7.5 A saida foi registrada pelo trigger.
--     Esperado: Calça Sarja | Angelo Hank | saida | 3
select m.idmovimentacao, p.nome as produto, f.nome as funcionario, m.tipo, m.quantidade
from estoque_movimentacao m
join produtos p     on p.idproduto = m.idproduto
join funcionarios f on f.idfuncionario = m.idfuncionario
order by m.idmovimentacao desc
limit 1;
 
-- 7.6 BLOQUEIO: o Casaco tem 10 em estoque; tentar vender 11.
--     ERRO ESPERADO: estoque insuficiente para este produto
--     (na janela de erro, clique em Pular ou Parar)
set @id_prod2 = (select idproduto from produtos where nome = 'Casaco de Frio Acolchoado');
 
insert into itens_venda (idvenda, idproduto, quantidade, preco_unitario)
values (@id_venda, @id_prod2, 11, 119.90);
 
-- 7.7 (opcional) Terceiro trigger.
--     ERRO ESPERADO: estoque nao pode ficar negativo
update produtos set estoque_atual = -5 where nome = 'Boné Aba Reta';
 
-- =====================================================
-- 8. LIMPEZA
--    Esperado no final: vendas 10 | itens_venda 14 | movimentacoes 9 | estoque 25
-- =====================================================
delete from itens_venda where idvenda = @id_venda;
 
delete from vendas where data_venda = '2026-11-11 10:00:00';
 
delete from estoque_movimentacao where tipo = 'saida';
 
update produtos set estoque_atual = 25 where nome = 'Calça Sarja';
 
select
    (select count(*) from vendas)               as vendas,
    (select count(*) from itens_venda)          as itens_venda,
    (select count(*) from estoque_movimentacao) as movimentacoes,
    (select estoque_atual from produtos where nome = 'Calça Sarja') as estoque_calca_sarja;
