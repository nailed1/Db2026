do $$
begin
    drop table if exists calc_correction cascade;
    drop table if exists calc_correction_types cascade;
    drop table if exists calc_correction_heights cascade;
    drop table if exists calc_correction_headers cascade;

    drop sequence if exists calc_correction_seq cascade;
    drop sequence if exists calc_correction_types_seq cascade;
    drop sequence if exists calc_correction_height_seq cascade;
    drop sequence if exists seq_calc_correction_headers cascade;

    -- таблица справочных высот
    create sequence calc_correction_height_seq;
    create table calc_correction_heights (
        id integer primary key default nextval('calc_correction_height_seq'),
        height integer not null
    );

    insert into calc_correction_heights (height)
    values (200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);

    -- справочник типов таблиц (с колонкой code)
    create sequence calc_correction_types_seq;
    create table calc_correction_types (
        id integer primary key default nextval('calc_correction_types_seq'),
        parent_id integer,
        measurment_equipment_id integer,
        code text,
        description text not null
    );

    insert into calc_correction_types(id, code, description, parent_id, measurment_equipment_id) values
    (1, 'temp_base', 'Таблица 2', null, null),
    (2, 'speed_base', 'Таблица 3, скорость', null, null),
    (3, 'dir_base', 'Таблица 3, направление', null, null),
    (4, 'speed', 'Таблица 3, скорость (ВР)', 2, 2),
    (5, 'direction', 'Таблица 3, направление (ВР)', 3, 2),
    (6, 'speed', 'Таблица 3, скорость (ДМК)', 2, 1),
    (7, 'direction', 'Таблица 3, направление (ДМК)', 3, 1),
    (8, 'temp_positive', 'Таблица 2, плюс', 1, null),
    (9, 'temp_negative', 'Таблица 2, минус', 1, null);

    -- таблица заголовков
    create sequence seq_calc_correction_headers;
    create table calc_correction_headers (
        id integer primary key default nextval('seq_calc_correction_headers'),
        type_id integer not null,
        col_index integer not null,
        header_value integer not null
    );

    -- заголовки для таблицы 2
    insert into calc_correction_headers (type_id, col_index, header_value)
    select t_id, ord, val
    from unnest(ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,40,50]) with ordinality as u(val, ord)
    cross join (values (8), (9)) as types(t_id);

    -- заголовки для скорости вр
    insert into calc_correction_headers (type_id, col_index, header_value)
    select 4, ord, val from unnest(array[40,50,60,70,80,90,100,110,120,130,140,150]) with ordinality as u(val, ord);

    -- заголовки для скорости дмк
    insert into calc_correction_headers (type_id, col_index, header_value)
    select 6, ord, val from unnest(array[3,4,5,6,7,8,9,10,11,12,13,14,15]) with ordinality as u(val, ord);

    -- универсальная таблица корректировок
    create sequence calc_correction_seq;
    create table calc_correction (
        id integer primary key default nextval('calc_correction_seq'),
        height_id integer not null,
        type_id integer not null,
        row_values integer[]
    );

    insert into calc_correction (height_id, type_id, row_values) values
    -- таблица 2 минус
    (1, 9, array[-1,-2,-3,-4,-5,-6,-7,-8,-8,-9,-20,-29,-39,-49]), 
    (2, 9, array[-1,-2,-3,-4,-5,-6,-6,-7,-8,-9,-19,-29,-38,-48]), 
    (3, 9, array[-1,-2,-3,-4,-5,-6,-6,-7,-7,-8,-18,-28,-37,-46]), 
    (4, 9, array[-1,-2,-3,-4,-4,-5,-5,-6,-7,-8,-17,-26,-35,-44]), 
    (5, 9, array[-1,-2,-3,-3,-4,-4,-5,-6,-7,-7,-17,-25,-34,-42]), 
    (6, 9, array[-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-16,-24,-32,-40]), 
    (7, 9, array[-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-15,-23,-31,-38]), 
    (8, 9, array[-1,-2,-2,-3,-4,-4,-4,-5,-5,-6,-15,-22,-30,-37]), 
    (9, 9, array[-1,-2,-2,-3,-4,-4,-4,-4,-5,-6,-14,-20,-27,-34]), 

    -- таблица 2 плюсы
    (1, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (2, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (3, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (4, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (5, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (6, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (7, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (8, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
    (9, 8, array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),

    -- скорость вр
    (1, 4, array[3,4,5,6,7,7,8,9,10,11,12,12]),
    (2, 4, array[4,5,6,7,8,9,10,11,12,13,14,15]),
    (3, 4, array[4,5,6,7,8,9,10,11,13,14,15,16]),
    (4, 4, array[4,5,7,8,8,9,11,12,13,15,15,16]),
    (5, 4, array[4,6,7,8,9,10,11,13,14,15,17,17]),
    (6, 4, array[4,6,7,8,9,10,11,13,14,16,17,18]),
    (7, 4, array[4,6,8,9,9,10,12,14,15,16,18,19]),
    (8, 4, array[5,6,8,9,10,11,12,14,15,17,18,19]),
    (9, 4, array[5,6,8,9,10,11,12,14,16,18,19,20]),

    -- направление вр
    (1, 5, array[0]), (2, 5, array[1]), (3, 5, array[2]), (4, 5, array[2]), (5, 5, array[3]),
    (6, 5, array[3]), (7, 5, array[3]), (8, 5, array[4]), (9, 5, array[4]),

    -- скорость дмк
    (1, 6, array[4,6,8,9,10,12,14,15,16,18,20,21,22]),
    (2, 6, array[5,7,10,11,12,14,17,18,20,22,23,25,27]),
    (3, 6, array[5,8,10,11,13,15,18,19,21,23,25,27,28]),
    (4, 6, array[5,8,11,12,13,16,19,20,22,24,26,28,30]),
    (5, 6, array[6,8,11,13,14,17,20,21,23,25,27,29,32]),
    (6, 6, array[6,9,11,13,14,17,20,21,24,26,28,30,32]),
    (7, 6, array[6,9,12,14,15,18,21,22,25,27,29,32,34]),
    (8, 6, array[6,9,12,14,15,18,21,23,25,28,30,32,36]),
    (9, 6, array[6,10,12,14,16,19,22,24,26,29,32,34,36]),

    -- направление дмк
    (1, 7, array[1]), (2, 7, array[2]), (3, 7, array[3]), (4, 7, array[3]), (5, 7, array[4]),
    (6, 7, array[4]), (7, 7, array[4]), (8, 7, array[5]), (9, 7, array[5]);

    -- связи
    alter table calc_correction_headers 
    add constraint fk_headers_type foreign key (type_id) references calc_correction_types(id);

    alter table calc_correction 
    add constraint fk_calc_height foreign key (height_id) references calc_correction_heights(id),
    add constraint fk_calc_type foreign key (type_id) references calc_correction_types(id);

    -- таблица 1 (поправки для интерполяции)
    drop table if exists calc_correction_temperature cascade;
    create table calc_correction_temperature (
        id serial primary key,
        temperature numeric not null,
        correction numeric not null
    );
    insert into calc_correction_temperature (temperature, correction) values
    (0, 0.5), (5, 0.5), (10, 1), (15, 1), (20, 1.5), (25, 2), (30, 3.5), (40, 4.5);

    raise notice 'структура справочников создана';
end $$;