-- Проверка работы функций интерполяции согласно примерам ТЗ.

DO $$
DECLARE
    v_target numeric;
    v_struct interp_struct;
    v_result numeric;
BEGIN
-- Тест 1: температура 23°C (внутри таблицы, между 20 и 25)
    v_target := 23;
    v_struct := get_interpolation_params(v_target);
    
    RAISE NOTICE 'Тест 1 (x = %): x0=%, y0=%, x1=%, y1=%', 
        v_target, v_struct.x0, v_struct.y0, v_struct.x1, v_struct.y1;
        
    v_result := calculate_interpolation(v_target, v_struct);
    RAISE NOTICE 'Результат интерполяции: % (ожидалось примерно 1.8)', ROUND(v_result, 2);

    -- Тест 2: температура 50°C (выход за пределы таблицы)
    v_target := 50;
    v_struct := get_interpolation_params(v_target);
    
    RAISE NOTICE 'Тест 2 (x = %): x0=%, y0=%, x1=%, y1=%', 
        v_target, v_struct.x0, v_struct.y0, v_struct.x1, v_struct.y1;
        
    v_result := calculate_interpolation(v_target, v_struct);
    RAISE NOTICE 'Результат интерполяции: % (ожидалось 4.5, так как 50 > 40)', ROUND(v_result, 2);
END $$;