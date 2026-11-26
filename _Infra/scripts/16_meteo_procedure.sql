do $$
begin
    drop function if exists public.fn_get_calc_row(integer, integer);
    drop function if exists public.fn_get_type_id(text, integer);
    drop function if exists public.fn_calc_temp_correction(numeric, integer);
    drop function if exists public.fn_calc_speed_correction(numeric, integer, integer);
    drop function if exists public.fn_calc_direction_correction(numeric, integer, integer);
    drop type if exists input_params cascade;

    -- создание типа для входящих параметров
    create type input_params as (
        temperature numeric,
        pressure numeric,
        wind_dir numeric,
        wind_speed numeric,
        bullet_drift numeric,
        device_id integer
    );

    -- функция получения массива значений по типу таблицы и высоте
    create or replace function public.fn_get_calc_row(
        p_type_id integer,
        p_height_id integer
    )
    returns integer[]
    language plpgsql
    as $f1$
    declare
        v_row integer[];
    begin
        select c.row_values into v_row
        from public.calc_correction c
        where c.type_id = p_type_id and c.height_id = p_height_id;

        if v_row is null then
            raise exception 'нет данных в calc_correction: type_id = %, height_id = %', p_type_id, p_height_id;
        end if;
        return v_row;
    end;
    $f1$;

    -- функция поиска id типа таблицы по коду и оборудованию
    create or replace function public.fn_get_type_id(
        p_code text,
        p_device_id integer default null
    )
    returns integer
    language plpgsql
    as $f2$
    declare
        v_id integer;
    begin
        select t.id into v_id
        from public.calc_correction_types t
        where t.code = p_code
          and (p_device_id is null or t.measurment_equipment_id = p_device_id);

        if v_id is null then
            raise exception 'не найден тип таблицы корректировок: %', p_code;
        end if;
        return v_id;
    end;
    $f2$;

    -- функция расчета отклонения температуры
    create or replace function public.fn_calc_temp_correction(
        p_temperature numeric,
        p_height_id integer,
        out p_value integer,
        out p_code integer
    )
    language plpgsql
    as $f3$
    declare
        v_delta_tv numeric;
        v_t0 numeric;
        v_dt integer;
        v_type_id integer;
        v_row integer[];
        v_rem integer;
        v_part integer;
        v_col integer;
        v_sum integer := 0;
    begin
        -- честная интерполяция по таблице 1
        select t2.correction - (t2.temperature - p_temperature) * (t2.correction - t1.correction) / (t2.temperature - t1.temperature)
        into v_delta_tv
        from (select temperature, correction from calc_correction_temperature where temperature <= p_temperature order by temperature desc limit 1) t1
        cross join (select temperature, correction from calc_correction_temperature where temperature >= p_temperature order by temperature limit 1) t2;
        
        -- защита от выхода за границы таблицы
        if v_delta_tv is null then
            select correction into v_delta_tv from calc_correction_temperature 
            where temperature = (select max(temperature) from calc_correction_temperature where temperature <= p_temperature)
            or temperature = (select min(temperature) from calc_correction_temperature where temperature >= p_temperature)
            limit 1;
        end if;

        v_t0 := p_temperature + v_delta_tv;
        v_dt := round(v_t0 - 15.9)::integer;

        -- определяем, плюсовая или минусовая таблица
        v_type_id := public.fn_get_type_id(
            case when v_dt < 0 then 'temp_negative' else 'temp_positive' end
        );

        v_row := public.fn_get_calc_row(v_type_id, p_height_id);
        v_rem := abs(v_dt);

        -- цикл разложения (например, 12 на 10 + 2)
        while v_rem > 0 loop
            select h.header_value, h.col_index into v_part, v_col
            from public.calc_correction_headers h
            where h.type_id = v_type_id
              and h.header_value <= v_rem
              and v_row[h.col_index] is not null
            order by h.header_value desc limit 1;

            if v_part is null then
                raise exception 'не удалось разложить отклонение %', v_dt;
            end if;

            v_sum := v_sum + v_row[v_col];
            v_rem := v_rem - v_part;
        end loop;

        p_value := v_sum;
        -- если минус, добавляем 50 к коду
        if v_dt < 0 then p_code := 50 + abs(v_sum); else p_code := v_sum; end if;
    end;
    $f3$;

    -- функция расчета скорости ветра
    create or replace function public.fn_calc_speed_correction(
        p_input numeric,
        p_device_id integer,
        p_height_id integer
    )
    returns integer
    language plpgsql
    as $f4$
    declare
        v_type_id integer;
        v_min_input numeric;
        v_row integer[];
        v_col0 integer; v_col1 integer;
        v_x0 numeric; v_x1 numeric; v_y0 numeric; v_y1 numeric;
        v_result numeric;
    begin
        v_type_id := public.fn_get_type_id('speed', p_device_id);
        if p_input = 0 then return 0; end if;

        select min(h.header_value) into v_min_input from public.calc_correction_headers h where h.type_id = v_type_id;
        if p_input < v_min_input then return 0; end if;

        v_row := public.fn_get_calc_row(v_type_id, p_height_id);

        -- ищем левую границу для интерполяции
        select h.header_value, h.col_index into v_x0, v_col0
        from public.calc_correction_headers h
        where h.type_id = v_type_id and h.header_value <= p_input
        order by h.header_value desc limit 1;

        -- ищем правую границу
        select h.header_value, h.col_index into v_x1, v_col1
        from public.calc_correction_headers h
        where h.type_id = v_type_id and h.header_value >= p_input
        order by h.header_value limit 1;

        v_y0 := v_row[v_col0];
        v_y1 := v_row[v_col1];

        if v_x0 = v_x1 then return v_y0; end if;

        -- линейная интерполяция
        v_result := v_y0 + (p_input - v_x0) * (v_y1 - v_y0) / (v_x1 - v_x0);
        return round(v_result)::integer;
    end;
    $f4$;

    -- функция расчета направления ветра
    create or replace function public.fn_calc_direction_correction(
        p_input numeric,
        p_device_id integer,
        p_height_id integer
    )
    returns integer
    language plpgsql
    as $f5$
    declare
        v_type_id integer; v_speed_type_id integer;
        v_min_input numeric; v_delta integer;
    begin
        if p_input = 0 then return 0; end if;

        v_speed_type_id := public.fn_get_type_id('speed', p_device_id);
        select min(h.header_value) into v_min_input from public.calc_correction_headers h where h.type_id = v_speed_type_id;
        if p_input < v_min_input then return 0; end if;

        v_type_id := public.fn_get_type_id('direction', p_device_id);
        select c.row_values[1] into v_delta
        from public.calc_correction c
        where c.type_id = v_type_id and c.height_id = p_height_id;

        return coalesce(v_delta, 0);
    end;
    $f5$;
end $$;