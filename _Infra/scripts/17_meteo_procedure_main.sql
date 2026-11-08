do $$
begin
    -- главная процедура расчета по высотам
    create or replace procedure public.calc_meteo11(
        p_params input_params
    )
    language plpgsql
    as $f6$
    declare
        r record;
        v_temp_val integer; v_temp_code integer;
        v_wind_speed integer; v_wind_dir_delta integer; v_final_dir integer;
    begin
        raise notice 'результаты расчета (оборудование id: %)', p_params.device_id;

        -- цикл по всем высотам
        for r in select id, height from public.calc_correction_heights order by height
        loop
            -- считаем температуру
            select p_value, p_code into v_temp_val, v_temp_code
            from public.fn_calc_temp_correction(p_params.temperature, r.id);

            -- считаем скорость и направление в зависимости от оборудования
            if p_params.device_id = 1 then
                v_wind_speed := public.fn_calc_speed_correction(p_params.wind_speed, p_params.device_id, r.id);
                v_wind_dir_delta := public.fn_calc_direction_correction(p_params.wind_speed, p_params.device_id, r.id);
            else
                v_wind_speed := public.fn_calc_speed_correction(p_params.bullet_drift, p_params.device_id, r.id);
                v_wind_dir_delta := public.fn_calc_direction_correction(p_params.bullet_drift, p_params.device_id, r.id);
            end if;
            
            -- итоговое направление
            v_final_dir := p_params.wind_dir + v_wind_dir_delta;

            raise notice 'высота: %, откл: % (код %), ветер: %, напр: %', 
                r.height, v_temp_val, v_temp_code, v_wind_speed, v_final_dir;
        end loop;
    end;
    $f6$;
end $$;

-- тестовый вызов
do $$
begin
    raise notice 'тест для дмк';
    call public.calc_meteo11(row(23.0, 750, 15, 6, 0, 1)::input_params);
    
    raise notice ' ';
    raise notice 'тест для вр';
    call public.calc_meteo11(row(23.0, 750, 15, 0, 100, 2)::input_params);
end $$;