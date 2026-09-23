-- Удаление таблиц (для повторного запуска)
DROP TABLE IF EXISTS parameters CASCADE;
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS equipment_types CASCADE;
DROP TABLE IF EXISTS positions CASCADE;

-- Справочник должностей
CREATE TABLE positions (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Справочник типов оборудования (ДМК, ВР)
CREATE TABLE equipment_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Пользователи системы
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    position_id INTEGER
);

-- Пачки измерений
CREATE TABLE batches (
    id SERIAL PRIMARY KEY,
    number TEXT NOT NULL,
    equipment_id INTEGER,
    user_id INTEGER,
    created_at DATE
);

-- Параметры измерений (привязаны к пачке)
CREATE TABLE parameters (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    value INTEGER,
    batch_id INTEGER
);

-- Тестовые данные

-- Должности
INSERT INTO positions (name)
VALUES
    ('Engineer'),
    ('Operator'),
    ('Technologist');

-- Типы оборудования (ДМК, ВР)
INSERT INTO equipment_types (name)
VALUES
    ('DMK'),
    ('VR');

-- Пользователи
INSERT INTO users (full_name, position_id)
VALUES
    ('Ivan Petrov', 2),
    ('Sergey Ivanov', 1),
    ('Alexander Luzhnyakov', 1),
    ('Dmitry Bering', 3);

-- Пачки
INSERT INTO batches (number, equipment_id, user_id, created_at)
VALUES
    ('P-001', 1, 1, '2026-09-20'),
    ('P-002', 2, 2, '2026-09-20'),
    ('P-003', 1, 1, '2026-09-21'),
    ('P-004', 2, 3, '2026-09-21'),
    ('P-005', 1, 4, '2026-09-22');

-- Параметры (привязаны к пачкам через batch_id)
INSERT INTO parameters (name, value, batch_id)
VALUES
    -- Параметры для пачки 1
    ('Meteopost height', 100, 1),
    ('Temperature', 15, 1),
    ('Pressure', 750, 1),
    ('Wind direction', 0, 1),
    ('Wind speed', 0, 1),
    -- Параметры для пачки 2
    ('Meteopost height', 120, 2),
    ('Temperature', 20, 2),
    ('Pressure', 760, 2),
    ('Wind direction', 15, 2),
    ('Wind speed', 5, 2),
    -- Параметры для пачки 3
    ('Meteopost height', 100, 3),
    ('Temperature', 10, 3),
    ('Pressure', 745, 3),
    ('Wind direction', 30, 3),
    ('Wind speed', 8, 3),
    -- Параметры для пачки 4
    ('Meteopost height', 150, 4),
    ('Temperature', 25, 4),
    ('Pressure', 765, 4),
    ('Projectile drift range', 0, 4),
    -- Параметры для пачки 5
    ('Meteopost height', 90, 5),
    ('Temperature', 18, 5),
    ('Pressure', 755, 5),
    ('Wind direction', 45, 5),
    ('Wind speed', 10, 5);

-- Выборка с объединением таблиц
SELECT
    b.number AS batch_number,
    b.created_at,
    et.name AS equipment,
    u.full_name,
    pos.name AS position,
    p.name AS parameter_name,
    p.value AS parameter_value
FROM batches b
JOIN equipment_types et ON b.equipment_id = et.id
JOIN users u ON b.user_id = u.id
JOIN positions pos ON u.position_id = pos.id
JOIN parameters p ON p.batch_id = b.id
ORDER BY b.number, p.name;