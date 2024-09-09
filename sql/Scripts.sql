-- Volume de Vendas
-- Agrupa os produtos por Ano, Fabricante e Categoria, classificando
-- os 5 melhores com maior volume de vendas => total de produtos vendidos
select ano,
    produto,
    fabricante,
    categoria,
    count(produto) as volume_vendas,
    round((count(produto) / (select count(produto) from `bq_dataset.venda` as ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_volume_vendas,
    round(sum(sub.vlr_venda),2) as receita,
    round((sum(sub.vlr_venda) / (select sum(ven.valorvenda) from `bq_dataset.venda` ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_receita,
    rank() over (partition by sub.ano order by count(produto) desc) as ranking
from (
        select extract(YEAR from ven.datavenda) as ano,
            prd.produto as produto,
            fab.fabricante as fabricante,
            cat.categoria as categoria,
            ven.valorvenda as vlr_venda
            from `bq_dataset.venda` as ven
            inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
            inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
            inner join `bq_dataset.categoria` as cat on cat.categoriaid = prd.categoriaid
      ) as sub
group by sub.ano, produto, fabricante, categoria
qualify ranking <= 5 
order by ano, ranking

-- Receita
-- Agrupa os produtos por Ano, Fabricante e Categoria, classificando
-- os 5 melhores com maior receita => total valor_venda
select ano,
    produto,
    fabricante,
    categoria,
    round(sum(sub.vlr_venda),2) as receita,
    round((sum(sub.vlr_venda) / (select sum(ven.valorvenda) from `bq_dataset.venda` ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_receita,
    count(produto) as volume_vendas,
    round((count(produto) / (select count(produto) from `bq_dataset.venda` as ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_volume_vendas,
    rank() over (partition by sub.ano order by sum(sub.vlr_venda) desc) as ranking
from (
        select extract(YEAR from ven.datavenda) as ano,
            prd.produto as produto,
            fab.fabricante as fabricante,
            cat.categoria as categoria,
            ven.valorvenda as vlr_venda
            from `bq_dataset.venda` as ven
            inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
            inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
            inner join `bq_dataset.categoria` as cat on cat.categoriaid = prd.categoriaid
      ) as sub
group by sub.ano, produto, fabricante, categoria
qualify ranking <= 5 
order by ano, ranking


-- Ticket Medio
# Fabricante
select 
sub.ano as ano,
sub.fabricante,
round(avg(sub.valorvenda),2) as ticket_medio,
round(sum(sub.valorvenda),2) as receita,
round((sum(sub.valorvenda) / (select sum(ven.valorvenda) from `bq_dataset.venda` ven where extract(YEAR from ven.datavenda) = sub.ano)*100), 2) as perc_receita,
from 
(select 
    extract(YEAR from ven.datavenda) as ano,
    fab.fabricante,
    ven.valorvenda
    from `bq_dataset.venda` as ven
    inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
    inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
) as sub
group by sub.ano, sub.fabricante
order by 1


# Segmento
select 
sub.ano as ano,
sub.segmento,
round(avg(sub.valorvenda),2) as ticket_medio,
round(sum(sub.valorvenda),2) as receita,
round((sum(sub.valorvenda) / (select sum(ven.valorvenda) from `bq_dataset.venda` ven where extract(YEAR from ven.datavenda) = sub.ano)*100), 2) as perc_receita,
from 
(select 
    extract(YEAR from ven.datavenda) as ano,
    seg.segmento,
    ven.valorvenda
    from `bq_dataset.venda` as ven
    inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
    inner join `bq_dataset.segmento` as seg on seg.segmentoid = prd.segmentoid
) as sub
group by sub.ano, sub.segmento
order by 1

-- Lucro
select fab.fabricante,
round(sum(ven.valorvenda - ((ven.valorvenda * ven.perc_comissao) / 100) - ven.custo), 2) as lucro
from `bq_dataset.venda` as ven
inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
group by fab.fabricante
order by 2 desc


select seg.segmento,
round(sum(ven.valorvenda - ((ven.valorvenda * ven.perc_comissao) / 100) - ven.custo), 2) as lucro
from `bq_dataset.venda` as ven
inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
inner join `bq_dataset.segmento` as seg on seg.segmentoid = prd.segmentoid
group by seg.segmento
order by 2 desc

select cat.categoria,
round(sum(ven.valorvenda - ((ven.valorvenda * ven.perc_comissao) / 100) - ven.custo), 2) as lucro
from `bq_dataset.venda` as ven
inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
inner join `bq_dataset.categoria` as cat on cat.categoriaid = prd.categoriaid
group by cat.categoria
order by 2 desc

-- Maiores Volume de Vendas
-- Agrupa os produtos por Ano, Fabricante, classificando
-- os 5 melhores com maior volume de vendas => total de produtos vendidos
select ano,
    fabricante,
    produto,
    count(produto) as volume_vendas,
    round((count(produto) / (select count(produto) from `bq_dataset.venda` as ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_volume_vendas,
    round(sum(sub.vlr_venda),2) as receita,
    round((sum(sub.vlr_venda) / (select sum(ven.valorvenda) from `bq_dataset.venda` ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_receita,
    rank() over (partition by sub.ano order by count(produto) desc) as ranking
from (
        select extract(YEAR from ven.datavenda) as ano,
            prd.produto as produto,
            fab.fabricante as fabricante,
            ven.valorvenda as vlr_venda
            from `bq_dataset.venda` as ven
            inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
            inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
      ) as sub
group by sub.ano, fabricante, produto
qualify ranking <= 5 
order by ano, ranking


-- Maiores receitas
-- Agrupa os produtos por Ano, Fabricante e Categoria, classificando
-- os 5 melhores com maior receita => total valor_venda
select ano,
    fabricante,
    produto,
    round(sum(sub.vlr_venda),2) as receita,
    round((sum(sub.vlr_venda) / (select sum(ven.valorvenda) from `bq_dataset.venda` ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_receita,
    count(produto) as volume_vendas,
    round((count(produto) / (select count(produto) from `bq_dataset.venda` as ven where extract(YEAR from ven.datavenda) = ano)*100), 2) as perc_volume_vendas,
    rank() over (partition by sub.ano order by sum(sub.vlr_venda) desc) as ranking
from (
        select extract(YEAR from ven.datavenda) as ano,
            prd.produto as produto,
            fab.fabricante as fabricante,
            ven.valorvenda as vlr_venda
            from `bq_dataset.venda` as ven
            inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
            inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
      ) as sub
group by sub.ano, fabricante, produto
qualify ranking <= 5 
order by ano, ranking

------
with base_vendas as 
(
SELECT prd.produtoid, 
  prd.produto, 
  cat.categoria, 
  seg.segmento, 
  fab.fabricante, 
  loj.lojaid as loja, 
  cid.cidade,
  est.uf,
  ven.datavenda as data_venda,
  extract(year from ven.datavenda) as ano,
  extract(month from ven.datavenda) as mes,
  extract(day from ven.datavenda) as dia,
  ven.valorvenda as vlr_venda,
  ven.perc_comissao,
  round((ven.valorvenda * ven.perc_comissao) / 100, 2) as comissao,
  ven.custo,
  round(ven.valorvenda - ((ven.valorvenda * ven.perc_comissao) / 100) - ven.custo, 2) as lucro
FROM bq_dataset.produto as prd
inner join bq_dataset.categoria as cat on cat.categoriaid = prd.categoriaid
inner join bq_dataset.segmento as seg on seg.segmentoid = prd.segmentoid
inner join bq_dataset.fabricante as fab on fab.fabricanteid = prd.fabricanteid
inner join bq_dataset.loja as loj on loj.lojaid = prd.lojaid
inner join bq_dataset.cidade as cid on cid.cidadeid = loj.cidadeid
inner join `bq_dataset.estado`as est on est.uf = cid.uf
inner join `bq_dataset.venda` as ven on ven.produtoid = prd.produtoid
order by 1
)

-- os Top 5 Lojas com maior volume de vendas => total de produtos vendidos
select ano,
       loja,
    count(produtoid) as volume_vendas,
    round((count(produtoid) / (select count(produtoid) from base_vendas b where b.ano = bv.ano)*100), 2) as perc_volume_vendas,
    rank() over (partition by ano order by count(produtoid) desc) as ranking
from base_vendas as bv 
group by ano, loja
qualify ranking <= 5 
order by ano, ranking

# Fabricante x Produto - crescimento anual ticket medio
select 
sub.fabricante,
sub.ano as ano,
round(avg(sub.valorvenda),2) as ticket_medio_atual,
ifnull(lag(round(avg(sub.valorvenda),2)) over (partition by sub.fabricante order by sub.ano), 0) as ticket_medio_anterior,
ifnull(round((round(avg(sub.valorvenda),2) - lag(round(avg(sub.valorvenda),2)) over (partition by sub.fabricante order by sub.ano)) / lag(round(avg(sub.valorvenda),2)) over (partition by sub.fabricante order by sub.ano) * 100, 2), 0) as perc_crescimento -- (crescimento/ticket_medio_anterior)*100
from 
(select 
    extract(YEAR from ven.datavenda) as ano,
    fab.fabricante,
    ven.valorvenda
    from `bq_dataset.venda` as ven
    inner join `bq_dataset.produto` as prd on prd.produtoid = ven.produtoid
    inner join `bq_dataset.fabricante` as fab on fab.fabricanteid = prd.fabricanteid
) as sub
group by sub.fabricante, sub.ano
order by sub.fabricante, sub.ano

