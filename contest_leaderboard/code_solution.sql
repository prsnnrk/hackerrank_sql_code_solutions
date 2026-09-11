WITH hackers_submissions AS(
    SELECT h.hacker_id AS hacker_id, h.name AS name, s.challenge_id AS challenge_id, s.submission_id AS submission_id, s.score AS score,
    ROW_NUMBER() OVER (
        PARTITION BY s.challenge_id, h.hacker_id
        ORDER BY s.submission_id ASC
    ) AS row_num,
    COUNT(*) OVER (
        PARTITION BY s.challenge_id, h.hacker_id
    ) AS number_of_submissions
    FROM hackers h
    INNER JOIN submissions s
    ON h.hacker_id = s.hacker_id
), max_scores AS(
    SELECT hacker_id, name, challenge_id, MAX(score) AS max_score
    FROM hackers_submissions
    GROUP BY hacker_id, name, challenge_id
    ORDER BY hacker_id
), total_scores AS(
    SELECT hacker_id, name, SUM(max_score) AS total_score
    FROM max_scores
    GROUP BY hacker_id, name
)
SELECT * FROM total_scores
WHERE total_score != 0
ORDER BY total_score DESC, hacker_id ASC;
