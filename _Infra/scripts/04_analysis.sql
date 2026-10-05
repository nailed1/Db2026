-- Запрос 1: каждый пользователь имеет одинаковое количество измерений?
-- Внутренний SELECT считает количество партий у каждого солдата.
-- Внешний SELECT берёт MIN и MAX этих количеств.
-- Если MIN = MAX - у всех одинаково. Если разные - есть расхождение.
SELECT
    MIN(cnt) AS min_cnt,
    MAX(cnt) AS max_cnt
FROM (
    SELECT s.id, COUNT(b.id) AS cnt
    FROM soldiers s
    LEFT JOIN batch b ON b.soldier_id = s.id
    GROUP BY s.id
) AS t;

-- Детальный список: сколько партий у каждого солдата.
SELECT
    s.id,
    s.personal_id,
    COUNT(b.id) AS batch_count
FROM soldiers s
LEFT JOIN batch b ON b.soldier_id = s.id
GROUP BY s.id, s.personal_id
ORDER BY batch_count;


-- Запрос 2: у нас нет пустых пачек измерения?
SELECT
    b.id AS batch_id,
    b.measured_at
FROM batch b
LEFT JOIN (
    SELECT p.batch_id, COUNT(*) AS meas_counter
    FROM parameters p
    GROUP BY p.batch_id
) AS t ON b.id = t.batch_id
WHERE t.meas_counter IS NULL;


-- Запрос 3: каждая пачка измерений содержит 5 параметров?
SELECT
    b.id AS batch_id,
    COUNT(p.id) AS param_count
FROM batch b
LEFT JOIN parameters p ON p.batch_id = b.id
GROUP BY b.id
HAVING COUNT(p.id) <> 5
ORDER BY b.id;


-- Запрос 4: все значения в рамках нужных диапазонов?
SELECT
    p.id AS parameter_id,
    p.batch_id,
    p.parameter_type_id,
    p.value
FROM parameters p
WHERE
    (p.parameter_type_id = 2 AND (p.value < -58.0 OR p.value > 58.0))
    OR (p.parameter_type_id = 3 AND (p.value < 500 OR p.value > 900))
    OR (p.parameter_type_id = 4 AND (p.value < 0 OR p.value > 59))
    OR (p.parameter_type_id = 5 AND (p.value < 0 OR p.value > 15))
    OR (p.parameter_type_id = 6 AND (p.value < 0 OR p.value > 150));


-- Запрос 5: все единицы измерения верны и корректны?
SELECT
    p.id AS parameter_id,
    p.batch_id,
    pt.id AS parameter_type_id,
    pt.name AS parameter_name,
    u.id AS unit_id,
    u.name AS unit_name
FROM parameters p
JOIN parameter_types pt ON p.parameter_type_id = pt.id
JOIN units u ON pt.unit_id = u.id
WHERE
    (pt.id = 1 AND u.id <> 1)
    OR (pt.id = 2 AND u.id <> 2)
    OR (pt.id = 3 AND u.id <> 3)
    OR (pt.id = 4 AND u.id <> 5)
    OR (pt.id = 5 AND u.id <> 4)
    OR (pt.id = 6 AND u.id <> 1);