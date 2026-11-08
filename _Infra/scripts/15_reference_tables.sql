-- Таблица 2 (ДМК)
CREATE TABLE ref_dmk_table2_temp (
    id SERIAL PRIMARY KEY,
    height_y INTEGER NOT NULL,
    temp_deviation NUMERIC NOT NULL,
    val_neg NUMERIC,
    val_pos NUMERIC
);
COMMENT ON TABLE ref_dmk_table2_temp IS 'Таблица 2 для ДМК (среднее отклонение температуры)';
COMMENT ON COLUMN ref_dmk_table2_temp.height_y IS 'Высота, м';
COMMENT ON COLUMN ref_dmk_table2_temp.temp_deviation IS 'Отклонение температуры, °C';
COMMENT ON COLUMN ref_dmk_table2_temp.val_neg IS 'Числитель (отрицательные)';
COMMENT ON COLUMN ref_dmk_table2_temp.val_pos IS 'Знаменатель (положительные)';

-- Таблица 3 (ДМК)
CREATE TABLE ref_dmk_table3_wind (
    id SERIAL PRIMARY KEY,
    height_y INTEGER NOT NULL,
    wind_speed_v0 INTEGER NOT NULL,
    avg_wind_speed_wy NUMERIC NOT NULL,
    dir_angle_increase TEXT NOT NULL
);
COMMENT ON TABLE ref_dmk_table3_wind IS 'Таблица 3 для ДМК (ветер)';
COMMENT ON COLUMN ref_dmk_table3_wind.height_y IS 'Высота, м';
COMMENT ON COLUMN ref_dmk_table3_wind.wind_speed_v0 IS 'Скорость приземного ветра, м/с';
COMMENT ON COLUMN ref_dmk_table3_wind.avg_wind_speed_wy IS 'Скорость среднего ветра, м/с';
COMMENT ON COLUMN ref_dmk_table3_wind.dir_angle_increase IS 'Приращение угла';

-- Таблица 2 (ВР)
CREATE TABLE ref_bp_table2_temp (
    id SERIAL PRIMARY KEY,
    height_y INTEGER NOT NULL,
    temp_deviation NUMERIC NOT NULL,
    val_neg NUMERIC,
    val_pos NUMERIC
);
COMMENT ON TABLE ref_bp_table2_temp IS 'Таблица 2 для ВР';
COMMENT ON COLUMN ref_bp_table2_temp.height_y IS 'Высота, м';
COMMENT ON COLUMN ref_bp_table2_temp.temp_deviation IS 'Отклонение температуры, °C';
COMMENT ON COLUMN ref_bp_table2_temp.val_neg IS 'Числитель (отрицательные)';
COMMENT ON COLUMN ref_bp_table2_temp.val_pos IS 'Знаменатель (положительные)';

-- Таблица 3 (ВР)
CREATE TABLE ref_bp_table3_wind (
    id SERIAL PRIMARY KEY,
    height_y INTEGER NOT NULL,
    bullet_drift_dg INTEGER NOT NULL,
    avg_wind_speed_wy NUMERIC NOT NULL,
    dir_angle_increase TEXT NOT NULL
);
COMMENT ON TABLE ref_bp_table3_wind IS 'Таблица 3 для ВР';
COMMENT ON COLUMN ref_bp_table3_wind.height_y IS 'Высота, м';
COMMENT ON COLUMN ref_bp_table3_wind.bullet_drift_dg IS 'Дальность сноса пуль, м';
COMMENT ON COLUMN ref_bp_table3_wind.avg_wind_speed_wy IS 'Скорость среднего ветра, м/с';
COMMENT ON COLUMN ref_bp_table3_wind.dir_angle_increase IS 'Приращение угла';

-- ДМК
INSERT INTO ref_dmk_table2_temp (height_y, temp_deviation, val_neg, val_pos) VALUES
(200, 1, -1, 1),
(200, 20, -20, 20),
(200, 40, -39, NULL), 
(400, 1, -1, 1),
(400, 20, -19, 20);

INSERT INTO ref_dmk_table3_wind (height_y, wind_speed_v0, avg_wind_speed_wy, dir_angle_increase) VALUES
(200, 3, 4, '1-00'),
(200, 4, 6, '1-00'),
(400, 3, 5, '2-00'),
(400, 4, 7, '2-00');

-- ВР
INSERT INTO ref_bp_table2_temp (height_y, temp_deviation, val_neg, val_pos) VALUES
(200, 10, -10, 10),
(400, 10, -10, 10);

INSERT INTO ref_bp_table3_wind (height_y, bullet_drift_dg, avg_wind_speed_wy, dir_angle_increase) VALUES
(200, 40, 3, '0-00'),
(200, 50, 4, '0-00'),
(200, 150, 12, '0-00'),
(400, 40, 4, '1-00');