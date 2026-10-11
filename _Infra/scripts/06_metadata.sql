-- Вывод метаданных о таблицах и колонках в формате "№ | Наименование | Тип".

-- Список таблиц с типом "Таблица"
SELECT
    ROW_NUMBER() OVER (ORDER BY table_name) AS "№",
    table_name AS "Наименование",
    'Таблица' AS "Тип"
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Список колонок с типами данных
SELECT
    ROW_NUMBER() OVER (ORDER BY table_name, ordinal_position) AS "№",
    table_name || '.' || column_name AS "Наименование",
    CASE
        WHEN data_type = 'integer' THEN 'INTEGER'
        WHEN data_type = 'bigint' THEN 'BIGINT'
        WHEN data_type = 'numeric' THEN 'NUMERIC'
        WHEN data_type = 'text' THEN 'TEXT'
        WHEN data_type = 'boolean' THEN 'BOOLEAN'
        WHEN data_type = 'date' THEN 'DATE'
        WHEN data_type = 'timestamp without time zone' THEN 'TIMESTAMP'
        ELSE UPPER(data_type)
    END AS "Тип"
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;