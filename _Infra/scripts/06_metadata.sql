-- Вывод метаданных: таблицы и их колонки в одном списке.

SELECT
    ROW_NUMBER() OVER (ORDER BY sort_key, sub_order, name) AS "№",
    name AS "Наименование",
    type AS "Тип"
FROM (
    SELECT
        table_name AS name,
        'TABLE' AS type,
        table_name AS sort_key,
        0 AS sub_order
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'

    UNION ALL

    SELECT
        table_name || '.' || column_name,
        UPPER(data_type),
        table_name,
        1
    FROM information_schema.columns
    WHERE table_schema = 'public'
) AS t
ORDER BY sort_key, sub_order, name;