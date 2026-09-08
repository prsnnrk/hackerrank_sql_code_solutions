WITH challenges_details AS (
    SELECT h.hacker_id AS hacker_id, h.name AS name, COUNT(c.challenge_id) AS challenges
    FROM hackers h
    INNER JOIN challenges c
    ON h.hacker_id = c.hacker_id
    GROUP BY h.hacker_id, h.name
    ORDER BY challenges DESC, hacker_id ASC
), row_num_challenges AS(
    SELECT hacker_id, name, challenges,
    ROW_NUMBER() OVER (
        PARTITION BY challenges
        ORDER BY hacker_id
    ) AS row_num,
    COUNT(*) OVER (
        PARTITION BY challenges
    ) AS total_count
    FROM challenges_details
), filter_duplicates_max AS(
    SELECT hacker_id, name, challenges
    FROM row_num_challenges
    WHERE row_num > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details)
)
SELECT
    CASE 
        -- first record as part of duplicate set with max number of challenges - keep
        WHEN row_num = 1 AND total_count > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details) THEN
            CONCAT((SELECT hacker_id FROM row_num_challenges WHERE row_num = 1 AND total_count > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details)), ' ',
            (SELECT name FROM row_num_challenges WHERE row_num = 1 AND total_count > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details)), ' ',
            (SELECT challenges FROM row_num_challenges WHERE row_num = 1 AND total_count > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details)))
            -- 'test'
        -- second record onwards as part of duplicate set with max number of challenges - keep
        WHEN row_num > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details) THEN
            CONCAT((SELECT hacker_id FROM row_num_challenges b WHERE b.row_num = a.row_num AND challenges >= (SELECT MAX(challenges) FROM challenges_details)), ' ',
            (SELECT name FROM row_num_challenges b WHERE b.row_num = a.row_num AND challenges >= (SELECT MAX(challenges) FROM challenges_details)), ' ',
            (SELECT challenges FROM row_num_challenges b WHERE b.row_num = a.row_num AND challenges >= (SELECT MAX(challenges) FROM challenges_details)))
        -- no duplicate - keep all regardless of max number of challenges or not
        WHEN total_count = 1 THEN
            CONCAT((SELECT hacker_id FROM row_num_challenges b WHERE row_num = 1 AND total_count = 1 AND b.hacker_id = a.hacker_id), ' ',
            (SELECT name FROM row_num_challenges b WHERE row_num = 1 AND total_count = 1 AND b.hacker_id = a.hacker_id), ' ',
            (SELECT challenges FROM row_num_challenges b WHERE row_num = 1 AND total_count = 1 AND b.hacker_id = a.hacker_id))
    END AS filter_1_dup_max
FROM row_num_challenges a
-- filter out the duplicate records with the number of challenges not being the max value:
WHERE (
    row_num = 1 AND total_count > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details)
) OR
(
    row_num > 1 AND challenges >= (SELECT MAX(challenges) FROM challenges_details)
) OR
(
    total_count = 1
)
ORDER BY challenges DESC, hacker_id ASC;
