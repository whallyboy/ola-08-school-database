-- Query examples for the school database; apply schema.sql and seed.sql first.
-- Result queries use the sample term; change the academic-year and term-name filters as needed.

-- 1) Business question: Which students are in JSS1 A, and who is their form teacher?
-- Technique: JOINs connect the class to its form teacher and term enrollment to students.
SELECT
    c.class_name,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    s.admission_no,
    CONCAT_WS(' ', ft.first_name, ft.middle_name, ft.last_name) AS form_teacher_name
FROM school_classes AS c
INNER JOIN teachers AS ft
    ON ft.staff_no = c.form_teacher_staff_no
INNER JOIN student_enrollments AS se
    ON se.class_id = c.class_id
INNER JOIN students AS s
    ON s.admission_no = se.admission_no
INNER JOIN terms AS t
    ON t.term_id = se.term_id
WHERE c.class_name = 'JSS1 A'
  AND t.academic_year = '2026/2027'
  AND t.term_name = 'First Term'
ORDER BY s.last_name, s.first_name;

-- 2) Business question: What is each student's total and letter grade for every subject?
-- Technique: CASE maps the 0-100 total to grade bands (A >= 80, B >= 70, C >= 60,
-- D >= 50, E >= 40, otherwise F).
SELECT
    s.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    c.class_name,
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
FROM results AS r
INNER JOIN students AS s
    ON s.admission_no = r.admission_no
INNER JOIN subjects AS sub
    ON sub.subject_code = r.subject_code
INNER JOIN student_enrollments AS se
    ON se.admission_no = r.admission_no
   AND se.term_id = r.term_id
INNER JOIN school_classes AS c
    ON c.class_id = se.class_id
INNER JOIN terms AS t
    ON t.term_id = r.term_id
WHERE t.academic_year = '2026/2027'
  AND t.term_name = 'First Term'
ORDER BY c.class_name, s.last_name, s.first_name, sub.subject_name;

-- 3) Business question: What is each student's term average and rank within their class?
-- Technique: A CTE calculates per-student averages; RANK() OVER (PARTITION BY ...)
-- ranks students in each class and gives tied averages the same position.
WITH student_averages AS (
    SELECT
        se.admission_no,
        se.class_id,
        se.term_id,
        AVG(r.ca_score + r.exam_score) AS average_score
    FROM student_enrollments AS se
    INNER JOIN results AS r
        ON r.admission_no = se.admission_no
       AND r.term_id = se.term_id
    INNER JOIN terms AS t
        ON t.term_id = se.term_id
    WHERE t.academic_year = '2026/2027'
      AND t.term_name = 'First Term'
    GROUP BY se.admission_no, se.class_id, se.term_id
)
SELECT
    c.class_name,
    s.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    ROUND(sa.average_score, 2) AS average_score,
    RANK() OVER (
        PARTITION BY sa.class_id, sa.term_id
        ORDER BY sa.average_score DESC
    ) AS class_position
FROM student_averages AS sa
INNER JOIN students AS s
    ON s.admission_no = sa.admission_no
INNER JOIN school_classes AS c
    ON c.class_id = sa.class_id
ORDER BY c.class_name, class_position, s.last_name, s.first_name;

/*
Older MySQL 5.7 fallback for Query 3: run this instead of the CTE/window-function query.
The correlated count gives tied averages the same rank, like RANK().
SELECT
    c.class_name,
    s.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    ROUND(a.average_score, 2) AS average_score,
    1 + (
        SELECT COUNT(*)
        FROM (
            SELECT
                se2.admission_no,
                se2.class_id,
                se2.term_id,
                AVG(r2.ca_score + r2.exam_score) AS average_score
            FROM student_enrollments AS se2
            INNER JOIN results AS r2
                ON r2.admission_no = se2.admission_no
               AND r2.term_id = se2.term_id
            INNER JOIN terms AS t2
                ON t2.term_id = se2.term_id
            WHERE t2.academic_year = '2026/2027'
              AND t2.term_name = 'First Term'
            GROUP BY se2.admission_no, se2.class_id, se2.term_id
        ) AS other_averages
        WHERE other_averages.class_id = a.class_id
          AND other_averages.term_id = a.term_id
          AND other_averages.average_score > a.average_score
    ) AS class_position
FROM (
    SELECT
        se.admission_no,
        se.class_id,
        se.term_id,
        AVG(r.ca_score + r.exam_score) AS average_score
    FROM student_enrollments AS se
    INNER JOIN results AS r
        ON r.admission_no = se.admission_no
       AND r.term_id = se.term_id
    INNER JOIN terms AS t
        ON t.term_id = se.term_id
    WHERE t.academic_year = '2026/2027'
      AND t.term_name = 'First Term'
    GROUP BY se.admission_no, se.class_id, se.term_id
) AS a
INNER JOIN students AS s
    ON s.admission_no = a.admission_no
INNER JOIN school_classes AS c
    ON c.class_id = a.class_id
ORDER BY c.class_name, class_position, s.last_name, s.first_name;
*/

-- 4) Business question: What are the average, highest, and lowest total scores per subject and class?
-- Technique: GROUP BY forms class/subject groups; AVG, MAX, and MIN summarize their scores.
SELECT
    c.class_name,
    sub.subject_code,
    sub.subject_name,
    ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_total,
    MAX(r.ca_score + r.exam_score) AS highest_total,
    MIN(r.ca_score + r.exam_score) AS lowest_total,
    COUNT(*) AS students_with_results
FROM results AS r
INNER JOIN student_enrollments AS se
    ON se.admission_no = r.admission_no
   AND se.term_id = r.term_id
INNER JOIN school_classes AS c
    ON c.class_id = se.class_id
INNER JOIN subjects AS sub
    ON sub.subject_code = r.subject_code
INNER JOIN terms AS t
    ON t.term_id = r.term_id
WHERE t.academic_year = '2026/2027'
  AND t.term_name = 'First Term'
GROUP BY c.class_id, c.class_name, sub.subject_code, sub.subject_name
ORDER BY c.class_name, sub.subject_name;

-- 5) Business question: Which students scored below 40 in at least two subjects?
-- Technique: GROUP BY gathers a student's term results; HAVING filters the groups by failed-subject count.
SELECT
    s.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    c.class_name,
    SUM(CASE WHEN r.ca_score + r.exam_score < 40 THEN 1 ELSE 0 END) AS failed_subjects
FROM results AS r
INNER JOIN students AS s
    ON s.admission_no = r.admission_no
INNER JOIN student_enrollments AS se
    ON se.admission_no = r.admission_no
   AND se.term_id = r.term_id
INNER JOIN school_classes AS c
    ON c.class_id = se.class_id
INNER JOIN terms AS t
    ON t.term_id = r.term_id
WHERE t.academic_year = '2026/2027'
  AND t.term_name = 'First Term'
GROUP BY s.admission_no, s.first_name, s.middle_name, s.last_name, c.class_id, c.class_name
HAVING SUM(CASE WHEN r.ca_score + r.exam_score < 40 THEN 1 ELSE 0 END) >= 2
ORDER BY c.class_name, student_name;

-- 6) Business question: How many subjects and classes does each teacher teach this term?
-- Technique: LEFT JOIN keeps teachers with no matching offering; term criteria stay in ON.
SELECT
    teacher.staff_no,
    CONCAT_WS(' ', teacher.first_name, teacher.middle_name, teacher.last_name) AS teacher_name,
    COUNT(DISTINCT offering.subject_code) AS subjects_taught,
    COUNT(DISTINCT offering.class_id) AS classes_taught
FROM teachers AS teacher
LEFT JOIN class_subject_offerings AS offering
    ON offering.teacher_staff_no = teacher.staff_no
   AND offering.term_id = (
        SELECT term_id
        FROM terms
        WHERE academic_year = '2026/2027'
          AND term_name = 'First Term'
   )
GROUP BY teacher.staff_no, teacher.first_name, teacher.middle_name, teacher.last_name
ORDER BY teacher.last_name, teacher.first_name;

-- 7) Business question: Which students have attendance below 80% for the term?
-- Technique: A derived table aggregates attendance first; Present and Late count as attended,
-- and the percentage denominator is the student's recorded attendance days in the term.
SELECT
    s.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    c.class_name,
    attendance_summary.recorded_days,
    attendance_summary.attended_days,
    ROUND(100.0 * attendance_summary.attended_days
        / NULLIF(attendance_summary.recorded_days, 0), 2) AS attendance_percentage
FROM (
    SELECT
        se.admission_no,
        se.class_id,
        se.term_id,
        COUNT(a.attendance_id) AS recorded_days,
        SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) AS attended_days
    FROM student_enrollments AS se
    INNER JOIN terms AS t
        ON t.term_id = se.term_id
    LEFT JOIN attendance AS a
        ON a.admission_no = se.admission_no
       AND a.attendance_date BETWEEN t.start_date AND t.end_date
    WHERE t.academic_year = '2026/2027'
      AND t.term_name = 'First Term'
    GROUP BY se.admission_no, se.class_id, se.term_id
) AS attendance_summary
INNER JOIN students AS s
    ON s.admission_no = attendance_summary.admission_no
INNER JOIN school_classes AS c
    ON c.class_id = attendance_summary.class_id
WHERE attendance_summary.recorded_days > 0
  AND 100.0 * attendance_summary.attended_days
      / NULLIF(attendance_summary.recorded_days, 0) < 80
ORDER BY attendance_percentage, c.class_name, s.last_name, s.first_name;

-- 8) Business question: Who is the top student in each class for the term?
-- Technique: A correlated NOT EXISTS removes any student with a higher class average;
-- ties are retained. The form works on older MySQL versions without window functions.
SELECT
    c.class_name,
    s.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    ROUND(student_average.average_score, 2) AS average_score
FROM (
    SELECT
        se.admission_no,
        se.class_id,
        se.term_id,
        AVG(r.ca_score + r.exam_score) AS average_score
    FROM student_enrollments AS se
    INNER JOIN results AS r
        ON r.admission_no = se.admission_no
       AND r.term_id = se.term_id
    INNER JOIN terms AS t
        ON t.term_id = se.term_id
    WHERE t.academic_year = '2026/2027'
      AND t.term_name = 'First Term'
    GROUP BY se.admission_no, se.class_id, se.term_id
) AS student_average
INNER JOIN students AS s
    ON s.admission_no = student_average.admission_no
INNER JOIN school_classes AS c
    ON c.class_id = student_average.class_id
WHERE NOT EXISTS (
    SELECT 1
    FROM student_enrollments AS other_enrollment
    INNER JOIN results AS other_result
        ON other_result.admission_no = other_enrollment.admission_no
       AND other_result.term_id = other_enrollment.term_id
    WHERE other_enrollment.class_id = student_average.class_id
      AND other_enrollment.term_id = student_average.term_id
    GROUP BY other_enrollment.admission_no
    HAVING AVG(other_result.ca_score + other_result.exam_score) > student_average.average_score
)
ORDER BY c.class_name, student_average.average_score DESC, s.last_name, s.first_name;

-- View: one row per student, subject, and term with class, teacher, scores, total, and grade.
CREATE OR REPLACE VIEW v_student_results AS
SELECT
    r.admission_no,
    CONCAT_WS(' ', s.first_name, s.middle_name, s.last_name) AS student_name,
    c.class_name,
    t.academic_year,
    t.term_name,
    sub.subject_code,
    sub.subject_name,
    teacher.staff_no AS teacher_staff_no,
    CONCAT_WS(' ', teacher.first_name, teacher.middle_name, teacher.last_name) AS teacher_name,
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
FROM results AS r
INNER JOIN students AS s
    ON s.admission_no = r.admission_no
INNER JOIN student_enrollments AS se
    ON se.admission_no = r.admission_no
   AND se.term_id = r.term_id
INNER JOIN school_classes AS c
    ON c.class_id = se.class_id
INNER JOIN terms AS t
    ON t.term_id = r.term_id
INNER JOIN subjects AS sub
    ON sub.subject_code = r.subject_code
INNER JOIN class_subject_offerings AS offering
    ON offering.class_id = se.class_id
   AND offering.subject_code = r.subject_code
   AND offering.term_id = r.term_id
INNER JOIN teachers AS teacher
    ON teacher.staff_no = offering.teacher_staff_no;

-- View: one row per class and enrolled term with form teacher, headcounts, and class score average.
CREATE OR REPLACE VIEW v_class_summary AS
SELECT
    c.class_id,
    c.class_name,
    se.term_id,
    t.academic_year,
    t.term_name,
    ft.staff_no AS form_teacher_staff_no,
    CONCAT_WS(' ', ft.first_name, ft.middle_name, ft.last_name) AS form_teacher_name,
    COUNT(DISTINCT se.admission_no) AS student_count,
    COUNT(DISTINCT offering.subject_code) AS subject_count,
    ROUND(AVG(r.ca_score + r.exam_score), 2) AS average_total_score
FROM school_classes AS c
INNER JOIN teachers AS ft
    ON ft.staff_no = c.form_teacher_staff_no
LEFT JOIN student_enrollments AS se
    ON se.class_id = c.class_id
LEFT JOIN terms AS t
    ON t.term_id = se.term_id
LEFT JOIN class_subject_offerings AS offering
    ON offering.class_id = c.class_id
   AND offering.term_id = se.term_id
LEFT JOIN results AS r
    ON r.admission_no = se.admission_no
   AND r.term_id = se.term_id
   AND r.subject_code = offering.subject_code
GROUP BY
    c.class_id,
    c.class_name,
    se.term_id,
    t.academic_year,
    t.term_name,
    ft.staff_no,
    ft.first_name,
    ft.middle_name,
    ft.last_name;
