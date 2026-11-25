-- Run once after schema.sql. These indexes target the term-based reports in queries.sql.

-- Queries 3 and 5 filter results by term and join them to enrollments by student and term.
-- The existing unique key starts with admission_no, subject_code, so it cannot efficiently
-- seek by term_id; the added columns also cover the score aggregation.
CREATE INDEX idx_results_term_student_subject_scores
    ON results (term_id, admission_no, subject_code, ca_score, exam_score);

-- Queries 3, 5, and 7 select enrollments for one term and group/join by class and student.
CREATE INDEX idx_enrollments_term_class_student
    ON student_enrollments (term_id, class_id, admission_no);

-- Query 7 already uses uq_attendance_student_day (admission_no, attendance_date)
-- for its student-and-date-range lookup, so an additional attendance index is unnecessary.
