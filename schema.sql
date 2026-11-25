-- MySQL 8.0.16+ or MariaDB 10.2.1+ is required for enforced CHECK constraints.
SET NAMES utf8mb4;

-- Drop dependent objects before their parent tables so this file can be rerun.
DROP TRIGGER IF EXISTS bi_results_validate_offering;
DROP TRIGGER IF EXISTS bu_results_validate_offering;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS student_guardians;
DROP TABLE IF EXISTS class_transfers;
DROP TABLE IF EXISTS student_enrollments;
DROP TABLE IF EXISTS class_subject_offerings;
DROP TABLE IF EXISTS school_classes;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS guardians;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS terms;
DROP TABLE IF EXISTS teachers;

CREATE TABLE teachers (
    staff_no VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(254) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL,
    PRIMARY KEY (staff_no),
    UNIQUE KEY uq_teachers_email (email)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE school_classes (
    class_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_name VARCHAR(20) NOT NULL,
    form_teacher_staff_no VARCHAR(20) NOT NULL,
    PRIMARY KEY (class_id),
    UNIQUE KEY uq_school_classes_name (class_name),
    -- Restrict deletion so a class cannot lose its required form teacher; cascade key corrections.
    CONSTRAINT fk_school_classes_form_teacher
        FOREIGN KEY (form_teacher_staff_no) REFERENCES teachers (staff_no)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subjects (
    subject_code VARCHAR(10) NOT NULL,
    subject_name VARCHAR(80) NOT NULL,
    PRIMARY KEY (subject_code),
    UNIQUE KEY uq_subjects_name (subject_name)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE terms (
    term_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    academic_year VARCHAR(9) NOT NULL,
    term_name ENUM('First Term', 'Second Term', 'Third Term') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (term_id),
    UNIQUE KEY uq_terms_year_name (academic_year, term_name),
    CONSTRAINT chk_terms_dates CHECK (start_date <= end_date)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE guardians (
    guardian_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    guardian_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (guardian_id)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE students (
    admission_no VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Female', 'Male', 'Other') NOT NULL,
    PRIMARY KEY (admission_no)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE student_guardians (
    admission_no VARCHAR(20) NOT NULL,
    guardian_id INT UNSIGNED NOT NULL,
    relationship_to_student ENUM('Mother', 'Father', 'Guardian', 'Other') NOT NULL,
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (admission_no, guardian_id),
    -- These are link rows, so remove them when either linked record is deleted; propagate key corrections.
    CONSTRAINT fk_student_guardians_student
        FOREIGN KEY (admission_no) REFERENCES students (admission_no)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_student_guardians_guardian
        FOREIGN KEY (guardian_id) REFERENCES guardians (guardian_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE student_enrollments (
    enrollment_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_no VARCHAR(20) NOT NULL,
    term_id SMALLINT UNSIGNED NOT NULL,
    class_id SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (enrollment_id),
    UNIQUE KEY uq_enrollment_student_term (admission_no, term_id),
    -- Keep enrollment history intact; cascade corrections to natural or referenced keys.
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (admission_no) REFERENCES students (admission_no)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_term
        FOREIGN KEY (term_id) REFERENCES terms (term_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_class
        FOREIGN KEY (class_id) REFERENCES school_classes (class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE class_transfers (
    transfer_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    enrollment_id BIGINT UNSIGNED NOT NULL,
    from_class_id SMALLINT UNSIGNED NOT NULL,
    to_class_id SMALLINT UNSIGNED NOT NULL,
    transferred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transfer_id),
    KEY idx_class_transfers_enrollment (enrollment_id),
    CONSTRAINT chk_class_transfer_changes_class CHECK (from_class_id <> to_class_id),
    -- Retain audit history by preventing enrollment deletion; propagate key corrections.
    CONSTRAINT fk_class_transfers_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES student_enrollments (enrollment_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- Keep both historical class references valid; class deletion is restricted, key updates cascade.
    CONSTRAINT fk_class_transfers_from_class
        FOREIGN KEY (from_class_id) REFERENCES school_classes (class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_class_transfers_to_class
        FOREIGN KEY (to_class_id) REFERENCES school_classes (class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE class_subject_offerings (
    offering_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_id SMALLINT UNSIGNED NOT NULL,
    subject_code VARCHAR(10) NOT NULL,
    term_id SMALLINT UNSIGNED NOT NULL,
    teacher_staff_no VARCHAR(20) NOT NULL,
    PRIMARY KEY (offering_id),
    UNIQUE KEY uq_offering_class_subject_term (class_id, subject_code, term_id),
    -- Restrict deletion to retain teaching history; cascade updates to referenced keys.
    CONSTRAINT fk_offerings_class
        FOREIGN KEY (class_id) REFERENCES school_classes (class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_offerings_subject
        FOREIGN KEY (subject_code) REFERENCES subjects (subject_code)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_offerings_term
        FOREIGN KEY (term_id) REFERENCES terms (term_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_offerings_teacher
        FOREIGN KEY (teacher_staff_no) REFERENCES teachers (staff_no)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE results (
    result_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_no VARCHAR(20) NOT NULL,
    term_id SMALLINT UNSIGNED NOT NULL,
    subject_code VARCHAR(10) NOT NULL,
    ca_score DECIMAL(5,2) NOT NULL,
    exam_score DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (result_id),
    UNIQUE KEY uq_result_student_subject_term (admission_no, subject_code, term_id),
    CONSTRAINT chk_results_ca_score CHECK (ca_score BETWEEN 0.00 AND 40.00),
    CONSTRAINT chk_results_exam_score CHECK (exam_score BETWEEN 0.00 AND 60.00),
    -- Results belong to an enrollment; deleting that enrollment removes its dependent scores.
    CONSTRAINT fk_results_enrollment
        FOREIGN KEY (admission_no, term_id)
        REFERENCES student_enrollments (admission_no, term_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- Keep subjects referenced by results; cascade a subject-code correction.
    CONSTRAINT fk_results_subject
        FOREIGN KEY (subject_code) REFERENCES subjects (subject_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attendance (
    attendance_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_no VARCHAR(20) NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late') NOT NULL,
    PRIMARY KEY (attendance_id),
    UNIQUE KEY uq_attendance_student_day (admission_no, attendance_date),
    -- Restrict student deletion to preserve attendance history; cascade admission-number corrections.
    CONSTRAINT fk_attendance_student
        FOREIGN KEY (admission_no) REFERENCES students (admission_no)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A result's student and term identify their class through enrollment. Ensure that class
-- actually has the subject offering in that term without duplicating class_id in results.
DELIMITER //
CREATE TRIGGER bi_results_validate_offering
BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM student_enrollments AS se
        INNER JOIN class_subject_offerings AS cso
            ON cso.class_id = se.class_id
           AND cso.term_id = se.term_id
        WHERE se.admission_no = NEW.admission_no
          AND se.term_id = NEW.term_id
          AND cso.subject_code = NEW.subject_code
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student class has no offering for this subject and term';
    END IF;
END//

CREATE TRIGGER bu_results_validate_offering
BEFORE UPDATE ON results
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM student_enrollments AS se
        INNER JOIN class_subject_offerings AS cso
            ON cso.class_id = se.class_id
           AND cso.term_id = se.term_id
        WHERE se.admission_no = NEW.admission_no
          AND se.term_id = NEW.term_id
          AND cso.subject_code = NEW.subject_code
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student class has no offering for this subject and term';
    END IF;
END//
DELIMITER ;
