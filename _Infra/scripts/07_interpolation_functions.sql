-- Создание типа данных и функций для линейной интерполяции.
DO $$
BEGIN

-- 1. DDL структуры: новый тип данных для интерполяции
DROP TYPE IF EXISTS interp_struct CASCADE;

CREATE TYPE interp_struct AS (
    x0 NUMERIC,
    y0 NUMERIC,
    x1 NUMERIC,
    y1 NUMERIC
);

COMMIT; -- Первая транзакция завершена

-- 2. Функция определения параметров интерполяции
DROP FUNCTION IF EXISTS get_interpolation_params(NUMERIC);

CREATE OR REPLACE FUNCTION get_interpolation_params(p_target_temp NUMERIC)
RETURNS interp_struct AS $func$
DECLARE
    res interp_struct;
BEGIN
    SELECT 
        COALESCE(
            (SELECT MAX(t1.t0) FROM temp_correction t1 WHERE t1.t0 <= p_target_temp),
            p_target_temp
        ),
        COALESCE(
            (SELECT t3.delta_tv FROM temp_correction t3 
             WHERE t3.t0 = (SELECT MAX(t1.t0) FROM temp_correction t1 WHERE t1.t0 <= p_target_temp)),
            (SELECT t4.delta_tv FROM temp_correction t4 
             WHERE t4.t0 = (SELECT MIN(t2.t0) FROM temp_correction t2))
        ),
        COALESCE(
            (SELECT MIN(t1.t0) FROM temp_correction t1 WHERE t1.t0 >= p_target_temp),
            p_target_temp
        ),
        COALESCE(
            (SELECT t3.delta_tv FROM temp_correction t3 
             WHERE t3.t0 = (SELECT MIN(t1.t0) FROM temp_correction t1 WHERE t1.t0 >= p_target_temp)),
            (SELECT t4.delta_tv FROM temp_correction t4 
             WHERE t4.t0 = (SELECT MAX(t2.t0) FROM temp_correction t2))
        )
    INTO res.x0, res.y0, res.x1, res.y1;

    RETURN res;
END;
$func$ LANGUAGE plpgsql;


-- 3. Функция расчета интерполяции
DROP FUNCTION IF EXISTS calculate_interpolation(NUMERIC, interp_struct);

CREATE OR REPLACE FUNCTION calculate_interpolation(p_x NUMERIC, p_struct interp_struct)
RETURNS NUMERIC AS $func$
DECLARE
    res NUMERIC;
BEGIN
    IF p_struct.x0 = p_struct.x1 THEN
        RETURN p_struct.y0;
    END IF;

    res := p_struct.y0 + (p_x - p_struct.x0) * (p_struct.y1 - p_struct.y0) / (p_struct.x1 - p_struct.x0);
    
    RETURN res;
END;
$func$ LANGUAGE plpgsql;

COMMIT; -- Вторая транзакция завершена

END
$$;