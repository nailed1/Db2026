do $$
begin

-- Продукты
drop table if exists dim_products;
drop sequence if exists seq_dim_products;
create sequence seq_dim_products;
create table dim_products
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_products'),
    external_id bigint not null unique,
    name        text,
    flaging     smallint,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Категории
drop table if exists dim_categories;
drop sequence if exists seq_dim_categories;
create sequence seq_dim_categories;
create table dim_categories
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_categories'),
    external_id bigint not null unique,
    name        text,
    parent_id   bigint,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Единицы измерения
drop table if exists dim_ranges;
drop sequence if exists seq_dim_ranges;
create sequence seq_dim_ranges;
create table dim_ranges
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_ranges'),
    external_id bigint not null unique,
    name        text,
    factor      float,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Поставщики
drop table if exists dim_vendors;
drop sequence if exists seq_dim_vendors;
create sequence seq_dim_vendors;
create table dim_vendors
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_vendors'),
    external_id bigint not null unique,
    name        text,
    parent_id   bigint,
    parent_name text,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Склады
drop table if exists dim_storages;
drop sequence if exists seq_dim_storages;
create sequence seq_dim_storages;
create table dim_storages
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_storages'),
    external_id bigint not null unique,
    name        text,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Свои организации
drop table if exists dim_companies;
drop sequence if exists seq_dim_companies;
create sequence seq_dim_companies;
create table dim_companies
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_companies'),
    external_id bigint not null unique,
    name        text,
    inn         text,
    kpp         text,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Сотрудники
drop table if exists dim_personnel;
drop sequence if exists seq_dim_personnel;
create sequence seq_dim_personnel;
create table dim_personnel
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_personnel'),
    external_id bigint not null unique,
    lastname    text,
    firstname   text,
    middlename  text,
    percent     float,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Роли
drop table if exists dim_roles;
drop sequence if exists seq_dim_roles;
create sequence seq_dim_roles;
create table dim_roles
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_roles'),
    external_id bigint not null unique,
    name        text,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Виды складских операций
drop table if exists dim_operation_types;
drop sequence if exists seq_dim_operation_types;
create sequence seq_dim_operation_types;
create table dim_operation_types
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_operation_types'),
    external_id bigint not null unique,
    name        text,
    factor      smallint,
    -- Дата добавления
    date_add    timestamp default now()
);

-- Типы транзакций
drop table if exists dim_transaction_types;
drop sequence if exists seq_dim_transaction_types;
create sequence seq_dim_transaction_types;
create table dim_transaction_types
(
    -- Внутренний код
    id            bigint primary key default nextval('seq_dim_transaction_types'),
    external_id   bigint not null unique,
    name          text,
    preview_group text,
    -- Дата добавления
    date_add      timestamp default now()
);

-- Причины списания
drop table if exists dim_reasons;
drop sequence if exists seq_dim_reasons;
create sequence seq_dim_reasons;
create table dim_reasons
(
    -- Внутренний код
    id          bigint primary key default nextval('seq_dim_reasons'),
    external_id bigint not null unique,
    name        text,
    -- Дата добавления
    date_add    timestamp default now()
);

end $$;
