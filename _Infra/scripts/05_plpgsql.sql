-- PL/pgSQL скрипт: структура, данные, связи — в одном блоке с тремя commit.

do $$
begin

-- СТРУКТУРА

drop table if exists temperature_calc cascade;
drop table if exists parameters cascade;
drop table if exists device_parameter_types cascade;
drop table if exists parameter_types cascade;
drop table if exists units cascade;
drop table if exists base_units cascade;
drop table if exists batch cascade;
drop table if exists soldiers cascade;
drop table if exists ranks cascade;
drop table if exists devices cascade;

drop sequence if exists seq_base_units cascade;
drop sequence if exists seq_units cascade;
drop sequence if exists seq_parameter_types cascade;
drop sequence if exists seq_device_parameter_types cascade;
drop sequence if exists seq_ranks cascade;
drop sequence if exists seq_soldiers cascade;
drop sequence if exists seq_devices cascade;
drop sequence if exists seq_batch cascade;
drop sequence if exists seq_parameters cascade;
drop sequence if exists seq_temperature_calc cascade;

create sequence seq_base_units;
create sequence seq_units;
create sequence seq_parameter_types;
create sequence seq_device_parameter_types;
create sequence seq_ranks;
create sequence seq_soldiers;
create sequence seq_devices;
create sequence seq_batch;
create sequence seq_parameters;
create sequence seq_temperature_calc;

create table base_units (
    id int primary key default nextval('seq_base_units'),
    name text
);
comment on table base_units is 'Справочник базовых единиц измерения';
comment on column base_units.id is 'Уникальный код базовой величины';
comment on column base_units.name is 'Название базовой величины';

create table units (
    id int primary key default nextval('seq_units'),
    base_unit_id int,
    name text
);
comment on table units is 'Справочник единиц измерения';
comment on column units.id is 'Уникальный код единицы измерения';
comment on column units.base_unit_id is 'Ссылка на базовую величину из base_units';
comment on column units.name is 'Название единицы измерения';

create table parameter_types (
    id int primary key default nextval('seq_parameter_types'),
    unit_id int,
    name text
);
comment on table parameter_types is 'Справочник типов параметров измерения';
comment on column parameter_types.id is 'Уникальный код типа параметра';
comment on column parameter_types.unit_id is 'Ссылка на единицу измерения из units';
comment on column parameter_types.name is 'Название типа параметра';

create table devices (
    id int primary key default nextval('seq_devices'),
    name text
);
comment on table devices is 'Справочник типов оборудования для измерений';
comment on column devices.id is 'Уникальный код оборудования';
comment on column devices.name is 'Название оборудования';

create table device_parameter_types (
    id int primary key default nextval('seq_device_parameter_types'),
    device_id int,
    parameter_type_id int
);
comment on table device_parameter_types is 'Связка: доступные типы параметров для оборудования';
comment on column device_parameter_types.id is 'Уникальный код записи';
comment on column device_parameter_types.device_id is 'Ссылка на оборудование из devices';
comment on column device_parameter_types.parameter_type_id is 'Ссылка на тип параметра из parameter_types';

create table ranks (
    id int primary key default nextval('seq_ranks'),
    rank text
);
comment on table ranks is 'Справочник военных званий';
comment on column ranks.id is 'Уникальный код звания';
comment on column ranks.rank is 'Название звания';

create table soldiers (
    id int primary key default nextval('seq_soldiers'),
    personal_id int,
    rank_id int
);
comment on table soldiers is 'Справочник военнослужащих';
comment on column soldiers.id is 'Уникальный код военнослужащего';
comment on column soldiers.personal_id is 'Личный номер военнослужащего';
comment on column soldiers.rank_id is 'Ссылка на звание из ranks';

create table batch (
    id int primary key default nextval('seq_batch'),
    soldier_id int,
    device_id int,
    measured_at timestamptz default now()
);
comment on table batch is 'История измерений (кто, оборудование, дата)';
comment on column batch.id is 'Уникальный код партии';
comment on column batch.soldier_id is 'Ссылка на военнослужащего из soldiers';
comment on column batch.device_id is 'Ссылка на оборудование из devices';
comment on column batch.measured_at is 'Дата и время измерения';

create table parameters (
    id int primary key default nextval('seq_parameters'),
    batch_id int,
    parameter_type_id int,
    value numeric
);
comment on table parameters is 'Параметры метеоизмерений';
comment on column parameters.id is 'Уникальный код записи';
comment on column parameters.batch_id is 'Ссылка на партию из batch';
comment on column parameters.parameter_type_id is 'Ссылка на тип параметра из parameter_types';
comment on column parameters.value is 'Числовое значение параметра';

create table temperature_calc (
    id int primary key default nextval('seq_temperature_calc'),
    batch_id int,
    temperature numeric(5,2),
    calculated_at timestamptz default now()
);
comment on table temperature_calc is 'Расчет температуры, таблица 1';
comment on column temperature_calc.id is 'Уникальный код записи';
comment on column temperature_calc.batch_id is 'Ссылка на партию из batch';
comment on column temperature_calc.temperature is 'Расчётная температура';
comment on column temperature_calc.calculated_at is 'Дата и время расчёта';

commit;


-- ДАННЫЕ

insert into base_units(name) values
    ('Длина'),
    ('Температура'),
    ('Давление'),
    ('Скорость'),
    ('Угол');

insert into units(base_unit_id, name) values
    (1, 'Метр'),
    (2, 'Градус Цельсия'),
    (3, 'Миллиметр ртутного столба'),
    (4, 'Метр в секунду'),
    (5, 'Большое деление угломера');

insert into parameter_types(unit_id, name) values
    (1, 'Высота метеопоста'),
    (2, 'Температура воздуха'),
    (3, 'Давление атмосферы'),
    (4, 'Большое деление угломера'),
    (5, 'Скорость ветра'),
    (1, 'Дальность сноса пуль');

insert into devices(name) values
    ('ДМК'),
    ('ВР');

insert into device_parameter_types(device_id, parameter_type_id) values
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 6);

insert into ranks(rank) values
    ('рядовой'), ('ефрейтор'), ('младший сержант'),
    ('сержант'), ('старший сержант'), ('старшина'),
    ('прапорщик'), ('старший прапорщик'), ('младший лейтенант'),
    ('лейтенант'), ('старший лейтенант'), ('капитан');

insert into soldiers(personal_id, rank_id) values
    (32589, 2),
    (59589, 5),
    (19589, 1),
    (92589, 3),
    (73589, 4),
    (82589, 6);

insert into batch(soldier_id, device_id, measured_at) values
    (1, 1, '2026-09-20 08:00:00+08'),
    (2, 1, '2026-09-21 08:00:00+08'),
    (3, 2, '2026-09-21 10:00:00+08'),
    (4, 2, '2026-09-21 12:00:00+08'),
    (5, 1, '2026-09-21 14:00:00+08'),
    (6, 1, '2026-09-22 08:00:00+08');

insert into parameters(batch_id, parameter_type_id, value) values
    (1, 1, 100), (1, 2, 15.0), (1, 3, 750), (1, 4, 0), (1, 5, 0),
    (2, 1, 150), (2, 2, -10.5), (2, 3, 745), (2, 4, 12), (2, 5, 5),
    (3, 1, 200), (3, 2, 25.0), (3, 3, 765), (3, 4, 15), (3, 6, 30),
    (4, 1, 100), (4, 2, 15.0), (4, 3, 750), (4, 4, 0), (4, 6, 0),
    (5, 1, 300), (5, 2, 30.5), (5, 3, 800), (5, 4, 45), (5, 5, 10),
    (6, 1, 120), (6, 2, 20.0), (6, 3, 760), (6, 4, 20), (6, 5, 7);

insert into temperature_calc(batch_id, temperature, calculated_at) values
    (1, 15.00, '2026-09-20 08:05:00+08'),
    (2, -10.50, '2026-09-21 08:05:00+08'),
    (3, 25.00, '2026-09-21 10:05:00+08'),
    (4, 15.00, '2026-09-21 12:05:00+08'),
    (5, 30.50, '2026-09-21 14:05:00+08'),
    (6, 20.00, '2026-09-22 08:05:00+08');

commit;


-- СВЯЗИ И ОГРАНИЧЕНИЯ

alter table base_units
    alter column name set not null;

alter table units
    alter column name set not null,
    alter column base_unit_id set not null,
    add constraint fk_units_base_unit foreign key (base_unit_id) references base_units(id);

alter table parameter_types
    alter column name set not null,
    alter column unit_id set not null,
    add constraint fk_parameter_types_unit foreign key (unit_id) references units(id);

alter table devices
    alter column name set not null;

alter table device_parameter_types
    alter column device_id set not null,
    alter column parameter_type_id set not null,
    add constraint fk_dpt_device foreign key (device_id) references devices(id),
    add constraint fk_dpt_parameter_type foreign key (parameter_type_id) references parameter_types(id);

alter table ranks
    alter column rank set not null;

alter table soldiers
    alter column personal_id set not null,
    alter column rank_id set not null,
    add constraint fk_soldiers_ranks foreign key (rank_id) references ranks(id);

alter table batch
    alter column soldier_id set not null,
    alter column device_id set not null,
    alter column measured_at set not null,
    add constraint fk_batch_soldiers foreign key (soldier_id) references soldiers(id),
    add constraint fk_batch_devices foreign key (device_id) references devices(id);

alter table parameters
    alter column batch_id set not null,
    alter column parameter_type_id set not null,
    alter column value set not null,
    add constraint fk_parameters_batch foreign key (batch_id) references batch(id),
    add constraint fk_parameters_type foreign key (parameter_type_id) references parameter_types(id);

alter table temperature_calc
    alter column batch_id set not null,
    alter column temperature set not null,
    alter column calculated_at set not null,
    add constraint fk_temp_calc_batch foreign key (batch_id) references batch(id),
    add constraint chk_temp_calc_range check (temperature between -58.0 and 58.0);

commit;

end
$$;