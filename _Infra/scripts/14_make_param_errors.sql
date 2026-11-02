-- Тестовые пачки с ошибками параметров (аналог 010_make_param_errors.sql).
-- Запускать после 09_check_parameters_func.sql.
do $$
begin
    insert into batch (id, soldier_id, device_id) values (100, 1, 1);
    insert into parameters (batch_id, parameter_type_id, value) values
    (100, 2, 100.0);

    insert into batch (id, soldier_id, device_id) values (101, 1, 1);
    insert into parameters (batch_id, parameter_type_id, value) values
    (101, 3, 2000),
    (101, 6, 50);

    insert into batch (id, soldier_id, device_id) values (102, 1, 2);
    insert into parameters (batch_id, parameter_type_id, value) values
    (102, 4, 99);

    insert into batch (id, soldier_id, device_id) values (103, 2, 1);
    insert into parameters (batch_id, parameter_type_id, value) values
    (103, 5, 20);

    insert into batch (id, soldier_id, device_id) values (104, 2, 2);
    insert into parameters (batch_id, parameter_type_id, value) values
    (104, 6, 200),
    (104, 5, 5);

    insert into batch (id, soldier_id, device_id) values (105, 3, 1);
    insert into parameters (batch_id, parameter_type_id, value) values
    (105, 2, -100.0);
end $$;
