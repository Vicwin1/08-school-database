-- EXPLAIN examples and optional performance indexes for queries.sql.
-- Run the BEFORE EXPLAIN statements first, then create the indexes, then run
-- ANALYZE TABLE and the AFTER EXPLAIN statements. Index creation is one-time.

-- BEFORE: query 3 (average and class rank for the selected term).
EXPLAIN
SELECT
    t.term_name,
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_score,
    RANK() OVER (
        PARTITION BY r.class_id, r.term_id
        ORDER BY AVG(r.ca_score + r.exam_score) DESC
    ) AS class_position
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
GROUP BY
    r.class_id, r.term_id, s.student_id, s.admission_number,
    s.first_name, s.middle_name, s.last_name, c.class_name, t.term_name
ORDER BY c.class_name, class_position, s.admission_number;

-- BEFORE: query 5 (students with two or more failing subjects).
EXPLAIN
SELECT
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    COUNT(*) AS failed_subject_count
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
  AND r.ca_score + r.exam_score < 40
GROUP BY c.class_id, c.class_name, s.student_id, s.admission_number,
         s.first_name, s.middle_name, s.last_name
HAVING COUNT(*) >= 2
ORDER BY c.class_name, failed_subject_count DESC, s.last_name, s.first_name;

-- BEFORE: query 7 (attendance percentage per student, below 80%).
EXPLAIN
WITH attendance_stats AS (
    SELECT
        s.student_id,
        s.admission_number,
        s.first_name,
        s.middle_name,
        s.last_name,
        c.class_name,
        COUNT(a.student_id) AS recorded_days,
        SUM(CASE WHEN a.status IN ('present', 'late') THEN 1 ELSE 0 END) AS attended_days
    FROM student AS s
    JOIN school_class AS c ON c.class_id = s.class_id
    LEFT JOIN attendance AS a ON a.student_id = s.student_id
    GROUP BY
        s.student_id, s.admission_number, s.first_name, s.middle_name,
        s.last_name, c.class_name
)
SELECT
    class_name,
    admission_number,
    CONCAT_WS(' ', first_name, middle_name, last_name) AS student_name,
    recorded_days,
    attended_days,
    ROUND(100.0 * attended_days / NULLIF(recorded_days, 0), 2) AS attendance_percentage
FROM attendance_stats
WHERE 100.0 * attended_days / NULLIF(recorded_days, 0) < 80
   OR recorded_days = 0
ORDER BY class_name, attendance_percentage, admission_number;

-- One covering index for the term-scoped result scans/grouping in queries 3
-- and 5. The score columns are included so these reports can be served from
-- the secondary index without fetching each result row from the clustered PK.
CREATE INDEX idx_result_term_class_student_subject_scores
    ON result (term_id, class_id, student_id, subject_id, ca_score, exam_score);

-- Covers query 7's per-student attendance counts and status tally. The existing
-- attendance PK starts with student_id but does not contain status.
CREATE INDEX idx_attendance_student_status
    ON attendance (student_id, status);

ANALYZE TABLE result, attendance;

-- AFTER: rerun the same plans after index creation and statistics refresh.
EXPLAIN
SELECT
    t.term_name,
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_score,
    RANK() OVER (
        PARTITION BY r.class_id, r.term_id
        ORDER BY AVG(r.ca_score + r.exam_score) DESC
    ) AS class_position
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
GROUP BY
    r.class_id, r.term_id, s.student_id, s.admission_number,
    s.first_name, s.middle_name, s.last_name, c.class_name, t.term_name
ORDER BY c.class_name, class_position, s.admission_number;

EXPLAIN
SELECT
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    COUNT(*) AS failed_subject_count
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
  AND r.ca_score + r.exam_score < 40
GROUP BY c.class_id, c.class_name, s.student_id, s.admission_number,
         s.first_name, s.middle_name, s.last_name
HAVING COUNT(*) >= 2
ORDER BY c.class_name, failed_subject_count DESC, s.last_name, s.first_name;

EXPLAIN
WITH attendance_stats AS (
    SELECT
        s.student_id,
        s.admission_number,
        s.first_name,
        s.middle_name,
        s.last_name,
        c.class_name,
        COUNT(a.student_id) AS recorded_days,
        SUM(CASE WHEN a.status IN ('present', 'late') THEN 1 ELSE 0 END) AS attended_days
    FROM student AS s
    JOIN school_class AS c ON c.class_id = s.class_id
    LEFT JOIN attendance AS a ON a.student_id = s.student_id
    GROUP BY
        s.student_id, s.admission_number, s.first_name, s.middle_name,
        s.last_name, c.class_name
)
SELECT
    class_name,
    admission_number,
    CONCAT_WS(' ', first_name, middle_name, last_name) AS student_name,
    recorded_days,
    attended_days,
    ROUND(100.0 * attended_days / NULLIF(recorded_days, 0), 2) AS attendance_percentage
FROM attendance_stats
WHERE 100.0 * attended_days / NULLIF(recorded_days, 0) < 80
   OR recorded_days = 0
ORDER BY class_name, attendance_percentage, admission_number;
