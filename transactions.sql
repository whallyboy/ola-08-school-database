-- class_transfers is created by schema.sql.
-- Example 1: a basic transaction. Confirm the student, term, and target class first.
-- This sample block is commented so importing this file does not move a student.
/*
SET @transfer_admission_no = 'ADM-J1-001';
SET @transfer_term_id = (
    SELECT term_id
    FROM terms
    WHERE academic_year = '2026/2027'
      AND term_name = 'First Term'
);
SET @target_class_id = (
    SELECT class_id
    FROM school_classes
    WHERE class_name = 'JSS2 A'
);

START TRANSACTION;

-- Statement 1: record the old and new class before changing the enrollment.
INSERT INTO class_transfers (enrollment_id, from_class_id, to_class_id)
SELECT se.enrollment_id, se.class_id, @target_class_id
FROM student_enrollments AS se
WHERE se.admission_no = @transfer_admission_no
  AND se.term_id = @transfer_term_id
  AND @target_class_id IS NOT NULL
  AND se.class_id <> @target_class_id;

-- Statement 2: move the student's enrollment for this term.
UPDATE student_enrollments
SET class_id = @target_class_id
WHERE admission_no = @transfer_admission_no
  AND term_id = @transfer_term_id
  AND @target_class_id IS NOT NULL
  AND class_id <> @target_class_id;

COMMIT;
*/

-- Example 2: safer reusable version. Any missing target/enrollment or SQL error
-- raises an error; the exception handler rolls back both the audit and enrollment change.
DROP PROCEDURE IF EXISTS sp_move_student_class_safe;

DELIMITER //
CREATE PROCEDURE sp_move_student_class_safe(
    IN p_admission_no VARCHAR(20),
    IN p_term_id SMALLINT UNSIGNED,
    IN p_target_class_name VARCHAR(20)
)
BEGIN
    DECLARE v_target_class_id SMALLINT UNSIGNED DEFAULT NULL;
    DECLARE v_enrollment_id BIGINT UNSIGNED DEFAULT NULL;
    DECLARE v_from_class_id SMALLINT UNSIGNED DEFAULT NULL;
    DECLARE v_not_found BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT class_id
    INTO v_target_class_id
    FROM school_classes
    WHERE class_name = p_target_class_name;

    IF v_not_found OR v_target_class_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Target class does not exist; transfer rolled back';
    END IF;

    SET v_not_found = FALSE;
    SELECT enrollment_id, class_id
    INTO v_enrollment_id, v_from_class_id
    FROM student_enrollments
    WHERE admission_no = p_admission_no
      AND term_id = p_term_id
    FOR UPDATE;

    IF v_not_found OR v_enrollment_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student has no enrollment for this term; transfer rolled back';
    END IF;

    IF v_from_class_id = v_target_class_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student is already in the target class';
    END IF;

    INSERT INTO class_transfers (enrollment_id, from_class_id, to_class_id)
    VALUES (v_enrollment_id, v_from_class_id, v_target_class_id);

    UPDATE student_enrollments
    SET class_id = v_target_class_id
    WHERE enrollment_id = v_enrollment_id
      AND class_id = v_from_class_id;

    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enrollment was not updated; transfer rolled back';
    END IF;

    COMMIT;
END//
DELIMITER ;

-- Valid example (moves Amina to JSS2 A if you choose to run it):
-- CALL sp_move_student_class_safe('ADM-J1-001', 1, 'JSS2 A');
-- Missing-target example: raises an error and rolls back without changing data:
-- CALL sp_move_student_class_safe('ADM-J1-001', 1, 'NO SUCH CLASS');
