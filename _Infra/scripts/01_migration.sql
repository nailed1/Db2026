-- Скрипт миграции №1
-- Создание справочников и основных таблиц

-- Удаление таблиц (для повторного запуска)
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS parameters CASCADE;
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

-- Справочник параметров (высота, температура и т.д.)
CREATE TABLE parameters (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    value INTEGER
);

-- Пачки измерений
CREATE TABLE batches (
    id SERIAL PRIMARY KEY,
    number TEXT NOT NULL,
    equipment_id INTEGER,
    user_id INTEGER,
    created_at DATE
);

-- Тестовые данные

-- Должности
INSERT INTO positions (name)
VALUES
    ('Engineer'),
    ('Operator'),
    ('Technologist');

-- Типы оборудования
INSERT INTO equipment_types (name)
VALUES
    ('DMK'),
    ('VR'),
    ('CNC Machine');

-- Пользователи
INSERT INTO users (full_name, position_id)
VALUES
    ('Ivan Petrov', 2),
    ('Sergey Ivanov', 1),
    ('Alexander Luzhnyakov', 1),
    ('Dmitry Bering', 3);

-- Параметры
INSERT INTO parameters (name, value)
VALUES
    ('Meteopost height', 150),
    ('Temperature', 15),
    ('Pressure', 750),
    ('Wind direction', 0),
    ('Wind speed', 0);

-- Пачки
INSERT INTO batches (number, equipment_id, user_id, created_at)
VALUES
    ('P-001', 1, 1, '2026-09-20'),
    ('P-002', 2, 2, '2026-09-20'),
    ('P-003', 3, 1, '2026-09-21'),
    ('P-004', 1, 3, '2026-09-21'),
    ('P-005', 2, 4, '2026-09-22');

-- Выборка с объединением таблиц
SELECT
    b.number AS batch_number,
    b.created_at,
    et.name AS equipment,
    u.full_name,
    p.name AS position
FROM batches b
JOIN equipment_types et ON b.equipment_id = et.id
JOIN users u ON b.user_id = u.id
JOIN positions p ON u.position_id = p.id
ORDER BY b.number;