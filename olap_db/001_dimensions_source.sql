-- Продукты
select p.id as external_id, p.[description] as name, p.flaging
from dbo.product p
order by p.id;

select 'insert into dim_products(external_id, name, flaging) values ('
    + cast(p.id as varchar(max)) + ', '''
    + replace(p.[description], '''', '''''') + ''', '
    + coalesce(cast(p.flaging as varchar(max)), 'null') + ');'
    as [sql]
from dbo.product p
order by p.id;


-- Категории
select c.id as external_id, c.[description] as name,
       case when coalesce(c.ParentID, 0) = 0 then null else c.ParentID end as parent_id
from dbo.category c
order by c.id;

select 'insert into dim_categories(external_id, name, parent_id) values ('
    + cast(c.id as varchar(max)) + ', '''
    + replace(c.[description], '''', '''''') + ''', '
    + coalesce(cast(case when coalesce(c.ParentID, 0) = 0 then null else c.ParentID end as varchar(max)), 'null') + ');'
    as [sql]
from dbo.category c
order by c.id;


-- Единицы измерения
select s.ID as external_id, s.sizeid as name, s.portionrate as factor
from dbo.[size] s
order by s.ID;

select 'insert into dim_ranges(external_id, name, factor) values ('
    + cast(s.ID as varchar(max)) + ', '''
    + replace(s.sizeid, '''', '''''') + ''', '
    + coalesce(cast(s.portionrate as varchar(max)), 'null') + ');'
    as [sql]
from dbo.[size] s
order by s.ID;


-- Поставщики
select v.id as external_id, v.clientid as name, v.clientgroup as parent_id,
       g.[description] as parent_name
from dbo.vendors v
left join dbo.vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;

select 'insert into dim_vendors(external_id, name, parent_id, parent_name) values ('
    + cast(v.id as varchar(max)) + ', '''
    + replace(v.clientid, '''', '''''') + ''', '
    + coalesce(cast(v.clientgroup as varchar(max)), 'null') + ', '
    + coalesce('''' + replace(g.[description], '''', '''''') + '''', 'null') + ');'
    as [sql]
from dbo.vendors v
left join dbo.vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;


-- Склады
select s.id as external_id, s.[description] as name
from dbo.storages s
order by s.id;

select 'insert into dim_storages(external_id, name) values ('
    + cast(s.id as varchar(max)) + ', '''
    + replace(s.[description], '''', '''''') + ''');'
    as [sql]
from dbo.storages s
order by s.id;


-- Свои организации
select c.ID as external_id, c.CompanyName as name, c.INN, c.KPP
from dbo.bm_Companies c
order by c.ID;

select 'insert into dim_companies(external_id, name, inn, kpp) values ('
    + cast(c.ID as varchar(max)) + ', '''
    + replace(c.CompanyName, '''', '''''') + ''', '
    + coalesce('''' + replace(c.INN, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(c.KPP, '''', '''''') + '''', 'null') + ');'
    as [sql]
from dbo.bm_Companies c
order by c.ID;


-- Сотрудники
select p.personid as external_id, p.lastname, p.firstname, p.middlename, p.[percent]
from dbo.personnel p
order by p.personid;

select 'insert into dim_personnel(external_id, lastname, firstname, middlename, percent) values ('
    + cast(p.personid as varchar(max)) + ', '''
    + replace(coalesce(p.lastname, ''), '''', '''''') + ''', '''
    + replace(coalesce(p.firstname, ''), '''', '''''') + ''', '''
    + replace(coalesce(p.middlename, ''), '''', '''''') + ''', '
    + coalesce(cast(p.[percent] as varchar(max)), 'null') + ');'
    as [sql]
from dbo.personnel p
order by p.personid;


-- Роли
drop table if exists #roles;

select s.securityaccessid as external_id, s.[description] as name
into #roles
from dbo.securityaccess s
union all
select distinct p.securityaccess, 'Не определена'
from dbo.personnel p
where p.securityaccess is not null
  and not exists (select 1 from dbo.securityaccess s2
                  where s2.securityaccessid = p.securityaccess);

select external_id, name from #roles order by external_id;

select 'insert into dim_roles(external_id, name) values ('
    + cast(r.external_id as varchar(max)) + ', '''
    + replace(r.name, '''', '''''') + ''');'
    as [sql]
from #roles r
order by r.external_id;


-- Виды складских операций
select o.ID as external_id, o.[Description] as name, o.Factor
from dbo.bm_StorageOperationsType o
order by o.ID;

select 'insert into dim_operation_types(external_id, name, factor) values ('
    + cast(o.ID as varchar(max)) + ', '''
    + replace(o.[Description], '''', '''''') + ''', '
    + coalesce(cast(o.Factor as varchar(max)), 'null') + ');'
    as [sql]
from dbo.bm_StorageOperationsType o
order by o.ID;


-- Типы транзакций
select t.transtypeid as external_id, t.[description] as name, t.PreviewGroupType
from dbo.transtype t
where exists (select 1 from dbo.journal j where j.transtype = t.transtypeid)
order by t.transtypeid;

select 'insert into dim_transaction_types(external_id, name, preview_group) values ('
    + cast(t.transtypeid as varchar(max)) + ', '''
    + replace(t.[description], '''', '''''') + ''', '
    + coalesce('''' + replace(t.PreviewGroupType, '''', '''''') + '''', 'null') + ');'
    as [sql]
from dbo.transtype t
where exists (select 1 from dbo.journal j where j.transtype = t.transtypeid)
order by t.transtypeid;


-- Причины списания
select r.ID as external_id, r.[Description] as name
from dbo.bm_ReasonDebit r
order by r.ID;

select 'insert into dim_reasons(external_id, name) values ('
    + cast(r.ID as varchar(max)) + ', '''
    + replace(r.[Description], '''', '''''') + ''');'
    as [sql]
from dbo.bm_ReasonDebit r
order by r.ID;
