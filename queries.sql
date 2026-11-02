-- Example reports for the school database. Run schema.sql and seed.sql first.
-- The sample-term queries use the seeded term name; change it to report another term.

-- 1. Business question: Who is in JSS1 A, and who is their form teacher?
-- Technique: JOIN connects each student to their class and the teacher assigned
-- as that class's form teacher.
SELECT
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    CONCAT_WS(' ', ft.first_name, ft.middle_name, ft.last_name) AS form_teacher
FROM school_class AS c
JOIN student AS s ON s.class_id = c.class_id
JOIN teacher AS ft ON ft.teacher_id = c.form_teacher_id
WHERE c.class_name = 'JSS1 A'
ORDER BY s.last_name, s.first_name, s.admission_number;

-- 2. Business question: What is each student's total and letter grade in each subject?
-- Technique: CASE maps the CA + exam total to a grading band (A: 80-100,
-- B: 70-79.99, C: 60-69.99, D: 50-59.99, E: 40-49.99, F: below 40).
SELECT
    t.term_name,
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    sub.subject_code,
    sub.subject_name,
    r.ca_score,
    r.exam_score,
    r.ca_score + r.exam_score AS total_score,
    CASE
        WHEN r.ca_score + r.exam_score >= 80 THEN 'A'
        WHEN r.ca_score + r.exam_score >= 70 THEN 'B'
        WHEN r.ca_score + r.exam_score >= 60 THEN 'C'
        WHEN r.ca_score + r.exam_score >= 50 THEN 'D'
        WHEN r.ca_score + r.exam_score >= 40 THEN 'E'
        ELSE 'F'
    END AS grade
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN subject AS sub ON sub.subject_id = r.subject_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
ORDER BY c.class_name, s.last_name, s.first_name, sub.subject_name;

-- 3. Business question: What is each student's average and rank in their class?
-- Technique: AVG summarizes each student's subject totals; RANK() OVER
-- (PARTITION BY class) creates competition ranks, so ties share a position.
-- Requires MySQL 8.0+ or MariaDB 10.2+. Use the following fallback on older MySQL.
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

-- 3 (older-MySQL fallback). The correlated count gives competition ranking:
-- a student's position is one plus the number of classmates with a higher average.
SELECT
    averages.term_name,
    averages.class_name,
    averages.admission_number,
    averages.student_name,
    averages.average_score,
    1 + (
        SELECT COUNT(*)
        FROM (
            SELECT
                r2.class_id,
                r2.term_id,
                r2.student_id,
                AVG(r2.ca_score + r2.exam_score) AS average_score
            FROM result AS r2
            GROUP BY r2.class_id, r2.term_id, r2.student_id
        ) AS other_averages
        WHERE other_averages.class_id = averages.class_id
          AND other_averages.term_id = averages.term_id
          AND other_averages.average_score > averages.average_score
    ) AS class_position
FROM (
    SELECT
        r.class_id,
        r.term_id,
        c.class_name,
        t.term_name,
        s.admission_number,
        CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
        ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_score
    FROM result AS r
    JOIN student AS s ON s.student_id = r.student_id
    JOIN school_class AS c ON c.class_id = r.class_id
    JOIN term AS t ON t.term_id = r.term_id
    WHERE t.term_name = '2026/2027 First Term'
    GROUP BY
        r.class_id, r.term_id, c.class_name, t.term_name,
        s.student_id, s.admission_number,
        s.first_name, s.middle_name, s.last_name
) AS averages
ORDER BY averages.class_name, class_position, averages.admission_number;

-- 4. Business question: What are the average, highest, and lowest scores for
-- each subject in each class for the selected term?
-- Technique: GROUP BY forms one group per class and subject; AVG, MAX, and MIN
-- aggregate the individual student totals in that group.
SELECT
    c.class_name,
    sub.subject_code,
    sub.subject_name,
    ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_score,
    MAX(r.ca_score + r.exam_score) AS highest_score,
    MIN(r.ca_score + r.exam_score) AS lowest_score
FROM result AS r
JOIN school_class AS c ON c.class_id = r.class_id
JOIN subject AS sub ON sub.subject_id = r.subject_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
GROUP BY c.class_id, c.class_name, sub.subject_id, sub.subject_code, sub.subject_name
ORDER BY c.class_name, sub.subject_name;

-- 5. Business question: Which students scored below 40 in at least two subjects?
-- Technique: GROUP BY counts each student's failed subjects; HAVING filters
-- groups after aggregation (unlike WHERE, which filters individual rows).
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

-- 6. Business question: How many subjects and distinct classes does each
-- teacher teach, including teachers with no teaching assignments?
-- Technique: LEFT JOIN retains every teacher. COUNT(DISTINCT ...) avoids
-- counting the same class more than once when a teacher teaches several subjects.
SELECT
    t.teacher_id,
    t.staff_number,
    CONCAT_WS(' ', t.first_name, t.middle_name, t.last_name) AS teacher_name,
    COUNT(DISTINCT cs.subject_id) AS subject_count,
    COUNT(DISTINCT cs.class_id) AS class_count
FROM teacher AS t
LEFT JOIN class_subject AS cs ON cs.teacher_id = t.teacher_id
GROUP BY t.teacher_id, t.staff_number, t.first_name, t.middle_name, t.last_name
ORDER BY teacher_name;

-- 7. Business question: Which students have attended fewer than 80% of their
-- recorded school days?
-- Technique: A CTE aggregates attendance per student; the outer query filters
-- the calculated percentage. "Attended" counts both present and late. Students
-- with no attendance rows are included at 0%; the denominator is recorded days.
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

-- 8. Business question: Who is the top-scoring student in each class for the term?
-- Technique: The correlated subquery calculates each student's average and
-- compares it with the highest class average. Equality returns every co-leader.
SELECT
    c.class_name,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_score
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN term AS t ON t.term_id = r.term_id
WHERE t.term_name = '2026/2027 First Term'
GROUP BY
    r.class_id, r.term_id, s.student_id, s.admission_number,
    s.first_name, s.middle_name, s.last_name, c.class_name
HAVING AVG(r.ca_score + r.exam_score) = (
    SELECT MAX(student_average.average_score)
    FROM (
        SELECT
            r2.class_id,
            r2.term_id,
            r2.student_id,
            AVG(r2.ca_score + r2.exam_score) AS average_score
        FROM result AS r2
        GROUP BY r2.class_id, r2.term_id, r2.student_id
    ) AS student_average
    WHERE student_average.class_id = r.class_id
      AND student_average.term_id = r.term_id
)
ORDER BY c.class_name, s.admission_number;

-- VIEW 1: One row per student, subject, and term, including calculated total and grade.
-- Technique: CREATE OR REPLACE VIEW saves a reusable join and derived columns.
CREATE OR REPLACE VIEW v_student_results AS
SELECT
    r.student_id,
    s.admission_number,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    r.class_id,
    c.class_name,
    r.subject_id,
    sub.subject_code,
    sub.subject_name,
    r.term_id,
    t.term_name,
    r.ca_score,
    r.exam_score,
    r.ca_score + r.exam_score AS total_score,
    CASE
        WHEN r.ca_score + r.exam_score >= 80 THEN 'A'
        WHEN r.ca_score + r.exam_score >= 70 THEN 'B'
        WHEN r.ca_score + r.exam_score >= 60 THEN 'C'
        WHEN r.ca_score + r.exam_score >= 50 THEN 'D'
        WHEN r.ca_score + r.exam_score >= 40 THEN 'E'
        ELSE 'F'
    END AS grade
FROM result AS r
JOIN student AS s ON s.student_id = r.student_id
JOIN school_class AS c ON c.class_id = r.class_id
JOIN subject AS sub ON sub.subject_id = r.subject_id
JOIN term AS t ON t.term_id = r.term_id;

-- VIEW 2: One row per class and term, with enrollment, offerings, and result summaries.
-- Technique: A pre-aggregated result subquery avoids multiplying score rows when
-- class-level student and subject counts are added.
CREATE OR REPLACE VIEW v_class_summary AS
SELECT
    c.class_id,
    c.class_name,
    t.term_id,
    t.term_name,
    (
        SELECT COUNT(*)
        FROM student AS s
        WHERE s.class_id = c.class_id
    ) AS student_count,
    (
        SELECT COUNT(*)
        FROM class_subject AS cs
        WHERE cs.class_id = c.class_id
    ) AS subject_count,
    COALESCE(result_summary.result_count, 0) AS result_count,
    result_summary.average_score,
    result_summary.highest_score,
    result_summary.lowest_score
FROM school_class AS c
CROSS JOIN term AS t
LEFT JOIN (
    SELECT
        r.class_id,
        r.term_id,
        COUNT(*) AS result_count,
        ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_score,
        MAX(r.ca_score + r.exam_score) AS highest_score,
        MIN(r.ca_score + r.exam_score) AS lowest_score
    FROM result AS r
    GROUP BY r.class_id, r.term_id
) AS result_summary
    ON result_summary.class_id = c.class_id
   AND result_summary.term_id = t.term_id;
