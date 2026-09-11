WITH rn_first_table AS (
    SELECT X AS first_x, Y AS first_y,
    ROW_NUMBER() OVER (
        ORDER BY X
    ) AS row_num_first_tbl
    FROM functions
    ORDER BY X
), rn_second_table AS(
    SELECT X AS second_x, Y AS second_y, 
    ROW_NUMBER() OVER(
        ORDER BY X
    ) AS row_num_second_tbl
    FROM functions
    ORDER BY X
), union_result AS (
    SELECT X, Y, row_num_first_tbl FROM rn_first_table
    UNION ALL
    SELECT X, Y, row_num_second_tbl FROM rn_second_table
), symmetric_condition_check AS (
    SELECT a.first_x AS x_pair_1, a.first_y AS y_pair_1, b.second_x AS x_pair_2, b.second_y AS y_pair_2
    FROM rn_first_table a
    INNER JOIN rn_second_table b
    ON a.first_x = b.second_y and a.first_y = b.second_x
    WHERE a.row_num_first_tbl != b.row_num_second_tbl
), symmetric_pairs_split AS (
    SELECT x_pair_1 AS x, y_pair_1 AS y FROM symmetric_condition_check
    UNION
    SELECT x_pair_2 AS x, y_pair_2 AS y FROM symmetric_condition_check
)
SELECT x, y FROM symmetric_pairs_split
WHERE x <= y
ORDER BY x;
