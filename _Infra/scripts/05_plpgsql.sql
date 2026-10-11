-- PL/pgSQL скрипт: структура, данные, связи - в трёх отдельных транзакциях.

-- ТРАНЗАКЦИЯ 1: структура таблиц и счетчики
BEGIN;

DO $$
BEGIN
    DROP TABLE IF EXISTS temperature_calc CASCADE;
    DROP TABLE IF EXISTS parameters CASCADE;
    DROP TABLE IF EXISTS device_parameter_types CASCADE;
    DROP TABLE IF EXISTS parameter_types CASCADE;
    DROP TABLE IF EXISTS units CASCADE;
    DROP TABLE IF EXISTS base_units CASCADE;
    DROP TABLE IF EXISTS batch CASCADE;
    DROP TABLE IF EXISTS soldiers CASCADE;
    DROP TABLE IF EXISTS ranks CASCADE;
    DROP TABLE IF EXISTS devices CASCADE;

    DROP SEQUENCE IF EXISTS seq_base_units CASCADE;
    DROP SEQUENCE IF EXISTS seq_units CASCADE;
    DROP SEQUENCE IF EXISTS seq_parameter_types CASCADE;
    DROP SEQUENCE IF EXISTS seq_device_parameter_types CASCADE;
    DROP SEQUENCE IF EXISTS seq_ranks CASCADE;
    DROP SEQUENCE IF EXISTS seq_soldiers CASCADE;
    DROP SEQUENCE IF EXISTS seq_devices CASCADE;
    DROP SEQUENCE IF EXISTS seq_batch CASCADE;
    DROP SEQUENCE IF EXISTS seq_parameters CASCADE;
    DROP SEQUENCE IF EXISTS seq_temperature_calc CASCADE;

    CREATE SEQUENCE seq_base_units;
    CREATE SEQUENCE seq_units;
    CREATE SEQUENCE seq_parameter_types;
    CREATE SEQUENCE seq_device_parameter_types;
    CREATE SEQUENCE seq_ranks;
    CREATE SEQUENCE seq_soldiers;
    CREATE SEQUENCE seq_devices;
    CREATE SEQUENCE seq_batch;
    CREATE SEQUENCE seq_parameters;
    CREATE SEQUENCE seq_temperature_calc;

    CREATE TABLE base_units (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_base_units'),
        name TEXT NOT NULL
    );

    CREATE TABLE units (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_units'),
        base_unit_id INTEGER,
        name TEXT NOT NULL
    );

    CREATE TABLE parameter_types (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_parameter_types'),
        unit_id INTEGER,
        name TEXT NOT NULL
    );

    CREATE TABLE devices (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_devices'),
        name TEXT NOT NULL
    );

    CREATE TABLE device_parameter_types (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_device_parameter_types'),
        device_id INTEGER,
        parameter_type_id INTEGER
    );

    CREATE TABLE ranks (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_ranks'),
        rank TEXT NOT NULL
    );

    CREATE TABLE soldiers (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_soldiers'),
        personal_id INTEGER,
        rank_id INTEGER
    );

    CREATE TABLE batch (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_batch'),
        soldier_id INTEGER,
        device_id INTEGER,
        measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE parameters (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_parameters'),
        batch_id INTEGER,
        parameter_type_id INTEGER,
        value NUMERIC
    );

    CREATE TABLE temperature_calc (
        id INTEGER PRIMARY KEY DEFAULT nextval('seq_temperature_calc'),
        batch_id INTEGER,
        temperature NUMERIC(5,2),
        calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    RAISE NOTICE 'Транзакция 1: структура создана.';
END $$;

COMMIT;


-- ТРАНЗАКЦИЯ 2: тестовые данные
BEGIN;

DO $$
BEGIN
    INSERT INTO base_units (id, name) VALUES
    (1, 'Длина'), (2, 'Температура'), (3, 'Давление'), (4, 'Скорость'), (5, 'Угол');

    INSERT INTO units (id, base_unit_id, name) VALUES
    (1, 1, 'Метр'),
    (2, 2, 'Градус Цельсия'),
    (3, 3, 'Миллиметр ртутного столба'),
    (4, 4, 'Метр в секунду'),
    (5, 5, 'Большое деление угломера');

    INSERT INTO parameter_types (id, unit_id, name) VALUES
    (1, 1, 'Высота метеопоста'),
    (2, 2, 'Температура воздуха'),
    (3, 3, 'Давление атмосферы'),
    (4, 5, 'Направление ветра'),
    (5, 4, 'Скорость ветра'),
    (6, 1, 'Дальность сноса пуль');

    INSERT INTO devices (id, name) VALUES
    (1, 'ДМК'), (2, 'ВР');

    INSERT INTO device_parameter_types (id, device_id, parameter_type_id) VALUES
    (1, 1, 1), (2, 1, 2), (3, 1, 3), (4, 1, 4), (5, 1, 5),
    (6, 2, 1), (7, 2, 2), (8, 2, 3), (9, 2, 4), (10, 2, 6);

    INSERT INTO ranks (id, rank) VALUES
    (1, 'рядовой'), (2, 'ефрейтор'), (3, 'младший сержант'),
    (4, 'сержант'), (5, 'старший сержант');

    INSERT INTO soldiers (id, personal_id, rank_id) VALUES
    (1, 32589, 2), (2, 59589, 5), (3, 19589, 1), (4, 92589, 3), (5, 73589, 4);

    INSERT INTO batch (id, soldier_id, device_id, measured_at) VALUES
    (1, 1, 1, '2026-09-20 08:00:00'),
    (2, 2, 1, '2026-09-21 08:00:00'),
    (3, 3, 2, '2026-09-21 10:00:00'),
    (4, 4, 2, '2026-09-21 12:00:00'),
    (5, 5, 1, '2026-09-21 14:00:00');

    INSERT INTO parameters (id, batch_id, parameter_type_id, value) VALUES
    (1, 1, 1, 100), (2, 1, 2, 15.0), (3, 1, 3, 750), (4, 1, 4, 0), (5, 1, 5, 0),
    (6, 2, 1, 150), (7, 2, 2, -10.5), (8, 2, 3, 745), (9, 2, 4, 12), (10, 2, 5, 5),
    (11, 3, 1, 200), (12, 3, 2, 25.0), (13, 3, 3, 765), (14, 3, 4, 15), (15, 3, 6, 30),
    (16, 4, 1, 100), (17, 4, 2, 15.0), (18, 4, 3, 750), (19, 4, 4, 0), (20, 4, 6, 0),
    (21, 5, 1, 300), (22, 5, 2, 30.5), (23, 5, 3, 800), (24, 5, 4, 45), (25, 5, 5, 10);

    INSERT INTO temperature_calc (id, batch_id, temperature, calculated_at) VALUES
    (1, 1, 15.00, '2026-09-20 08:05:00'),
    (2, 2, -10.50, '2026-09-21 08:05:00'),
    (3, 3, 25.00, '2026-09-21 10:05:00'),
    (4, 4, 15.00, '2026-09-21 12:05:00'),
    (5, 5, 30.50, '2026-09-21 14:05:00');

    PERFORM setval('seq_base_units', (SELECT MAX(id) FROM base_units));
    PERFORM setval('seq_units', (SELECT MAX(id) FROM units));
    PERFORM setval('seq_parameter_types', (SELECT MAX(id) FROM parameter_types));
    PERFORM setval('seq_device_parameter_types', (SELECT MAX(id) FROM device_parameter_types));
    PERFORM setval('seq_ranks', (SELECT MAX(id) FROM ranks));
    PERFORM setval('seq_soldiers', (SELECT MAX(id) FROM soldiers));
    PERFORM setval('seq_devices', (SELECT MAX(id) FROM devices));
    PERFORM setval('seq_batch', (SELECT MAX(id) FROM batch));
    PERFORM setval('seq_parameters', (SELECT MAX(id) FROM parameters));
    PERFORM setval('seq_temperature_calc', (SELECT MAX(id) FROM temperature_calc));

    RAISE NOTICE 'Транзакция 2: данные вставлены.';
END $$;

COMMIT;


-- ТРАНЗАКЦИЯ 3: связи и ограничения
BEGIN;

DO $$
BEGIN
    ALTER TABLE units
        ADD CONSTRAINT fk_units_base FOREIGN KEY (base_unit_id) REFERENCES base_units(id);

    ALTER TABLE parameter_types
        ADD CONSTRAINT fk_pt_unit FOREIGN KEY (unit_id) REFERENCES units(id);

    ALTER TABLE device_parameter_types
        ADD CONSTRAINT fk_dpt_device FOREIGN KEY (device_id) REFERENCES devices(id),
        ADD CONSTRAINT fk_dpt_pt FOREIGN KEY (parameter_type_id) REFERENCES parameter_types(id);

    ALTER TABLE soldiers
        ADD CONSTRAINT fk_soldiers_rank FOREIGN KEY (rank_id) REFERENCES ranks(id);

    ALTER TABLE batch
        ADD CONSTRAINT fk_batch_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers(id),
        ADD CONSTRAINT fk_batch_device FOREIGN KEY (device_id) REFERENCES devices(id);

    ALTER TABLE parameters
        ADD CONSTRAINT fk_params_batch FOREIGN KEY (batch_id) REFERENCES batch(id),
        ADD CONSTRAINT fk_params_pt FOREIGN KEY (parameter_type_id) REFERENCES parameter_types(id),
        ADD CONSTRAINT chk_params_value CHECK (value IS NOT NULL);

    ALTER TABLE temperature_calc
        ADD CONSTRAINT fk_temp_batch FOREIGN KEY (batch_id) REFERENCES batch(id),
        ADD CONSTRAINT chk_temp_range CHECK (temperature BETWEEN -58.0 AND 58.0);

    RAISE NOTICE 'Транзакция 3: связи и ограничения добавлены.';
END $$;

COMMIT;