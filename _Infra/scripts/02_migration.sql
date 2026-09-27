-- Удаление объектов для идемпотентности повторного запуска
DROP TABLE IF EXISTS parameters_new;
DROP TABLE IF EXISTS device_parameter_types;
DROP TABLE IF EXISTS parameter_types;
DROP TABLE IF EXISTS units;
DROP TABLE IF EXISTS base_units;

-- Справочник базовых единиц измерения
CREATE TABLE base_units (
    id INTEGER,
    name TEXT
);

COMMENT ON TABLE base_units IS 'Справочник базовых единиц измерения (физических величин)';
COMMENT ON COLUMN base_units.id IS 'Уникальный код базовой величины';
COMMENT ON COLUMN base_units.name IS 'Название базовой величины (Длина, Температура и т.д.)';

INSERT INTO base_units (id, name) VALUES
(1, 'Длина'),
(2, 'Температура'),
(3, 'Давление'),
(4, 'Скорость'),
(5, 'Угол');

-- Справочник единиц измерения
CREATE TABLE units (
    id INTEGER,
    base_unit_id INTEGER,
    name TEXT
);

COMMENT ON TABLE units IS 'Справочник единиц измерения';
COMMENT ON COLUMN units.id IS 'Уникальный код единицы измерения';
COMMENT ON COLUMN units.base_unit_id IS 'Ссылка на базовую величину из base_units';
COMMENT ON COLUMN units.name IS 'Название единицы измерения (Метр, Градус Цельсия и т.д.)';

INSERT INTO units (id, base_unit_id, name) VALUES
(1, 1, 'Метр'),
(2, 2, 'Градус Цельсия'),
(3, 3, 'Миллиметр ртутного столба'),
(4, 4, 'Метр в секунду'),
(5, 5, 'Большое деление угломера');

-- Справочник типов параметров
CREATE TABLE parameter_types (
    id INTEGER,
    unit_id INTEGER,
    name TEXT
);

COMMENT ON TABLE parameter_types IS 'Справочник типов параметров измерения';
COMMENT ON COLUMN parameter_types.id IS 'Уникальный код типа параметра';
COMMENT ON COLUMN parameter_types.unit_id IS 'Ссылка на единицу измерения из units';
COMMENT ON COLUMN parameter_types.name IS 'Название типа параметра (Высота, Температура и т.д.)';

INSERT INTO parameter_types (id, unit_id, name) VALUES
(1, 1, 'Высота метеопоста'),
(2, 2, 'Температура воздуха'),
(3, 3, 'Давление атмосферы'),
(4, 5, 'Направление ветра'),
(5, 4, 'Скорость ветра'),
(6, 1, 'Дальность сноса пуль');

-- Связка оборудования и доступных типов параметров
CREATE TABLE device_parameter_types (
    id INTEGER,
    device_id INTEGER,
    parameter_type_id INTEGER
);

COMMENT ON TABLE device_parameter_types IS 'Связка: какие типы параметров доступны какому оборудованию';
COMMENT ON COLUMN device_parameter_types.id IS 'Уникальный код записи';
COMMENT ON COLUMN device_parameter_types.device_id IS 'Ссылка на оборудование из devices';
COMMENT ON COLUMN device_parameter_types.parameter_type_id IS 'Ссылка на тип параметра из parameter_types';

INSERT INTO device_parameter_types (id, device_id, parameter_type_id) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5),
(6, 2, 1),
(7, 2, 2),
(8, 2, 3),
(9, 2, 4),
(10, 2, 6);

-- Новая универсальная таблица параметров (создаётся под временным именем)
CREATE TABLE parameters_new (
    id SERIAL,
    batch_id INTEGER,
    parameter_type_id INTEGER,
    value NUMERIC
);

COMMENT ON TABLE parameters_new IS 'Параметры метеоизмерений (универсальная структура)';
COMMENT ON COLUMN parameters_new.id IS 'Уникальный код записи (суррогатный ключ)';
COMMENT ON COLUMN parameters_new.batch_id IS 'Ссылка на партию измерений из batch';
COMMENT ON COLUMN parameters_new.parameter_type_id IS 'Ссылка на тип параметра из parameter_types';
COMMENT ON COLUMN parameters_new.value IS 'Числовое значение параметра';

-- Перенос данных из старой parameters в новую структуру
INSERT INTO parameters_new (batch_id, parameter_type_id, value)
SELECT batch.id, 1, height
FROM parameters
JOIN batch ON parameters.id = batch.parameter_id
WHERE parameters.height IS NOT NULL
UNION ALL
SELECT batch.id, 2, temp
FROM parameters
JOIN batch ON parameters.id = batch.parameter_id
WHERE parameters.temp IS NOT NULL
UNION ALL
SELECT batch.id, 3, atm_press
FROM parameters
JOIN batch ON parameters.id = batch.parameter_id
WHERE parameters.atm_press IS NOT NULL
UNION ALL
SELECT batch.id, 4, dir_wind
FROM parameters
JOIN batch ON parameters.id = batch.parameter_id
WHERE parameters.dir_wind IS NOT NULL
UNION ALL
SELECT batch.id, 5, speed_wind
FROM parameters
JOIN batch ON parameters.id = batch.parameter_id
WHERE parameters.speed_wind IS NOT NULL
UNION ALL
SELECT batch.id, 6, bullet_dist
FROM parameters
JOIN batch ON parameters.id = batch.parameter_id
WHERE parameters.bullet_dist IS NOT NULL;

-- Перенос device_id из старой parameters в batch
ALTER TABLE batch ADD COLUMN device_id INTEGER;

COMMENT ON COLUMN batch.device_id IS 'Ссылка на оборудование из devices';

UPDATE batch
SET device_id = parameters.device_id
FROM parameters
WHERE parameters.id = batch.parameter_id;

-- Удаление старой структуры parameters
DROP TABLE IF EXISTS parameters;

ALTER TABLE batch DROP COLUMN parameter_id;

-- Переименование новой таблицы в финальное имя
ALTER TABLE parameters_new RENAME TO parameters;

-- Итоговый запрос: журнал измерений
SELECT
    batch.measured_at AS "Дата измерения",
    batch.id AS "Номер пачки",
    soldiers.personal_id AS "ФИО сотрудника",
    parameter_types.name || ' и ' || units.name AS "Параметр и ед. изм.",
    parameters.value AS "Значение"
FROM parameters
JOIN batch ON parameters.batch_id = batch.id
JOIN soldiers ON batch.soldier_id = soldiers.id
JOIN parameter_types ON parameters.parameter_type_id = parameter_types.id
JOIN units ON parameter_types.unit_id = units.id
ORDER BY batch.id, parameters.parameter_type_id;