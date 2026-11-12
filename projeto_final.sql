/* =====================================================
   PROJETO INTEGRADOR - BANCO DE DADOS
   Tema : Varejo de roupas
   Aluno: Eduardo de Almeida Farias
   SGBD : MariaDB (executado no DBeaver)

   Como executar: abrir este arquivo no DBeaver e rodar
   o script inteiro (Alt+X) em uma conexao MariaDB.
   O script recria o banco do zero a cada execucao.
   ===================================================== */


/* =====================================
   1. CRIACAO DO BANCO
   ===================================== */

drop database if exists varejo_de_roupas;

create database varejo_de_roupas
    character set utf8mb4
    collate utf8mb4_general_ci;

use varejo_de_roupas;


/* =====================================
   2. CRIACAO DAS TABELAS
   ===================================== */

-- Tabelas sem dependencia (nao possuem chave estrangeira)

create table clientes (
    idcliente int auto_increment primary key,
    nome varchar(50) not null,
    telefone varchar(20),
    data_cadastro date default (current_date)
);

create table funcionarios (
    idfuncionario int auto_increment primary key,
    nome varchar(50) not null,
    cargo varchar(50),
    data_admissao date
);

create table fornecedores (
    idfornecedor int auto_increment primary key,
    nome varchar(50) not null,
    cnpj varchar(18) unique,
    telefone varchar(20)
);

create table categorias (
    idcategoria int auto_increment primary key,
    nome_categoria varchar(50) not null,
    descricao varchar(200)
);

create table forma_de_pagamento (
    idforma int auto_increment primary key,
    descricao varchar(30) not null
);

-- Tabelas que dependem das anteriores (possuem chave estrangeira)

create table produtos (
    idproduto int auto_increment primary key,
    nome varchar(50) not null,
    preco decimal(10,2) not null,
    estoque_atual int default 0,
    idcategoria int not null,
    idfornecedor int not null,
    foreign key (idcategoria) references categorias(idcategoria),
    foreign key (idfornecedor) references fornecedores(idfornecedor)
);

create table vendas (
    idvenda int auto_increment primary key,
    idcliente int not null,
    idfuncionario int not null,
    data_venda datetime default current_timestamp,
    valor_total decimal(10,2) default 0,
    foreign key (idcliente) references clientes(idcliente),
    foreign key (idfuncionario) references funcionarios(idfuncionario)
);

-- Tabela associativa: resolve o relacionamento N:N entre vendas e produtos
-- Chave primaria composta (idvenda, idproduto)
create table itens_venda (
    idvenda int not null,
    idproduto int not null,
    quantidade int not null,
    preco_unitario decimal(10,2) not null,
    primary key (idvenda, idproduto),
    foreign key (idvenda) references vendas(idvenda),
    foreign key (idproduto) references produtos(idproduto)
);

create table pagamentos (
    idpagamento int auto_increment primary key,
    idvenda int not null,
    idforma int not null,
    valor decimal(10,2) not null,
    data_pagamento datetime default current_timestamp,
    foreign key (idvenda) references vendas(idvenda),
    foreign key (idforma) references forma_de_pagamento(idforma)
);

create table estoque_movimentacao (
    idmovimentacao int auto_increment primary key,
    idproduto int not null,
    idfuncionario int not null,
    tipo varchar(10) not null,
    quantidade int not null,
    data datetime default current_timestamp,
    foreign key (idproduto) references produtos(idproduto),
    foreign key (idfuncionario) references funcionarios(idfuncionario)
);


/* =====================================
   3. INSERTS
   ===================================== */

-- 3.1 Tabelas sem dependencia

insert into clientes (nome, telefone, data_cadastro) values
('Lucas Antonio', '46999180691', '2026-01-11'),
('Joao Pedro', '46999170541', '2026-02-18'),
('Sofia Gabriele', '46999310032', '2026-03-03'),
('Erick do Santos', '46999910695', '2026-04-19'),
('Luiz Sencoski', '46999610876', '2026-05-06'),
('Luiz Gabriel', '46999160987', '2026-06-13'),
('Matheus Defaveri', '46999120258', '2026-07-01'),
('Kevin', '46999180649', '2026-08-22'),
('Victor Luiz', '46999130540', '2026-09-10'),
('Cleiton de Quadros', '46999716511', '2026-10-08');

insert into funcionarios (nome, cargo, data_admissao) values
('Jackson Schimit', 'Gerente', '2026-01-01'),
('Eduardo de Almeida', 'Vendedor', '2026-01-03'),
('Angelo Hank', 'Vendedor', '2026-02-02'),
('Edri Colpani', 'Vendedor', '2026-03-15'),
('Marcos Eduardo', 'Vendedor', '2026-04-19'),
('Gabriela Noara', 'Vendedor', '2026-05-12'),
('Anselmo Peretto', 'Caixa', '2026-01-02'),
('Gaya Valentina', 'Caixa', '2026-05-20'),
('Eduardo Rompkovski', 'Estoquista', '2026-01-08'),
('Henrique', 'Estoquista', '2026-04-09');

insert into fornecedores (nome, cnpj, telefone) values
('Almeida Gestao', '12.698.678/0001-54', '4635921660'),
('Mengao do Povo', '21.345.698/0001-98', '5932641169'),
('Neymar no Gol', '03.674.247/0001-24', '4732551142'),
('NegoNei Distribuidora', '09.665.418/0001-14', '4962269109'),
('Calcas Ltda', '01.911.428/0001-01', '4059247104'),
('Acessorios & Cia', '36.988.618/0001-00', '6632741109'),
('Uniformes Sudotec Ltda', '11.658.148/0001-69', '1132741906'),
('Camisetas Ltda', '11.435.123/0001-63', '46999189101'),
('Jaquetas & Casacos SA', '12.444.699/0001-22', '46991121108'),
('Meias Ltda', '98.456.114/0001-25', '4652269102');

-- tabela auxiliar (menos de 10 registros)
insert into categorias (nome_categoria, descricao) values
('Camisetas', 'Camisetas Casuais, Básicas, Over Sized e Dry Fit'),
('Calças', 'Calças jeans, Sarja e Social'),
('Calçados', 'Tênis, Sapatos e Chinelos'),
('Jaquetas', 'Jaquetas e Casacos'),
('Acessórios', 'Cintos, Bonés e Oculos');

-- tabela auxiliar (menos de 10 registros)
insert into forma_de_pagamento (descricao) values
('Pix'),
('Dinheiro'),
('Cartão de Débito'),
('Cartão de Crédito');

-- 3.2 Produtos (as chaves estrangeiras sao buscadas por subquery)

insert into produtos (nome, preco, estoque_atual, idcategoria, idfornecedor) values
('Camiseta Casual Preta', 32.90, 50,
  (select idcategoria from categorias where nome_categoria = 'Camisetas'),
  (select idfornecedor from fornecedores where nome = 'Camisetas Ltda')),

('Camiseta Over Sized Premium Preta', 49.90, 40,
  (select idcategoria from categorias where nome_categoria = 'Camisetas'),
  (select idfornecedor from fornecedores where nome = 'Camisetas Ltda')),

('Calça Social', 79.90, 30,
  (select idcategoria from categorias where nome_categoria = 'Calças'),
  (select idfornecedor from fornecedores where nome = 'Calcas Ltda')),

('Calça Sarja', 69.90, 25,
  (select idcategoria from categorias where nome_categoria = 'Calças'),
  (select idfornecedor from fornecedores where nome = 'Calcas Ltda')),

('Tênis Casual Branco', 119.90, 20,
  (select idcategoria from categorias where nome_categoria = 'Calçados'),
  (select idfornecedor from fornecedores where nome = 'Meias Ltda')),

('Chinelo Masculino', 59.90, 35,
  (select idcategoria from categorias where nome_categoria = 'Calçados'),
  (select idfornecedor from fornecedores where nome = 'Meias Ltda')),

('Jaqueta de Couro', 149.90, 15,
  (select idcategoria from categorias where nome_categoria = 'Jaquetas'),
  (select idfornecedor from fornecedores where nome = 'Jaquetas & Casacos SA')),

('Casaco de Frio Acolchoado', 119.90, 10,
  (select idcategoria from categorias where nome_categoria = 'Jaquetas'),
  (select idfornecedor from fornecedores where nome = 'Jaquetas & Casacos SA')),

('Boné Aba Reta', 34.90, 60,
  (select idcategoria from categorias where nome_categoria = 'Acessórios'),
  (select idfornecedor from fornecedores where nome = 'Acessorios & Cia')),

('Cinto de Couro', 59.90, 45,
  (select idcategoria from categorias where nome_categoria = 'Acessórios'),
  (select idfornecedor from fornecedores where nome = 'Acessorios & Cia'));

-- 3.3 Vendas
-- (o valor_total sera recalculado na secao de UPDATES, somando os itens)

insert into vendas (idcliente, idfuncionario, data_venda, valor_total) values
((select idcliente from clientes where nome = 'Lucas Antonio'),
 (select idfuncionario from funcionarios where nome = 'Eduardo de Almeida'), '2026-01-11 09:15:00', 229.90),

((select idcliente from clientes where nome = 'Joao Pedro'),
 (select idfuncionario from funcionarios where nome = 'Angelo Hank'), '2026-02-18 10:30:00', 99.90),

((select idcliente from clientes where nome = 'Sofia Gabriele'),
 (select idfuncionario from funcionarios where nome = 'Marcos Eduardo'), '2026-03-03 11:00:00', 149.90),

((select idcliente from clientes where nome = 'Erick do Santos'),
 (select idfuncionario from funcionarios where nome = 'Gabriela Noara'), '2026-04-19 14:20:00', 79.90),

((select idcliente from clientes where nome = 'Luiz Sencoski'),
 (select idfuncionario from funcionarios where nome = 'Edri Colpani'), '2026-05-06 15:45:00', 300.00),

((select idcliente from clientes where nome = 'Luiz Gabriel'),
 (select idfuncionario from funcionarios where nome = 'Eduardo de Almeida'), '2026-06-13 09:00:00', 59.90),

((select idcliente from clientes where nome = 'Matheus Defaveri'),
 (select idfuncionario from funcionarios where nome = 'Angelo Hank'), '2026-07-01 16:10:00', 129.90),

((select idcliente from clientes where nome = 'Kevin'),
 (select idfuncionario from funcionarios where nome = 'Marcos Eduardo'), '2026-08-22 12:00:00', 89.90),

((select idcliente from clientes where nome = 'Victor Luiz'),
 (select idfuncionario from funcionarios where nome = 'Edri Colpani'), '2026-09-10 13:30:00', 149.90),

((select idcliente from clientes where nome = 'Cleiton de Quadros'),
 (select idfuncionario from funcionarios where nome = 'Gabriela Noara'), '2026-10-08 17:00:00', 29.90);

-- 3.4 Itens das vendas (tabela associativa N:N com chave composta)

insert into itens_venda (idvenda, idproduto, quantidade, preco_unitario) values

-- venda 1 - Lucas Antonio
((select idvenda from vendas where data_venda = '2026-01-11 09:15:00'),
 (select idproduto from produtos where nome = 'Camiseta Casual Preta'), 7, 32.90),
((select idvenda from vendas where data_venda = '2026-01-11 09:15:00'),
 (select idproduto from produtos where nome = 'Boné Aba Reta'), 1, 34.90),

-- venda 2 - Joao Pedro
((select idvenda from vendas where data_venda = '2026-02-18 10:30:00'),
 (select idproduto from produtos where nome = 'Tênis Casual Branco'), 1, 119.90),

-- venda 3 - Sofia Gabriele
((select idvenda from vendas where data_venda = '2026-03-03 11:00:00'),
 (select idproduto from produtos where nome = 'Calça Social'), 1, 79.90),
((select idvenda from vendas where data_venda = '2026-03-03 11:00:00'),
 (select idproduto from produtos where nome = 'Cinto de Couro'), 1, 59.90),

-- venda 4 - Erick do Santos
((select idvenda from vendas where data_venda = '2026-04-19 14:20:00'),
 (select idproduto from produtos where nome = 'Calça Social'), 1, 79.90),

-- venda 5 - Luiz Sencoski
((select idvenda from vendas where data_venda = '2026-05-06 15:45:00'),
 (select idproduto from produtos where nome = 'Camiseta Over Sized Premium Preta'), 6, 49.90),

-- venda 6 - Luiz Gabriel
((select idvenda from vendas where data_venda = '2026-06-13 09:00:00'),
 (select idproduto from produtos where nome = 'Chinelo Masculino'), 1, 59.90),
((select idvenda from vendas where data_venda = '2026-06-13 09:00:00'),
 (select idproduto from produtos where nome = 'Boné Aba Reta'), 1, 34.90),

-- venda 7 - Matheus Defaveri
((select idvenda from vendas where data_venda = '2026-07-01 16:10:00'),
 (select idproduto from produtos where nome = 'Casaco de Frio Acolchoado'), 1, 119.90),

-- venda 8 - Kevin
((select idvenda from vendas where data_venda = '2026-08-22 12:00:00'),
 (select idproduto from produtos where nome = 'Calça Social'), 1, 79.90),

-- venda 9 - Victor Luiz
((select idvenda from vendas where data_venda = '2026-09-10 13:30:00'),
 (select idproduto from produtos where nome = 'Camiseta Over Sized Premium Preta'), 2, 49.90),
((select idvenda from vendas where data_venda = '2026-09-10 13:30:00'),
 (select idproduto from produtos where nome = 'Cinto de Couro'), 1, 59.90),

-- venda 10 - Cleiton de Quadros
((select idvenda from vendas where data_venda = '2026-10-08 17:00:00'),
 (select idproduto from produtos where nome = 'Boné Aba Reta'), 1, 34.90);

-- 3.5 Pagamentos
-- (o valor sera ajustado na secao de UPDATES, igualando ao total da venda)

insert into pagamentos (idvenda, idforma, valor, data_pagamento) values
((select idvenda from vendas where data_venda = '2026-01-11 09:15:00'),
 (select idforma from forma_de_pagamento where descricao = 'Pix'), 0, '2026-01-11 09:15:00'),

((select idvenda from vendas where data_venda = '2026-02-18 10:30:00'),
 (select idforma from forma_de_pagamento where descricao = 'Cartão de Crédito'), 0, '2026-02-18 10:30:00'),

((select idvenda from vendas where data_venda = '2026-03-03 11:00:00'),
 (select idforma from forma_de_pagamento where descricao = 'Cartão de Débito'), 0, '2026-03-03 11:00:00'),

((select idvenda from vendas where data_venda = '2026-04-19 14:20:00'),
 (select idforma from forma_de_pagamento where descricao = 'Dinheiro'), 0, '2026-04-19 14:20:00'),

((select idvenda from vendas where data_venda = '2026-05-06 15:45:00'),
 (select idforma from forma_de_pagamento where descricao = 'Pix'), 0, '2026-05-06 15:45:00'),

((select idvenda from vendas where data_venda = '2026-06-13 09:00:00'),
 (select idforma from forma_de_pagamento where descricao = 'Cartão de Crédito'), 0, '2026-06-13 09:00:00'),

((select idvenda from vendas where data_venda = '2026-07-01 16:10:00'),
 (select idforma from forma_de_pagamento where descricao = 'Cartão de Débito'), 0, '2026-07-01 16:10:00'),

((select idvenda from vendas where data_venda = '2026-08-22 12:00:00'),
 (select idforma from forma_de_pagamento where descricao = 'Pix'), 0, '2026-08-22 12:00:00'),

((select idvenda from vendas where data_venda = '2026-09-10 13:30:00'),
 (select idforma from forma_de_pagamento where descricao = 'Dinheiro'), 0, '2026-09-10 13:30:00'),

((select idvenda from vendas where data_venda = '2026-10-08 17:00:00'),
 (select idforma from forma_de_pagamento where descricao = 'Cartão de Crédito'), 0, '2026-10-08 17:00:00');

-- 3.6 Movimentacao de estoque (entradas iniciais)

insert into estoque_movimentacao (idproduto, idfuncionario, tipo, quantidade, data) values
((select idproduto from produtos where nome = 'Camiseta Casual Preta'),
 (select idfuncionario from funcionarios where nome = 'Henrique'), 'entrada', 50, '2026-01-02 08:30:00'),

((select idproduto from produtos where nome = 'Camiseta Over Sized Premium Preta'),
 (select idfuncionario from funcionarios where nome = 'Henrique'), 'entrada', 40, '2026-01-02 08:50:00'),

((select idproduto from produtos where nome = 'Calça Social'),
 (select idfuncionario from funcionarios where nome = 'Eduardo Rompkovski'), 'entrada', 30, '2026-01-02 09:10:00'),

((select idproduto from produtos where nome = 'Calça Sarja'),
 (select idfuncionario from funcionarios where nome = 'Eduardo Rompkovski'), 'entrada', 25, '2026-01-02 09:18:00'),

((select idproduto from produtos where nome = 'Tênis Casual Branco'),
 (select idfuncionario from funcionarios where nome = 'Henrique'), 'entrada', 20, '2026-01-02 09:24:00'),

((select idproduto from produtos where nome = 'Chinelo Masculino'),
 (select idfuncionario from funcionarios where nome = 'Eduardo Rompkovski'), 'entrada', 35, '2026-01-02 09:33:00'),

((select idproduto from produtos where nome = 'Jaqueta de Couro'),
 (select idfuncionario from funcionarios where nome = 'Henrique'), 'entrada', 15, '2026-01-02 09:45:00'),

((select idproduto from produtos where nome = 'Casaco de Frio Acolchoado'),
 (select idfuncionario from funcionarios where nome = 'Eduardo Rompkovski'), 'entrada', 10, '2026-01-02 09:58:00'),

((select idproduto from produtos where nome = 'Boné Aba Reta'),
 (select idfuncionario from funcionarios where nome = 'Henrique'), 'entrada', 60, '2026-01-02 10:10:00'),

((select idproduto from produtos where nome = 'Cinto de Couro'),
 (select idfuncionario from funcionarios where nome = 'Eduardo Rompkovski'), 'entrada', 45, '2026-01-02 10:26:00');


/* =====================================
   4. UPDATES
   ===================================== */

-- UPDATE 01: recalcula o valor_total de cada venda somando seus itens
-- (subquery correlacionada: roda uma vez para cada venda)
update vendas v
set valor_total = (
    select sum(iv.quantidade * iv.preco_unitario)
    from itens_venda iv
    where iv.idvenda = v.idvenda
);

-- UPDATE 02: reajuste de 10% no preco de todos os produtos da categoria Jaquetas
update produtos
set preco = preco * 1.10
where idcategoria = (
    select idcategoria
    from categorias
    where nome_categoria = 'Jaquetas'
);

-- UPDATE 03: corrige o telefone de um cliente (filtrando pela chave primaria)
update clientes
set telefone = '46999716500'
where idcliente = (
    select idcliente
    from clientes
    where nome = 'Cleiton de Quadros'
);

-- UPDATE 04: promove um funcionario para Gerente
update funcionarios
set cargo = 'Gerente'
where idfuncionario = (
    select idfuncionario
    from funcionarios
    where nome = 'Eduardo de Almeida'
);

-- UPDATE 05: corrige o estoque de um produto apos contagem fisica
update produtos
set estoque_atual = 42
where idproduto = (
    select idproduto
    from produtos
    where nome = 'Boné Aba Reta'
);

-- UPDATE EXTRA: acerta o valor de cada pagamento para ficar igual ao total da venda
update pagamentos p
set valor = (
    select v.valor_total
    from vendas v
    where v.idvenda = p.idvenda
);

/* =====================================
   5. DELETES
   ===================================== */

-- Registros extras, criados apenas para servirem de exemplo de exclusao.
-- (um registro que ja possui vendas/produtos vinculados nao pode ser apagado,
--  pois a chave estrangeira protege a integridade dos dados)

insert into clientes (nome, telefone, data_cadastro) values
('cliente teste cadastro duplicado', '46999999999', '2026-06-15');

insert into categorias (nome_categoria, descricao) values
('calca cargo', 'categoria cadastrada por engano');

insert into fornecedores (nome, cnpj, telefone) values
('fornecedor cancelado Ltda', '04.698.125/0001-99', '4631429529');

insert into produtos (nome, preco, estoque_atual, idcategoria, idfornecedor) values
('produto descontinuado teste', 19.90, 0,
  (select idcategoria from categorias where nome_categoria = 'Acessórios'),
  (select idfornecedor from fornecedores where nome = 'Acessorios & Cia'));

-- DELETE 01: remove cliente cadastrado errado, sem nenhuma venda associada
delete from clientes
where nome = 'cliente teste cadastro duplicado';

-- DELETE 02: remove categoria criada por engano, sem produtos vinculados
delete from categorias
where nome_categoria = 'calca cargo';

-- DELETE 03: remove fornecedor com contrato cancelado, sem produtos vinculados
delete from fornecedores
where nome = 'fornecedor cancelado Ltda';

-- DELETE 04: remove produto descontinuado antes de gerar qualquer venda/movimentacao
delete from produtos
where nome = 'produto descontinuado teste';

-- DELETE 05: remove um lancamento de estoque feito com quantidade errada
delete from estoque_movimentacao
where idproduto = (
    select idproduto
    from produtos
    where nome = 'Cinto de Couro'
)
and tipo = 'entrada'
and quantidade = 45;


/* =====================================
   6. RELATORIOS
   ===================================== */

-- RELATORIO 01: Quais produtos estao com estoque baixo, do mais critico ao menos critico?
-- Recursos: WHERE + ORDER BY
select nome, estoque_atual, preco
from produtos
where estoque_atual < 20
order by estoque_atual asc;


-- RELATORIO 02: Como esta o desempenho geral de vendas da loja?
-- Recursos: funcoes agregadas COUNT, SUM, AVG, MAX, MIN
select
    count(*)         as total_vendas,
    sum(valor_total) as faturamento_total,
    avg(valor_total) as ticket_medio,
    max(valor_total) as maior_venda,
    min(valor_total) as menor_venda
from vendas;


-- RELATORIO 03: Quem vendeu, para quem e quando? (extrato das vendas)
-- Recursos: JOIN simples com 3 tabelas (vendas, clientes, funcionarios)
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


-- RELATORIO 04: Quanto cada produto vendeu, de qual categoria e de qual fornecedor,
-- incluindo os produtos que nunca foram vendidos?
-- Recursos: JOIN + LEFT JOIN com 4 tabelas
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


-- RELATORIO 05: Quais vendas foram acima do ticket medio da loja e quem foi o cliente?
-- Recursos: SUBQUERY no WHERE
select
    v.idvenda,
    c.nome as cliente,
    v.data_venda,
    v.valor_total
from vendas v
join clientes c on c.idcliente = v.idcliente
where v.valor_total > (select avg(valor_total) from vendas)
order by v.valor_total desc;

-- RELATORIO 05 (variacao): quanto cada venda ficou acima ou abaixo da media
-- Recursos: SUBQUERY no SELECT
select idvenda, valor_total,
       valor_total - (select avg(valor_total) from vendas) as diferenca_da_media
from vendas;


/* =====================================
   7. TRIGGERS
   ===================================== */

-- Os triggers usam DELIMITER $$ porque o corpo (begin ... end) contem ';' internos.
-- Sem isso o cliente SQL corta o comando no primeiro ';' e da erro de sintaxe.
delimiter $$

-- TRIGGER 01: validacao
-- Impede a venda de um produto quando o estoque e insuficiente.
-- BEFORE INSERT em itens_venda: roda antes de gravar e pode cancelar a operacao.
create trigger trg_valida_estoque_venda
before insert on itens_venda
for each row
begin
    declare v_estoque int;

    select estoque_atual into v_estoque
    from produtos
    where idproduto = new.idproduto;

    if v_estoque < new.quantidade then
        signal sqlstate '45000'
        set message_text = 'estoque insuficiente para este produto';
    end if;
end$$

-- TRIGGER 02: automacao
-- Apos registrar um item de venda, da baixa no estoque do produto
-- e registra a saida na tabela estoque_movimentacao.
-- AFTER INSERT em itens_venda: roda depois de gravar o item.
create trigger trg_baixa_estoque_venda
after insert on itens_venda
for each row
begin
    update produtos
    set estoque_atual = estoque_atual - new.quantidade
    where idproduto = new.idproduto;

    insert into estoque_movimentacao (idproduto, idfuncionario, tipo, quantidade)
    values (
        new.idproduto,
        (select idfuncionario from vendas where idvenda = new.idvenda),
        'saida',
        new.quantidade
    );
end$$

-- TRIGGER 03: validacao
-- Impede que o estoque de um produto fique negativo em qualquer atualizacao.
-- BEFORE UPDATE em produtos.
create trigger trg_impede_estoque_negativo
before update on produtos
for each row
begin
    if new.estoque_atual < 0 then
        signal sqlstate '45000'
        set message_text = 'estoque nao pode ficar negativo';
    end if;
end$$

delimiter ;
