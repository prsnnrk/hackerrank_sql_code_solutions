WITH wands_details AS (
    SELECT w.id AS id, wp.age AS age, w.coins_needed AS coins_needed, w.power AS power,
    ROW_NUMBER() OVER (
        PARTITION BY w.power, wp.age
        ORDER BY coins_needed ASC
    ) AS row_num
    FROM wands w
    INNER JOIN wands_property wp
    ON w.code = wp.code
    WHERE wp.is_evil = 0
) 
SELECT id, age, coins_needed, power
FROM wands_details
WHERE row_num = 1
ORDER BY power DESC, age DESC;
