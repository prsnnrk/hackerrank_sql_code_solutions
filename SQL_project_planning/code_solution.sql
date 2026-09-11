WITH ordered_records AS (
    SELECT task_id, start_date, end_date
    FROM projects
    ORDER BY end_date
), calc_date_difference AS (
    SELECT task_id, start_date, end_date,
    DATEDIFF(end_date, (LAG(end_date, 1, 0) OVER (ORDER BY end_date))) AS date_difference
    FROM ordered_records
), consec_check_rn AS (
    SELECT task_id, start_date, end_date, date_difference,
    DATEDIFF(end_date, (SELECT end_date FROM calc_date_difference WHERE date_difference IS NULL)) AS consecutive_check,
    ROW_NUMBER() OVER (ORDER BY end_date) AS row_num
    FROM calc_date_difference
    ORDER BY end_date
), group_key AS (
    SELECT task_id, start_date, end_date, date_difference, consecutive_check, row_num, 
    CASE WHEN consecutive_check > row_num THEN (consecutive_check - row_num)
         WHEN row_num > consecutive_check THEN (row_num - consecutive_check)
         WHEN row_num = consecutive_check THEN 0
    END AS segmentation_key
    FROM consec_check_rn
), project_segmentation AS (
    SELECT task_id, start_date, end_date, date_difference, consecutive_check, row_num, segmentation_key,
    ROW_NUMBER() OVER(
        PARTITION BY segmentation_key
        ORDER BY end_date
    ) AS project_row_num,
    COUNT(*) OVER (PARTITION BY segmentation_key) AS max_row_num
    FROM group_key
    ORDER BY end_date
), project_start_dates AS (
    SELECT segmentation_key, start_date
    FROM project_segmentation
    WHERE project_row_num = 1
    ORDER BY end_date
), project_end_dates AS (
    SELECT segmentation_key, end_date
    FROM project_segmentation 
    WHERE project_row_num = max_row_num
    ORDER BY end_date
), completion_days AS (
    SELECT s.start_date AS start_date, e.end_date AS end_date, DATEDIFF(e.end_date, s.start_date) AS completion_days
    FROM project_start_dates s
    JOIN project_end_dates e
    ON s.segmentation_key = e.segmentation_key
)
SELECT
    start_date, end_date
FROM completion_days
ORDER BY completion_days ASC, start_date ASC;
