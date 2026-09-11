WITH best_friends AS (
    SELECT s.id AS id, s.name AS name, f.friend_id AS friend_id
    FROM students s
    INNER JOIN friends f
    ON s.id = f.id
), student_salary AS (
    SELECT b.id AS id, b.name AS name, b.friend_id AS friend_id, p.salary AS stu_sal
    FROM best_friends b
    INNER JOIN packages p
    ON b.id = p.id
), best_friend_salary AS (
    SELECT ss.id AS id, ss.name AS name, ss.friend_id AS friend_id, ss.stu_sal AS stu_sal, p.salary AS friend_salary
    FROM student_salary ss
    INNER JOIN packages p
    ON ss.friend_id = p.id
) 
SELECT name
FROM best_friend_salary
WHERE friend_salary > stu_sal
ORDER BY friend_salary;
