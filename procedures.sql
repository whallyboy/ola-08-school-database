-- Run after schema.sql. The procedure validates the enrollment/offering and score ranges.
DROP PROCEDURE IF EXISTS sp_record_result;

DELIMITER //
CREATE PROCEDURE sp_record_result(
    IN p_admission_no VARCHAR(20),
    IN p_subject_code VARCHAR(10),
    IN p_term_id SMALLINT UNSIGNED,
    IN p_ca_score DECIMAL(5,2),
    IN p_exam_score DECIMAL(5,2)
)
BEGIN
    IF p_admission_no IS NULL OR CHAR_LENGTH(TRIM(p_admission_no)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Admission number is required';
    END IF;

    IF p_subject_code IS NULL OR CHAR_LENGTH(TRIM(p_subject_code)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Subject code is required';
    END IF;

    IF p_term_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Term ID is required';
    END IF;

    IF p_ca_score IS NULL OR p_ca_score < 0 OR p_ca_score > 40 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CA score must be between 0 and 40';
    END IF;

    IF p_exam_score IS NULL OR p_exam_score < 0 OR p_exam_score > 60 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Exam score must be between 0 and 60';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM student_enrollments AS se
        INNER JOIN class_subject_offerings AS offering
            ON offering.class_id = se.class_id
           AND offering.term_id = se.term_id
        WHERE se.admission_no = p_admission_no
          AND se.term_id = p_term_id
          AND offering.subject_code = p_subject_code
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student is not enrolled in a class offering this subject for the term';
    END IF;

    INSERT INTO results (admission_no, term_id, subject_code, ca_score, exam_score)
    VALUES (p_admission_no, p_term_id, p_subject_code, p_ca_score, p_exam_score)
    ON DUPLICATE KEY UPDATE
        ca_score = VALUES(ca_score),
        exam_score = VALUES(exam_score);
END//
DELIMITER ;

-- Example call (edit values before running):
-- CALL sp_record_result('ADM-J1-001', 'ENG', 1, 32.00, 55.00);
