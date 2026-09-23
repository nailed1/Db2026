DROP TABLE IF EXISTS batch CASCADE;
DROP TABLE IF EXISTS parameters CASCADE;
DROP TABLE IF EXISTS soldiers CASCADE;
DROP TABLE IF EXISTS devices CASCADE;
DROP TABLE IF EXISTS ranks CASCADE;

CREATE TABLE ranks (
    id SERIAL PRIMARY KEY,
    rank TEXT
);
COMMENT ON TABLE ranks IS 'Справочник военных званий';
COMMENT ON COLUMN ranks.rank IS 'Название звания';

CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    name TEXT
);
COMMENT ON TABLE devices IS 'Справочник типов оборудования для измерений';
COMMENT ON COLUMN devices.name IS 'Название оборудования';

CREATE TABLE soldiers (
    id SERIAL PRIMARY KEY,
    personal_id INTEGER,
    rank_id INTEGER
);
COMMENT ON TABLE soldiers IS 'Справочник военнослужащих';
COMMENT ON COLUMN soldiers.personal_id IS 'Личный номер военнослужащего';
COMMENT ON COLUMN soldiers.rank_id IS 'Звание военнослужащего из ranks';

CREATE TABLE parameters (
    id SERIAL PRIMARY KEY,
    device_id INTEGER,
    height INTEGER,
    temp NUMERIC(3,1) CHECK (temp BETWEEN -58.0 AND 58.0),
    atm_press INTEGER CHECK (atm_press BETWEEN 500 AND 900),
    dir_wind INTEGER CHECK (dir_wind BETWEEN 0 AND 59),
    speed_wind INTEGER CHECK (speed_wind BETWEEN 0 AND 15),
    bullet_dist INTEGER CHECK (bullet_dist BETWEEN 0 AND 150),
    CHECK (
        (device_id = 1 AND speed_wind IS NOT NULL AND bullet_dist IS NULL)
        OR
        (device_id = 2 AND speed_wind IS NULL AND bullet_dist IS NOT NULL)
    )
);
COMMENT ON TABLE parameters IS 'Параметры метеоизмерения для расчёта';
COMMENT ON COLUMN parameters.device_id IS 'Тип оборудования из devices';
COMMENT ON COLUMN parameters.height IS 'Высота метеопоста над уровнем моря, м';
COMMENT ON COLUMN parameters.temp IS 'Температура воздуха, °C (-58.0 … 58.0)';
COMMENT ON COLUMN parameters.atm_press IS 'Атмосферное давление, мм рт.ст. (500 … 900)';
COMMENT ON COLUMN parameters.dir_wind IS 'Направление ветра, деления угломера (0 … 59)';
COMMENT ON COLUMN parameters.speed_wind IS 'Скорость ветра, м/с (0 … 15). Только для ДМК';
COMMENT ON COLUMN parameters.bullet_dist IS 'Дальность сноса пуль, м (0 … 150). Только для ВР';

CREATE TABLE batch (
    id SERIAL PRIMARY KEY,
    soldier_id INTEGER,
    parameter_id INTEGER,
    measured_at TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE batch IS 'История измерений (кто, параметры, дата)';
COMMENT ON COLUMN batch.soldier_id IS 'Военнослужащий из soldiers';
COMMENT ON COLUMN batch.parameter_id IS 'Параметры из parameters';
COMMENT ON COLUMN batch.measured_at IS 'Дата и время измерения';

INSERT INTO ranks (id, rank) VALUES
(1, 'рядовой'), (2, 'ефрейтор'), (3, 'младший сержант'),
(4, 'сержант'), (5, 'старший сержант');

INSERT INTO soldiers (id, personal_id, rank_id) VALUES
(1, 32589, 2), (2, 59589, 5), (3, 19589, 1), (4, 92589, 3), (5, 73589, 4);

INSERT INTO devices (id, name) VALUES
(1, 'ДМК'), (2, 'ВР');

INSERT INTO parameters (id, device_id, height, temp, atm_press, dir_wind, speed_wind, bullet_dist) VALUES
(1, 1, 100, 15.0, 750, 0, 0, NULL),
(2, 1, 150, -10.5, 745, 12, 5, NULL),
(3, 2, 200, 25.0, 765, 15, NULL, 30),
(4, 2, 100, 15.0, 750, 0, NULL, 0),
(5, 1, 300, 30.5, 800, 45, 10, NULL);

INSERT INTO batch (id, soldier_id, parameter_id, measured_at) VALUES
(1, 1, 1, '2026-09-20 08:00:00+08'),
(2, 2, 2, '2026-09-21 08:00:00+08'),
(3, 3, 3, '2026-09-21 10:00:00+08'),
(4, 4, 4, '2026-09-21 12:00:00+08'),
(5, 5, 5, '2026-09-21 14:00:00+08');

SELECT
    b.id AS batch_id,
    b.measured_at,
    d.name AS device,
    s.personal_id,
    r.rank,
    p.height, p.temp, p.atm_press, p.dir_wind, p.speed_wind, p.bullet_dist
FROM batch b
JOIN soldiers s ON b.soldier_id = s.id
JOIN ranks r ON s.rank_id = r.id
JOIN parameters p ON b.parameter_id = p.id
JOIN devices d ON p.device_id = d.id
ORDER BY b.id;